param($InputBlob, $TriggerMetadata)


if ($InputBlob) {
    # Log the trigger metadata
    Write-Verbose 'Testing $TriggerMetadata'
    Write-Verbose $TriggerMetadata
} else {
    Write-Error "InputBlob is null or empty."
}

if ($TriggerMetadata){ 
    # Log the trigger metadata
    Write-Verbose 'Testing $InputBlob'
    Write-Verbose $InputBlob
} else {
    Write-Error "TriggerMetadata is null or empty."
}

