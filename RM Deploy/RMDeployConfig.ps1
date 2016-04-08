# copy DSC modules into system modules folder
$customModuleDirectory = Join-Path $env:SystemDrive "\Program Files\WindowsPowerShell\Modules"
$customModuleSrc = Join-Path $applicationPath "RM Deploy\xWebAdministration"
Copy-Item -Verbose -Force -Recurse -Path $customModuleSrc -Destination $customModuleDirectory 

write-verbose ("{0}\{1}" -f $applicationPath,"Marisa.Ecommerce.Web") -Verbose

if ((Get-NetFirewallRule -DisplayName $WebSiteName -ErrorAction SilentlyContinue) -eq $null)
{
	New-NetFirewallRule -DisplayName $WebSiteName -Action Allow -Direction Inbound -LocalPort $Port -Profile Any -Protocol TCP -RemotePort Any
}

$ConfigData = @{
    AllNodes = @(
		@{ NodeName = "*"},

        @{
			NodeName = $env:COMPUTERNAME
            DeploymentPath = $WebSiteDirectory
            WebSiteName  = $WebSiteName
            WebAppPoolName = $WebAppPollName
            Port = $Port 
            BackupPath = $BackupPath  
			StaticDeploymentPath = $StaticWebSiteDirectory
            StaticWebSiteName  = $StaticWebSiteName
            StaticPort = $StaticPort
            StaticBackupPath = $StaticBackupPath   
        }
    );
}