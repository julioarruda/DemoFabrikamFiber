Configuration SampleSite 
{ 
	Import-DSCResource -ModuleName xWebAdministration

	Node $AllNodes.NodeName
	{
		#Install the IIS Role 
		WindowsFeature IIS 
		{ 
		  Ensure = "Present" 
		  Name = "Web-Server"
		} 

		# Install the ASP .NET 4.5 role 
		WindowsFeature AspNet45 
		{ 
			Ensure = "Present" 
			Name = "Web-Asp-Net45" 
		} 
		
		# Create a Web Application Pool 
        xWebAppPool NewWebAppPool 
        { 
            Name   = $Node.WebAppPoolName 
            Ensure = "Present" 
            State  = "Started" 
        } 

		# Copy website bits to configured deployment path
		File BackupSite
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = $Node.DeploymentPath
            DestinationPath = $Node.BackupPath
		}

		# Copy website bits to configured deployment path
		File BackupStaticSite
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = $Node.StaticDeploymentPath
            DestinationPath = $Node.StaticBackupPath
		}
        
		
		# Copy website bits to configured deployment path
		File CopyDeploymentBits
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = ("{0}\{1}" -f $applicationPath,"FabrikamFiber.Web")
            DestinationPath = $Node.DeploymentPath
        }


	
		
		# Stop the default website 
		xWebsite DefaultSite  
		{ 
			Ensure          = "Present" 
			Name            = "Default Web Site" 
			State           = "Stopped" 
			PhysicalPath    = "C:\inetpub\wwwroot" 
			DependsOn       = "[WindowsFeature]IIS" 
		}

		# Create and start Site
		xWebsite FabrikamWeb  
		{ 
			Ensure          = "Present" 
			Name            = $Node.WebSiteName 
			State           = "Started" 
			PhysicalPath    = $Node.DeploymentPath
			ApplicationPool  = $Node.WebAppPoolName 
			BindingInfo = MSFT_xWebBindingInformation 
                        { 
                            Port = $Node.Port 
                        } 
			DependsOn       = "[File]CopyDeploymentBits" 
		}
		
		
	}
	
}

SampleSite -ConfigurationData $ConfigData -Verbose