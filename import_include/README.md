# import and include

ansible has two ways to split and reuse tasks or roles: **import** (static) and **include** (dynamic).

the difference is WHEN ansible loads the content:

- `import_*` - loaded at **parse time**, before execution starts
- `include_*` - loaded at **runtime**, when execution reaches that line

---

## two phases of ansible execution

ansible doesn't just run YAML line by line. it has two phases:

**parse phase** - before anything runs:
- reads all YAML files
- validates syntax
- expands all `import_*` statements (copy-pastes their content in)
- builds a full execution plan

**execution phase** - actual work:
- runs tasks in order
- evaluates conditions (`when:`)
- resolves variables
- loads `include_*` files when their line is reached

---

## see the difference yourself

the easiest way to feel parse vs runtime is to break something and watch when the error shows up.

**test with import_tasks:**

break `tasks/step_b.yml` - add an invalid key:

```yaml
- name: step B
  debug:
    msg: "step B"
  invalid_key: this should fail   # bad yaml structure
```

now run:

```bash
ansible-playbook playbooks/01_import_tasks.yaml
```

ansible fails **immediately**, before any task runs. you'll see the error at the top with no tasks executed at all - because `step_b.yml` was loaded at parse time.

---

**now do the same with include_tasks:**

same broken `tasks/step_b.yml`. run:

```bash
ansible-playbook playbooks/02_include_tasks.yaml
```

this time:
- `before include` task **runs and succeeds**
- `step_a.yml` **runs and succeeds**
- then ansible hits the `include_tasks: step_b.yml` line, loads it, **fails here**

the error shows up mid-execution, not at the start. tasks before the include already ran.

this is the core behavioral difference in one experiment.

revert `step_b.yml` after testing:

```yaml
- name: step B
  debug:
    msg: "step B executed"
```

---

## import_tasks


static. task file content is expanded into the playbook at parse time.

```yaml
- import_tasks: ../tasks/step_a.yml
- import_tasks: ../tasks/step_b.yml
```

ansible sees both as if they were written inline. all tasks are known before execution starts.

- tags applied to `import_tasks` propagate into the imported tasks
- cannot use `when:` to skip at the task-file level (it gets applied to each individual task inside)
- cannot use `loop:` on `import_tasks`
- `ansible-playbook --list-tasks` shows all tasks because ansible knows them at parse time

---

## include_tasks

dynamic. task file is loaded at runtime when execution reaches that line.

```yaml
- include_tasks: ../tasks/step_a.yml
- include_tasks: ../tasks/step_b.yml
```

ansible doesn't know what's inside until it gets there.

- supports `when:` - the whole file is skipped if condition is false
- supports `loop:` - can load the same file multiple times with different vars
- supports dynamic filenames based on variables:

```yaml
- include_tasks: "../tasks/{{ ansible_os_family }}.yml"  # loads ubuntu.yml or redhat.yml at runtime
```

- `ansible-playbook --list-tasks` won't show tasks inside includes because they aren't loaded yet
- a syntax error inside an included file only surfaces when execution reaches it - hidden bugs are possible if a `when:` condition is rarely true

---

## import_role

static. role is loaded at parse time.

```yaml
tasks:
  - name: before
    debug:
      msg: "before role"

  - import_role:
      name: my_role

  - name: after
    debug:
      msg: "after role"
```

ansible sees all role tasks before execution. tags work fully. but `when:` on `import_role` applies per-task inside the role, not to the role as a whole.

---

## include_role

dynamic. role is loaded at runtime when execution reaches that task.

```yaml
tasks:
  - name: before
    debug:
      msg: "before role"

  - include_role:
      name: my_role

  - name: after
    debug:
      msg: "after role"
```

execution is strictly sequential - `before` runs, then the entire role, then `after`.

supports `when:` on the role itself:

```yaml
- include_role:
    name: optional_role
  when: run_optional | bool
```

if `run_optional` is false, the entire role is skipped. this is only possible with `include_role`.

`| bool` is needed when passing the value from cli with `-e` - cli always passes strings, so `"false"` would be truthy without the filter.

supports `loop:` too - can call the same role multiple times with different vars.

---

## import_tasks inside a role

a role can use `import_tasks` internally to split its own tasks into sub-files while keeping `main.yml` clean:

```
roles/modular_role/
└── tasks/
    ├── main.yml       ← entry point
    ├── install.yml    ← install phase
    └── verify.yml     ← verify phase
```

```yaml
# tasks/main.yml
- import_tasks: install.yml
- import_tasks: verify.yml
```

from outside, you just call the role normally. the internal split is invisible to the playbook.

---

## comparison

| | import_tasks | include_tasks | import_role | include_role |
| --- | --- | --- | --- | --- |
| when loaded | parse time | runtime | parse time | runtime |
| `when:` skips whole thing | no | yes | no | yes |
| `loop:` supported | no | yes | no | yes |
| dynamic filename | no | yes | no | no |
| tags propagate fully | yes | limited | yes | limited |

---

## how to run the playbooks in this dir

```bash
# import_tasks - static task split, inline tasks around it
ansible-playbook playbooks/01_import_tasks.yaml

# include_tasks - dynamic task split, inline tasks around it
ansible-playbook playbooks/02_include_tasks.yaml

# import_role - static role loading, inline tasks before and after
ansible-playbook playbooks/03_import_role.yaml

# include_role - dynamic role loading, inline tasks before and after
ansible-playbook playbooks/04_include_role.yaml

# include_role with when: - conditional role, try with -e "run_optional=false"
ansible-playbook playbooks/05_include_role_when.yaml
ansible-playbook playbooks/05_include_role_when.yaml -e "run_optional=false"

# mixed - everything together: import_tasks, include_role, role with internal import_tasks, include_role with when:
ansible-playbook playbooks/06_mixed.yaml
```

---

## mixing both

you don't have to pick one. you can use `import_*` inside a role to keep the task structure clean and predictable, and use `include_*` at the playbook level where you need runtime decisions.

```yaml
# tasks/main.yml inside a role - split into phases with import_tasks
- import_tasks: install.yml
- import_tasks: config.yml
- import_tasks: service.yml
```

```yaml
# inside config.yml - load the right file based on OS at runtime
- include_tasks: "{{ ansible_os_family }}.yml"   # loads ubuntu.yml or redhat.yml
```


---

## mental model

```
parse time:
  import_tasks  → content copy-pasted inline
  import_role   → role tasks copy-pasted inline
  result: ansible has full execution plan before running

runtime:
  include_tasks → file loaded when execution reaches that line
  include_role  → role loaded when execution reaches that task
  result: decisions made as execution progresses
```
