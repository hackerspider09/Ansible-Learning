# Ansible Learning Notes

This repository contains notes and examples for learning Ansible automation.

## Index of Concepts

- [Ad-hoc Commands](install-pkg-ubuntu/adhoccmd.md) - Understanding one-time Ansible commands
- [Installing Packages on Ubuntu](install-pkg-ubuntu/README.md) - Examples of Ansible commands for package installation
- [Variable Precedence](variables_order/variables.md) - Variable types, role variables and precedence order
- [Config and Inventory](config_and_inventory/README.md) - `ansible.cfg` setup, SSH defaults, privilege escalation, inventory file syntax, host/group variables, connection variables

## Ansible Notes

### What is Ansible?
Ansible is an open-source automation tool for configuration management, application deployment, and task automation. It uses SSH for communication and doesn't require agents on managed nodes.

### Architecture

```
  Control Node (your machine)
  ├── ansible.cfg       ← config (SSH user, key, inventory path...)
  ├── inventory         ← who to connect to (IPs, groups)
  └── playbook.yml      ← what to do
           │
           │  SSH (no agent needed on remote)
           │
  ┌────────┴────────────────────┐
  │         Managed Nodes       │
  ├── server1 (ubuntu)          │
  ├── server2 (ubuntu)          │
  └── server3 (redhat)          │
  └────────────────────────────-┘
```

Ansible connects from the control node over SSH, pushes the module to a temp dir on the remote, runs it, returns the result, then deletes the module. nothing stays on the managed node.

### Key Concepts

- **Inventory** - list of servers (hosts) Ansible will manage, can be grouped

- **Playbook** - a YAML file you run. contains one or more plays

- **Play** - maps a group of hosts to a list of tasks. a playbook can have multiple plays targeting different host groups

- **Task** - a single action inside a play. each task calls one module

  play vs task in a playbook:

  ```yaml
  # ── PLAY 1 ────────────────────────────────
  - name: Setup web servers         # play name
    hosts: webservers               # which hosts this play runs on
    become: yes
    tasks:
      - name: Install nginx         # ← TASK 1
        apt:                        #   module: apt
          name: nginx
          state: present

      - name: Start nginx           # ← TASK 2
        service:                    #   module: service
          name: nginx
          state: started

  # ── PLAY 2 ────────────────────────────────
  - name: Setup db servers          # second play, different hosts
    hosts: dbservers
    tasks:
      - name: Install postgres      # ← TASK 1 of play 2
        apt:
          name: postgresql
          state: present
  ```

  the whole file = playbook. each top-level `-` block with `hosts:` = a play. each item under `tasks:` = a task. the key under the task name (`apt`, `service`) = the module.

- **Module** - built-in unit of work (`apt`, `copy`, `service`, `template`, etc.) called by a task. Ansible copies it to the remote, runs it, deletes it.

- **Role** - reusable, organized structure of tasks, handlers, templates, vars, defaults, files grouped by purpose

- **Galaxy** - Ansible's hub for sharing and downloading community roles and collections (like npm for Ansible)

### Basic Workflow
1. Define inventory (which servers)
2. Write playbook (what to do)
3. Run with `ansible-playbook`

### Useful Commands
- `ansible --version` - check version and active config file
- `ansible all -m ping` - test SSH connectivity to all hosts
- `ansible all --list-hosts` - list all hosts Ansible can see
- `ansible-playbook playbook.yml` - run a playbook
- `ansible-playbook playbook.yml --check` - dry run, no changes made
- `ansible-playbook playbook.yml -e "key=value"` - pass extra variables (highest priority)
- `ansible-galaxy init roles/myrole` - create role directory structure