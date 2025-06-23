Import necessary modules 

Import-Module BcContainerHelper Import-Module UniversalDashboard.Community 

Define selectable options 

# the versions here we can add it

$BCVersions = @( '19.0.29794.0', '20.0.30904.0', '25.5.30849.32364', '25.6.30910.32415' ) $CountryCodes = @('w1', 'de', 'ch', 'dk', 'us') $ContainerTypes = @('sandbox', 'onprem') 

Build the dashboard 

$Dashboard = New-UDDashboard -Title 'BC Container Creator Intern' -Content { New-UDInput -Title 'Create BC Container' -Id 'bcContainerForm' -Content { New-UDInputField -Type 'select' -Name 'Version' -Placeholder 'Select BC Version' -Values $BCVersions New-UDInputField -Type 'select' -Name 'Country' -Placeholder 'Select Country Code' -Values $CountryCodes New-UDInputField -Type 'select' -Name 'ContainerType' -Placeholder 'Select Container Type' -Values $ContainerTypes } -Endpoint { param($Version, $Country, $ContainerType) 

   # Generate a unique container name 
    $containerName = "bc-$($Version.Replace('.', ''))-$Country-$ContainerType" 
 
    # Create credentials 
    $securePassword = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force 
    $credential = New-Object System.Management.Automation.PSCredential('admin', $securePassword) 
 
    # Retrieve the artifact URL 
    $artifactUrl = Get-BcArtifactUrl -type $ContainerType -version $Version -country $Country -select 'Closest' 
 
    # Create the Business Central container 
    New-BcContainer -accept_eula ` 
                    -containerName $containerName ` 
                    -credential $credential ` 
                    -auth 'UserPassword' ` 
                    -artifactUrl $artifactUrl ` 
                    -imageName 'mybcimage' ` 
                    -updateHosts 
 
    # Construct the login URL 
    $loginUrl = "http://$containerName/BC" 
 
    # Display a success message with the login URL 
    Show-UDToast -Message "Created container: $containerName. Login at: $loginUrl" -Duration 4000 
 
    # Display the login URL on the dashboard 
    New-UDParagraph -Text "Access your container at: $loginUrl" 
} 
  

} 

Start the dashboard on port 10001 

Start-UDDashboard -Dashboard $Dashboard -Port 10001 

Keep the script running to keep the dashboard open 

while ($true) { Start-Sleep -Seconds 60 } 
