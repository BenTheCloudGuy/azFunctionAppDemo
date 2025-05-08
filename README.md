# azFunctionAppDemo
Deploying FunctionApp Demo assumes that ResourceGroup for Demo environment already exists and that below SPN has been setup and configured on GitHub and in Azure. In my example I'll be using cglabs-azfuncdemo. 


## Setup SPN on GitHub Secrets for Terraform Deployment. ## 

1. Login to Azure via CLI with Permissions needed to create Application Registrations (AppReg or SPN):
```bash
az login
```

2. Create SPN and assign it OWNER to our Target ResourceGroup. This is required since we are using Terraform to deploy resources and configure RBAC on those resources. 
```bash
azFuncDemoSPN=$(az ad sp create-for-rbac --name azFuncDemoSPN --role Owner --scopes /subscriptions/d79627b1-6f38-4296-92ae-6de3c9d881a4/resourceGroups/cglabs-azfuncdemo)
```

Example of output of azFuncDemoSPN:
```json
{
  "appId": "...",
  "displayName": "azFuncDemoSPN",
  "password": "...",
  "tenant": "..."
}
```

3. Extract Azure Variables from SPN:
```bash
# Extract values from azFuncDemoSPN and set environment variables
export AZURE_CLIENT_ID=$(echo $azFuncDemoSPN | jq -r '.appId')
export AZURE_TENANT_ID=$(echo $azFuncDemoSPN | jq -r '.tenant')
export AZURE_CLIENT_SECRET=$(echo $azFuncDemoSPN | jq -r '.password')
export AZURE_SUBSCRIPTION_ID=$(az account show | jq -r '.id') ## Pulls Subscription via AzCLI Context.
```

4. Create secrets for AZURE_CLIENT_ID, AZURE_TENANT_ID, and AZURE_SUBSCRIPTION_ID, AZURE_CLIENT_SECRET.Use these values from your Azure Active Directory application for your GitHub secrets: ($GITHUB_TOKEN requires additional permissions to manage secrets at the repo.)
```bash
# Create GitHub secrets
gh secret set AZURE_CLIENT_ID --body "$AZURE_CLIENT_ID"
gh secret set AZURE_TENANT_ID --body "$AZURE_TENANT_ID"
gh secret set AZURE_CLIENT_SECRET --body "$AZURE_CLIENT_SECRET"
gh secret set AZURE_SUBSCRIPTION_ID --body "$AZURE_SUBSCRIPTION_ID"
```

## Setup Terraform ## 

Create Terraform Environment