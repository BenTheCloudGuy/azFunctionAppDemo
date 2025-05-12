param([byte[]] $InputBlob, $TriggerMetadata)

# Authenticate using the managed identity
$storageAccountName = $env:AzureWebJobsStorage__accountName
$archiveContainerName = $env:archive_container_name
$blobName = $InputBlob.Name

# Log the trigger metadata
Write-Verbose "Blob Triggered: $($blobObject.Name)"

# Parse the CSV content
$csvContent = Get-Content -Path $blobObject.Properties.OriginalFilePath | ConvertFrom-Csv
Write-Verbose "Parsed CSV Content: $($csvContent | Out-String)"

Write-Host "PowerShell Blob trigger: Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"
