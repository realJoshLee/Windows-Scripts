# Update the $domain variable to your local domain controller address
# Update the $password variable to the account password
# Update the username text in the $username variable with the username used to enroll computers in a domain
#   This account should have admin access

$domain = "domain.local"
$password = "password" | ConvertTo-SecureString -asPlainText -Force
$username = "$domain\username" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $credential -OUPath "OU=Staff Computers,DC=domain,DC=local"
