function Get-ServiceConnectionObjectId {
    param(
        [string]$Organization,  # Azure DevOps Organization Name
        [string]$Project,       # Azure DevOps Project Name
        [string]$ServiceConnectionName  # Service Connection Name
    )

    # Get Azure DevOps Access Token
    $secureToken = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" -AsSecureString).Token
    $token = [System.Net.NetworkCredential]::new("", $secureToken).Password

    # Define API Headers
    $headers = @{
        Authorization = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # API URL to list all service connections in the project
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"

    try {
        # Get all service connections
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

        # Find the service connection by name
        $serviceConnection = $response.value | Where-Object { $_.name -eq $ServiceConnectionName }

        if ($serviceConnection) {
            $servicePrincipalId = $serviceConnection.authorization.parameters.serviceprincipalid

            if ($servicePrincipalId) {
                # Now lookup the Azure AD Object ID from the Service Principal ID
                $servicePrincipal = Get-AzADServicePrincipal -Filter "appId eq '$servicePrincipalId'"

                if ($servicePrincipal) {
                    # Write-Host "Azure AD Object ID for '$ServiceConnectionName': $($servicePrincipal.Id)" -ForegroundColor Green
                    return $servicePrincipal.Id  # Return the Object ID
                } else {
                    Write-Host "Service Principal found, but no Object ID retrieved!" -ForegroundColor Yellow
                    return $null
                }
            } else {
                Write-Host "No Service Principal ID found. This might be using Workload Identity Federation (OIDC) instead of a Service Principal." -ForegroundColor Yellow
                return $null
            }
        } else {
            Write-Host "Service Connection '$ServiceConnectionName' not found!" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "Error retrieving service connections: $_" -ForegroundColor Red
        return $null
    }
}

# # Example Usage:
# $organization = "rcorf"
# $project = "Bicep Example"
# $serviceConnectionName = "GenricServiceConnection"

# $objectId = Get-ServiceConnectionObjectId -Organization $organization -Project $project -ServiceConnectionName $serviceConnectionName

