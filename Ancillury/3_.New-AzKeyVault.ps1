param (
    $resourceGroupName,
    $location = "australia east",
    $Sku = "Standard",
    $tag = "Dev"
)


(ls C:\Users\line\git\bicep-powershell\functions).FullName |%{. $_ }


# Prompt user to log in
if (!(Get-AzContext)) {Connect-AzAccount}




# # Prompt user to select a subscription and set it
# $AzSubscriptionId =  Get-AzSubscriptionId
# Write-Host "Setting Az Subscription $AzSubscriptionId..." -NoNewline
# $subscription = Set-AzContext -SubscriptionId $AzSubscriptionId
# Write-Host " OK" -ForegroundColor Green


write-host "Invoking: 2_New-AzResourceGroup.ps1"
# Generate names
$keyVaultName = "$(Get-RandomName)-KV"

# Create Key Vault
Write-Host "Creating Key Vault: $keyVaultName in Resource Group $resourceGroupName..." -ForegroundColor Cyan -NoNewline
$azKeyVault = New-AzKeyVault -Name $keyVaultName -ResourceGroupName $resourceGroupName -Location $location -Sku $sku -Tag @{Environment=$Environment}
Write-Host "OK" -ForegroundColor Green
return $keyVaultName