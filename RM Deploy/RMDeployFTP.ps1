$customModuleDirectory = Join-Path $env:SystemDrive "\Program Files\WindowsPowerShell\Modules"
$customModuleSrc = Join-Path $applicationPath "RM Deploy\xWebAdministration"
$localpath= Join-Path $applicationPath "Marisa.Ecommerce.Web"
$exeLocation = Join-Path $applicationPath "RM Deploy"
Copy-Item -Verbose -Force -Recurse -Path $customModuleSrc -Destination $customModuleDirectory 
#Start To Start Application Pool

    Function fnStartApplicationPool([string]$appPoolName)
    {
	  import-module WebAdministration
       if((Get-WebAppPoolState $appPoolName).Value -ne 'Started')
       {
	      Start-WebAppPool -Name $appPoolName
       }
    }
    
#End To Start Application Pool

   Function fnStopApplicationPool([string]$appPoolName)
    {
	  import-module WebAdministration
       if((Get-WebAppPoolState $appPoolName).Value -ne 'Stopped')
       {
	      Stop-WebAppPool -Name $appPoolName
       }
    }
    
#End To Stop Application Pool

if (test-connection -computername $computer -quiet)
{
	Set-Location $exeLocation
    #fnStopApplicationPool $WebAppPollName
    .\2pcUploadFTP $ftproot $ftpuser $ftppassword $localpath $ftpdirectory
    #fnStartApplicationPool $WebAppPollName
}
else
{
    #Write-Verbose "Máquina indisponivel" -Verbose
	throw "Máquina $computer indisponivel"
}
