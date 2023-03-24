# 01_Infrastructure

## Terraform - Infrastructure as Code

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (used for interacting with Azure)
- [(Google) Cloud SDK](https://cloud.google.com/sdk/docs/install) (tools SDK for interacting with Google Cloud Platform)

### Remote State

Terraform best practice is to use a remote state. For such a small project scope, and being intended only for testing, a local Terraform state file would be easier.

My configuration uses Azure Blob Storage as the location to save Terraform state. As long as the state Blob Storage is not maintained within the same Terraform configuration being deployed, no amount of Terraform plan / apply or other Terraform-originating changes will corrupt or invalidate the state file. The last thing I want is to make a change, and accidentally destroy our Terraform state but not our resources...

### Proving the Design

I used my knowledge of Azure to prove that this architecture is suitable. Although the intention of this problem space is to make our sender function call a receiver function in a different cloud provider, we can test out the code deployed to Azure by first referencing the `receiver` Azure Function directly from the `sender` Azure Function. 

I achieved this by using Terraform's resource referencing directly within the `azurerm_linux_function_app`'s `app_settings` map. Doing so reduces number of deployment steps up to now -- I run `terraform plan` and `terraform apply`, then deploy the code, then test.

```terraform
# terraform/az_deps.tf (line 29 - azurerm_linux_function_app.sender)
app_settings = {
    "RECEIVERADDR" = "https://${azurerm_linux_function_app.receiver[0].default_hostname}/api/receiver?code=${data.azurerm__function_app_host_keys.receiver[0].default_function_key}"
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
}
```

When I am ready to venture into the world of GCP, I can simply create those resources, then change the `azurerm_linux_function_app`'s `app_settings` map to reference GCP's `receiver` Cloud Function. The code reusability _should_ mean that functionality works the same regardless of cloud provider.

### Deploying Terraform

Terraform Init (configure backend - avoid pushing secrets to git)
Terraform Validate - validate configuration. great for CI, but not foolproof
Terraform Plan - the dry run, good to check out the resulting plan
Terraform Apply - make infrastructure changes. performs a dry run with prompt to continue. not useful for CI, until setting --auto-approve

## Azure Infrastructure

Function Apps and App Service resources are run on an App Service Plan (a managed server running a container instance). Many apps can be deployed to the same Plan, using the same pool of assigned resource (memory, CPU etc.). It is important to be mindful about the service reuqirements when choosing to use a Function App or App Service, and the tier in which it is run.

As the services making use of Serverless Architecture are designed to be cost effective and distributed, it is not uncommon to find that most infrastructure can be run ad-hoc, or only when required. Azure enables you to specify a "Consumption Plan" or "Dynamic" tier for an App Serivce Plan, which make the container and deployed applications go "cold" or almost effectively stop running, until called by a dependency. The nature of dynamically executing functions comes with a tradeoff, where requests take longer if the service is not already running. This is suitable for behind-the-scenes tasks, but maybe not for front-end interfaces that must be responsive all the time.

For the purpose of this problem space, cost is a major factor, so Consumption plan is the way to go, and the function can only run when called, so costs will always be low. Function Apps also require an underlying storage account (effectively a hard drive) to manage function state. This is used by some triggers to track work that has been done. For example, triggering on a new file being uploaded to a Blob Storage Account will produce a receipt, to prevent the function from attempting to read the file again.

## Google Cloud Infrastructure

Now this is a learning experience. I have to figure out how to set up a workspace to deploy my infrastructure to, and identify the correct configurations to be cost effective and fit-for-purpose.

Regardless of deploying Azure only, setting up Terraform requires the following commands:

```
gcloud init
gcloud auth application-default login
```