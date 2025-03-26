function New-AzDevOpsLibraryGroup {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$variables,

        [Parameter(Mandatory = $true)]
        [string]$libraryGroupName,

        [Parameter(Mandatory = $true)]
        [string]$organization,

        [Parameter(Mandatory = $true)]
        [string]$project
    )

    # Define the Azure DevOps REST API URL
    $orgUrl = "https://dev.azure.com/$organization"
    $uri = "$orgUrl/$project/_apis/distributedtask/variablegroups?api-version=6.0-preview.2"

    $secureToken = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798" -AsSecureString).Token
    # Convert SecureString to plain text for use in the API call
    $token = [System.Net.NetworkCredential]::new("", $secureToken).Password
    # Set API Headers
    $headers = @{
        Authorization  = "Bearer $token"
        "Content-Type" = "application/json"
    }

    # Build the full request body
    $projectRefId = (Invoke-RestMethod -Uri "$orgUrl/_apis/projects/$project" -Headers $headers -Method Get).id


    $existingGroups = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $existingGroup = $existingGroups.value | Where-Object { $_.name -eq $libraryGroupName }

    # Convert the hashtable of variables to JSON format
    # $variableJson = @{}
    # foreach ($key in $variables.Keys) {
    #     $variableJson[$key] = @{ value = $variables[$key] }
    # }

    $body = @{
        name      = $libraryGroupName
        type = "Vsts"
        description = "Created via PowerShell"
        variables = $variables
        variableGroupProjectReferences = @(@{ 
            name = $libraryGroupName
            projectReference = @{
                id = $projectRefId
                name = $project
            }
        })
    } | ConvertTo-Json -Depth 10

    if ($existingGroup) {
        # Update existing variable group
        $updateUri = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups/$($existingGroup.id)?api-version=6.0-preview.2"
        Write-Host "Updating existing variable group '$libraryGroupName'..."
        Invoke-RestMethod -Uri $updateUri -Headers $headers -Method Put -Body $body
    } else {
        # Create new variable group
        Write-Host "Creating new variable group '$libraryGroupName'..."
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body
    }

    Write-Host "Variable Group '$libraryGroupName' updated successfully!"
}
