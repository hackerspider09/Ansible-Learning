# templates

templates let you generate dynamic config files using variables. instead of copying a fixed file, ansible renders the template at runtime - substituting variables into the file content before placing it on the host.

uses jinja2 templating syntax.

---

## how it works

1. you write a `.j2` file with placeholders like `{{ variable_name }}`
2. the `template` module renders it - substituting all variables with their actual values
3. the rendered file is placed on the remote host

---

## jinja2 basics

variables:

```
{{ app_name }}
{{ app_port }}
```

conditions:

```
{% if enable_ssl %}
ssl = true
{% endif %}
```

loops:

```
{% for item in list %}
  - {{ item }}
{% endfor %}
```

---

## template module

```yaml
- name: Generate config
  template:
    src: app.conf.j2        # relative to templates/ dir automatically
    dest: /etc/app/app.conf
```

ansible looks for `src` inside `roles/<role_name>/templates/` automatically.

---

## where variables come from

any variable that's in ansible's scope can be used in a template. that includes:

- `defaults/main.yaml` in the role
- `vars/main.yaml` in the role
- `group_vars/`, `host_vars/`
- passed inline when calling the role
- extra vars from cli

see [variables_order](../variables_order/variables.md) for the full priority chain.

---

## files vs templates

| files/              | templates/               |
| ------------------- | ------------------------ |
| static              | dynamic                  |
| copied exactly      | rendered using variables |
| use `copy` module   | use `template` module    |
| no jinja2           | full jinja2 support      |