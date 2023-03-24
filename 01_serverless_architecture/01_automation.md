# 01_Automation

# Azure Function App Deployment (Locally)

In the case where I am trying to set things up quickly to prove what I have thus far, the Azure CLI is a reliable method of deploying, and can even be built upon by custom scripts. In theory, this would also allow for Terraform deployment, followed by a function code deployment on success. This enables for entry-level automation without the need to set up and solve authentication / authorisation from a cloud-based CI/CD tool.

As an engineer with experience only in Azure, PowerShell Core is thne most comfortable environment for me to use for these types of automation.