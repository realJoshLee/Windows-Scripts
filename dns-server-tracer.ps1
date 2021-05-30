# Allows PS scripts to be ran
set-executionpolicy remotesigned

$domainName = Read-Host -Prompt 'Enter a website'
#$domainName = "bendu.company.local"
$dnsServers = @()

Get-NetAdapter | ForEach-Object {
    $adapterInfo = $_
    if ($adapterInfo.Status -eq "up")
    {
        Get-DnsClientServerAddress -InterfaceAlias $adapterInfo.Name | ForEach-Object {
            if ($_.ServerAddresses.Length -ne 0) {
                $dnsClientInfo = $_
                Write-Host ""
                Write-Host "$domainName"
                Write-Host "Adapter: $($adapterInfo.Name)"

                foreach($addressInfo in $dnsClientInfo.ServerAddresses) {
                    $result = Resolve-DnsName -Name $domainName -Server $addressInfo -Type A -ErrorAction Ignore
                    if ($result)
                    {
                        Write-Output "DNS $($addressInfo): $($result.IPAddress)"
                    }
                    else
                    {
                        Write-Host "DNS $($addressInfo): Count not find $($domainName)"
                    }                    
                }
                Write-Host ""
            }
        }

    }
}
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
