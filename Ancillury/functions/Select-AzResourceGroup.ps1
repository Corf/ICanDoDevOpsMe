function Select-AzResourceGroup {
    <#
    .SYNOPSIS
    This function lists all available Azure Resource Groups and allows the user to select one by entering a number.

    .DESCRIPTION
    The function retrieves all Azure Resource Groups using Get-AzResourceGroup, displays them in a numbered list,
    and prompts the user to select one by entering the corresponding number. The selected resource group name is returned.

    .PARAMETER None
    This function does not take any parameters.

    .OUTPUTS
    String - The name of the selected Azure Resource Group.

    .EXAMPLE
    $selectedRG = Select-AzResourceGroup
    if ($selectedRG) {
        Write-Host "You selected: $selectedRG" -ForegroundColor Green
    }

    This example calls the function, allows the user to select a resource group, and stores the selected name in $selectedRG.

    .NOTES
    Author: ChatGPT
    Requires: Az PowerShell module
    #>

    # Get all resource groups
    $resourceGroups = Get-AzResourceGroup | Select-Object -ExpandProperty ResourceGroupName

    if (-not $resourceGroups) {
        Write-Host "No resource groups found." -ForegroundColor Red
        return $null
    }

    # Display a numbered list of resource groups
    Write-Host "`nAvailable Resource Groups:`n"
    for ($i = 0; $i -lt $resourceGroups.Count; $i++) {
        Write-Host "$($i + 1): $($resourceGroups[$i])"
    }

    # Prompt user for selection
    do {
        $selection = Read-Host "`nEnter the number of the Resource Group you want to select"
        $valid = ($selection -match "^\d+$") -and ([int]$selection -ge 1) -and ([int]$selection -le $resourceGroups.Count)
        if (-not $valid) {
            Write-Host "Invalid selection. Please enter a valid number from the list." -ForegroundColor Yellow
        }
    } while (-not $valid)

    # Convert selection to zero-based index and get the resource group name
    $selectedGroup = $resourceGroups[[int]$selection - 1]
    
    return $selectedGroup
}

