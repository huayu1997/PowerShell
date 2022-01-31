
Get-ADGroupMember -identity 'CS-Support-Basic' -Recursive |get-aduser -Properties description |select name,description,samaccountname | Export-CSV "C:\Users\hyu\CS_Support_Basic.csv"

| Export-CSV "C:\Users\hyu\CS_Support_Basic.csv"