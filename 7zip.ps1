<#   
This script compress all non .txt files in there cureent folder and make new .7zip file. 
   
#> 
 
 
#### 7 zip variable I got it from the below link  
 
#### http://mats.gardstad.se/matscodemix/2009/02/05/calling-7-zip-from-powershell/  
# Alias for 7-zip 
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 
 
############################################ 
#### Variables  
 
$filePath = "C:\inetpub\logs\FailedReqLogFiles\W3SVC1" 
 
$tracelogs = Get-ChildItem -Recurse -Path $filePath | Where-Object { $_.Extension -ne ".txt" } 
 
########### END of VARABLES ################## 
 
foreach ($file in $tracelogs) { 
                    $name = $file.name 
                    $directory = $file.DirectoryName 
                    $zipfile = $name + ".7z"
                    sz a -t7z "$directory\$zipfile" "$directory\$name"      
                } 
 
########### END OF SCRIPT ########## 