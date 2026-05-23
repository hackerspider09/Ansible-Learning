# Ansible Roles, Imports and Includes

This README explains:

* what roles are
* how roles work internally
* role directory structure
* ways to use roles
* difference between imports and includes
* how orchestration works in playbooks
* role dependencies
* dynamic vs static execution

Based on the uploaded content. 

---

# Why Roles Exist

Initially, Ansible playbooks are usually small.

Example:

```yaml
- name: Install Docker
  apt:
    name: docker.io
    state: present

- name: Start Docker
  service:
    name: docker
    state: started

- name: Install kubectl
  ...

- name: Configure nginx
  ...
```

As infrastructure grows:

* playbooks become huge
* code gets duplicated
* maintenance becomes difficult
* debugging becomes messy
* reuse becomes hard

Roles solve this problem.

---

# What Is a Role

A role is a reusable and organized unit of automation.

Instead of putting everything into one playbook, automation is separated into components.

Example:

```text
roles/
├── docker/
├── nginx/
├── kubectl/
└── monitoring/
```

Each role manages one responsibility.

Examples:

* Docker installation
* Nginx configuration
* Kubernetes tools
* Monitoring agents

---

# How Roles Work

Suppose playbook contains:

```yaml
roles:
  - docker
```

Ansible automatically looks for:

```text
roles/docker/tasks/main.yml
```

and executes it.

The role becomes a reusable automation module.

---

# Role Structure

Standard structure:

```text
roles/
└── docker/
    ├── tasks/
    │   └── main.yml
    │
    ├── handlers/
    │   └── main.yml
    │
    ├── files/
    │
    ├── templates/
    │
    ├── vars/
    │   └── main.yml
    │
    ├── defaults/
    │   └── main.yml
    │
    ├── meta/
    │   └── main.yml
    │
    ├── tests/
    │
    └── README.md
```

Most directories are optional.

Minimum working role:

```text
roles/
└── docker/
    └── tasks/
        └── main.yml
```

---

# Creating Roles

## Manual Method

```bash
mkdir -p roles/docker/tasks
touch roles/docker/tasks/main.yml
```

---

## Using Ansible Galaxy

Ansible Galaxy

Create role:

```bash
ansible-galaxy init roles/docker
```

Generated structure:

```text
roles/docker/
├── defaults
├── files
├── handlers
├── meta
├── README.md
├── tasks
├── templates
├── tests
└── vars
```

---

# Role Directories Explained

---

# tasks/

Contains actual automation tasks.

Example:

```yaml
- name: Install Docker
  apt:
    name: docker.io
    state: present

- name: Start Docker
  service:
    name: docker
    state: started
```

Entry point:

```text
tasks/main.yml
```

Ansible automatically executes this file.

---

# Splitting Tasks

Instead of one huge file:

```text
tasks/
├── main.yml
├── install.yml
├── config.yml
└── service.yml
```

Example:

```yaml
# tasks/main.yml

- import_tasks: install.yml
- import_tasks: config.yml
- import_tasks: service.yml
```

---

# handlers/

Handlers are special tasks.

They execute only when notified.

Mostly used for:

* restarting services
* reloading configs

Example:

```yaml
# handlers/main.yml

- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

Task triggering handler:

```yaml
- name: Copy nginx config
  copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx
```

Handler runs only if file changes.

---

# files/

Stores static files.

Examples:

* configs
* scripts
* certificates

Structure:

```text
files/
└── nginx.conf
```

Usage:

```yaml
- copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
```

---

# templates/

Stores dynamic templates.

Uses:

* variables
* Jinja2 templating
* `.j2` files

Example:

```text
templates/nginx.conf.j2
```

Content:

```nginx
server {
    listen 80;
    server_name {{ domain_name }};
}
```

Usage:

```yaml
- template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

---

# files vs templates

| files               | templates                |
| ------------------- | ------------------------ |
| static              | dynamic                  |
| copied exactly      | rendered using variables |
| no variable support | variable support         |

---

# vars/

Stores high-priority variables.

Example:

```yaml
# vars/main.yml

docker_package: docker.io
```

Usage:

```yaml
name: "{{ docker_package }}"
```

Usually used for:

* internal role variables
* values not expected to change

---

# defaults/

Stores low-priority variables.

Example:

```yaml
docker_package: docker.io
```

These can easily be overridden.

Used for:

* configurable defaults
* reusable roles

---

# Variable Priority

Simplified order:

```text
defaults < inventory vars < playbook vars < vars
```

---

# meta/

Stores role metadata.

Example:

```yaml
galaxy_info:
  author: admin
  description: installs docker
```

Also used for dependencies.

---

# Role Dependencies

Example:

```yaml
# meta/main.yml

dependencies:
  - role: common
  - role: firewall
```

Execution order:

1. common
2. firewall
3. current role

---

# tests/

Used for testing roles.

Usually contains:

* inventory
* test playbooks

---

# README.md

Role documentation.

Usually contains:

* purpose
* supported platforms
* variables
* examples
* usage instructions

---

# Ways To Use Roles

---

# 1. Using `roles`

Simplest method.

```yaml
- hosts: all

  roles:
    - docker
    - nginx
```

Execution order:

1. docker
2. nginx

---

# Internal Execution Order

Ansible internally executes:

```text
pre_tasks
roles
tasks
post_tasks
```

So roles execute before normal tasks.

---

# 2. Using `include_role`

Executes role dynamically during runtime.

Example:

```yaml
tasks:
  - include_role:
      name: docker
```

Role executes exactly at that point.

---

# Example With Tasks + Roles

```yaml
- hosts: all
  become: yes

  tasks:

    - name: Update packages
      apt:
        update_cache: yes
        upgrade: yes

    - name: Install Docker
      include_role:
        name: docker

    - name: Verify Docker
      command: docker --version
```

Execution flow:

```text
1. Update packages
2. Enter docker role
3. Execute docker role tasks
4. Return to playbook
5. Verify Docker
```

---

# 3. Using `import_role`

Static role loading.

Example:

```yaml
tasks:
  - import_role:
      name: docker
```

Role is parsed before execution starts.

---

# include_role vs import_role

| include_role               | import_role                 |
| -------------------------- | --------------------------- |
| dynamic                    | static                      |
| runtime loading            | preloaded                   |
| supports conditions easily | less flexible               |
| supports loops             | limited                     |
| better for orchestration   | better for static structure |

---

# include_role Example

```yaml
- include_role:
    name: docker
  when: ansible_distribution == "Ubuntu"
```

Dynamic execution.

---

# import_role Example

```yaml
- import_role:
    name: docker
```

Loaded during parsing stage.

---

# Task Includes

Roles are not the only thing that can be included.

Tasks can also be split.

---

# include_tasks

Dynamic task loading.

Example:

```yaml
- include_tasks: install.yml
```

Loaded during execution.

Supports:

* conditions
* loops
* dynamic paths

---

# import_tasks

Static task loading.

Example:

```yaml
- import_tasks: install.yml
```

Loaded before execution begins.

---

# include_tasks vs import_tasks

| include_tasks            | import_tasks |
| ------------------------ | ------------ |
| dynamic                  | static       |
| runtime                  | parse time   |
| supports loops           | no loops     |
| supports conditions well | limited      |
| flexible                 | predictable  |

---

# Example

## import_tasks

```yaml
# tasks/main.yml

- import_tasks: install.yml
- import_tasks: config.yml
```

Ansible loads everything before execution.

---

## include_tasks

```yaml
- include_tasks: "{{ ansible_os_family }}.yml"
```

Dynamic loading based on OS.

---

# Full Orchestration Example

```yaml
- hosts: all
  become: yes

  tasks:

    - name: Install base packages
      apt:
        name:
          - curl
          - wget
        state: present

    - name: Install Docker
      include_role:
        name: docker

    - name: Install kubectl
      include_role:
        name: kubectl

    - name: Install Helm
      include_role:
        name: helm

    - name: Verify kubectl
      command: kubectl version --client
```

---

# Important Concepts

---

# Playbook

Acts as orchestrator.

Controls:

* target hosts
* execution order
* role execution
* variables
* conditions

---

# Role

Reusable automation component.

Contains:

* tasks
* handlers
* templates
* variables
* dependencies

---

# Tasks

Actual automation steps.

Examples:

* install package
* copy config
* restart service

---

# Modules

Actual Ansible operations.

Examples:

* apt
* yum
* copy
* service
* template

---

# Mental Model

```text
Playbook
   ↓
Calls Roles
   ↓
Roles Organize Automation
   ↓
Tasks Execute Logic
   ↓
Modules Perform System Operations
```
