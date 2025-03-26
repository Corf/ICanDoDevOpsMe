# load all the modules
ls  .\Ancillury\functions | %{. $_.fullname }


# our Variables for Azure DevOps
$userPrincipalName = 'bob@bob.net' # it's a me!
$organization = "BobsBigProject" # this is your Azure Devops Organisation
$project = "Bicep Example" # this is the Azure Devops Project
$SubscriptionId = "123123-122345-1236-8620-125623" # the subscription you want to use. It'll prompt you if you don't have it.


 # this is the Azure Devops Service connection name: rcorf/Bicep Example/Settings/Service connections.
 # The connection type is a "Azure Resource Manager" should you need to create one
$serviceConnectionName = "GenricServiceConnection"

# our varables for Azure Infrastructure
$location  = 'australia east' # for some reason "australia southeast" is not building sql service at this time :/


##### Start building the environment. ####

# Select Subscription
Write-host "Select subscription, if required."
. .\Ancillury\1_Set-AzSubscriptionContext.ps1 -SubscriptionId $SubscriptionId


Write-host "Creating Resource groups"
# Create 3 resource groups:
# 1 for the keyvault
# 2 for enviromnets dev and test
# Keyvault
$rgKeyVault = . .\Ancillury\2_New-AzResourceGroup.ps1 -location $location -Environment "KeyVault"
# dev
$rgDev = . .\Ancillury\2_New-AzResourceGroup.ps1 -location $location -Environment "Dev"
# test
$rgTest = . .\Ancillury\2_New-AzResourceGroup.ps1 -location $location -Environment "Test"

Write-host "Creating key vaults"
# now we need to create 2 keyvaults. one for dev and one for Test in the Key Vault resource group 
$kvDev = . .\Ancillury\3_.New-AzKeyVault.ps1 -resourceGroupName $rgKeyVault -location $location -Sku Standard -tag Dev
$kvTest =. .\Ancillury\3_.New-AzKeyVault.ps1 -resourceGroupName $rgKeyVault -location $location -Sku Standard -tag Test

Write-host "Add the rights"
# next we have to add outselves as custodians of both keyvaults
. .\Ancillury\4_Add-UserRoleToKeyVault.ps1 -userPrincipalName $userPrincipalName  -resourceGroupName $rgKeyVault -keyVaultName $kvDev
. .\Ancillury\4_Add-UserRoleToKeyVault.ps1 -userPrincipalName $userPrincipalName  -resourceGroupName $rgKeyVault -keyVaultName $kvTest


Write-host "Note: As the 'cloud Pixies' have to run around a bit to apply rights they don't get applied very quickly, `r`n Best just to wait a moment or two before trying the next step of adding passwords." -ForegroundColor Yellow
Pause
Write-host "Adding Password to keyvalut."
# have to add the sql admin user password secret to the keyvaults
. .\Ancillury\5_Add-AzPasswordToKeyvault.ps1 -secretname sqlAdminPassword -keyVaultName $kvDev
. .\Ancillury\5_Add-AzPasswordToKeyvault.ps1 -secretname sqlAdminPassword -keyVaultName $kvTest


Write-host "Set the rights to Azure devops Service containing account"
# we have to give our DevOps account access to the keyvaults, otherwise we get odd errors.
. .\Ancillury\6_set-KeyVaultDevOpsserviceConnectionRights.ps1 -keyVaultName $kvDev -organization $organization -project $project -serviceConnectionName $serviceConnectionName -role "Key Vault Secrets User"
. .\Ancillury\6_set-KeyVaultDevOpsserviceConnectionRights.ps1 -keyVaultName $kvTest -organization $organization -project $project -serviceConnectionName $serviceConnectionName -role "Key Vault Secrets User"

Write-host "Note: Ok, so we're gonna pause here again.`nHave you removed the orginal library groups?`nWell you should." -ForegroundColor Yellow
Pause
Write-host "Create the secure library groups"

Write-host "Create library groups for environments"
# ok. Next is the variables for each environment. This will create 2 library groups. One for Dev and one for test
# Look insid this script for the varables I've used.
# yes, I should have pulled them out and passed them through. But at this point I'm just happy it's working
. .\Ancillury\7_new-AzDevOpsLibraryGroup.ps1 -devResourceGroup $rgDev -testResourceGroup $rgTest -location $location -serviceConnectionName $serviceConnectionName -organization $organization -project $project
# if you want to change or add more variables, go into the script. It's hash tables and a wizzy function. change the hash tables as required. 




# finally we need to add secure library groups connected to out keyvaults. One for dev on for Test
. .\Ancillury\8_new-AzDevOpsLibraryGroupFromKeyVault.ps1 -keyVaultName $kvDev -libraryGroupName secrets-dev -organization $organization -project $project -serviceConnectionName $serviceConnectionName
. .\Ancillury\8_new-AzDevOpsLibraryGroupFromKeyVault.ps1 -keyVaultName $kvTest -libraryGroupName secrets-test -organization $organization -project $project -serviceConnectionName $serviceConnectionName

Write-host "You're Environment `"should`" be OK to go now. 🤞"

# remove the resource groups
# $jobs  = Get-AzResourceGroup | ?{$_.ResourceGroupName -match '-RG'}| %{$_ | Remove-AzResourceGroup -Force -AsJob}