# 01_Development

Specific documentation for developing a Serverless Application to use in this problem space.

## Guide to run

Here's some quick notes to get started with the code in this directory if you don't want to read on.
```
cd serverless_app
dotnet build
dotnet test .\serverless_app.sln
```

## C# Justification

C# is a common language used for FaaS resources across multiple cloud providers. As a result, this has been chosen to simplify development, meaning I am able to reuse a lot of code. I do have some prior experience with this language so hopefully I can remember enough to make development a breeze!

Prerequisites:

- VS Code (plus C# extensions)
- dotnet 6.0

### How I set up the C# project

1. Navigate to /serverless_app.
1. Create solution file.
    ```
    dotnet new sln
    ```
1. Create common code and testing projects.
    ```
    dotnet new classlib -o data
    dotnet new classlib -o sender
    dotnet new classlib -o receiver

    dotnet new nunit -o data.test
    dotnet new nunit -o sender.test
    dotnet new nunit -o receiver.test
    
    # add to the solution
    dotnet sln add data/data.csproj sender/sender.csproj receiver/receiver.csproj data.test/data.test.csproj sender.test/sender.test.csproj receiver.test/receiver.test.csproj azure_host/azure_host.csproj azure_host.test\azure_host.test.csproj gcp_host/gcp_host.csproj
    ```
1. Set up cloud provider packages

    [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=csharp)
    ```
    npm install -g azure-functions-core-tools@4 --unsafe-perm true

    # Azure Function App
    func init azure_host_receiver
    func init azure_host_sender
    # dotnet worker runtime
    ```
    [GCP Cloud Functions]()
    ```
    dotnet new gcf-http -o gcp_host_receiver
    dotnet new gcf-http -o gcp_host_sender
    ```
1. Add cloud provider projects to the solution
    ```
    dotnet sln add azure_host_receiver/azure_host_receiver.csproj
    dotnet sln add azure_host_sender/azure_host_sender.csproj
    dotnet sln add gcp_host_receiver/gcp_host_receiver.csproj
    dotnet sln add gcp_host_sender/gcp_host_sender.csproj
    ```
1. Reference the right projects to where they are needed
    ```
    dotnet add sender/sender.csproj reference data/data.csproj
    dotnet add receiver/receiver.csproj reference data/data.csproj

    # CLOUD PROVIDERS
    dotnet add azure_host_receiver/azure_host_receiver.csproj reference receiver/receiver.csproj data/data.csproj
    dotnet add azure_host_sender/azure_host_sender.csproj reference sender/sender.csproj data/data.csproj
    dotnet add gcp_host_receiver/gcp_host_receiver.csproj reference receiver/receiver.csproj data/data.csproj
    dotnet add gcp_host_sender/gcp_host_sender.csproj reference sender/sender.csproj data/data.csproj
    ```
1. Reference projects to test projects as required
    ```
    dotnet add data.test/data.test.csproj reference data/data.csproj
    dotnet add sender.test/sender.test.csproj reference sender/sender.csproj data/data.csproj
    dotnet add receiver.test/receiver.test.csproj reference receiver/receiver.csproj data/data.csproj
    ```
1. Update packages (per project, identify packages in `<PackageReference>` tags)
    ```
    cd /project
    dotnet add package PACKAGE_NAME
    ...
    ```

## Developing Azure Functions

### Tools
- Azurite - Local Blob Storage
    ```
    npm install -g azurite
    azurite
    ```

### Testing Azure Functions in VSCode

Azure Functions are quite nice to work with. Locally, they interface with Azurite (or the deprecated Microsoft Azure Storage Emulator) to successfully run multiple functions with the required underlying storage. You get a real-world experience right on your machine! 

```
# cmd prompt 1
cd azure_host_receiver
func start # port 7071

# cmd prompt 2
cd azure_host_sender
func start -p 7171 # port 7171
```

`local.settings.json` acts as an Azure Function App's configuration, which you would normally locate via Azure Portal > `function_app_name` > Configuration. All Environment Variables are found here, and are treated as a key value pair in JSON.

- 01_serverless_architecture/serverless_app/azure_host_sender/local.settings.json
    ```json
    {
        "IsEncrypted": false,
        "Values": {
            "AzureWebJobsStorage": "",
            "FUNCTIONS_WORKER_RUNTIME": "dotnet",
            "RECEIVERADDR": "http://localhost:7071/api/receiver"
        }
    }
    ```

### Environment Variables

Cloud provider projects make use of environment variables to reference another cloud provider's function via HTTP. This achieves the goal of cloud agnostisism in this problem space. As the code will behave the same way, regardless of which cloud provider each function is deployed in, I can even make Azure Function Sender call Azure Function Receiver!

## Developing Google Cloud Functions

This section is still largely untested, although I have been able to verify that both GCP Functions start.

So far, I have had no success configuring local environment variables. I believe it requires and `appsettings.json` file, but no documentation I could find to date had shown me how to do this accurately.

### Tools

### Testing
```
dotnet run --project gcp_host_sender/gcp_host_sender.csproj --port 8080
dotnet run --project gcp_host_receiver/gcp_host_receiver.csproj --port 8081
```
