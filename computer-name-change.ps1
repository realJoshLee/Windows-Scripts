# Will ask for the new computer name and then you will enter it.
# This is useful for mass domain deployments

$compname=Read-Host "Computer Name:"
$PC = Get-WmiObject -Class Win32_ComputerSystem
$PC.Rename($compname)
