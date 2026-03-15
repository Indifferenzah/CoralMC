# Richiede privilegi amministratore
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
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

# ── 1. Journal ─ ────────────────────────────────────────────────────
Write-Host "[*] Ricerca file eliminati in corso..." -ForegroundColor Yellow
$logsPath = "C:\logs.txt"
cmd /c "fsutil usn readjournal c: csv | findstr /i /C:`"0x80000200`" /C:`"0x00001000`" /C:`"0x00002000`" | findstr /i /C:`".log`" | findstr /i /C:`".json`" /C:`".gz`" /C:`".txt`" | findstr /i /v /C:`".lnk`" > $logsPath"
if (Test-Path $logsPath) {
    Start-Process notepad.exe -ArgumentList $logsPath
    Write-Host "[+] logs.txt aperto." -ForegroundColor Green
} else {
    Write-Host "[-] logs.txt non trovato o vuoto." -ForegroundColor Red
}

Start-Sleep -Milliseconds 500

# ── 2. Apri cartelle Minecraft ─────────────────────────────────────────────────
Write-Host "[*] Apertura cartelle Minecraft..." -ForegroundColor Yellow

$paths = @(
    "$env:APPDATA\.minecraft",
    "$env:USERPROFILE\.lunarclient",
    "$env:APPDATA\.Salwyrr"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Start-Process explorer.exe -ArgumentList $path
        Write-Host "[+] Aperto: $path" -ForegroundColor Green
    } else {
        Write-Host "[-] Non trovato: $path" -ForegroundColor DarkGray
    }
}

Start-Sleep -Milliseconds 500

# ── 3. Installazione tools ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "                 Vuoi installare qualcosa?" -ForegroundColor Cyan
Write-Host ""
Write-Host "                 [1] Solo WinRAR"
Write-Host "                 [2] Solo PreviousFilesRecovery"
Write-Host "                 [9] Entrambi"
Write-Host "                 [0] Niente"
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
    "9" {
        Write-Host "[*] Installazione WinRAR..." -ForegroundColor Yellow
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/winrar.ps1" | Invoke-Expression
        Write-Host "[*] Installazione PreviousFilesRecovery..." -ForegroundColor Yellow
        Invoke-RestMethod "https://raw.githubusercontent.com/Indifferenzah/CoralMC/refs/heads/main/Stringhe/pfile.ps1" | Invoke-Expression
    }
    "0" {
        Write-Host "[*] Nessuna installazione." -ForegroundColor DarkGray
    }
    default {
        Write-Host "[-] Scelta non valida." -ForegroundColor Red
    }
}

Write-Host ""
Read-Host "Premi Invio per chiudere"