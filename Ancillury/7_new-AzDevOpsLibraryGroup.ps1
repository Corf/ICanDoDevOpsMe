param (
    $devResourceGroup,
    $testResourceGroup,
    $location = "Australia East",
    $serviceConnectionName,
    $organization,
    $project
)

write-host "Invoking: 7_new-AzDevOpsLibraryGroup.ps1"

$variables  = @{
    azureSubscription = $serviceConnectionName
    env = "Dev"
    location = $location
    resourceGroupName  = $devResourceGroup
    skipValidate = "True"
    sqlAdminUsername = "DevBob"
    templateFile = "main.bicep"
}


# LibraryGroup-Dev
New-AzDevOpsLibraryGroup -variables $variables -libraryGroupName LibraryGroup-dev -organization $organization -project $project | out-null


$variables  = @{
    azureSubscription =  $serviceConnectionName
    env = "Test"
    location = $location
    resourceGroupName  = $testResourceGroup
    skipValidate = "True"
    sqlAdminUsername = "TestBob"
    templateFile = "main.bicep"
}
# create LibraryGroup-Test
New-AzDevOpsLibraryGroup -variables $variables -libraryGroupName LibraryGroup-Test -organization $organization -project $project | out-null

<#
# see Get-AZDevOpsBearerToken.ps1
# Login to Azure and Get an Azure AD Token for Azure DevOps
$token = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" ).Token 

$organization = "rcorf"
$project = "Bicep Example"  # Replace with your Azure DevOps project name
$orgUrl = "https://dev.azure.com/$organization"

# Define the Library Group Name and Variables
$libraryGroupName = "MyLibraryGroup3"

# Define the variables for the Library Group
$variables = @{
    "MySecretVariable" = @{
        isSecret = $true
        value = "MySuperSecretValue"
    }
    "MyPlainVariable" = @{
        isSecret = $false
        value = "HelloWorld"
    }
}

# Set API Headers
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# Build the full request body
$projectRefId = (Invoke-RestMethod -Uri "$orgUrl/_apis/projects/$project" -Headers $headers -Method Get).id

$body = @{
    name = $libraryGroupName
    type = "Vsts"
    description = "Created via PowerShell"
    variables = $variables  # Variables are nested inside the body
    variableGroupProjectReferences = @(@{ 
        name = $libraryGroupName
        projectReference = @{
            id = $projectRefId
            name = $project
        }
    })
} | ConvertTo-Json -Depth 3

# Define the API URL for Creating a Library Group
$uri = "$orgUrl/$project/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"

# Send the API Request to Create the Library Group
$response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

# Output the Response
$response | Select-Object id, name, createdBy


#>