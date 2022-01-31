$path = "C:\Users\hyu\Documents\PowerShell"
$runtime=Get-Date #-format "yyyy-M-d HH:mm:ss"

$files = Get-ChildItem -Path $path -Recurse | Where-Object { !$PsIsContainer -and [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq "select" }
$files | gm property


$creation_time = $files | foreach-object {$_.LastWriteTime }

$elapsed_time = $files |foreach-object {$runtime - $_.LastWriteTime }

$elapsed_time | where-object {$_.Minute -ge 5} | foreach-object {
    Write-host "A New File has been generated."
}

