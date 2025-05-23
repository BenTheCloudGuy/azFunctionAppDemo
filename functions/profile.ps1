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

# filepath: /workspaces/azFunctionAppDemo/functions/profile.ps1

try {
    # Disable context autosave and authenticate using MSI
    Disable-AzContextAutosave -Scope Process | Out-Null
    if ($env:MSI_SECRET) {
        Connect-AzAccount -Identity -ErrorAction SilentlyContinue
    }
} catch {
    Write-Error "Failed to load Az module or authenticate: $_"
}


# You can also define functions or aliases that can be referenced in any of your PowerShell functions.