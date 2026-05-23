# EC2 setup for Ansible practice

uses Terraform to spin up EC2 instances on AWS to use as managed nodes (and optionally a control node) for Ansible practice.

---

## what it creates

- **worker nodes** - EC2 instances Ansible will manage (defined in `locals.tf`)
- **control node** - an EC2 to run Ansible from, commented out 
- **key pair** - uploads your local SSH public key to AWS so Ansible can connect

currently active instance in `locals.tf`:

```
ubuntu  →  ami-0ec10929233384c7f  (user: ubuntu)
```

commented out (uncomment to add):

```
amazon  →  ami-01b14b7ad41e17ba4  (user: ec2-user)
redhat  →  ami-056244ee7f6e2feb8  (user: ec2-user)
```

---

## before running

generate SSH key:

```bash
ssh-keygen -f ansible-ssh-key
```

this creates `ansible-ssh-key` (private) and `ansible-ssh-key.pub` (public).

`locals.tf` already points to `./ansible-ssh-key.pub` - don't change the filename unless you update it there too.

---

## terraform commands

initialise:

```bash
terraform init
```

validate config:

```bash
terraform validate
```

preview what will be created:

```bash
terraform plan
```

apply (create infra):

```bash
terraform apply -auto-approve
```

destroy (delete infra):

```bash
terraform destroy -auto-approve
```

---

## after apply

terraform prints worker node IPs:

```
worker_node_info = [
  "PubIP: 3.81.6.13 | PrvIP: 172.31.x.x"
]
```

use the public IP in your Ansible inventory to connect.

---

## enabling control node

in `main.tf`, uncomment the `aws_instance.control_node` block.

in `outputs.tf`, uncomment the `control_node_info` output.

in `locals.tf`, the `control_node` block is already defined - it uses the ubuntu AMI by default.

---

## config

all instance config is in `locals.tf`:

| key | value |
| --- | --- |
| region | `us-east-1` |
| instance type | `t2.micro` |
| subnet | update `sn_id` to your subnet |
| security group | update `sg_id` to your SG |
| SSH key | `./ansible-ssh-key.pub` |
