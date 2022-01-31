


Add-PSSnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue
Add-PSSnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue

$SqlSettings = @{username="huadesk"; password="Midgard0"; ConnectionTimeout=60;QueryTimeout=60}
$Connection=@{ServerInstance = "VSACSQLBAK02";Database = "dbastuff"}



Invoke-Sqlcmd  @Connection @SqlSettings -InputFile "C:\Users\hyu\Documents\PowerShell\Hua_OnDemandDBSize_trend.sql" |out-file c:\users\hyu\Documents\PowerShell\Hua_OnDemandDBSize_trend.txt;

$Query=@{Query="select ServerName,YearMonth,MonthlyDataSizeAvgMB,PrevTotalDataSizeMB as PrevMonthTotalDataSizeMB,
ChangeTotal as GrowthCurrentMonthMB, ChangesubTotal as AccumulativeDataGrowthMB, convert(varchar(10),PercDiff) + '%' as PercGrowth, convert(varchar(10),PercentTotal) + '%' as AccumulativePercGrowth
from  [VSACSQLBAK02].[tempdb].[dbo].[tmptblDatabaseSpaceStats6]
order by servername,PartRowID 
go" }


    Invoke-Sqlcmd @Connection @SqlSettings @Query| 
    Select-Object -Property * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors |
    Export-csv C:\Users\hyu\Documents\PowerShell\OnDemandDBSize_trend.csv 


