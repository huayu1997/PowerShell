cls

$servername = gc env:computername
$runtime=Get-Date
$Path = "D:\DebugDiag_Dumps"

if (!(test-path $Path))
{
    New-Item -ItemType directory -Path $Path
}

Add-Content -Path "$Path\MonitorLog.txt" -Value "-----------------------------------------------"
Add-Content -Path "$Path\MonitorLog.txt"  -Value "Start Script to Monitor Crash Dump File: $runtime"
Add-Content -Path "$Path\MonitorLog.txt"  -Value "Searching for Crash Dump File Created in the past 5 minute ----------"

$files = Get-ChildItem -Path $Path -Recurse | Where-Object { !$PsIsContainer -and $_.Extension -eq ".dmp" -and $_.LastWriteTime.AddMinutes(5) -ge $runtime } 

if ($files) 
{
    $files | out-file $Path\MonitorLog.txt -append -noclobber -encoding ASCII
    $from = $servername | foreach-object{$_ + '@advent.com'}
   	send-mailmessage -to "amhapps@advent.com" -from $from -SmtpServer "sacmail" -subject "New Crash Dump File *$files* is Created on $servername!" -body "Log on to $servername and look for it in $Path."
}
  Add-Content -Path "$Path\MonitorLog.txt"  -Value "Script Completed: $runtime" 
    
     
