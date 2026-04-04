# Ansible Learning Notes

This repository contains notes and examples for learning Ansible automation.

## Index of Concepts

- [Ad-hoc Commands](install-pkg-ubuntu/adhoccmd.md) - Understanding one-time Ansible commands
- [Installing Packages on Ubuntu](install-pkg-ubuntu/README.md) - Examples of Ansible commands for package installation

## Ansible Notes

### What is Ansible?
Ansible is an open-source automation tool for configuration management, application deployment, and task automation. It uses SSH for communication and doesn't require agents on managed nodes.

### Key Concepts
- **Inventory**: List of hosts to manage
- **Playbooks**: YAML files containing tasks
- **Modules**: Reusable units of code
- **Roles**: Organized way to group tasks, variables, and handlers

### Basic Workflow
1. Define inventory
2. Write playbooks
3. Run with `ansible-playbook`

### Useful Commands
- `ansible --version` - Check version
- `ansible all -m ping` - Test connectivity
- `ansible-playbook playbook.yml` - Run a playbook