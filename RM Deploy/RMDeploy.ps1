Configuration MarisaSite 
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
            SourcePath = ("{0}\{1}" -f $applicationPath,"Marisa.Ecommerce.Web")
            DestinationPath = $Node.DeploymentPath
        }

		# Copy website bits to configured deployment path
		File CopyStaticDeploymentBits
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = ("{0}\{1}\{2}" -f $applicationPath,"Marisa.Ecommerce.Web","StaticFiles")
            DestinationPath = $Node.StaticDeploymentPath
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

		# Create and start MarisaWebSite
		xWebsite MarisaWebSite01  
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
		
		# Create and start MarisaWebSite
		xWebsite MarisaWebStaticSite01  
		{ 
			Ensure          = "Present" 
			Name            = $Node.StaticWebSiteName 
			State           = "Started" 
			PhysicalPath    = $Node.StaticDeploymentPath
			ApplicationPool  = $Node.WebAppPoolName 
			BindingInfo = MSFT_xWebBindingInformation 
                        { 
                            Port = $Node.StaticPort 
                        } 
			DependsOn       = "[File]CopyDeploymentBits" 
		}
	}
	
}

MarisaSite -ConfigurationData $ConfigData -Verbose