# Variable order

lowest to highest priority:

```
role defaults < ini [all:vars] < ini [group:vars] < group_vars/all < group_vars/<group> < ini inline host var < host_vars < play vars < role vars < task vars < cli extra vars
```

---

## what is a group?

in ansible inventory you define hosts and you can put them into groups.
eg in `local_host.ini`:

```ini
[local]           <- this is a group called "local"
localhost ansible_connection=local
```

so `localhost` is a host that belongs to group `local`.
`all` is a special built-in group every host is automatically part of it.

---

## inventory file variables

you can define variables directly inside the `.ini` file. there are 3 ways, each with different priority:

```ini
[local]
# 3. inline host var - written on the same line as the host, highest among ini vars
localhost ansible_connection=local app_name="value_from_ini_inline_host"

# 2. group vars for [local] group - applies to all hosts in this group
[local:vars]
app_name="value_from_ini_groupedhosts"

# 1. all:vars - applies to every host, lowest among ini vars
[all:vars]
app_name="value_from_ini_allhosts"
```

precedence inside inventory file (lowest to highest):
```
[all:vars]  <  [group:vars]  <  inline host var
```

so if all three are active, inline host var wins.

note: `group_vars/` directory files beat ini [all:vars] and ini [group:vars], but ini inline host var beats `group_vars/`. only `host_vars/` beats inline host var.

---

## group_vars/

instead of putting vars inside the .ini file you can create a `group_vars/` directory.
ansible will automatically pick it up.

```
group_vars/
  all.yaml        <- same as [all:vars] in ini, applies to all hosts
  local.yaml      <- same as [local:vars] in ini, applies to [local] group
```

`group_vars/local.yaml` beats `group_vars/all.yaml` because specific group > all group

---

## host_vars/

for host-specific variables, create a `host_vars/` directory.
file name should match the hostname exactly.

```
host_vars/
  localhost.yaml  <- only applies to the host named "localhost"
```

`host_vars` beats everything in `group_vars` because it's host-specific, more specific = higher priority

---

## role variable:

role has two places to define variables:
- `defaults/main.yaml` - lowest priority, easy to override
- `vars/main.yaml` - high priority, hard to override

`role vars` beats `host_vars`, `group_vars`, `play vars` etc.
`role defaults` is the lowest of all - gets overridden by almost everything

---

## play vars:

variables defined directly in playbook under `vars:` section

```yaml
- hosts: all
  vars:
    app_name: value_from_playbook
```

---

## task vars:

variables defined directly on a task or inside a block using `vars:` key.
applies only to that specific task or block, not the whole play.

```yaml
tasks:
  - name: Check variable priority
    include_role:
      name: variable_role
    vars:
      app_name: value_from_task    # <- only for this task
```

beats role vars, play vars, host_vars - basically everything except cli extra vars

---

## extra vars:

passed from cli, highest priority, overrides everything

```bash
ansible-playbook playbook.yaml -e "app_name=value_from_cli"
```

---

# how to test precedence

run: `ansible-playbook playbook.yaml`

the playbook has everything commented out so you can uncomment one at a time and see which one wins.

**step by step - uncomment only one at a time and run:**

1. **role defaults** - uncomment `defaults/main.yaml`, comment everything else  
   → should print `value_from_defaults`

2. **ini [all:vars]** - keep only `[all:vars]` active in `local_host.ini`  
   → should print `value_from_ini_allhosts` (beats defaults)

3. **ini [local:vars]** - keep `[local:vars]` active too  
   → should print `value_from_ini_groupedhosts` (beats [all:vars])

4. **group_vars/all** - uncomment `group_vars/all.yaml`, keep ini vars active  
   → should print `value_from_group_vars_all` (beats ini [all:vars] and [group:vars])

5. **group_vars/local** - uncomment `group_vars/local.yaml`  
   → should print `value_from_group_vars_local` (beats group_vars/all)

6. **ini inline host var** - uncomment the inline host line in `local_host.ini`, comment out `localhost ansible_connection=local`  
   → should print `value_from_ini_inline_host` (beats group_vars)

7. **host_vars** - `host_vars/localhost.yaml` is already active  
   → should print `value_from_host_vars` (beats inline host var)

8. **play vars** - uncomment `vars:` block in playbook.yaml  
   → should print `value_from_playbook` (beats host_vars)

9. **role vars** - uncomment `vars/main.yaml`  
   → should print `value_from_vars` (beats play vars)

10. **task vars** - uncomment `vars:` under the task in playbook.yaml  
    → should print `value_from_task` (beats role vars)

11. **cli extra vars** - run with `-e "app_name=value_from_cli"`  
    → should print `value_from_cli` (beats everything)