$compname=Read-Host "Computer Name:"
$PC = Get-WmiObject -Class Win32_ComputerSystem
$PC.Rename($compname)
