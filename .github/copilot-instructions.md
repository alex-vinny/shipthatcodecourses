# Copilot instructions

The instructions for this repository live in [`AGENTS.md`](../AGENTS.md) at the
repository root. Read that file and follow it.

Summary of the rules most easily broken here:

- Never edit `courses/*/tests/**` or `courses/*/.shipthatcode.json`.
- Write solutions only in the course's declared entrypoint (one file per course).
- Never install a language toolchain on the host; use `scripts/stc`, which runs
  everything in Docker.
- Tests are compared byte for byte. No stray output, no trailing newlines.
- Don't paste course lesson prose into tracked files — this repo is public.
