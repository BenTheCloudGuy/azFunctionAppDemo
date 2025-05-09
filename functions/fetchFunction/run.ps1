param($TriggerMetadata)

# Log the trigger metadata
Write-Verbose "Blob Triggered: $($TriggerMetadata.Name)"

# Parse the CSV content
$csvContent = Get-Content -Path $TriggerMetadata.Properties.OriginalFilePath | ConvertFrom-Csv
Write-Verbose "Parsed CSV Content: $($csvContent | Out-String)"

# Authenticate using the managed identity
$storageAccountName = $env:AzureWebJobsStorage
$archiveContainerName = $env:ArchiveContainerName
$blobName = $TriggerMetadata.Name

Write-Verbose "Authenticating with Managed Identity..."
$token = (Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https://storage.azure.com/' -Headers @{Metadata="true"}).access_token
$headers = @{Authorization = "Bearer $token"}

# Move the file to the archive container
Write-Verbose "Moving $blobName to archive container..."
Invoke-RestMethod -Uri "https://$storageAccountName.blob.core.windows.net/$env:BlobContainerName/$blobName?comp=copy&destination=$archiveContainerName/$blobName" -Headers $headers -Method Put
Write-Verbose "File moved successfully."
