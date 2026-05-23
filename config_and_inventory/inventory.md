# inventory file

inventory file tells Ansible **which servers to manage**.

it's just a list of hosts (servers) you want Ansible to connect to and run tasks on.

also called **hosts file** - same thing. you'll see it named `hosts`, `hosts.ini`, `inventory`, `inventory.ini` - all inventory files.

without it, Ansible doesn't know where to go.

---

## where Ansible looks for inventory

Ansible checks in this order (top = highest priority):

**1. `-i` flag - pass it directly on the command line:**

```bash
ansible-playbook -i hosts.ini playbook.yml
ansible-playbook -i ./inventory/prod.ini playbook.yml
```

**2. `ANSIBLE_INVENTORY` env variable:**

```bash
export ANSIBLE_INVENTORY=~/myproject/hosts.ini
ansible-playbook playbook.yml
```


**3. `inventory` set in `ansible.cfg`:**

```ini
[defaults]
inventory = hosts.ini
```

```bash
ansible-playbook playbook.yml   # picks up hosts.ini automatically
```

**4. `/etc/ansible/hosts` - default fallback:**

```bash
ansible-playbook playbook.yml
# no -i flag, no env var, no ansible.cfg → reads /etc/ansible/hosts
```

so if you don't pass `-i` and haven't set it in `ansible.cfg`, Ansible falls back to `/etc/ansible/hosts`.

---

## what it contains

- IP addresses or hostnames of your servers
- SSH connection details (user, key, port)
- grouping of servers
- variables per host or group

---

## basic format

```ini
[servers]
ubuntu ansible_host=3.81.6.13
```

`[servers]` is a group name. `ubuntu` is an alias for that host.

---

## how Ansible reads inventory and SSHes

inventory syntax can go from bare minimum to fully explicit. each level gives Ansible more info.

**just a hostname:**

```ini
[web]
server1
server2
```

Ansible has no IP, no user info. it will try to SSH using the name directly:

```bash
ssh <current-system-user>@server1
ssh <current-system-user>@server2
```

this only works if `server1` resolves via DNS or `/etc/hosts`. otherwise it fails.

---

**hostname with IP (`ansible_host`):**

```ini
[web]
server1 ansible_host=10.0.0.1
server2 ansible_host=10.0.0.2
```

`server1` is just an alias now. Ansible SSHes to the actual IP:

```bash
ssh <current-system-user>@10.0.0.1
ssh <current-system-user>@10.0.0.2
```

---

**with user (`ansible_user`):**

```ini
[web]
server1 ansible_host=10.0.0.1 ansible_user=ubuntu
server2 ansible_host=10.0.0.2 ansible_user=ubuntu
```

now Ansible knows which user to log in as:

```bash
ssh ubuntu@10.0.0.1
ssh ubuntu@10.0.0.2
```

---

**with SSH key (`ansible_ssh_private_key_file`):**

```ini
[web]
server1 ansible_host=10.0.0.1 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops.pem
```

equivalent:

```bash
ssh -i ~/.ssh/devops.pem ubuntu@10.0.0.1
```

---

**with port (`ansible_port`):**

```ini
[web]
server1 ansible_host=10.0.0.1 ansible_user=ubuntu ansible_port=2222
```

equivalent:

```bash
ssh -p 2222 ubuntu@10.0.0.1
```

---

so the more you tell Ansible in inventory, the more specific its SSH command becomes. without `ansible_host`, it guesses. without `ansible_user`, it uses your current system user.

putting everything inline gets messy. better to use `[group:vars]` to keep it clean:

```ini
[servers]
ubuntu ansible_host=3.81.6.13

[servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/devops.pem
```

---

## groups

you can group servers by role, environment, region - anything.

```ini
[webservers]
web1 ansible_host=10.0.0.1
web2 ansible_host=10.0.0.2

[dbservers]
db1 ansible_host=10.0.0.10
```

then in playbook you can target a specific group:

```yaml
- hosts: webservers
```

or all of them:

```yaml
- hosts: all
```

`all` is a built-in group. every host is automatically part of it.

---

## host variables

you can attach variables to a specific host inline:

```ini
[servers]
web1 ansible_host=10.0.0.1 ansible_user=ubuntu app_port=8080
web2 ansible_host=10.0.0.2 ansible_user=ec2-user app_port=3000
```

each host gets its own values.

---

## group variables

instead of repeating per host, set variables for a whole group:

```ini
[webservers]
web1 ansible_host=10.0.0.1
web2 ansible_host=10.0.0.2

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/devops.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

applies to every host in `[webservers]`.

---

## all:vars

applies to every host in the entire inventory:

```ini
[all:vars]
ansible_user=ubuntu

[webservers]
web1 ansible_host=10.0.0.1

[dbservers]
db1 ansible_host=10.0.0.10
```

both `web1` and `db1` get `ansible_user=ubuntu`.

---

## localhost

for local machine, use `ansible_connection=local` so Ansible doesn't SSH:

```ini
[local]
localhost ansible_connection=local
```

useful for testing playbooks locally without any remote server.

---

## common connection variables

| variable | what it does |
| --- | --- |
| `ansible_host` | actual IP or hostname to connect to |
| `ansible_user` | SSH user |
| `ansible_ssh_private_key_file` | path to SSH key |
| `ansible_port` | SSH port (default 22) |
| `ansible_connection` | connection type (`ssh`, `local`, `docker`) |
| `ansible_ssh_common_args` | extra SSH args like StrictHostKeyChecking |

---

## disabling strict host key checking

when connecting to a new server SSH asks:

```
Are you sure you want to continue connecting?
```

you can disable that per group:

```ini
[servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

or globally in `ansible.cfg`:

```ini
[defaults]
host_key_checking = False
```

---

## pointing ansible.cfg to your inventory

instead of passing `-i` every time:

```bash
ansible-playbook -i hosts.ini playbook.yml
```

set it once in `ansible.cfg`:

```ini
[defaults]
inventory = hosts.ini
```

then just:

```bash
ansible-playbook playbook.yml
```

---

## verify your inventory

list all hosts Ansible can see:

```bash
ansible all --list-hosts
```

list hosts in a specific group:

```bash
ansible webservers --list-hosts
```

ping all hosts to check connectivity:

```bash
ansible all -m ping
```
