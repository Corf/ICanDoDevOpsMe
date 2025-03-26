param (
    $secretname = "sqlAdminPassword",
    $keyVaultName
)



write-host "Invoking: 5_Add-AzPasswordToKeyvault.ps1"
# Generate a random password
$randomPassword = Get-RandomPassword
$securePassword = ConvertTo-SecureString $randomPassword -AsPlainText -Force

# Store the password in Key Vault
$secretname = "sqlAdminPassword" # "$(Get-RandomName)-PW"
Write-Host "Storing $secretname in Key Vault $keyVaultName..." -ForegroundColor Green -NoNewline
sleep -Seconds 5
$passwordSet = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretname -SecretValue $securePassword
Write-Host "OK" -ForegroundColor Green