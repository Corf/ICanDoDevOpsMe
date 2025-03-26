param (
    $location = "australia east",
    $Environment = "Dev"
)

Write-host "Invoking: 2_New-AzResourceGroup.ps1"
# load functions
# ls .\functions | %{. $_.FullName}



# Generate name for Resource Group
$resourceGroupName = "$(Get-RandomName)-RG"

# Create resource group
Write-Host "Creating Resource Group: $resourceGroupName..." -ForegroundColor Cyan -NoNewline
$resourceGroup =  New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{Environment=$Environment}
Write-Host "OK" -ForegroundColor Green
return $resourceGroupName