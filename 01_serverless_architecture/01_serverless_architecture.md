# 01_SERVERLESS_ARCHITECTURE

Number One. How to deploy platform architecture consisting of multiple serverless functions.

I hope this one will be nice and straightforward, or at least in relation to many problems experienced and solved by Platform Engineers.

## Aims
- Deploy simple, serverless functions to a cloud provider, passing messages between them. 
- A personal-first outing on a platform that isn't Azure.

## Scenario
Spike the setup and execution of basic serverless architecture containing two functions. A sender and receiver. The contents of the sender's payloads is not important, but must be understood and processed by the receiver.

Assess multiple cloud providers' relative ease of deployment and functionality.

## Serverless Architecture

Now is a good opportunity to briefly explain what Serverless Architecture is - for my own benefit... When I first heard of the term, I assumed some cloud wizardry was at play, which removed the need for code to be deployed on a server, at all. In reality, it isn't as mysterious.

Serverless Computing relies solely on the chosen cloud provider to execute application code in response to well-defined events, such as HTTP requests or timers. The cloud provider will automatically assign the required compute resources to the application, and scale this to meet demand. 

This type of architecture is useful for cost saving, and makes for a great first venture into Platform Engineering. When not in use, the cloud provider scales down the resources completely, removing or reducing running costs. As long as a platform has a well-adjusted scaling plan, this can save effort and outgoing costs to a cloud provider.

The scalability and affordability of Serverless computing comes at the detriment of response times in certain cases. If application code is scaled down completely, a new request will take longer to invoke and complete. It is up to the individual whether this tradeoff is acceptable. For example, a scheduled task that performs defined actions on variable workloads, then completing, is more suited for serverless than an alternative that is required to have a high throughput and response time, or stable workflows.

## Scope

- Infrastructure
    - Infrastructure as Code
- Application development
- Deployment

## Solution Design

--diagraaam
Sender -> Receiver (C# Net Core 6.0)

## Experiences

### Development

Azure is the cloud platform which I have the most experience with, and will serve as a baseline to prove to myself that I can develop, deploy and run Serverless Architecture. Azure supports a subset of languages, compared to other cloud providers. To keep this spike simple, the selected programming language and automation tools will be chosen if they are supported by multiple cloud platform's serverless offerings. 

Unfortunately for me, I do not actively write code in languages supported by Azure... But it's gotta be done!

For more specific documentation on this stage, visit the [dedicated page](01_development.md)

### Infrastructure

Terraform will be particularly applicable for deploying infrastructure quickly, between multiple cloud providers. Luckily, this bit (at least in Azure) is my day job! So this should be the least embarrassing part of the first problem space!

For more specific documentation on this stage, visit the [dedicated page]()

### Automation

For more specific documentation on this stage, visit the [dedicated page]()
