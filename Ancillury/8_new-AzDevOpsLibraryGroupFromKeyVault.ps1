param (
    $keyVaultName,
    $libraryGroupName = "secrets-dev",
    $organization = "rcorf",
    $project = "Bicep Example",
    $serviceConnectionName =  "GenricServiceConnection"
)


Write-host "Invoking: 8_new-AzDevOpsLibraryGroupFromKeyVault.ps1"
# # Load functions
# (Get-ChildItem C:\Users\line\git\bicep-powershell\functions).FullName |%{. $_ }

# Step 1: Login to Azure and Get an Azure AD Token for Azure DevOps
# note:  For Azure DevOps, the ResourceUrl is 499b84ac-1321-427f-aa17-267ca6975798, which is the well-known Azure AD application ID for DevOps.
$secureToken = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" -AsSecureString).Token
# Convert SecureString to plain text for use in the API call
$token = [System.Net.NetworkCredential]::new("", $secureToken).Password

# Step 2: Define Azure DevOps Organization, Project, and Service connction
# $organization = "rcorf"
# $project = "Bicep Example"
$orgUrl = "https://dev.azure.com/$organization"
# $serviceConnectionName =  "GenricServiceConnection"

# Step 3: Define the Library Group Name and Key Vault Details
# $libraryGroupName = "$(Get-RandomName)-LG"
# $keyVaultName = (get-azkeyVault).vaultname  # Name of your Azure Key Vault


# Set API Headers
$headers = @{
    Authorization  = "Bearer $token"
    "Content-Type" = "application/json"
}


# Get Project Reference ID
$projectRefId = (Invoke-RestMethod -Uri "$orgUrl/_apis/projects/$project" -Headers $headers -Method Get).id

# get service connection ID 
# note: there is only one in my environemnt
$serviceEndpointUri = "$orgUrl/$project/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"

# select the Service connection your want 
$response = Invoke-RestMethod -Uri $serviceEndpointUri -Method Get -Headers $headers
$armServiceConnection = $response.value | Where-Object { $_.type -eq "azurerm" -and $_.name -eq $serviceConnectionName } 
$serviceEndpointId = $armServiceConnection.id  # Extract the ID correctly

# get the passwords your want
$secretNames =  (Get-AzKeyVaultSecret -VaultName $keyVaultName).name

$variables = @{}

$secretNames | %{
    
    $variables."$_" = @{
        contentType = ""
        isSecret    = $true
        isReadOnly	= $false
        value       = ""
        enabled     = $true
    }
}
# $jsonSecretStrings

# Step 5: Build the full request body with Key Vault integration
$body = @{
    name = $libraryGroupName
    providerData = @{
        serviceEndpointId =  $serviceEndpointId  #"4bdcd719-9cda-40ef-a834-8fc3cf6a2cc1"
        vault = $keyVaultName
    }
    type = "AzureKeyVault"
    variables = $variables
    variableGroupProjectReferences = @(
        @{
            name = $libraryGroupName
            projectReference = @{
                id = $projectRefId
                name = ""
            }
        }
    )
} | ConvertTo-Json -Depth 3 -Compress



# Write-Host "Debugging JSON payload before sending:" -ForegroundColor Cyan
# $body | ConvertFrom-Json | ConvertTo-Json -Depth 3 | Write-Host

# Step 6: Define the API URL for Creating a Key Vault Linked Library Group
$uri = "$orgUrl/$project/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"

# Step 7: Send the API Request to Create the Key Vault Variable Group
$response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

# Step 8: Output the Response
# $response | Select-Object id, name, createdBy

# Step9: Autherize the keyvault
# note: the Service Connection Object Id is NOT the id in Azure Devops.
#       rather it's the Object ID of the Service princile for the connection service
$ObjectId =  Get-ServiceConnectionObjectId -Organization $organization -Project $project -ServiceConnectionName $armServiceConnection.name
$kvInfo =  Add-KeyVaultRoleAssignment -KeyVaultName $keyVaultName -ObjectId $ObjectId | out-null




Write-Host "Setup complete!`nAzure Devops Library: $libraryGroupName `nKey Vault: $keyVaultName`nPasswordNames:`n`t$($secretNames -join "`n`t")" -ForegroundColor Cyan
