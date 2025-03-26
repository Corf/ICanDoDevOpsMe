param (
    $userPrincipalName,
    $resourceGroupName,
    $keyVaultName,
    $role = "Key Vault Secrets Officer"

)


write-host "Invoking: 4_Add-UserRoleToKeyVault.ps1"
# # Prompt user to select a subscription and set it
# $AzSubscriptionId =  Get-AzSubscriptionId
# Write-Host "Setting Az Subscription $AzSubscriptionId..." -NoNewline
# $subscription = Set-AzContext -SubscriptionId $AzSubscriptionId
# Write-Host " OK" -ForegroundColor Green
$subscriptionId =  (Get-AzContext).Subscription.id


# Assign user as Key Vault Secrets Officer
#$userPrincipalName = "rcorf@nibbleandbyte.net"
$userObjectId = (Get-AzADUser -UserPrincipalName $userPrincipalName).Id
Write-Host "Assigning $role role to:" -NoNewline
Write-Host "$userPrincipalName..." -ForegroundColor Yellow -NoNewline
$azRole =  New-AzRoleAssignment -ObjectId $userObjectId -RoleDefinitionName $role -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"

# check role assignmant
$roleCheck = Get-AzRoleAssignment -ObjectId $userObjectId -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
$i= 0
while ($roleCheck.RoleDefinitionName -notcontains "Key Vault Secrets Officer")
{
    if($i -gt 5)
    {
        Write-Error "Role 'Key Vault Secrets Officer' not added to KeyVault: $subscriptionId"
        return # continue
    }
    $roleCheck = Get-AzRoleAssignment -ObjectId $userObjectId -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.KeyVault/vaults/$keyVaultName"
    sleep -Seconds 3
    $i++
}
Write-Host "OK" -ForegroundColor green