function New-AzDevOpsServiceConnection {
    param(
        [string]$Organization,   # Azure DevOps Organization Name
        [string]$Project,        # Azure DevOps Project Name
        [string]$ServiceConnectionName,  # Name for the new Service Connection
        [string]$SubscriptionId,  # Azure Subscription ID
        [string]$SubscriptionName, # Azure Subscription Name
        [string]$TenantId,       # Azure AD Tenant ID
        [string]$ResourceGroup,  # Resource Group Scope (optional)
        [string]$Description = "Created via PowerShell"
    )

    # Get Azure DevOps Access Token
    $secureToken = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" -AsSecureString).Token
    $token = [System.Net.NetworkCredential]::new("", $secureToken).Password

    # Define API Headers
    $headers = @{
        Authorization = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Define the API URL for creating a new service connection
    $projectUri = "https://dev.azure.com/$Organization/_apis/projects/$Project"# ?api-version=7.1-preview.4"
    $projectResponse = Invoke-RestMethod -Uri $projectUri -Headers $headers -Method Get
    $ProjectId = $projectResponse.id
    

    # Get Project ID (If needed)
    #$projectResponse = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    #$ProjectId = $projectResponse.value.id

    # Construct the JSON body
    $body = @{
        name = $ServiceConnectionName
        type = "azurerm"
        url = "https://management.azure.com/"
        owner = "library"
        description = $Description
        authorization = @{
            parameters = @{
                tenantid = $TenantId
                scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup"
            }
            scheme = "WorkloadIdentityFederation"
        }
        data = @{
            environment = "AzureCloud"
            scopeLevel = "Subscription"
            subscriptionId = $SubscriptionId
            subscriptionName = $SubscriptionName
            resourceGroupName = $ResourceGroup
            creationMode = "Automatic"
            identityType = "AppRegistrationAutomatic"
        }
        serviceEndpointProjectReferences = @(
            @{
                name = $ServiceConnectionName
                description = $Description
                projectReference = @{
                    id = $ProjectId
                    name = $Project
                }
            }
        )
    } | ConvertTo-Json -Depth 5 -Compress

    # Create the Service Connection
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body
        Write-Host "Successfully created Service Connection: $ServiceConnectionName" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "Error creating Service Connection: $_" -ForegroundColor Red
        return $null
    }
}

# # Example Usage
# New-AzDevOpsServiceConnection `
#     -Organization "rcorf" `
#     -Project "Bicep Example" `
#     -ServiceConnectionName "NewAzureServiceConnection2" `
#     -SubscriptionId (Get-azsubscription).id `
#     -SubscriptionName "Microsoft Partner Network" `
#     -TenantId (Get-AzTenant).id `
#     -ResourceGroup "LegendaryBridge-RG"
