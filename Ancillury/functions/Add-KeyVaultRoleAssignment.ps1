function Add-KeyVaultRoleAssignment {
    param(
        [string]$KeyVaultName,   # Name of the Key Vault
        [string]$ObjectId,    # Object ID of the Service Principal or Managed Identity
        [string]$Role = "Key Vault Secrets User"  # Default role
    )

    # Get the subscription ID
    $SubscriptionId = (Get-AzContext).Subscription.Id

    # Get the Key Vault Resource Group
    $KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction Stop
    $ResourceGroup = $KeyVault.ResourceGroupName

    # Define the scope (Key Vault)
    $Scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.KeyVault/vaults/$KeyVaultName"

    # Check if the role is already assigned
    $existingRole = Get-AzRoleAssignment -Scope $Scope | Where-Object { $_.ObjectId -eq $ObjectId -and $_.RoleDefinitionName -eq $Role }

    if ($existingRole) {
        Write-Host "Role '$Role' is already assigned to Principal ID '$ObjectId' on Key Vault '$KeyVaultName'." -ForegroundColor Yellow
    } else {
        # Assign the role
        New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $Role -Scope $Scope
        # Write-Host "Successfully assigned '$Role' to Principal ID '$ObjectId' on Key Vault '$KeyVaultName'." -ForegroundColor Green
    }
}

# Example Usage:
# Add-KeyVaultRoleAssignment -KeyVaultName "GentleCafe-KV" -ObjectId "027d03b4-1151-494f-8bb0-33462fdfa1c2"
