cls

$servername = gc env:computername
$runtime=Get-Date
$Path = "D:\vol1\staging"
#$path = 'D:\vol1\staging\2051\Rex'

if (!(test-path $Path))
{
    New-Item -ItemType directory -Path $Path
}

Add-Content -Path "$Path\RemoveOldFileLog.txt" -Value "-----------------------------------------------"
Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Start Script to Remove Old File  $runtime"
Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Searching for files with extension ends with '2' and Older than 2 years ---------"

$files = Get-ChildItem -Path $Path -Recurse | Where-Object { !$PsIsContainer -and $_.Extension.EndsWith('2') -and $_.name -cnotlike('*CF.*') }

$files_tobedeleted = $files | where-object { !$PsIsContainer -and  $_.LastWriteTime.AddYears(2) -le $runtime }


$totalsize = ($files_tobedeleted | measure-object -Sum Length).Sum / 1GB

if ($files_tobedeleted) 
{
    Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Found Files with extension ends with '2' and Older than 2 years ---------"
    $files_tobedeleted | out-file $Path\RemoveOldFileLog.txt -append -noclobber -encoding ASCII
    #Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Remove Files with extension ends with '2' and Older than 2 years  ---------"
    foreach ($file in $files_tobedeleted) { 
         $filepath = split-path $file.fullname
         $lastAccessTime = $file.lastAccessTime 
       # Remove-item $filepath\$file -force | out-file $Path\RemoveOldFileLog.txt -append -noclobber -encoding ASCII
       
        $destination = $filepath.replace('D:\vol1', 'D:\vol_temp')
         
         if (!(test-path $destination))
            {
               New-Item -ItemType directory -Path $destination
            }
            
             move-item -path $filepath\$file -force -destination $destination\$file | out-file $Path\RemoveOldFileLog.txt -append -noclobber -encoding ASCII
     }
	   
       # Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Removed $filepath\$file LastAccessTime $lastAccessTime  ---------"
    #$from = $servername | foreach-object{$_ + '@advent.com'}
   	#send-mailmessage -to "amhapps@advent.com" -from $from -SmtpServer "sacmail" -subject "Old ACD Control Files are Deleted on $servername!" -body "Log on to $servername and look for the details in $Path."
    }
}
else
{
	Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "No Files with extension ends with '2' and Older than 2 years ---------"
} 
 Add-Content -Path "$Path\RemoveOldFileLog.txt"  -Value "Script Completed: $runtime" 
    
     
