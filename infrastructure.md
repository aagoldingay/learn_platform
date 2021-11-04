# Infrastructure

This page covers everything related to understanding and provisioning infrastructure.

## Infrastructure As Code

IaC is an industry standard method of defining (but not limited to!!) cloud infrastructure. An IaC tool provides engineers with a method of having a source-of-truth for their platform resources and the configuration of each piece of the puzzle. 

Furthermore, by acting as a source-of-truth, that can be expanded to include variables and conditionals, engineers are also gifted a repeatable method of deploying and destroying the same infrastructure into multiple "environments". These environments, for example, can be the commonly seen "Development", "User Acceptance Testing" and "Production".

Having the power to provision and tear-down infrastructure on command, and quickly, is ideal for testing scenarios, such as this entire repository, because it helps keep the costs down (providing you remember to destroy all billable resources once you're done testing...).

### IaC and Automation
IaC can be facilitated by Continuous Integration (source control and build pipelines), to manage many members contributing to the code, at once. Additionally, one pipeline to run can help reduce the knowledge (and sharing of) secrets relating directly to the infrastructure. 

As an engineer, deploying infrastructure from a pipeline, you or other engineers could then refine your privileges in a cloud provider, which can make your infrastructure safer from pesky unintended changes.

## Terraform

Terraform is a successful IaC tool developed by HashiCorp, and there a plenty of great resources out there for diving into it - so go find some! 

Within this repository, each problem space may well have its own pattern to project structure. This would be caused by resource dependencies, or scope. I justify this by trying to avoid over-engineering a problem. Admittedly, there may be several examples of over-engineering in this repository... Sorry in advance!