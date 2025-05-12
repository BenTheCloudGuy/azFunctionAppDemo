# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

<#   ### Authenticate with Azure PowerShell using MSI. ###

This will authenticate as the System Managed Identity by default on any Function Running under this FunctionApp
Override this per function by Logging out and re-connecting using User Managed Identity in the Body of each Function that Requires it.
This SMI is configured as a Global Reader to the CGLABS Tenant and GET/LIST to CGLABS-AUTOMATION-KV (KeyVault) where Automation Secrets/Certs/Keys will be stored

#>
if ($env:MSI_SECRET) {
    Disable-AzContextAutosave -Scope Process | Out-Null
    Connect-AzAccount -Identity -ErrorAction SilentlyContinue
}



# Uncomment the next line to enable legacy AzureRm alias in Azure PowerShell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.