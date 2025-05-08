# Terraform Azure Workspace

This project is designed to deploy various Azure resources using Terraform. The resources include a User Defined Managed Identity, a Storage Account with a container, an App Service Plan, a Web Frontend (Python), a Function App (PowerShell), and SQL.

## Project Structure

- `main.tf`: Contains the main configuration for deploying the Azure resources.
- `vars.tf`: Defines the variables required for the Terraform configuration.
- `outputs.tf`: Specifies the outputs of the Terraform deployment.
- `providers.tf`: Configures the required providers for the Terraform project.
- `README.md`: Documentation for the project.

## Getting Started

### Prerequisites

- Ensure you have [Terraform](https://www.terraform.io/downloads.html) installed.
- An Azure account with the necessary permissions to create resources.

### Initialization

1. Navigate to the project directory:
   ```
   cd terraform-azure-workspace
   ```

2. Initialize the Terraform workspace:
   ```
   terraform init
   ```

### Applying the Configuration

To deploy the resources, run the following command:
```
terraform apply
```
Review the plan and type `yes` to confirm the deployment.

### Outputs

After the deployment is complete, Terraform will display the outputs defined in `outputs.tf`, which may include resource IDs and connection strings.

### Cleanup

To remove the deployed resources, run:
```
terraform destroy
```
Confirm the action by typing `yes`.

## Notes

- Ensure that you have configured your Azure credentials properly to allow Terraform to authenticate and create resources.
- Modify the `vars.tf` file to customize resource names and configurations as needed.