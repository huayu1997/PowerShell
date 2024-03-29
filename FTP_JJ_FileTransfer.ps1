
cls

$APXDBFolder = "\\vsacbak06\SQLBackups\vSacAxDb8-1"
#$RCDBFolder = "\\vsacbak06\SQLBackups\vSacMHRc8-2"
$TargetFolderAPXDBFolder =  "\\VSACBAK06\Fiera_APX_DB_Escrow\APX_Monthly"

if (!(test-path $TargetFolderAPXDBFolder))
{
    New-Item -ItemType directory -Path $TargetFolderAPXDBFolder
}

if (!(test-path $TargetFolderAPXDBFolder -PathType Leaf))
{
    Remove-item $TargetFolderAPXDBFolder\* -force 
}

$localServer = $env:computername + "@advent.com"
$subject = "AMH18 DB Backup Files Copy Completed" 
#$recipients = "hyu@advent.com","ayu@advent.com"
$recipients = "hyu@advent.com"


$BakFiles=Get-ChildItem -Path  $APXDBFolder -Filter APXFirm*.bak | sort -prop LastWriteTime -Descending  | Select-Object -first 1
$DBBackupFileDate=$BakFiles.LastWriteTime
write-host "DB Backup Date:($DBBackupFileDate)"
$DBBackupFileDate = $DBBackupFileDate.AddDays(-3)
write-host "Date After Adjustment: ($DBBackupFileDate)"


	$BakFiles_APX=Get-ChildItem -Path  $APXDBFolder\* -include "APX*.bak","MDM*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} 
    
	foreach ($backupFile in $BakFiles_APX)
	{
	 	$backupFile.FullName
		Copy-Item $backupFile.FullName $TargetFolderAPXDBFolder
	}
	
  #  $BakFiles_RC=Get-ChildItem -Path  $RCDBFolder\* -include "RC*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} 
   
#	foreach ($backupFile in $BakFiles_RC)
#	{
#	 	$backupFile.FullName
#		Copy-Item $backupFile.FullName $TargetFolderAPXDBFolder
#	}
	

 send-mailmessage -to $recipients -from $localServer -SmtpServer "sacmail" -subject $subject 