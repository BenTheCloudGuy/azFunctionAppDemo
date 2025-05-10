param($blobObject)

# Log the trigger metadata
Write-Verbose "Blob Triggered: $($blobObject.Name)"

# Parse the CSV content
$csvContent = Get-Content -Path $blobObject.Properties.OriginalFilePath | ConvertFrom-Csv
Write-Verbose "Parsed CSV Content: $($csvContent | Out-String)"

# Authenticate using the managed identity
$storageAccountName = $env:AzureWebJobsStorage
$archiveContainerName = $env:ArchiveContainerName
$blobName = $blobObject.Name

Write-Verbose "Authenticating with Managed Identity..."
$token = (Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https://storage.azure.com/' -Headers @{Metadata="true"}).access_token
$headers = @{Authorization = "Bearer $token"}

