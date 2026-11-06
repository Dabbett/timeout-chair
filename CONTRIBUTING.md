# Contributing

Issues and pull requests are welcome. The most useful report is a failure the investigator got wrong: what happened, what it concluded, and what it should have concluded. Remove anything private first.

Before opening a pull request:

```bash
claude plugin validate .
```

```bash
shellcheck tests/*.sh skills/*/scripts/*.sh
```

If you change the skills or the investigator, also run these. Both make real model calls on your account:

```bash
tests/scenarios.sh
```

```bash
claude plugin eval .
```

Bump `version` in `.claude-plugin/plugin.json` and add a `CHANGELOG.md` entry for any change users will notice.
