param([byte[]] $InputBlob, $TriggerMetadata)

Write-Host "PowerShell Blob trigger: Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

# Log the trigger metadata
Write-Verbose "Blob Triggered: $($TriggerMetadata.Name)"

# Convert the byte array to a string (assuming the blob contains text data)
$blobContent = [System.Text.Encoding]::UTF8.GetString($InputBlob)

# Parse the CSV content
try {
    $csvContent = $blobContent | ConvertFrom-Csv
    Write-Verbose "Parsed CSV Content: $($csvContent | Out-String)"
} catch {
    Write-Error "Failed to parse CSV content: $_"
}

