# ansible.cfg

`ansible.cfg` is the **main configuration file of Ansible**.

it tells Ansible:
- where your inventory file is
- how to connect to servers
- SSH settings
- privilege escalation settings
- logging, output formatting, retry behavior
- many other defaults

without `ansible.cfg`, Ansible uses built-in defaults or environment variables.

---

## why it matters

imagine running this every time:

```bash
ansible-playbook -i hosts.ini playbook.yml --user ubuntu --private-key key.pem --become
```

instead, define defaults once in `ansible.cfg`, then just run:

```bash
ansible-playbook playbook.yml
```

- cleaner commands
- reusable setup
- project-specific config
- avoids mistakes

---

## where Ansible looks for ansible.cfg

Ansible searches in this order (top = highest priority):

```
1. ANSIBLE_CONFIG  (env variable)
2. ./ansible.cfg   (current directory)
3. ~/.ansible.cfg
4. /etc/ansible/ansible.cfg
```

suppose one project structure is like this

```
project/
  ansible.cfg
  hosts.ini
  basics/
    ping.yml
```

so if you `cd basics/` and run a playbook there, it will **not** automatically pick up `../ansible.cfg`.
current dir is `basics/`, so Ansible only looks there.

---

## minimal ansible.cfg

```ini
[defaults]
inventory = hosts.ini
host_key_checking = False
remote_user = ubuntu
private_key_file = ~/.ssh/devops.pem

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

---

## line by line

**`[defaults]`** - main config section.

---

**`inventory = hosts.ini`** - default inventory file.

without this:
```bash
ansible-playbook -i hosts.ini playbook.yml
```

with this:
```bash
ansible-playbook playbook.yml
```

---

**`host_key_checking = False`** - disables SSH fingerprint confirmation.

without this you get:
```
Are you sure you want to continue connecting?
```

---

**`remote_user = ubuntu`** - default SSH user.

Ansible auto does:
```
ssh ubuntu@server
```

---

**`private_key_file = ~/.ssh/key.pem`** - default SSH key.

without this you have to pass it as a flag or define it in inventory:
```bash
--private-key key.pem
```
or in `hosts.ini`:
```ini
ansible_ssh_private_key_file=key.pem
```

---

**`[privilege_escalation]`** - separate section for sudo/become settings.

**`become = True`** - equivalent of `sudo`. most package installs need root.

**`become_method = sudo`** - how to escalate (sudo, su, pbrun, etc.)

**`become_user = root`** - which user to become.

**`become_ask_pass = False`** - don't ask for sudo password.

---

## real example

without config:
```bash
ansible-playbook \
  -i hosts.ini \
  -u ubuntu \
  --private-key ~/.ssh/devops.pem \
  --become \
  playbook.yml
```

with config:
```bash
ansible-playbook playbook.yml
```

---

## how to check which config is active

```bash
ansible --version
```

look for:
```
config file = /path/to/ansible.cfg
```

---

## file roles

| file | purpose |
| --- | --- |
| `hosts.ini` | list of servers |
| `ansible.cfg` | Ansible behavior / settings |
| `playbook.yml` | actual automation tasks |

---

## how to use ansible.cfg from subdirectories

if you have:
```
project/
  ansible.cfg
  hosts.ini
  basics/
    ping.yml
```

and you run:
```bash
cd basics
ansible-playbook ping.yml
```

it will **not** use `../ansible.cfg`. you have 3 options:

---

### option 1 - run from project root

```bash
cd project
ansible-playbook basics/ping.yml
```

---

### option 2 - export env variable

```bash
export ANSIBLE_CONFIG=../ansible.cfg
ansible-playbook ping.yml
```

works from subdirectories.

---

### option 3 - local config in each dir

create a tiny `ansible.cfg` inside the concept dir:

```ini
# basics/ansible.cfg
[defaults]
inventory = ../hosts.ini
```
