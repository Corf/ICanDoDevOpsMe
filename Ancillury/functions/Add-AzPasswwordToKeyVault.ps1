function Add-AzPasswordToKeyVault {
    Param(
        $username,
        [SecureString]$Password,
        $Environment = $null,
        $keyVaultName
    )

    if ($Environment)
    {
        $Environment = $Environment + "-"
    }
    $name = Get-RandomName
    $secretUserName = $Environment + "$($name)-User"
    $secretPasswordName = $Environment + "$($name)-Password"

    $userSet = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretUserName -SecretValue $($username  | ConvertTo-SecureString -AsPlainText -Force)
    $passwordSet = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretPasswordName -SecretValue $Password


   return [PSCustomObject]@{
    secretUserName = $secretUserName
    secretPasswordName = $secretPasswordName
   }   
}