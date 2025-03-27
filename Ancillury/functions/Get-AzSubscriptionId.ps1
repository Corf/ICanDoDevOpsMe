function Get-AzSubscriptionId {
    param ()

    try {
        $subscriptions = Get-AzSubscription -ErrorAction SilentlyContinue | Select-Object Name, Id
    }
    Catch {
        if (! $subscriptions) {
            Connect-AzAccount  | Out-Null
        }
    }
    $subscriptions = Get-AzSubscription | Select-Object Name, Id
    
    Write-Host "Available Subscriptions:" -ForegroundColor Cyan
    $i = 1
    $subscriptions | ForEach-Object { Write-Host "$i) $($_.Name) - $($_.Id)" ; $i++ }
    # Prompt user to select a subscription

    $subscriptionCount = ($subscriptions | measure).count

    $select = Read-Host -Prompt "Enter Subuscription No."
    while (1..$subscriptionCount -notcontains $select) {
        write-host "please enter valid subscrition number."
        $select = Read-Host -Prompt "Enter Subuscription No."
    }
     
    return $subscriptions[($select - 1)].id

}
