# handlers

handlers are special tasks that only run when they are **notified** by another task.

if a task doesn't result in a change, it doesn't notify - so the handler doesn't run. this makes handlers perfect for things like restarting a service only when its config actually changed.

---

## how it works

1. a task does something (copy a file, update a config, install a package)
2. if that task results in `changed`, it sends a notification using `notify:`
3. at the end of the play, ansible runs any handlers that were notified

key point: handlers run **once at the end**, not immediately when notified. even if 5 tasks notify the same handler, it runs only once.

---

## syntax

**task that notifies:**

```yaml
- name: Copy nginx config
  copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart nginx
```

**handler that responds:**

```yaml
# handlers/main.yml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

the string in `notify:` must exactly match the handler `name:`.

---

## listen

handlers can also use `listen:` instead of matching by name. useful when multiple handlers should respond to the same notification, or when you want to decouple the handler name from the notify string.

```yaml
- name: Print File Status
  debug:
    msg: "File exists => {{ taskOp.stat.exists }}"
  listen: Check File
```

task notifies `Check File` → any handler with `listen: Check File` runs, regardless of what the handler's own `name:` is.