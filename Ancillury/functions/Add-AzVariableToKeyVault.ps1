function Add-AzVariableToKeyVault {
    Param(
        $variableName,
        $variableValue,
        $Environment = $null,
        $keyVaultName
    )

    if ($Environment)
    {
        $Environment = $Environment + "-"
    }
    
    $secretVariableName = $Environment + "$variableName"

    $variableSet = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretVariableName -SecretValue $($variableValue  | ConvertTo-SecureString -AsPlainText -Force)


   return [PSCustomObject]@{
    secretVariableName = $secretVariableName
   }   

}