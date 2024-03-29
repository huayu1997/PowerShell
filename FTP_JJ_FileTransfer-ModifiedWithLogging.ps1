Param(
    $APXDBFolder = "\\vsacbak06.online.advent\SQLBackups\vSacAxDb8-1",
    $RCDBFolder = "\\sacbak05\SQLBackup\vSacMHRc8-2",
    $TargetFolderAPXDBFolder =  "\\VSACAXAPP8-1\SQLBackups",
    $CancelThreshold = 70,
    $EmailSubject = "AMH8 DB Backup Files Copy Completed", 
    $EmailRecipients = @("crosenbe@sscinc.com", "hyu@advent.com","jdillon@sscinc.com"),
    $LogFilePath="C:\Temp\FTP_JJ_FileTransfer-ModifiedWithLogging.log",
    [switch]$NoClean
)
$subject = $emailSubject
$recipients = $EmailRecipients
$localServer = $env:computername + "@advent.com"


function Append-Log {
    [cmdletbinding()]
    Param(
        [parameter(valuefrompipeline=$true)]
        [string]$message,
        [string]$VariableName="results",
        [string]$FilePath=$LogFilePath
    )
    process {
        write-output $message | out-file -Append -FilePath $FilePath
        $varLogger = get-variable $variablename 
        $varlogger.value = $varlogger.value + $message
    }
}

function SpaceExists {
    Param(
        $share,
        $File,
        $ThresholdUsed=$CancelThreshold
    )
    (($share.freespace - $File.length ) / $share.size * 100) -ge $ThresholdUsed
}

$results = @()

Append-Log -message @"
================================================================================================================================================
StartTime: $(get-date)
APXDBFolde: $APXDBFolder
RCDBFolder: $RCDBFolder
TargetFolderAPXDBFolder: $TargetFolderAPXDBFolder

"@ 

$share = get-wmiobject -class win32_logicaldisk | where {$_.VolumeName -like "*backup*"}
$GBFree = "{0:N2} GB" -f ($share.freespace /1GB )
$GBTotal="{0:N2} GB" -f ($share.size /1GB )
$percentUsed = "{0:N2} %" -f (($share.size - $share.freespace )/ $share.Size * 100)

Append-Log -message @"

DiskSpace Check Prior to execution:
    SQLBackups Share: $($share.Caption)\SqlBackups
    TotalSize: $GBTotal
    Freespace: $GBFree
    PercentUsed: $percentUsed

"@ 
if (!(test-path $TargetFolderAPXDBFolder)){
    Append-Log -message "$TargetFolderAPXDBFolder does not exist, creating folder`n"
    New-Item -ItemType directory -Path $TargetFolderAPXDBFolder
} else {
    Append-Log -message "$TargetFolderAPXDBFolder already exists, no need to create folder`n"
}

if($NoClean.IsPresent){
    Append-Log -message "Script called with -NoClean, NOT Deleting existing files from $TargetFolderAPXDBFolder`n"
} else {
    Append-Log -message "Script called without -NoClean, Deleting existing files from $TargetFolderAPXDBFolder`n"
    if (!(test-path $TargetFolderAPXDBFolder -PathType Leaf)){
        Append-Log -message "$TargetFolderAPXDBFolder NOT Empty, removing $TargetFolderAPXDBFolder\*`n"
        $files = get-childitem $TargetFolderAPXDBFolder\*

        $files| select -ExpandProperty Fullname | foreach {            
            try {
                Append-Log -message "Attempting to Remove $_`n"
                remove-item $_ -ErrorAction stop
                Append-Log -message "Completed Removing $_ `n"
            } catch {
                Append-Log -message "Error Removing $_ `nEXCEPTION: $($_.Exception.Message)`n"
            }
        }

        $share = get-wmiobject -class win32_logicaldisk | where {$_.VolumeName -like "*backup*"}
        $GBFree = "{0:N2} GB" -f ($share.freespace /1GB )
        $GBTotal="{0:N2} GB" -f ($share.size /1GB )
        $percentUsed = "{0:N2} %" -f (($share.size - $share.freespace )/ $share.Size * 100)
        Append-Log -message @"

DiskSpace Check After Pre-Cleanup:
    SQLBackups Share: $($share.Caption)\SqlBackups
    TotalSize: $GBTotal
    Freespace: $GBFree
    PercentUsed: $percentUsed

"@            
    } else {
        Append-Log -message "$TargetFolderAPXDBFolder is already Empty, not removing items.`n"
    }
}

$BakFiles=Get-ChildItem -Path $APXDBFolder -Filter APXFirm*.bak | sort -prop LastWriteTime -Descending  | Select-Object -first 1
if($BakFiles){
    Append-Log -message "Most Recent Backup of APXFirm*.bak found`n"

    $DBBackupFileDate=$BakFiles.LastWriteTime

    Append-Log -message "DB Backup Date:($DBBackupFileDate)`n"

    $DBBackupFileDate = $DBBackupFileDate.AddDays(-6)

    Append-Log -message "Date After Adjustment: ($DBBackupFileDate)`n"
	
    $BakFiles_APX=Get-ChildItem -Path  $APXDBFolder\* -include "APX*.bak","MDM*.bak","Report*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} 
    if($BakFiles_APX){
        Append-Log -message "Backup files for APX: `n$($Bakfiles_APX| select  fullname, length, LastWriteTime | ft -autosize | out-string)`n"    
        foreach ($backupFile in $BakFiles_APX){
            Append-Log -message "Beginning Copying $($backupFile.FullName) to $TargetFolderAPXDBFolder`n"
            $share = get-wmiobject -class win32_logicaldisk | where {$_.VolumeName -like "*backup*"}
            if(SpaceExists -share $share -file $backupfile -ThresholdUsed 70){
                try {                 
                    Copy-Item $backupFile.FullName $TargetFolderAPXDBFolder -ErrorAction stop
                    Append-Log -message "Completed  Copying $($backupFile.FullName) to $TargetFolderAPXDBFolder`n"
                } catch {
                    Append-Log -message "`tError Copying $($Backupfile.Fullname)`nEXCEPTION: $($_.exception.message)`n"
                }
            } else {
                Append-Log -message "`tNot enough freespace to Copy $($backupFile.FullName) to $TargetFolderAPXDBFolder without ending up with less than $CancelThreshold % freespace remaining`n"                
            }                       
    	}
    } else {
        Append-Log -message "No Backup files found for APX in $APXDBFolder`n"
    }
        		
    $BakFiles_RC=Get-ChildItem -Path  $RCDBFolder\* -include "RC*.bak" | where {$_.LastWriteTime -gt $DBBackupFileDate} 
    if($BakFiles_RC){
        Append-Log -message "Backup Files for RC in $RCDBFolder: `n$($BakFiles_RC|select fullname, length, LastWriteTime | ft -autosize | out-string)`n"
        foreach ($backupFile in $BakFiles_RC){    	 	            
            Append-Log -message "Beginning Copying $($backupFile.FullName) to $TargetFolderAPXDBFolder`n"
            $share = get-wmiobject -class win32_logicaldisk | where {$_.VolumeName -like "*backup*"}
            if(SpaceExists -share $share -file $backupfile -ThresholdUsed 70){
                try {
                    Copy-Item $backupFile.FullName $TargetFolderAPXDBFolder -ErrorAction stop
                    Append-Log -message "Completed  Copying $($backupFile.FullName) to $TargetFolderAPXDBFolder`n"
                } catch {
                    Append-Log -message "`tError Copying $($Backupfile.Fullname)`nEXCEPTION: $($_.exception.message)`n"
                }
            } else {
            	Append-Log -message "`tNot enough freespace to Copy $($backupFile.FullName) to $TargetFolderAPXDBFolder without ending up with less than $CancelThreshold % freespace remaining`n"                
            }
    	}
    } else {
        Append-Log -message "No Backup files found for RC in $RCDBFolder`n"
    }
    
} else {
    Append-Log -message "No Backup Files found matching $APXFirm*.bak in $APXDBFolder`n" 
}
$share = get-wmiobject -class win32_logicaldisk | where {$_.VolumeName -like "*backup*"}
$GBFree = "{0:N2} GB" -f ($share.freespace /1GB )
$GBTotal="{0:N2} GB" -f ($share.size /1GB )
$percentUsed = "{0:N2} %" -f (($share.size - $share.freespace )/ $share.Size * 100)

Append-Log -message @"

DiskSpace Check After Execution:
    SQLBackups Share: $($share.Caption)\SqlBackups
    TotalSize: $GBTotal
    Freespace: $GBFree
    PercentUsed: $percentUsed

"@    
Append-Log -message "Script FTP_JJ_FileTransfer-ModifiedWithLogging.ps1 Completed`n" 
Append-Log -message "EndTime: $(get-date)`n"
Append-Log -message "Log is located on  $($env:Computername) in file: $($LogFilePath)"
send-mailmessage -to $recipients -from $localServer -SmtpServer "sacmail" -subject $subject -Body ($results -join "`n")