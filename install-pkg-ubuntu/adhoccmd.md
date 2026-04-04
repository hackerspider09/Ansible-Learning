
# What is an Ad-hoc Command in Ansible?

**Ad-hoc = one-time, quick command executed without a playbook**

---

## Definition (simple)

Any command you run using:

```bash
ansible <hosts> -m <module> -a "<args>"
```

is called an **ad-hoc command**

---

## Key Idea

* Runs **immediately**
* Not saved in a YAML file
* Used for **quick tasks / testing**

---

**ALL of these are ad-hoc commands:**

```bash
ansible all -a "whoami"
ansible all -m command -a "whoami"
ansible all -m shell -a "df -h"
```

Even if you don’t write `-m`, it still uses:

```bash
-m command   (default)
```

---

## Ad-hoc vs Playbook

| Feature    | Ad-hoc Command            | Playbook                      |
| ---------- | ------------------------- | ----------------------------- |
| Format     | CLI                       | YAML file                     |
| Usage      | Quick / one-time          | Reusable automation           |
| Complexity | Simple                    | Complex workflows             |
| Example    | `ansible all -a "uptime"` | `ansible-playbook setup.yaml` |

---


## When to use what?

### Use Ad-hoc when:

* Testing connection (`ping`)
* Checking disk (`df -h`)
* Quick fixes

### Use Playbook when:

* Installing packages
* Deploying apps
* Repeated tasks

---

# Final One-Line Definition

**Ad-hoc commands = any Ansible CLI command used to run tasks directly without a playbook**

