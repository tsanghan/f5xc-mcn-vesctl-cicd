# f5xc-mcn-vesctl-cicd
[![Deploy to F5XC](https://github.com/tsanghan/f5xc-mcn-vesctl-cicd/actions/workflows/f5xc-mcn.yaml/badge.svg)](https://github.com/tsanghan/f5xc-mcn-vesctl-cicd/actions/workflows/f5xc-mcn.yaml)

f5xc-mcn-vesctl-cicd

### How to use this repository

1. `git clone https://github.com/tsanghan/f5xc-mcn-cicd.git`
2. `cd f5xc-mcn-cicd`
3. `cp .env.example .env`
4. Wiht your favourite editor, edit `.env` file, replace `<REPLACE ME>` with appririate, correct and accurate information.
5. If you are no using Terraform S3 backend, comment out all `AWS_*` line in `.env` file.
6. Source the `.env` file, i.e., `source .env`
7. To check that the environment variable is in your current shell environment, `env | egrep "VES_|TF_" | sed 's/=.*/=<...>/'`
8. `cd tofu_xc_resources`
9. If you are NOT using Terraform S3 backend,
    - a. If you are using `Terraform`, comment out all line in `backend.tf` and ignore `backend.tofu` file.
    - b. If you are using `OpenTofu`, comment out all line in `backend.tofu` and ignore `backend.tf` file.
10. If you ARE using Terraform S3 backend,
    - a. `cp backend_config.tfvars.example backend_config.tfvars`
    - b. Wiht your favourite editor, edit `backend_config.tfvars` file, replace `<REPLACE ME>` with appririate, correct and accurate information.
11. Wiht your favourite editor, edit `vars.tf` file, change values of available `variables` to suites your needs.
12. With `Terraform`, `terraform init -backend-config="./backend_config.tfvars"`
13. With `OpenTofu`, `tofu init -backend-config="./backend_config.tfvars"`
14. Do a `plan` command, `terraform|tofu plan -out myplan.tfplan`
15. Then `apply`, `terraform|tofu apply "myplan.tfplan"`
16. Wait till `terraform|tofu` runs till completion.
19. Go to F5XC console `Multi-Cloud Network Connect` Workspace
    - Go to `Manage->Site Management->AWS VPC Sites`
    - Select your `AWS VPC Site` created by `Terraform|OpenTofu`
    - Monitor the resource till succesfully created.