# Used Ansible Commands 

## 1. Basic Command Syntax

```bash
ansible <host-pattern> -i <inventory> -m <module> -a "<arguments>"
```

### Example:

```bash
ansible server -i inventory.ini -m command -a "whoami"
```

If `-m` is not given, default = `command`

---

## 2. Ad-hoc Commands

### Run simple command

```bash
ansible all -i inventory.ini -a "whoami"
```

### Disk usage

```bash
ansible all -i inventory.ini -a "df -h"
```

---

## 3. Common Modules

### ping (connectivity test)

```bash
ansible all -i inventory.ini -m ping
```

---

### command (default)

```bash
ansible all -i inventory.ini -m command -a "uptime"
```

---

### shell (for complex commands)

```bash
ansible all -i inventory.ini -m shell -a "echo hello && date"
```

---

### setup (gather system info)

```bash
ansible all -i inventory.ini -m setup
```

---

### apt (Ubuntu/Debian)

```bash
ansible all -i inventory.ini -m apt -a "name=nginx state=present" --become
```

---

### service

```bash
ansible all -i inventory.ini -m service -a "name=nginx state=started" --become
```

---

### copy

```bash
ansible all -i inventory.ini -m copy -a "src=file.txt dest=/tmp/file.txt"
```

---

## 4. Inventory Usage

### Specify inventory

```bash
-i inventory.ini
```

### Check inventory structure

```bash
ansible-inventory -i inventory.ini --list
```

---

## 5. Host Patterns

```bash
ansible all        # all hosts
ansible server     # specific group
ansible web[0]     # specific host
```

---

## 6. Privilege Escalation

```bash
--become
```

Example:

```bash
ansible all -i inventory.ini -a "apt update" --become
```

---

## 7. User & SSH Options

### Specify user

```bash
-u ubuntu
```

### Private key

```bash
--private-key ansible-ssh-key
```

---

## 8. Playbook Commands

### Run playbook

```bash
ansible-playbook -i inventory.ini playbook.yaml
```

### Verbose mode

```bash
-v
-vv
-vvv
```

### Dry run

```bash
ansible-playbook playbook.yaml --check
```

---

## 9. Debugging & Testing

### Test connection

```bash
ansible all -i inventory.ini -m ping
```

### Increase verbosity

```bash
-vvv
```

---


# Key Takeaways

* `ansible` → ad-hoc commands
* `ansible-playbook` → automation via YAML
* `-i` → inventory
* `-m` → module
* `-a` → arguments
* `--become` → sudo
