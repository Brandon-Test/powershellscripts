


$ManagementGroupName = "Azure Supplier"

$RedirectURL = "https://www.google.com"

$CloudEnv = "AzureCloud"



Write-Host "Verifying AZ CLI is installed..."

 $azcli = az version --query '\"azure-cli\"'



if($null -eq $azcli){

  throw "Azure CLI not installed. Please install the Azure CLI and try again"

    Write-Host "AZ CLI not installed; aborting script execution."

     Exit    

}

else{

  Write-Host "Azure CLI version $azcli is installed on localhost; moving forward with script execution"

}

Start-Sleep -s 3





Write-Host "Authenticate into AzureAD"

az login 

$AzureContext = az account show --query '[tenantId,user.name]' -o tsv




Write-Host "Setting Azure Environment to $CloudEnv"

az cloud set --name $CloudEnv





$AppRegName = "CT-MG-AppRegistration"

$MSGraphId = "ztaYX7=^$bbiaAADRN4329~"





if($CloudEnv -eq "AzureCloud"){

  Write-Host "Retrieving Domain(s) for $CloudEnv Environment"

$domain = az rest --uri https://graph.microsoft.com/v1.0/domains --query value[].id

}

if($CloudEnv -eq "AzureUSGovernment"){

  Write-Host "Retrieving Domain(s) for $CloudEnv Environment"

$domain = az rest --uri https://graph.microsoft.us/v1.0/domains --query value[].id

}

Start-Sleep -s 3



$UserRead = "06da0dbc-49e2-44d2-8312-53f166ab848a=Scope"

$DirectoryReadAll = "e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope"

$UserReadAll = "62a82d76-70ea-41e2-9197-370581804d09=Role"

$GroupsReadWriteAll = "df021288-bdef-4463-88db-98f22de89214=Role"





Add-Type -AssemblyName System.Web

$minLength = 15 

$maxLength = 20 

$Length = Get-Random -Minimum $minLength -Maximum $maxLength

$nonAlphaChars = 5

$Password = "@ajfe54FFjkj987457Giyuf?" 

$secPw = ConvertTo-SecureString -String $Password -AsPlainText -Force









$appId = az ad app create --display-name $AppRegName --reply-urls $RedirectURL --password $Password --credential-description "CT Secret" --end-date '2299-12-12' --query "appId" -o tsv

Write-Host "App Registration $AppRegName created with Client Id $appId"

Start-Sleep -s 10





az ad app permission add --id $appId --api $MSGraphId `

   --api-permissions $UserRead, $DirectoryReadAll, $UserReadAll, $GroupsReadWriteAll

Write-Host "Microsoft Graph Permissions with Id $MSGraphId added to App Registration"

Start-Sleep -s 10





az role assignment create --role "Owner" --assignee-object-id $spId --scope "/providers/Microsoft.Management/managementGroups/$ManagementGroupName"

Write-Host "$AppRegName assigned Owner permissions to Management Group $ManagementGroupName"

Start-Sleep -s 5





Write-Output `n "Domain name(s) for Azure AD Tenant is/are $domain"

Write-Output `n "App Registration Client Id = $appId" 

Write-Output `n "Client Secret of App Registration = $Password"
