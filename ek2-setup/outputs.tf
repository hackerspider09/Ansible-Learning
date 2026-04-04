output "worker_node_info" {
  value = [for k, v in aws_instance.worker_node : "PubIP: ${v.public_ip} | PrvIP: ${v.private_ip}"]
}

output "control_node_info" {
  value = "PubIP: ${aws_instance.control_node.public_ip} | PrvIP: ${aws_instance.control_node.private_ip}"
}