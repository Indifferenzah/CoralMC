$url = "https://www.nirsoft.net/utils/previousfilesrecovery-x64.zip"
$zipPath = "$env:TEMP\previousfilesrecovery.zip"
$extractPath = "$env:TEMP\PreviousFilesRecovery"

Write-Host "Scaricando PreviousFilesRecovery..."
Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

Write-Host "Estraendo..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

Write-Host "Avvio..."
Start-Process -FilePath "$extractPath\PreviousFilesRecovery.exe"

Remove-Item -Path $zipPath -Force