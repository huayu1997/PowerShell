param( [string] $username, [string] $ComputerName, [string] $Creds)
$localProfilePath = "C:\\Users\\$username"
$WMIQuery = "SELECT * FROM Win32_UserProfile WHERE localpath = '$localProfilePath'"
$profile = Get-WmiObject -Query $WMIQuery -ComputerName $ComputerName -Credential $Creds
#Remove-WmiObject -InputObject $profile  
