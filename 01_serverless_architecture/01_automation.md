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

