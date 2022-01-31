


Add-PSSnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue
Add-PSSnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue

$SqlSettings = @{username="huadesk"; password="Midgard0"; ConnectionTimeout=60;QueryTimeout=60}
$Connection=@{ServerInstance = "VSACSQLBAK02";Database = "dbastuff"}

$HTMLSettings = @{
Head = 
@"
<Title>
    DBA SQL Backup Location Page
</Title>
<style>
    BODY{
        font-size:smaller;
        font-family:Garamond;
    }
    TABLE{
        border-width: 1px;
        border-style: solid;
        border-color: black;
        border-collapse: collapse;
    } 
    TH{
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: black;
    } 
    TD{
        border-width: 1px;
        padding: 2px;
        border-style: solid;
        border-color: black;
    }
</style>
"@;
PreContent = "Last Updated " + (get-date).tostring("MM/dd/yy hh:mm:ss tt - ") + ([System.TimeZoneInfo]::Local).DisplayName +" by " + ([Environment]::UserDomainName) + "\" + ([Environment]::UserName) + "<br>`n<br>`n";
PostContent = "";
}

Invoke-Sqlcmd  @Connection @SqlSettings -InputFile "C:\Users\hyu\Documents\PowerShell\Hua_OnDemandDBSize_trend.sql" |out-file c:\users\hyu\Documents\PowerShell\Hua_OnDemandDBSize_trend.txt;

$Query=@{Query="select ServerName,YearMonth,MonthlyDataSizeAvgMB,PrevTotalDataSizeMB as PrevMonthTotalDataSizeMB,
ChangeTotal as GrowthCurrentMonthMB, ChangesubTotal as AccumulativeDataGrowthMB, convert(varchar(10),PercDiff) + '%' as PercGrowth, convert(varchar(10),PerCentAVG) + '%' as PerCentAVG
from  [VSACSQLBAK02].[tempdb].[dbo].[tmptblDatabaseSpaceStats6]
order by servername,PartRowID 
go" }

$HTMLSettings.PostContent ="<br><br>Generated using the following query on " + ($Connection.ServerInstance) + "\" + ($Connection.Database) + ":<br>`n <font face=""Courier New"">" + ($Query.Query) + "</font>"
#Invoke-Sqlcmd @Connection @SqlSettings -InputFile "C:\Users\hyu\Documents\PowerShell\Hua_OnDemandDBSize_trend.sql" 
try {
    Invoke-Sqlcmd @Connection @SqlSettings @Query| 
    Select-Object -Property * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors |
    ConvertTo-Html @HTMLSettings | 
    out-file -filePath "C:\Users\hyu\Documents\PowerShell\DbaSqlBackupLocationPage.html" -encoding "ASCII" -Force
} catch {
   "An error occurred while generating this page on " + (get-date).tostring("MM/dd/yy hh:mm:ss tt - ") + ([System.TimeZoneInfo]::Local).DisplayName +" as user " + ([Environment]::UserDomainName) + "\" + ([Environment]::UserName) + ".<br>`n"+
   "Please check the visualcron error log for details:<br>`n" + 
   "&nbsp;&nbsp;&nbsp;&nbsp;Server: 'vSacStpOps1-1'<br>`n" +
   "&nbsp;&nbsp;&nbsp;&nbsp;Group: 'Default Group'<br>`n" +
   "&nbsp;&nbsp;&nbsp;&nbsp;Job: 'Run Sql -> html scripts.ps1'<br>`n" +
   "&nbsp;&nbsp;&nbsp;&nbsp;Task: 'C:\APPS\UpdateDbaSqlBackupLocationPage.ps1'<br>`n"+
   "<img src=""DbaSqlBackupLocationPage-VisualCronScreenshot.JPG"" alt=""DbaSqlBackupLocationPage-VisualCronScreenshot.JPG""><br>`n" +
   "<br>`n" +
   "If this is an 'Cannot generate SSPI context' error, please escalate this issue to Prakash Heda" | out-file -filePath "C:\Inetpub\wwwroot\SQLMonitors\DbaSqlBackupLocationPage.html" -encoding "ASCII" -Force
   ($_ | Out-String) | Write-Error
}
write-error "Cannot generate SSPI context..."

