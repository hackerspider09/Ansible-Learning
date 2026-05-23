`ansible.cfg` is the **main configuration file of Ansible**.

It tells Ansible:

* where your inventory file is
* how to connect to servers
* where roles/playbooks are stored
* SSH settings
* logging behavior
* privilege escalation settings
* output formatting
* retry behavior
* many other defaults

Without `ansible.cfg`, Ansible uses built-in defaults or environment variables.

---

# Why `ansible.cfg` is Important

Imagine running this every time:

```bash
ansible-playbook -i hosts.ini playbook.yml --user ubuntu --private-key key.pem
```

Instead, you can define defaults once in `ansible.cfg`.

Then simply run:

```bash
ansible-playbook playbook.yml
```

So:

* cleaner commands
* reusable setup
* project-specific configuration
* avoids mistakes

---

# Where Ansible Looks for `ansible.cfg`

Ansible searches in this order:

1. `ANSIBLE_CONFIG` environment variable
2. `./ansible.cfg` (current project directory)
3. `~/.ansible.cfg`
4. `/etc/ansible/ansible.cfg`

---

# Minimal `ansible.cfg`

Example:

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

# Explanation Line by Line

`[defaults]`

Main configuration section.

---

`inventory = hosts.ini`

Default inventory file.

Without this:

```
ansible-playbook -i hosts.ini playbook.yml
```

With this:

```
ansible-playbook playbook.yml
```

---

`host_key_checking = False`

Disables SSH fingerprint confirmation.

Without this:

```text
Are you sure you want to continue connecting?
```

---

`remote_user = ubuntu`

Default SSH user.

Now Ansible auto does:

```
ssh ubuntu@server
```

---

`private_key_file = ~/.ssh/key.pem`

Default SSH key.

without this you have to pass flag or have to add in host file

```
--private-key key.pem
```

hosts.init

ansible_ssh_private_key_file= key.pem

---

Privilege Escalation Section

`become = True`

Equivalent of:

```
sudo
```

Most package installations require root.

---

`become_user = root`

Become root user.

---

`become_ask_pass = False`

Don't ask for sudo password.

---

# Real Example

Without config:

```bash
ansible-playbook \
-i hosts.ini \
-u ubuntu \
--private-key ~/.ssh/devops.pem \
--become \
playbook.yml
```

With config:

```bash
ansible-playbook playbook.yml
```


---


# How to Check Which Config is Used

Run:

```bash
ansible --version
```

You will see:

```text
config file = /path/to/ansible.cfg
```


---


| File           | Purpose                   |
| ---------------- | --------------------------- |
| `hosts.ini`    | List of servers           |
| `ansible.cfg`  | Ansible behavior/settings |
| `playbook.yml` | Actual automation tasks   |

---



---


How to use different methods of ansible config 

1. `ANSIBLE_CONFIG` env variable
2. `ansible.cfg` in current directory
3. `~/.ansible.cfg`
4. `/etc/ansible/ansible.cfg`

so if you are in specific dir and run

```bash id="96g1ir"
cd basics
ansible-playbook ping.yml
```

then it will NOT automatically use `../ansible.cfg`
because current dir is `basics/`.

You have 3 good options.

---

### Option 1

Always run commands from project root:

```bash
cd ansible-notes
ansible-playbook basics/ping.yml
```

---

### Option 2

Use environment variable:

```bash
export ANSIBLE_CONFIG=../ansible.cfg
ansible-playbook ping.yml
```

Works from subdirectories.

---

### Option 3

Create a tiny local config in each concept dir:

```ini
# basics/ansible.cfg
[defaults]
inventory = ../hosts.ini
```
