# Sample Functions #


## fetchFunction ##

This FunctionApp triggers when a new blob object is dropped in containers ```filedrop``` on the storage account defined in ```AzureWebJobsStorage``` and copy the CSV data to backend Azure SQL DB. The FunctionApp is configured with User-Defined Managed Identity configured in the Terraform Deployment using var: "managed_identity_name" . 


functions.json
```json
{
  "bindings": [
    {
      "name": "blobObject",
      "type": "blobTrigger",
      "direction": "in",
      "path": "filedrop/{name}",
      "connection": "AzureWebJobsStorage"
    }
  ]
}
```

|function property|	Description                                                         |
|-----------------|---------------------------------------------------------------------|                                                                                     
| type	          | Must be set to blobTrigger.|
| direction	      | This property is set automatically when you create the trigger in the Azure portal. Must be set to in. |
| name            | The name of the variable that represents the blob in function code. |
| path	          | The container to monitor. ```{name}``` references the above name variable. |
| connection	  | The name of an app setting that specifies how to connect to Azure Blobs.|


### Grant permission to the identity ###

Whatever identity is being used must have permissions to perform the intended actions. For most Azure services, this means you need to assign a role in Azure RBAC, using either built-in or custom roles which provide those permissions. For our BlobTrigger Example we will need to configure terraform to give our User-Defined Managed Identity the following Built-In Roles:

- Storage Blob Data Owner
- Storage Queue Data Contributor
- Storage Account Contributor roles

> **! Important**  
> Some permissions might be exposed by the target service that are not necessary for all contexts. Where possible, adhere to the principle of least privilege, granting the identity only required privileges. For example, if the app only needs to be able to read from a data source, use a role that only has permission to read. It would be inappropriate to assign a role that also allows writing to that service, as this would be excessive permission for a read operation. Similarly, you would want to ensure the role assignment is scoped only over the resources that need to be read.

You need to create a role assignment that provides access to your blob container at runtime. Management roles like ```Owner``` aren't sufficient. The following table shows built-in roles that are recommended when using the Blob Storage extension in normal operation. Your application may require further permissions based on the code you write.

|Binding type | Example built-in roles| 
|---|---|
| Trigger | Storage Blob Data Owner and Storage Queue Data Contributor. Extra permissions must also be granted to the AzureWebJobsStorage connection. |
| Input binding	| Storage Blob Data Reader |
| Output binding | Storage Blob Data Owner |

1. The blob trigger handles failure across multiple retries by writing poison blobs to a queue on the storage account specified by the connection.

2. The AzureWebJobsStorage connection is used internally for blobs and queues that enable the trigger. If it's configured to use an identity-based connection, it needs extra permissions beyond the default requirement. The required permissions are covered by the Storage Blob Data Owner, Storage Queue Data Contributor, and Storage Account Contributor roles. To learn more, see Connecting to host storage with an identity.



### Microsoft.Storage.BlobCreated event ###

EventGrid returns this payload to Fucntion. 

```json
[{
  "source": "/subscriptions/{subscription-id}/resourceGroups/Storage/providers/Microsoft.Storage/storageAccounts/my-storage-account",
  "subject": "/blobServices/default/containers/test-container/blobs/new-file.txt",
  "type": "Microsoft.Storage.BlobCreated",
  "time": "2017-06-26T18:41:00.9584103Z",
  "id": "831e1650-001e-001b-66ab-eeb76e069631",
  "data": {
    "api": "PutBlockList",
    "clientRequestId": "6d79dbfb-0e37-4fc4-981f-442c9ca65760",
    "requestId": "831e1650-001e-001b-66ab-eeb76e000000",
    "eTag": "0x8D4BCC2E4835CD0",
    "contentType": "text/plain",
    "contentLength": 524288,
    "blobType": "BlockBlob",
    "accessTier": "Default",
    "url": "https://my-storage-account.blob.core.windows.net/testcontainer/new-file.txt",
    "sequencer": "00000000000004420000000000028963",
    "storageDiagnostics": {
      "batchId": "b68529f3-68cd-4744-baa4-3c0498ec19f0"
    }
  },
  "specversion": "1.0"
}]
```