param([byte[]] $InputBlob, $TriggerMetadata)

# Authenticate using the managed identity
$storageAccountName = $AzureWebJobsStorage__accountName
$archiveContainerName = $archive_container_name
$blobName = $TriggerMetadata.Name

# Log the trigger metadata
Write-Verbose "Blob Triggered: $blobName"

# Convert the byte array to a string (assuming the blob contains text data)
$blobContent = [System.Text.Encoding]::UTF8.GetString($InputBlob)

# Parse the CSV content
try {
    $csvContent = $blobContent | ConvertFrom-Csv
    Write-Verbose "Parsed CSV Content: $($csvContent | Out-String)"
} catch {
    Write-Error "Failed to parse CSV content: $_"
}

Write-Host "PowerShell Blob trigger: Name: $blobName Size: $($InputBlob.Length) bytes"

# TESTING
if ($MSI_SECRET) {
    Write-Verbose "Authenticating with Azure PowerShell using MSI."
} else {
    Write-Verbose "No MSI secret found. Skipping authentication."
}