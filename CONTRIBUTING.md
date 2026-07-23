# Contributing

Issues and focused pull requests are welcome.

## Development

1. Fork and clone the repository.
2. Install `stylua` and `shellcheck`.
3. Run `make lint` before opening a pull request.
4. Run `make smoke` when changing plugin loading, installation, or session behavior.

Keep changes scoped. Do not commit credentials, `~/.codex`, machine-specific absolute paths, or generated plugin data. User-facing behavior should work on Linux, macOS, and WSL where practical.

## Commit messages

Use a short imperative summary, for example:

```text
Improve project session detection
```
