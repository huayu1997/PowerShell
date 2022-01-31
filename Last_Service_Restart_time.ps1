$servername = gc env:computername
$runtime=Get-Date
$from = $servername | foreach-object{$_ + '@advent.com'}

$service_Starttime= (Get-EventLog -LogName "System" -Source "Service Control Manager" -EntryType "Information" -Message "*Advent Application Server*running*" -Newest 1).TimeGenerated;

if ($service_Starttime.Addminutes(5) -ge $runtime )
{
    send-mailmessage -to "rkoshar@sbhic.com" -cc "hyu@advent.com" -from "hyu@advent.com" -SmtpServer "sacmail" -subject "APX Services were Restarted on $service_Starttime." -body "<EOM>" 
   
}