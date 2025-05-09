# azFunctionAppDemo
Deploying FunctionApp Demo assumes that ResourceGroup for Demo environment already exists and that below SPN has been setup and configured on GitHub and in Azure. In my example I'll be using Resource Group cglabs-azfuncdemo. 

>**NOTE**  
Typically you would want to create your Resource Group as part of the terraform deployment for that solution versus prestaging it. It isn't uncommon for a single platform or solution to be deployed across multiple Resource Groups. This is being done this way to emulate the way to satisfy this specific use case where another team prestages Resource Groups for downstream teams. 


## Setup Environment for Demo ##

### Setup SPN on GitHub Secrets for Terraform Deployment. ### 

1. Login to Azure via CLI with Permissions needed to create Application Registrations (AppReg or SPN):
```bash
AZURE_SUBSCRIPTION_ID='<subscription_id>'
RESOURCE_GROUP_NAME='<NAME_OF_RG>'
STORAGE_ACCOUNT_NAME='<NAME_OF_STORAGE_ACCOUNT_NAME>'
CONTAINER_NAME='tfstate'
AZURE_SPN_NAME='<NAME_OF_SPN>'

az login
```

2. Create SPN and assign it OWNER to our Target ResourceGroup. This is required since we are using Terraform to deploy resources and configure RBAC on those resources. 
```bash
azFuncDemoSPN=$(az ad sp create-for-rbac --name $AZURE_SPN_NAME --role Owner --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME --sdk-auth)
```

Example of output of azFuncDemoSPN:
```json
{ "clientId": "BLANKED", "clientSecret": "BLANKED", "subscriptionId": "BLANKED", "tenantId": "BLANKED", "activeDirectoryEndpointUrl": "https://login.microsoftonline.com", "resourceManagerEndpointUrl": "https://management.azure.com/", "activeDirectoryGraphResourceId": "https://graph.windows.net/", "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/", "galleryEndpointUrl": "https://gallery.azure.com/", "managementEndpointUrl": "https://management.core.windows.net/" }
```

3. Extract Azure Variables from SPN:
```bash
# Extract values from azFuncDemoSPN and set environment variables
export AZURE_CLIENT_ID=$(echo $azFuncDemoSPN | jq -r '.clientId')
export AZURE_TENANT_ID=$(echo $azFuncDemoSPN | jq -r '.tenantId')
export AZURE_OBJECT_ID=$(az ad sp show --id $AZURE_CLIENT_ID --query 'id' -o tsv)
export AZURE_SUBSCRIPTION_ID=$(az account show | jq -r '.id') ## Pulls Subscription via AzCLI Context.
```

4. Create secrets for AzureCLI Auth (Azure_CREDENTIALS):  
 ($GITHUB_TOKEN requires additional permissions to manage secrets at the repo via cli). Alternatively you can just create them in the GitHub Repo under Settings -> Secrets and Variables -> Actions. Then Repository Secrets. 
```bash
# Create GitHub secrets
gh secret set AZURE_CREDENTIALS --body "$azFuncDemoSPN"
```

>**NOTE**  
> To create App Registrations or Service Principal Names (SPNs) in Microsoft Entra (Azure Active Directory), you typically need one of the following roles:  
> - Application Administrator: Can create and manage all aspects of application registrations and enterprise applications.
> - Cloud Application Administrator: Can create and manage application registrations, but cannot manage conditional access policies.
> - Application Developer: Can create application registrations but cannot grant admin consent or manage other users' applications.  
>  
> Alternatively, the Global Administrator role has full permissions across Entra and can also perform these actions, but it is recommended to use the least privileged role necessary.  
>  
> Learn More: https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference

5. Prestage remote state file storage account: 
```bash
# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_ZRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Assign Storage Blob Data Contributor role to the SPN
az role assignment create \
  --assignee-object-id $AZURE_OBJECT_ID\
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"

```
> **! IMPORTANT**  
> For Production workloads your Terraform State File __**MUST**__ be stored in a redundant and secured locate. In this demo I'm using Azure Storage Account with  Standard_ZRS, but in a production workload I would either use Standad_GZRS or have a solution in place to replicate my statefile to another secure location as a backup. https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy  
**Storage Blob Data Contributor**: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/storage#storage-blob-data-contributor

### Terraform Setup ###

LINK: [TERRAFORM](infra/README.md)

### FunctionApp Demo ###

LINK: [FUNCTIONS](functions/README.md)

## Additional Notes ##

README files and Markdown documentation play a crucial role in GitHub and GitOps workflows by clearly communicating project purpose, setup instructions, and usage guidelines. They serve as the primary entry point for developers and operations teams, ensuring consistency, reproducibility, and ease of collaboration. Well-maintained Markdown documentation helps streamline onboarding, reduces errors during deployments, and supports automation by providing structured, easily accessible information directly within the repository.

> **NOTE**  
> Learn More about Markdown: https://gist.github.com/IEvangelist/c67adb2c40210bdb810103462a01a246
