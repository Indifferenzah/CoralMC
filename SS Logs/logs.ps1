# Richiede privilegi amministratore
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $cmd = "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force; irm 'https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/SS%20Logs/logs.ps1' | iex"
    Start-Process PowerShell -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-NoExit", "-Command", $cmd -Verb RunAs
    exit
}

# ── LOGO ──────────────────────────────────────────────────────────────────────
Clear-Host
Write-Host ""
$logo = @(
    "          ____    ___    ____       _      _       __  __    ____         ",
    "         / ___|  / _ \  |  _ \     / \    | |     |  \/  |  / ___|",
    "        | |     | | | | | |_| |   / _ \   | |     | |\/| | | |    ",
    "        | |___  | |_| | |  _ <   / ___ \  | |___  | |  | | | |___ ",
    "         \____|  \___/  |_| \_\ /_/   \_\ |_____| |_|  |_|  \____|"
)
foreach ($line in $logo) {
    Write-Host -NoNewline -ForegroundColor Cyan $line.Substring(0, [Math]::Min(49, $line.Length))
    if ($line.Length -gt 49) {
        Write-Host -ForegroundColor White $line.Substring(49)
    } else {
        Write-Host ""
    }
}
Write-Host ""
Write-Host "                              SS TOOL - CoralMC" -ForegroundColor Cyan
Write-Host "                              by Indifferenzah" -ForegroundColor Cyan
Write-Host ""

# ── Controllo registrazioni ───────────────────────────────────────────────────
do {
    $rec = Read-Host "                 Hai controllato le rec? [S/N]"
    if ($rec.ToUpper() -ne "S") {
        Write-Host "[-] Controlla le registrazioni prima di procedere!" -ForegroundColor Red
    }
} while ($rec.ToUpper() -ne "S")

# ── 1. File nascosti + Cestino ────────────────────────────────────────────────
$confirmCestino = Read-Host "                 Aprire il Cestino e mostrare file nascosti? [S/N]"
if ($confirmCestino.ToUpper() -eq "S") {
    Write-Host "[*] Abilitazione file nascosti e file di sistema..." -ForegroundColor Yellow
    $explorerKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $explorerKey -Name Hidden -Value 1
    Set-ItemProperty -Path $explorerKey -Name ShowSuperHidden -Value 1

    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1000
    Start-Process explorer.exe

    Write-Host "[+] File nascosti e file di sistema visibili." -ForegroundColor Green
    Start-Sleep -Milliseconds 1500

    Write-Host "[*] Apertura Cestino..." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList "C:\`$Recycle.Bin"
    Write-Host "[+] Cestino aperto." -ForegroundColor Green
} else {
    Write-Host "[*] Cestino saltato." -ForegroundColor DarkGray
}

Start-Sleep -Milliseconds 500

# ── 2. Journal ────────────────────────────────────────────────────────────────
Write-Host "[*] Ricerca file eliminati in corso..." -ForegroundColor Yellow
$logsPath = "C:\logs.txt"
cmd /c "fsutil usn readjournal c: csv | findstr /i /C:`"0x80000200`" /C:`"0x00001000`" /C:`"0x00002000`" | findstr /i /C:`".log`" | findstr /i /C:`".json`" /C:`".gz`" /C:`".txt`" | findstr /i /v /C:`".lnk`" > $logsPath"
if ((Test-Path $logsPath) -and (Get-Item $logsPath).Length -gt 0) {
    Start-Process notepad.exe -ArgumentList $logsPath
    Write-Host "[+] logs.txt aperto." -ForegroundColor Green
} else {
    Write-Host "[-] Journal Vuoto." -ForegroundColor Red
    Start-Process eventvwr.exe
}

Start-Sleep -Milliseconds 500

# ── 3. Apri cartelle Minecraft ─────────────────────────────────────────────────
Write-Host ""
$confirm = Read-Host "                 Aprire le cartelle Minecraft? [S/N]"
if ($confirm.ToUpper() -eq "S") {
    Write-Host "[*] Apertura cartelle Minecraft..." -ForegroundColor Yellow
    $paths = @(
        "$env:APPDATA\.minecraft\versions",
        "$env:APPDATA\.minecraft\logs",
        "$env:APPDATA\.minecraft\logs\blclient\minecraft",
        "$env:USERPROFILE\.lunarclient\offline\multiver\logs",
        "$env:USERPROFILE\.lunarclient\profiles\lunar",
        "$env:USERPROFILE\.lunarclient\profiles\badlion",
        "$env:USERPROFILE\.lunarclient\profiles\vanilla",
        "$env:APPDATA\.Salwyrr\logs",
        "$env:APPDATA\.tlauncher\legacy\Minecraft\game\logs"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Start-Process explorer.exe -ArgumentList $path
            Write-Host "[+] Aperto: $path" -ForegroundColor Green
        } else {
            Write-Host "[-] Non trovato: $path" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "[*] Cartelle saltate." -ForegroundColor DarkGray
}

Start-Sleep -Milliseconds 500

# ── 4. Installazione tools ─────────────────────────────────────────────────────
do {
    Write-Host ""
    Write-Host "                 Vuoi installare qualcosa?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                 [1] Solo WinRAR"
    Write-Host "                 [2] Solo PreviousFilesRecovery"
    Write-Host "                 [3] SystemInfo"
    Write-Host "                 [9] Entrambi"
    Write-Host "                 [0] Esci"
    Write-Host ""
    $choice = Read-Host "                 >>>"

    switch ($choice.ToUpper()) {
        "1" {
            Write-Host "[*] Installazione WinRAR..." -ForegroundColor Yellow
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
            Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/winrar.ps1" | Invoke-Expression
        }
        "2" {
            Write-Host "[*] Installazione PreviousFilesRecovery..." -ForegroundColor Yellow
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
            Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/pfile.ps1" | Invoke-Expression
        }
        "3" {
            Start-Process cmd.exe -ArgumentList "/k systeminfo" -Verb RunAs
        }
        "9" {
            Write-Host "[*] Installazione WinRAR..." -ForegroundColor Yellow
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
            Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/winrar.ps1" | Invoke-Expression
            Write-Host "[*] Installazione PreviousFilesRecovery..." -ForegroundColor Yellow
            Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/pfile.ps1" | Invoke-Expression
        }
        "0" {}
        default {
            Write-Host "[-] Scelta non valida." -ForegroundColor Red
        }
    }
} while ($choice -ne "0")
