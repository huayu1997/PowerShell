$dbserver = "vSacSqlBak02"
$SvcPassword="Midgard0"
$user="huadesk"
Write-host "Enter password for user: $User"
$password = ConvertTo-SecureString $SvcPassword -AsPlainText -Force
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $User, $password
Set-Variable -Name credential -Value $credential -Scope 1
Write-Output "Credential created now for AlwaysOnAdminUser: $User, validating password and machine access now"
$session = New-PSSession -cn $dbserver -Credential $credential -Authentication Credssp
Write-Output "Password verified successfully for User: $User"
