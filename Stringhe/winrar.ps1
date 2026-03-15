$url = "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-720.exe"
$outputPath = "$env:TEMP\winrar-installer.exe"
$logFile = "$env:TEMP\winrar-install.log"
$winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"

function Log-Message {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$type] $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

try {
    Log-Message "Starting download of WinRAR from $url"
    Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
    Log-Message "Download complete."
} catch {
    Log-Message "Failed to download WinRAR installer: $_" "ERROR"
    exit 1
}

if (-Not (Test-Path -Path $outputPath) -Or (Get-Item $outputPath).Length -eq 0) {
    Log-Message "Downloaded WinRAR installer is missing or empty." "ERROR"
    exit 1
}

try {
    Log-Message "Starting silent installation of WinRAR."
    Start-Process -FilePath $outputPath -ArgumentList "/S" -NoNewWindow -Wait
    Log-Message "WinRAR installation complete."
} catch {
    Log-Message "Failed to install WinRAR: $_" "ERROR"
    exit 1
}

try {
    Log-Message "Registering file associations in registry (HKLM)..."

    $extensions = @(".rar", ".zip", ".7z", ".tar", ".gz", ".iso")
    $classNames = @{
        ".rar" = "WinRAR.RAR"
        ".zip" = "WinRAR.ZIP"
        ".7z"  = "WinRAR.7Z"
        ".tar" = "WinRAR.TAR"
        ".gz"  = "WinRAR.GZ"
        ".iso" = "WinRAR.ISO"
    }

    foreach ($ext in $extensions) {
        $className = $classNames[$ext]

        New-Item -Path "HKLM:\Software\Classes\$ext" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\Software\Classes\$ext" -Name "(Default)" -Value $className

        New-Item -Path "HKLM:\Software\Classes\$className" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\Software\Classes\$className" -Name "(Default)" -Value "WinRAR Archive"

        New-Item -Path "HKLM:\Software\Classes\$className\shell\open\command" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\Software\Classes\$className\shell\open\command" -Name "(Default)" -Value "`"$winrarPath`" `"%1`""

        New-Item -Path "HKLM:\Software\Classes\$className\DefaultIcon" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\Software\Classes\$className\DefaultIcon" -Name "(Default)" -Value "`"$winrarPath`",0"
    }

    $code = @"
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, int uFlags, IntPtr dwItem1, IntPtr dwItem2);
"@
    $shell = Add-Type -MemberDefinition $code -Name "Shell32" -Namespace "Win32" -PassThru
    $shell::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)

    Log-Message "File associations registered successfully."
} catch {
    Log-Message "Failed to register file associations: $_" "WARNING"
}

try {
    Remove-Item -Path $outputPath -Force
    Log-Message "Cleaned up the downloaded installer."
} catch {
    Log-Message "Failed to remove the downloaded installer: $_" "WARNING"
}

Read-Host -Prompt "Press Enter to close"