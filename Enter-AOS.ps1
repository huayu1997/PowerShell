Param(
	[PSCredential]$credential
)
function rebuild-AOS {
    Param(
        $COMPUTERNAME="vsacstpops1-2.prod.dx",
        $ConfigurationName="AOS"        
    )
    Get-PSSession | Where-Object {$_.ConfigurationName -eq $ConfigurationName}| Remove-PSSession
    remove-module AOS_JEA_Workstation -Force -ErrorAction SilentlyContinue
    $session = New-PSSession -ComputerName $COMPUTERNAME -ConfigurationName $ConfigurationName -Credential $credential -Name "AOS_$($env:USERNAME)_$($env:COMPUTERNAME)" -EnableNetworkAccess -Verbose   
    Export-PSSession -Session $session -OutputModule AOS_JEA_Workstation -InformationAction Continue -Force -AllowClobber -WarningAction SilentlyContinue -Debug -CommandName @(                
        #"Send-ABOSMPStatusEmail",
        #"Get-AboxMorningProcess",
        #"Get-AMDService",
        #"Restart-AMDService",

        "find-secret",
        "get-secret",
        "Find-SecretFolder",
        "Get-SecretChildItem",
        "Add-secret",
        "New-Password",
        "Convert-SecretCredential",
        "Get-AOSEnvironment",
        "Translate-AOSAPI-Properties",

        "Get-AOSReportQueue",
		"Get-AOSMSMQueue",

        "Get-AbosFile",
		"Set-AbosFile",
        "Get-ABOSNonTranslatedFile",
        "Get-AboxEventLog",
        "Get-AboxStatus",
        "Get-AboxExtract",
        "Restart-Abox",
        "Get-AboxTranslateFile",

		"Get-AOSProcess",
		"Stop-AOSProcess",
		"Start-AOSProcess",
		"Get-AOSService",
		"Stop-AOSService",
		"Restart-AOSService",
		"Start-AOSService",

        "Get-AOSSqlActivity",
		"Stop-AOSSqlActivity",
        "Invoke-AOSSqlCmd",

        "Get-AOSMoxyCredential",
        "Get-AOSMoxyImporter",
		"Get-AOSMoxyFixConnection",
		"Start-AOSMoxyFixConnection",
		"Stop-AOSMoxyFixConnection",
		"Get-AOSMoxyEventLog",
        "Get-AOSGenericDate",
        "Get-AOSLogFile",
        "Invoke-AOSFixEOD",
        "Invoke-AOSPowershell",

		"Invoke-AOSVisualCronJob",
		"Get-AOSVisualCronJob",

        "Convert-TimeZone",
        "Get-AOSAPXEventLog",
		"Get-LocalCredentialStore",
		"Set-LocalCredentialStore",
		"Get-LocalCredential",
		"Remove-LocalCredentialStore",
		"Add-LocalCredential",
		"Remove-LocalCredential",
        "Update-LocalCredential",
        
        "Get-AOSRebootSchedule",
        "Validate-AOSRebootConditions",
        "Get-APXScriptResult",
        "Get-AOSPortContention"
    )
    import-module AOS_JEA_Workstation -DisableNameChecking -Global -Force -WarningAction SilentlyContinue
}
rebuild-AOS

Register-ArgumentCompleter -CommandName find-SecretFolder, Get-SecretChildItem, Add-secret, Update-Secret, new-Password, find-secret, get-secret -ParameterName SecretServerName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        @(
            "CORP",
            "US",
            "EMEA"
        ) | where-Object {$_-like "*$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Target SecretServerName $($_)")
    }
}
Register-ArgumentCompleter -CommandName Get-AOSEnvironment -ParameterName EnvironmentStatusCode -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        @(
            "A",
            "I",
            "N",
            "O"
        ) | where-Object {$_ -like "*$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Environment Status $($_)")
    }
}

Register-ArgumentCompleter -CommandName Get-AOSGenericDate -ParameterName GenericDateName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    @(
        @{Name='TODA';Desc="Today"},
        @{Name='YEST';Desc="Yesterday"},
        @{Name='PREV';Desc="Previous Last Business Date"},
        @{Name='LAST';Desc="Last Business Date"},
        @{Name='BDLW';Desc="Beginning Date of Last Week"},
        @{Name='EDLW';Desc="End Date of Last Week"},
        @{Name='EDNW';Desc="End Date of Next Week"},
        @{Name='ETNM';Desc="End of the Next Month"},
        @{Name='BDPM';Desc="Beginning Date of Previous Month"},
        @{Name='EDPM';Desc="End Date of Previous Month"},
        @{Name='BDLM';Desc="Beginning Date of Last Month"},
        @{Name='EDLM';Desc="End Date of Last Month"},
        @{Name='BDTM';Desc="Beginning Date of This Month"},
        @{Name='EDTM';Desc="End Date of This Month"},
        @{Name='BDNM';Desc="Beginning Date of Next Month"},
        @{Name='EDNM';Desc="End Date of Next Month"},
        @{Name='BTLW';Desc="Beginning of The Last Week"},
        @{Name='ETLW';Desc="End of the Last Week"},
        @{Name='BDTQ';Desc="Beginning Day of This Quarter"},
        @{Name='BDTY';Desc="Beginning Day of This Year"}
    ) | Where-Object{$_.name -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            $_.Name,
            $_.Name, 
            'ParameterValue', "$($_.Name) APX Label for: $($_.Desc)")
    }
}
Register-ArgumentCompleter -CommandName Get-AbosFile -ParameterName Status -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        "'Waiting to Receive'", 
        "'Downloading'",
        "'Translating'",
        "'Posting'",
        "'Successfully Processed File'",
        "'Failed to Process File'",
        "'Waiting on Sec File'",
        "'Waiting on Mvl File'",
        "'Waiting on Psn File'",
        "'Waiting on Trn File'",
        "'Waiting on Bulk Translate Process'" | Where-Object{$_ -like "*$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "set status to: $_")
    }
}
Register-ArgumentCompleter -CommandName Set-AbosFile -ParameterName FromStatus -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        "'Waiting to Receive'", 
        "'Downloading'",
        "'Translating'",
        "'Posting'",
        "'Successfully Processed File'",
        "'Failed to Process File'",
        "'Waiting on Sec File'",
        "'Waiting on Mvl File'",
        "'Waiting on Psn File'",
        "'Waiting on Trn File'",
        "'Waiting on Bulk Translate Process'" | Where-Object{$_ -like "*$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "set status to: $_")
    }
}
Register-ArgumentCompleter -CommandName Set-AbosFile -ParameterName ToStatus -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        "'Waiting to Receive'", 
        "'Downloading'",
        "'Translating'",
        "'Posting'",
        "'Successfully Processed File'",
        "'Failed to Process File'",
        "'Waiting on Sec File'",
        "'Waiting on Mvl File'",
        "'Waiting on Psn File'",
        "'Waiting on Trn File'",
        "'Waiting on Bulk Translate Process'" | Where-Object{$_ -like "*$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "set status to: $_")
    }
}
$AOS_MHID_Commands = @(
    "Get-AOSEnvironment",
    "Get-AOSMoxyCredential",
    "Get-AOSMSMQueue",
    "Get-AOSReportQueue",
    "Get-AOSProcess",
    "Get-AOSService",
    "Get-AOSSqlActivity",
    "Restart-AOSService",
    "Start-AOSProcess",
    "Start-AOSService",
    "Stop-AOSProcess",
    "Stop-AOSService",
    "Stop-AOSSqlActivity"
    "Invoke-AOSSqlCmd",
    "Get-ABOXStatus",
    "Get-ABOXEventLog",
    "Get-ABOXEXELog",
    "Get-AOSMoxyImporter",
    "Get-AOSMoxyFixConnection",
    "Start-AOSMoxyFixConnection",
    "Get-AOSVisualCronJob",
    "Invoke-AOSVisualCronJob",
    "Invoke-AOSPowershell"
)
$AOS_Server_Commands = @(
    "Get-AOSMSMQueue",
    "Get-AOSProcess",
    "Get-AOSService",
    "Restart-AOSService",
    "Start-AOSProcess",
    "Start-AOSService",
    "Stop-AOSProcess",
    "Stop-AOSService",
    "Stop-AOSSqlActivity",
    "Get-AOSVisualCronJob",
    "Invoke-AOSVisualCronJob",
    "Invoke-AOSPowershell"    
)
$AOS_Server_MX_Commands = @(
    "Get-AOSSqlActivity",
    "Get-AOSMoxyCredential"
    "Get-AOSMoxyImporter",
    "Get-AOSMoxyFixConnection",
    "Start-AOSMoxyFixConnection",
    "Invoke-AOSSqlCmd"
)
Register-ArgumentCompleter -CommandName $AOS_MHID_Commands -ParameterName MHID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-DX_AOSEnvironment -AdventSystem production | select -ExpandProperty MHID | Where-Object{$_ -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "Target MHID: $_")
    }
}
Register-ArgumentCompleter -CommandName $AOS_Server_Commands -ParameterName Server -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            "App", 
            "CA1",
            "CA2",
            "DB", 
            "MX"| Where-Object{$_ -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "Target Server: $_")
    }
}
Register-ArgumentCompleter -CommandName $AOS_Server_MX_Commands -ParameterName Server -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            "DB", 
            "MX"| Where-Object{$_ -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "Target Server: $_")
    }
}
Register-ArgumentCompleter -CommandName Convert-TimeZone -ParameterName FromTimeZone -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)   

    [System.TimeZoneInfo]::GetSystemTimeZones() |  Where-Object{$_.ID -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            "'$($_.ID)'",
            "'$($_.ID)'",
            'ParameterValue', 
            "TimeZone: $($_.ID) UTC Offset: $($_.BaseUTCOffSet)"
        )
    }
}
Register-ArgumentCompleter -CommandName Convert-TimeZone -ParameterName ToTimeZone -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)   

    [System.TimeZoneInfo]::GetSystemTimeZones() |  Where-Object{$_.ID -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new(
            "'$($_.ID)'",
            "'$($_.ID)'",
            'ParameterValue', 
            "TimeZone: $($_.ID) UTC Offset: $($_.BaseUTCOffSet)"
        )
    }
}
Register-ArgumentCompleter -CommandName Get-AOSEnvironment -ParameterName AdventSystem -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    "Production", "Staging"| Where-Object{$_ -like "$wordToComplete*"}  | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', "Target Server: $_")
    }
}