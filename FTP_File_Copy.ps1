Param(
	$APXDBFolder = "\\sacbak05\SQLBackup\vSacAxDb8-1";
    $RCDBFolder = "\\sacbak05\SQLBackup\vSacMhRc8-2"
	
)
cls
$TargetFolderAPXDBFolder =  "\\VSACAXAPP8-1\SQLBackups"
if (!(test-path $TargetFolderAPXDBFolder))
{
    New-Item -ItemType directory -Path $TargetFolderAPXDBFolder
}


$ScriptDir = split-path -parent $MyInvocation.MyCommand.Path
set-location "c:\" -PassThru | Out-Null
set-location $ScriptDir -PassThru | Out-Null
set-alias sz "$ScriptDir\7z.exe"  

$localServer = $env:computername + "@advent.com"
$subject = "MH17 DB Backup Files Copy Completed" 
#$recipients = "hyu@advent.com","ayu@advent.com"
$recipients = "hyu@advent.com"


$BakFiles=Get-ChildItem -Path  $APXDBFolder -Filter *.bak | sort -prop LastWriteTime -Descending  | Select-Object -first 1 
$DBBackupFileDate=$BakFiles.LastWriteTime
write-host "Date before Adjustment: ($DBBackupFileDate)"
$DBBackupFileDate = $DBBackupFileDate.AddDays(-6)
write-host "Date After Adjustment: ($DBBackupFileDate)"


	#$BakFiles=Get-ChildItem -Path  $APXDBFolder\* -include "APXController_Backup_*.bak","MDM*.bak","APXFirm_Backup_*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} #| Select-Object -first 2 
    $BakFiles=Get-ChildItem -Path  $APXDBFolder\* -include "*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} #| Select-Object -first 2 
    $body = $BakFiles.name | out-string
	foreach ($backupFile in $BakFiles)
	{
	 	$backupFile.FullName
		Copy-Item $backupFile.FullName $TargetFolderAPXDBFolder
	}
	

 send-mailmessage -to $recipients -from $localServer -SmtpServer "sacmail" -subject $subject -body $body