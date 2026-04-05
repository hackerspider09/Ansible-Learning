# Get VPC
resource "aws_default_vpc" "ansible_vpc" {
  lifecycle {
    ignore_changes = [ tags ]
  }
}
# Get subnet
data "aws_subnet" "ansible_sn" {
  id = local.sn_id
}

# Get security group
data "aws_security_group" "ansible_sg" {
  id = local.sg_id
}

# Get key
resource "aws_key_pair" "ansible_keypair" {
  key_name   = "ansible-keypair"
  public_key = file(local.ssh_filename)
}

# EC2
resource "aws_instance" "worker_node" {
  for_each = local.instances

  ami           = each.value.ami_id
  instance_type = local.instance_type
  vpc_security_group_ids = [data.aws_security_group.ansible_sg.id]
  key_name = aws_key_pair.ansible_keypair.key_name
  subnet_id = data.aws_subnet.ansible_sn.id

  tags = {
    Name = "${each.key}-WorkerNode}"
    User = "${each.value.username}"
  }
}
resource "aws_instance" "control_node" {
  ami           = local.instances.ubuntu.ami_id
  instance_type = local.instance_type
  vpc_security_group_ids = [data.aws_security_group.ansible_sg.id]
  key_name = aws_key_pair.ansible_keypair.key_name
  subnet_id = data.aws_subnet.ansible_sn.id



  tags = {
    Name = "${local.control_node.machine_type}-ControlNode}"
    User = "${local.control_node.username}"
  }
}

