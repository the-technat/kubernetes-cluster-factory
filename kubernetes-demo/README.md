# kubernetes-demo

> [!NOTE]
> This demo is outdated and not fully working. You might be able to use it as a starting point however.

A demo of a Kubernetes cluster fully setup and configured to show why Kubernetes is great (or not so great) 

## Deploy

Using Terraform Cloud:
- Create a workspace connected to this repository (e.g VCS-driven workflow)
- Connect the workspace with AWS via [Dynamic Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration), in short:
  - Add an Identity Provider in AWS IAM pointing to `https://app.terraform.io` with an audience of `aws.workload.identity`
  - Use the following trust-policy to create a role and assign it proper permissons:
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::351425708426:oidc-provider/app.terraform.io"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "app.terraform.io:aud": "aws.workload.identity"
                    },
                    "StringLike": {
                        "app.terraform.io:sub": "organization:technat:project:core:workspace:kubernetes-demo:run_phase:*"
                    }
                }
            }
        ]
    }
    ```
  - Set the following workspace environment variables:
    - `TFC_AWS_RUN_ROLE_ARN=<arn>`
    - `TFC_AWS_PROVIDER_AUTH=true`
    
- Trigger a new run in the workflow

## Technical Debts

Currently most of the stuff we deploy works, however:
- Many things can't be controlled from the outside (like feature toggles or config overrides)
- No app is HA (to be discussed if needed or added as feature toggle)
- No app is secure (missing securityContexts, except apps that are secure by default)
- No app has resource requests/limits (expect apps that have defaults)
- No app has network policies 
- No app has authentication (and those who have, just have a local admin user only suitable for Terraform)

## Design Decisions

- Everything is deployed using Terraform 
- Infrastructure addons are deploying using the helm provider
- Dependencies shall be strict and clear, providing seamless deploy and destroy runs 
- Metrics are enabled for almost all components and scraped using service-based discovery 
