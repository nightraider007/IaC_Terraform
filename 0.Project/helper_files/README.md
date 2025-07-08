For onboarding team members / documentation




version.tf	Sets provider, required Terraform version, and config block
variables.tf	Declares input variables
secrets.auto.tfvars	Stores sensitive or defaulted values, loaded automatically by Terraform
locals.tf	Defines internal computed values
main.tf	Core logic — resources, modules, etc.
outputs.tf	Outputs useful results and values
README.md	Set Up for documentation and outline modular scaffolding structure here to define the architecture  
.terraform.lock.hcl	Automatically created –  check it into version control
.gitignore	To exclude .terraform/, .tfstate, etc. from version control

Further suggestions for future enhancement:
environments/ folder	If you're managing multiple environments (dev/staging/prod)

