%COMSPEC% /C reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths /v "\\*\SYSVOL" /d "RequireMutualAuthentication=0" /t REG_SZ

%COMSPEC% /C reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths /v "\\*\NETLOGON" /d "RequireMutualAuthentication=0" /t REG_SZ