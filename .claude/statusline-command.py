#!/usr/bin/env python3
"""Claude Code status line: model + effort / project:git branch status / 5-hour usage / weekly (7d) usage / context window usage.

Reads the status line JSON from stdin. Does not require jq. Missing fields never
raise an error: before the first API response the usage segments are shown as
"--"; once a response has arrived, a usage limit the API does not report (for
example rate limits for non-subscribers) is hidden instead. Errors are written to
stderr, never to stdout.
"""
import json
import math
import os
import subprocess
import sys
import time
import traceback

RESET = "\033[0m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
MUTED = "\033[37m"  # light gray for separators, placeholders and countdowns; the old bright-black gray was hard to read when dimmed
CYAN = "\033[36m"
MAGENTA = "\033[35m"
BLUE = "\033[34m"
BRIGHT = "\033[97m"


def log(message):
    sys.stderr.write("statusline: %s\n" % message)


def get(data, *keys):
    for key in keys:
        if not isinstance(data, dict):
            return None
        data = data.get(key)
    return data


def as_number(value):
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        return None
    return value


def format_remaining(resets_at):
    """Time until an epoch-seconds timestamp, like "2d4h", "1h20m" or "5m"; None if unknown or already passed."""
    resets_at = as_number(resets_at)
    if resets_at is None:
        return None
    seconds = int(resets_at - time.time())
    if seconds <= 0:
        return None
    days, rest = divmod(seconds, 86400)
    hours, rest = divmod(rest, 3600)
    minutes = rest // 60
    if days:
        return "%dd%dh" % (days, hours)
    if hours:
        return "%dh%dm" % (hours, minutes)
    return "%dm" % minutes if minutes else "<1m"


def render(label, value, resets_at=None):
    value = as_number(value)
    if value is None:
        return "%s%s: --%s" % (MUTED, label, RESET)
    percent = math.floor(value + 0.5)  # round half up; this one integer drives both the shown text and the color
    if percent >= 80:
        color = RED
    elif percent >= 50:
        color = YELLOW
    else:
        color = GREEN
    text = "%s%s: %d%%%s" % (color, label, percent, RESET)
    remaining = format_remaining(resets_at)
    if remaining:
        text += " %s(%s)%s" % (MUTED, remaining, RESET)
    return text


def colored(value, color):
    if not isinstance(value, str) or not value:
        return None
    return "%s%s%s" % (color, value, RESET)


def git_status(directory):
    """Branch summary like "main* ↑1 ↓2" ("detached@<hash>" on a detached HEAD, "*" when dirty), or None outside a repository."""
    try:
        result = subprocess.run(
            ["git", "--no-optional-locks", "status", "--porcelain=v2", "--branch"],
            cwd=directory, capture_output=True, text=True, errors="replace", timeout=1,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        log("git status failed: %s" % exc)
        return None
    if result.returncode != 0:
        return None

    head = oid = None
    ahead = behind = 0
    dirty = False
    for line in result.stdout.splitlines():
        if line.startswith("# branch.head "):
            head = line[len("# branch.head "):]
        elif line.startswith("# branch.oid "):
            oid = line[len("# branch.oid "):]
        elif line.startswith("# branch.ab "):
            fields = line.split()  # ["#", "branch.ab", "+<ahead>", "-<behind>"]
            try:
                ahead, behind = abs(int(fields[2])), abs(int(fields[3]))
            except (IndexError, ValueError):
                pass
        elif not line.startswith("#"):
            dirty = True  # the header lines come first, so the first file entry means the tree is dirty
            break
    if not head:
        return None

    if head == "(detached)":
        text = "detached@%s" % (oid or "")[:7]
    else:
        text = head
    if dirty:
        text += "*"
    if ahead:
        text += " ↑%d" % ahead
    if behind:
        text += " ↓%d" % behind
    return text


def project_name(data):
    """Linked worktree name if set, else the repository name, else the current directory's basename."""
    directory = get(data, "workspace", "current_dir")
    candidates = (
        get(data, "workspace", "git_worktree"),
        get(data, "workspace", "repo", "name"),
        os.path.basename(directory.rstrip("/")) if isinstance(directory, str) else None,
    )
    for name in candidates:
        text = colored(name, BRIGHT)
        if text:
            return text
    return None


def main():
    sys.stdout.reconfigure(encoding="utf-8")  # the git segment uses non-ASCII arrows regardless of the locale
    try:
        data = json.load(sys.stdin)
    except Exception as exc:
        log("could not read the input JSON: %s" % exc)
        data = {}

    # effort.level is absent when the current model does not support the effort parameter
    model = colored(get(data, "model", "display_name"), CYAN)
    effort = colored(get(data, "effort", "level"), MAGENTA)
    head = " ".join(part for part in (model, effort) if part)

    context = get(data, "context_window", "used_percentage")

    # Rate limits are only reported for subscribers. Before the first response (context still unknown) show "--";
    # afterwards hide a limit that is not reported rather than showing "--" forever.
    first_response_seen = as_number(context) is not None
    limits = []
    for label, window in (("5h", "five_hour"), ("7d", "seven_day")):
        used = get(data, "rate_limits", window, "used_percentage")
        if as_number(used) is None and first_response_seen:
            continue
        limits.append(render(label, used, get(data, "rate_limits", window, "resets_at")))

    sep = " %s|%s " % (MUTED, RESET)
    directory = get(data, "workspace", "current_dir")
    branch = colored(git_status(directory if isinstance(directory, str) else None), BLUE)

    # project and branch form one segment joined by ":"; either one alone is shown as-is
    location = ("%s:%s" % (MUTED, RESET)).join(part for part in (project_name(data), branch) if part)

    parts = [part for part in (head, location) if part]
    parts += limits
    parts.append(render("ctx", context))
    sys.stdout.write(sep.join(parts))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        traceback.print_exc()  # to stderr; stdout stays empty rather than showing garbage
