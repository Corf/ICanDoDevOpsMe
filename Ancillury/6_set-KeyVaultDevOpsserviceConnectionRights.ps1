param (
    $keyVaultName,
    $organization = "rcorf",
    $project = "Bicep Example",
    $serviceConnectionName =  "GenricServiceConnection",
    $role = "Key Vault Secrets User"
)

Write-Host "Invoking: 6_set-KeyVaultDevOpsserviceConnectionRights.ps1"
# set Get, List secret management for the devops service that were using "Key Vault Secrets User" role
# $organization = "rcorf"
# $project = "Bicep Example"
$orgUrl = "https://dev.azure.com/$organization"
# $serviceConnectionName =  "GenricServiceConnection"


# note:  For Azure DevOps, the ResourceUrl is 499b84ac-1321-427f-aa17-267ca6975798, which is the well-known Azure AD application ID for DevOps.
$secureToken = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" -AsSecureString).Token
# Convert SecureString to plain text for use in the API call
$token = [System.Net.NetworkCredential]::new("", $secureToken).Password
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
Write-Host "Setting DevOps Service connection $serviceConnectionName's role..." -ForegroundColor Cyan -NoNewline
$response = Invoke-RestMethod -Uri $serviceEndpointUri -Method Get -Headers $headers
$armServiceConnection = $response.value | Where-Object { $_.type -eq "azurerm" -and $_.name -eq $serviceConnectionName } 
$serviceEndpointId = $armServiceConnection.id  # Extract the ID correctly


$ObjectId =  Get-ServiceConnectionObjectId -Organization $organization -Project $project -ServiceConnectionName $armServiceConnection.name
Add-KeyVaultRoleAssignment -KeyVaultName $keyVaultName -ObjectId $ObjectId -Role $role |out-null
Write-Host "OK... If theres no red." -ForegroundColor green