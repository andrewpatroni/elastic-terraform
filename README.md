# elastic-terraform
Terraform for personal elasticsearch cluster
- Will contain a terraform for an elastic stack cluster and various provisioners, First ansible, then puppet, chef, and salt.
- All, with the exception of salt, will contain _sanctioned_ methods of deployment modified in accordance with the provisioners methods.

```terraform plan -var-file="variables.tfvars"```