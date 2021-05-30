# This will ask for a domain and it will show what IP address each
# DNS server provides.
# Example:
#   1.1.1.1 - 93.184.216.34
#   1.0.0.1 - 93.184.216.34
#
# In this instance the traced domain is 'example.com' and it will
# show the domains IP. Used for diagnosis.

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
