#Add PowerCli Commandlets to Powershell
Add-PSSnapin VMware.VimAutomation.Core

#Connect to Lab Virtual Center
--Connect-VIServer -Server vSaclabVc01.prod.dx -Port 443 -User hyu@prod.dx -Password Midgard5!
--Disconnect-VIServer -Server vSacLabVc01.prod.dx 

--Connect-VIServer -Server vSacVc03.prod.dx -Port 443 -User hyu@prod.dx -Password Midgard5!
Disconnect-VIServer -Server vSacVc03.prod.dx 

--Connect-VIServer -Server vSacVc01.prod.dx -Port 443 -User hyu@prod.dx -Password Midgard5!
--Disconnect-VIServer -Server vSacVc01.prod.dx 

get-vm | where {$_.PowerState -eq 'Poweredon' } | get-snapshot 

$vms = get-vm
$vms.networkadapters
$networkadapters = get-vm | where {$_.PowerState -eq 'Poweredon' } |get-networkadapter

$networkadapters | gm

$networkadapters.networkname

$vms |gm
$top5VM = $vms | select -first 5
$OnD_VM = $vms | where {($_.Folder -match  'OnD') -and ($_.Name -match 'axdb') -and ($_.Folder -notmatch  'qa') -and ($_.PowerState -eq 'Poweredon') } 

$OnD_VM |  select Name, @{N="CPUs"; E={$_.NumCPU}}, MemoryGB | Export-Csv C:\Users\hyu\Documents\PowerShell\OnD_VMStats_Db.csv -noclobber -encoding ASCII

$top5VM.folder
$top5VM.vmresourceconfiguration
$OnD_VM.vmresourceconfiguration
$resources = $vms.vmresourceconfiguration
$vms.getconnectionparameters
$vms.VMhost | GM
$vms.VMhost.networkinfo

$vms.guest.ipaddress[0]

$vms.extensiondata

get-vm | select name, Powerstate, @{N="IPAddress"; E={$_.Guest.IPAddress[0]}}, @{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}}

$interim_VMs = $vms | where {$_.PowerState -eq 'Poweredon' } | select name, folder, @{N="IPAddress"; E={$_.Guest.IPAddress[0]}}, @{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}}

$interim_VMs | where {$_.Folder -like  'OnD08' } | gm

$resources | where {$_.vm -like  'OnD08' }

$resources | gm

$interim_VMs | where {($_.Folder -match  'OnD') -and ($_.Name -match 'db')}
