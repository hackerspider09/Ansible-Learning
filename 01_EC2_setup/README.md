## Setup ec2 for ansible practice

  - create ssh key using `ssh-keygen` and update public key name in local.tf
  - local.tf file will create 1 managed node and 1 control node (you can uncomment other os code in local.tf file)
  - if want to create control node uncomment code in main.tf 

initialise terraform
```
terraform init
```

validate terraform 

```
terraform validate
```

check outcome
```
terraform plan
```

apply infra
```
terraform apply -auto-approve
```

destroy infra
```
terraform destroy -auto-approve
```

