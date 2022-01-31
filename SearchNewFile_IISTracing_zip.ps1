cls

$servername = gc env:computername
$from = $servername | foreach-object{$_ + '@advent.com'}
$runtime=Get-Date
$Path = "C:\inetpub\logs\FailedReqLogFiles\W3SVC1"

if (!(test-path $Path))
{
    New-Item -ItemType directory -Path $Path
}



Add-Content -Path "$Path\MonitorLog.txt" -Value "-----------------------------------------------"
Add-Content -Path "$Path\MonitorLog.txt"  -Value "Start Script to Monitor Tracing Log  File: $runtime"
Add-Content -Path "$Path\MonitorLog.txt"  -Value "Searching for Tracing Log  File Created in the past 5 minute ----------"

#### http://mats.gardstad.se/matscodemix/2009/02/05/calling-7-zip-from-powershell/  
# Alias for 7-zip 
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"


$files = Get-ChildItem -Path $Path -Recurse | Where-Object { !$PsIsContainer  -and $_.Extension -ne ".txt" -and $_.Extension -ne ".7z" -and $_.LastWriteTime.AddMinutes(5) -ge $runtime }

if ($files) 
{
	$files | out-file $Path\MonitorLog.txt -append -noclobber -encoding ASCII
### Zip any new log files
	foreach ($file in $files) { 
                    $name = $file.name 
                    $directory = $file.DirectoryName 
                    $zipfile = $name + ".7z"
                    sz a -t7z "$directory\$zipfile" "$directory\$name"   
		    send-mailmessage -to "hyu@advent.com"  -cc "mmillson@advent.com" -from $from -SmtpServer "sacmail" -subject "New IIS Tracing Log *$files* is Created on $servername!" -Attachment  "$directory\$zipfile"  -body "Log on to $servername and look for it in $Path."
   
                }     

}
  Add-Content -Path "$Path\MonitorLog.txt"  -Value "Script Completed: $runtime" 
    
     
#amhapps -cc "mmillson@advent.com"