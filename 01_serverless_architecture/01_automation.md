# 01_Automation

# Azure Function App Deployment (Locally)

In the case where I am trying to set things up quickly to prove what I have thus far, the Azure CLI is a reliable method of deploying, and can even be built upon by custom scripts. In theory, this would also allow for Terraform deployment, followed by a function code deployment on success. This enables for entry-level automation without the need to set up and solve authentication / authorisation from a cloud-based CI/CD tool.

As an engineer with experience only in Azure, PowerShell Core is the most comfortable environment for me to use for these types of automation.

# Workflow

Whether writing a script to speed up development locally, or using a CI/CD platform, there are some consistent steps to be taken:

0. Build
0. Test
0. Package
0. Deploy Infrastructure
0. Deploy Code

Any failures in one step should prevent the script from actioning something later. For example, a failing build will not permit testing to run. Without successful tests, there would be no benefit from deploying code.

# Designing Automations

Tools are required throughout a project's lifecycle. For the purpose of automating setup or deployment, it is important to choose methods which can be run as part of a script (or equivalent such as CI/CD pipeline plugins), as early as possible to boost familiarity. Tools which can be downloaded as executables provide a consistent experience between users and environments, and make automation much more straightforward. 

As I made the decision to use C# as the programming language for the Functions, I chose to use VS Code over Visual Studio, as there is less out-of-the-box simplicity to project setup and deployment. This experience made it easier to produce the build and test methods in a local deployment script, `/automation_scripts/local_azure_build_deploy` written in PowerShell Core.

Terraform is an industry-standard Infrastructure as Code tool with a great executable (in my experience). It's common commands for deployment translates consistently into scripts and pipelines, and the user experience is largely down to the documentation and organisation of any `.tf` or `.tfvars` files.

# Deploying Code to Azure Functions

I was faced with a new issue when attempting to deploy to Azure Functions for the first time in this project. I realised I had either been a Developer sending code into mystical pipelines, seeing the results later on, or the Platform Engineer, reworking or replicating other pipelines to deploy new infrastructure. My history with Azure DevOps extensions had me unprepared for deploying packaged code, made from scratch, to an accessible environment.

I had initially tried to used `dotnet publish`, PowerShell's `Compress-Archive` and finally `az functionapp deployment source config-zip` to produce the `.zip` I required for Run-From-Package, and deploy it. This lead to a day's worth of problem solving to identify why the Function App was not listing any functions while the underlying file system appeared to have them.

Eventually, I had success with an alternative to the above 3 commands, which I had already used previously to set up the initial C# projects - `func azure functionapp publish`!