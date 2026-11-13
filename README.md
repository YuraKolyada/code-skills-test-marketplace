# code-skills-test: code standards for Claude Code

A plugin that makes Claude in the **Code** tab always write code by the rules: project style, security, accessibility, and checks after changes.

| What | How it works | How to use |
|---|---|---|
| Always-on quality mode | On every session start the `SessionStart` hook gives Claude the rules from `plugins/code-skills-test/rules/core.md`: repo rules (ESLint/Prettier/Pint/ruff, etc.) → smallest complete change → security (OWASP) → accessibility (WCAG 2.2 AA) → linter and tests after changes | Nothing, it is always on |
| `review` | Reviews the current changes: bugs, security, accessibility, project style, tests, performance, unneeded code. Plain-language report, "must fix / should fix / minor", numbered. Does not change code | "Check my changes", `/code-skills-test:review` |
| `publish-changes` | Linter, tests, review → fix the "must fix" items → save locally, push, or open a pull request that merges itself after green checks | "Done, publish it" |

To change the rules for everyone, edit `rules/core.md` (short rules that always apply) and `skills/review/references/*.md` (detailed rules and checklist), then push.

Safeguards: nothing is published without green checks and an explicit "yes"; no `--force`; no secrets in code. Changes to payments, authorization, or personal data go only through a pull request with separate confirmation.

---

## How it works

The skills live in a GitHub repository. A colleague connects it **once**, and from then on every `git push` to `main` reaches everyone: Claude Code checks for updates in the background at session start and pulls the new version (it applies from the next session or after `/reload-plugins`).

You do **not** need to bump a version number: `plugin.json` deliberately has no `version` field, so the commit hash is the version and every commit is a new update.

> ⚠️ The repository must be **public**, or each colleague must have GitHub access set up on their computer. A public repo is simpler for non-technical people: it only holds instructions, nothing secret.

## Install in the app (once per person)

**Code** tab → in the message box:

```
/plugin marketplace add YuraKolyada/code-skills-test-marketplace
/plugin install code-skills-test@lineup-tools
```

Choose **Install for you**.

**Turn on auto-update (required, otherwise your changes will not arrive):**
`/plugin` → **Marketplaces** tab → `lineup-tools` → **Enable auto-update**.

## I don't see the plugin

1. Quit the app completely (**Cmd+Q**, not just the window) and reopen it.
2. In the **Code** tab run `/plugin` and check that `code-skills-test` is installed.
3. To check that it works, write "check my changes".

The plugin is installed locally, in Claude Code on this computer. It will not appear on claude.ai or in cloud sessions.

## Alternative: script (auto-update is on right away)

Open the **Code** tab in the Claude app, paste **one line**, and send it:

**macOS:**
```
Run: curl -fsSL https://raw.githubusercontent.com/YuraKolyada/code-skills-test-marketplace/main/install.sh | bash
```

**Windows:**
```
Run in PowerShell: irm https://raw.githubusercontent.com/YuraKolyada/code-skills-test-marketplace/main/install.ps1 | iex
```

Claude will ask for permission: click **Allow**. Then quit and reopen the app completely. Done.

(You can paste the same command without "Run:" into a regular Terminal / PowerShell.)

The script adds two entries to `~/.claude/settings.json` (the repository with auto-update, and the enabled plugin). It does not touch the other settings and makes a backup before changing anything. If the `claude` CLI is installed, it also installs the plugin. Otherwise it prints the `/plugin install` command to run in the Code tab.

## Alternative: ask Claude to edit the settings

The desktop app already includes Claude Code and reads the same settings as the terminal version (`~/.claude/settings.json`). You do **not** need to install the CLI separately: it is enough to add a few lines to that file.

**Code** tab → open any folder → paste and send:

```
Open my ~/.claude/settings.json file (create it if it does not exist) and, WITHOUT removing what is already there, add:
- to "extraKnownMarketplaces": "lineup-tools": { "source": { "source": "github", "repo": "YuraKolyada/code-skills-test-marketplace" }, "autoUpdate": true }
- to "enabledPlugins": "code-skills-test@lineup-tools": true
Check that the JSON is valid. Change nothing else. Then tell me to restart the app.
```

Allow the file change → restart the app. On start, Claude Code downloads the repository and installs the plugin.

To check: **+ → Plugins → Manage plugins** lists `code-skills-test`. Or write "check my changes".

> On a Mac without git installed (common on fresh laptops) the download may fail: macOS will offer to install the Command Line Tools, and you need to accept.

### If you are an organization Owner (Team / Enterprise): colleagues need to do nothing

**Organization settings → Claude Code → Managed settings**, paste:

```json
{
  "extraKnownMarketplaces": {
    "lineup-tools": {
      "source": { "source": "github", "repo": "YuraKolyada/code-skills-test-marketplace" },
      "autoUpdate": true
    }
  },
  "enabledPlugins": {
    "code-skills-test@lineup-tools": true
  }
}
```

The plugin installs and updates itself on all of the organization's computers.

## How to ship an update

1. Change the files in `plugins/code-skills-test/skills/…` (or add a new folder with a `SKILL.md`).
2. `git commit` → `git push` to `main`.
3. That's it. Colleagues get the changes the next time they start the app (the new version downloads in the background and is picked up from the next session). Manually: **+ → Plugins → Manage plugins** → `code-skills-test` → update.

Check locally before pushing: `claude plugin validate .`

---

## Structure

```
.claude-plugin/marketplace.json      ← catalog (for the GitHub options)
plugins/code-skills-test/
  .claude-plugin/plugin.json
  skills/<name>/SKILL.md             ← the review and publish-changes skills
  rules/core.md                      ← always-on rules (SessionStart hook)
```
