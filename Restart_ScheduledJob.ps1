cls
$runtime=Get-Date -format "yyyy-M-d HH:mm:ss"
$servername = gc env:computername

Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "-----------------------------------------------"
Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "Start Script: $runtime"
$CurrentStatus = schtasks /query /fo CSV /TN "ProcDumpMon"

Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "-----------------------------------------------"
Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "Checking Scheduled Task Status: $runtime"
$CurrentStatus | convertfrom-csv | foreach-object{
    $taskname = $_.name
    $taskname
    if ($_.status -eq 'Running')  {Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "ProcDumpMon is running" }
    else {
        Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "Scheduled Task is not running. Will restart:"
        Add-Content -Path "C:\CrashDumps\ScheduledTaskLog.txt" -Value "Re-Start Scheduled Task ProcDumpMon: $runtime"
        
         schtasks /Run /TN "ProcDumpMon" >> C:\CrashDumps\ScheduledTaskLog.txt
        # D:\AdminTools\APX4_RestartApx.bat
	$servername = gc env:computername
  	$from = $servername | foreach-object{$_ + '@advent.com'}
  	send-mailmessage -to "amhapps@advent.com" -from $from -SmtpServer "sacmail" -subject "AxGate May Have Crashed on $servername!" -body "Log on to $servername and look for crash dump file in C:\crashdumps." -Attachment "C:\CrashDumps\ScheduledTaskLog.txt"
         }
    }
  
  