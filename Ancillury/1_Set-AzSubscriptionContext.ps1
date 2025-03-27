param (
    $SubscriptionId
)
# Prompt user to log in if required
Write-host "Invoking: 1_Set-AzSubscriptionContext.ps1"
if (!( (Get-AzContext -ErrorAction SilentlyContinue).Subscription.Id -eq $SubscriptionId) -or $null -eq (Get-AzContext -ErrorAction SilentlyContinue)) {

    # Prompt user to select a subscription and set it
    $AzSubscriptionId = Get-AzSubscriptionId
    Write-Host "Setting Az Subscription $AzSubscriptionId..." -NoNewline
    $subscription = Set-AzContext -SubscriptionId $AzSubscriptionId
    Write-Host " OK" -ForegroundColor Green
}
