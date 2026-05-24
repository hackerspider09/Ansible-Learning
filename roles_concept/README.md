# roles

roles are ansible's way to organize automation into reusable components.

instead of one giant playbook, you split your automation into focused units - each role handles one responsibility.

---

## why roles exist

playbooks start small, but they grow.

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

as infrastructure grows:

- playbooks get huge
- code gets duplicated
- debugging becomes messy
- reuse becomes hard

roles solve this.

---

## what a role is

a role is just a directory with a specific structure. ansible knows what to do with each folder automatically.

```
roles/
├── docker/
├── nginx/
└── monitoring/
```

each role handles one thing. you call it from your playbook, ansible handles the rest.

---

## role directory structure

```
roles/
└── my_role/
    ├── tasks/
    │   └── main.yml      ← entry point, always executed
    ├── handlers/
    │   └── main.yml      ← triggered by notify
    ├── files/            ← static files to copy
    ├── templates/        ← jinja2 templates (.j2)
    ├── vars/
    │   └── main.yml      ← high priority variables
    ├── defaults/
    │   └── main.yml      ← low priority variables (easy to override)
    ├── meta/
    │   └── main.yml      ← role metadata + dependencies
    ├── tests/
    └── README.md
```

most directories are optional. minimum working role:

```
roles/
└── my_role/
    └── tasks/
        └── main.yml
```

---

## creating roles

**manually:**

```bash
mkdir -p roles/my_role/tasks
touch roles/my_role/tasks/main.yml
```

**using ansible-galaxy (generates full structure):**

```bash
ansible-galaxy init roles/my_role
```

---

## role directories explained

### tasks/

actual automation tasks. `tasks/main.yml` is the entry point - ansible executes it automatically when the role is called.

for bigger roles, split tasks into multiple files and import them:

```yaml
# tasks/main.yml
- import_tasks: install.yml
- import_tasks: config.yml
- import_tasks: service.yml
```

### handlers/

handlers are special tasks that only run when notified by another task.

commonly used to restart services or reload configs after a change.

```yaml
# handlers/main.yml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

task that triggers it:

```yaml
- name: Copy nginx config
  copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx
```

handler only runs if the task actually changed something. even if multiple tasks notify the same handler, it runs only once at the end of the play.

handlers can also use `listen:` - useful when multiple handlers should respond to the same notification:

```yaml
- name: Print status
  debug:
    msg: "done"
  listen: Restart nginx   # responds to the same notify string
```

see [handler.md](handler.md) for more.

### files/

static files to copy to remote hosts. no variables, copied exactly as-is.

```yaml
- copy:
    src: nginx.conf        # relative to files/ dir automatically
    dest: /etc/nginx/nginx.conf
```

### templates/

dynamic files using jinja2 templating. variables get substituted at runtime.

```
templates/app.conf.j2
```

```
server_name = {{ domain_name }}
port = {{ app_port }}
```

used with the `template` module:

```yaml
- template:
    src: app.conf.j2
    dest: /etc/app/app.conf
```

see [template.md](template.md) for more on jinja2.

| files/              | templates/               |
| ------------------- | ------------------------ |
| static              | dynamic                  |
| copied exactly      | rendered using variables |
| no variable support | full jinja2 support      |

### vars/ vs defaults/

both store variables. difference is priority.

- `defaults/main.yml` - lowest priority, designed to be overridden
- `vars/main.yml` - high priority, usually internal role values

```
defaults < inventory vars < play vars < vars
```

see [variables_order](../variables_order/variables.md) for the full priority chain.

### meta/

`meta/main.yml` has two jobs: **galaxy_info** (role metadata) and **dependencies**.

#### galaxy_info

describes the role - used by ansible galaxy when you publish a role, but also just useful documentation even for private roles.

```yaml
# meta/main.yml
galaxy_info:
  author: yourname
  description: installs and configures nginx
  license: MIT
  min_ansible_version: "2.9"

  platforms:
    - name: Ubuntu
      versions:
        - focal
        - jammy
    - name: EL          # RHEL / CentOS / Rocky
      versions:
        - 8
        - 9

  galaxy_tags:
    - nginx
    - webserver
    - linux
```

- `platforms` - which OS/versions this role supports. ansible galaxy uses this to filter roles
- `min_ansible_version` - guards against running on old ansible
- `galaxy_tags` - searchable tags on galaxy.ansible.com

#### dependencies

roles this role needs to run first. ansible automatically runs them before the current role - even if you never called them in your playbook.

```yaml
dependencies:
  - role: common
  - role: firewall
```

you can also pass variables into a dependency:

```yaml
dependencies:
  - role: common
    vars:
      some_var: value
  - role: firewall
    vars:
      open_port: 80
```

execution order - if `app_role` declares `base_role` as a dependency:

```
1. base_role runs
2. app_role runs
```

even though you only called `app_role` in your playbook.

---

## using roles in a playbook

### method 1: `roles:` key

simplest. roles listed under `roles:` run before `tasks:`.

```yaml
- hosts: all
  roles:
    - docker
    - nginx
```

ansible internal execution order:

```
pre_tasks → roles → tasks → post_tasks
```

you can also pass variables directly at role call time:

```yaml
roles:
  - role: template_role
    app_name: "my app"
```

### method 2: `include_role` (dynamic)

role is loaded at runtime, exactly at that point in task execution.

```yaml
tasks:
  - name: Update packages
    apt:
      update_cache: yes

  - name: Install Docker
    include_role:
      name: docker

  - name: Verify Docker
    command: docker --version
```

execution goes line by line - the role runs between the tasks around it.

supports conditions and loops:

```yaml
- include_role:
    name: docker
  when: ansible_distribution == "Ubuntu"
```

### method 3: `import_role` (static)

role is parsed before execution starts. less flexible but more predictable.

```yaml
tasks:
  - import_role:
      name: docker
```

| include_role               | import_role                |
| -------------------------- | -------------------------- |
| dynamic (runtime)          | static (parse time)        |
| supports when + loops      | limited                    |
| flexible for orchestration | predictable, no surprises  |

---

## how to run the playbooks in this dir

```bash
# handler role - covers files/, handlers/, listen
ansible-playbook playbooks/handler_playbook.yaml

# template role - covers templates/, jinja2, passing vars via roles:
ansible-playbook playbooks/template_role.yaml

# dependency role - covers meta/, role dependencies, execution order
ansible-playbook playbooks/dependency_playbook.yaml
```

---

## mental model

```
Playbook
   ↓
calls Roles  (roles: / include_role / import_role)
   ↓
Roles organize automation
   ↓
tasks/ runs the steps
   ↓
handlers/ reacts to changes
   ↓
files/ + templates/ provide content
   ↓
vars/ + defaults/ provide values
   ↓
meta/ handles dependencies
```
