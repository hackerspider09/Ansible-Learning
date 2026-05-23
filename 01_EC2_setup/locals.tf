locals {
  region = "us-east-1"
  sn_id = "subnet-09de5aba1886a88d9"
  sg_id = "sg-0504ce3fbd0a6f844"

  instance_type = "t2.micro"
  ssh_filename = "./ansible-ssh-key.pub"

  instances = {
    "ubuntu" = {
      ami_id = "ami-0ec10929233384c7f"
      username = "ubuntu"
    }
    # "amazon" = {
    #   ami_id = "ami-01b14b7ad41e17ba4"
    #   username = "ec2-user"
    # }
    # "redhat" = {
    #   ami_id = "ami-056244ee7f6e2feb8"
    #   username = "ec2-user"
    # }
  }

  control_node = {
    ami_id = local.instances.ubuntu.ami_id
    username = local.instances.ubuntu.username
    machine_type = "ubuntu"
  }

}
