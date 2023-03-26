# 01_Infrastructure

## Terraform - Infrastructure as Code

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (used for interacting with Azure)
- [(Google) Cloud SDK](https://cloud.google.com/sdk/docs/install) (tools SDK for interacting with Google Cloud Platform)

### Remote State

Terraform best practice is to use a remote state. For such a small project scope, and being intended only for testing, a local Terraform state file would be easier.

My configuration should use Azure Blob Storage as the location to save Terraform state. As long as the state Blob Storage is not maintained within the same Terraform configuration being deployed, no amount of Terraform plan / apply or other Terraform-originating changes will corrupt or invalidate the state file. The last thing I want is to accidentally destroy our Terraform state but not our resources...

### Sensitive Information

Functions will have domain names, and someone on a different continent may wish to test this project. To account for that, I need to ensure that there can be some uniqueness in naming conventions. As a result, one file must be populated and named correctly...

GCP also requires the unique ID of the project which will contain the resources. This value is likely not something that should be exposed in a public repository.

Values in `terraform/vars/secrets.tfvars.example` should be populated correctly, then renamed to `secrets.tfvars`. This file can then be referenced in terraform commands to populate the outstanding values: 

```
terraform plan -var-file="vars/secrets.tfvars" -var-file="vars/az_only.tfvars"
```

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

### Retrieving Receiver's Function Key

I have noticed that (on 24/03/2023) Function App keys can take a while to appear on Azure Portal. The first successful, complete deployment spent ~5 minutes waiting for a successful response from Azure Resource Manager to populate the Terraform `azurerm_function_app_host_keys` resource. Subsequent creations then failed to retrieve a key, and the key did not appear in Azure after an hour, leaving Terraform state in a bad state.

## Google Cloud Infrastructure

Now this is a learning experience. I have to figure out how to set up a workspace to deploy my infrastructure to, and identify the correct configurations to be cost effective and fit-for-purpose.

Regardless of deploying Azure only, setting up Terraform requires the following commands:

```
gcloud init
gcloud auth application-default login
```

### Receiver Function Deployment with Terraform

I experienced issues deploying the first function to GCP with Terraform. I specified a GCP Bucket to contain zip files produced with `dotnet publish`. I had a hunch that my mileage with the publish command wouldn't get me far, as I already failed to use it for Microsoft Azure. The error, `Error waiting for Creating CloudFunctions Function: Error code 3, message: Function failed on loading user code. This is likely due to a bug in the user code.`, suggested the code (or published result) was not correct.

I attempted variations of the alternative, `gcloud functions deploy` by setting the `--entry-point` to various settings believing that was the issue. Running it in the source code directory, `/severless_app/gcp_host_receiver`, showed various errors about the receiver and data `.csproj` files not existing. I was able to replicate the Terraform error via the resulting directory from the `dotnet publish` command.

### Local CLI Deployment Breakthrough

I am unsure what changed, but I was able to used `gcloud functions deploy` with the following configuration to achieve a successful deployment from the source directory.

```
gcloud functions deploy <FUNCTION_NAME> \
    --region europe-west2 \
    --source=. \
    --entry-point=gcp_host_receiver.receiver \
    --runtime dotnet6 \
    --trigger-http
```

There was one catch, however. An attempt to test the function directly in GCP's web interface threw an unhandled exception, which I assume relates back to the errors I received attempting to deploy from the source directly earlier, where receiver or data csproj files could not be found. More investigation and testing is required to understand what is going wrong during deployment preparations. Viewing and downloading the source zip from the Cloud Function shows that the data and receiver `.dll`'s are present in `/bin`. 

I have not identified many good examples of C# deployments which feature multiple packaged dependencies, developed locally. This prevents me from understanding how Cloud Functions prepares Functions with dependencies, which would allow me to adjust my development method accordingly.

```
System.IO.FileNotFoundException: Could not load file or assembly 'receiver, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'. The system cannot find the file specified.

File name: 'receiver, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'
   at gcp_host_receiver.receiver.HandleAsync(HttpContext context)
   at System.Runtime.CompilerServices.AsyncMethodBuilderCore.Start[TStateMachine](TStateMachine& stateMachine)
   at gcp_host_receiver.receiver.HandleAsync(HttpContext context)
   at Google.Cloud.Functions.Hosting.HostingInternals.Execute(HttpContext context)
   at Microsoft.AspNetCore.Server.Kestrel.Core.Internal.Http.HttpProtocol.ProcessRequests[TContext](IHttpApplication`1 application)
```