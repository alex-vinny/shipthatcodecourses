# Environment: why Docker, and why not Nix

Constraint that drove every choice here: **this is a work machine and no
language toolchain gets installed on it.** The courses span ~35 languages, so
"just install the compiler" would mean 35 installs on a machine that shouldn't
have one.

## The decision

**Docker, with a per-course throwaway container.** Docker Desktop 28.0.1 was
already installed and running on this machine, so the recommended setup needed
**zero new installs**. Nothing else clears that bar.

The mechanism is deliberately small:

```
courses/<slug>/.shipthatcode.json   →  "language": "rust"
scripts/lib/langmap.sh              →  rust  →  rust:1-slim
scripts/stc test <slug>             →  docker run --rm -v <course>:/work rust:1-slim \
                                          bash ./run_tests.sh
```

The toolchain is therefore **derived from the course**, not configured. Unpack a
C course tomorrow and `stc test` uses `gcc:14` with no changes. Add an exotic
language and you add one line to `langmap.sh`.

Why per-course containers rather than one big image:

- A single image covering 35 languages would be tens of GB and slow to rebuild.
- Official per-language images already exist and are cached after first pull.
- Zero cross-contamination: the container is `--rm`, so a course can't leave
  anything behind — on the host or in another course.
- It matches the grader, which also compiles one file in a clean Linux box.

### Nix / devenv: considered, rejected

Nix is a genuinely good fit for this problem *in principle* — per-directory
declarative toolchains is exactly what devenv does. It lost on facts specific to
this machine:

- **Nix isn't installed, Docker is.** Installing Nix would be the very install
  the requirement forbids.
- **On Windows, Nix means WSL2 anyway.** There'd be Ubuntu-20.04 → Nix →
  devenv → toolchain, versus Docker → toolchain. Strictly more moving parts for
  the same result.
- **Docker already gives byte-identical Linux behaviour**, which is the actual
  requirement (see the CRLF trap in `docs/platform.md`). Nix on WSL would too,
  but adds nothing beyond it here.
- **The long tail is better served by images.** For cobol, sbcl, mono, dmd,
  octave, there is usually a maintained image; assembling them in Nix is work.

If this ever moves to a Linux or macOS machine, `devenv.nix` becomes a
reasonable alternative — but it would replace `langmap.sh`, not the workflow.

## Two ways to work

### 1. From the host (default, nothing to set up)

Docker is the only requirement. `stc` runs on the host and orchestrates
containers.

```powershell
# PowerShell
.\scripts\stc.cmd status
.\scripts\stc.cmd test rust-fundamentals 01
```

```bash
# Git Bash or WSL
scripts/stc test rust-fundamentals 01
scripts/stc shell rust-fundamentals     # poke around inside the toolchain
```

`scripts/stc.cmd` is a thin shim that hands off to Git Bash. It deliberately
does not change the working directory, so relative paths in arguments still
resolve.

### 2. Inside the devcontainer (optional)

`.devcontainer/devcontainer.json` gives a **thin** hub container: git, gh, the
docker CLI, shellcheck — *no language toolchains*. `stc` inside it launches
language containers as **siblings** on the host daemon
(`docker-outside-of-docker`).

The subtlety this handles, which bites everyone once: `-v` paths are always
interpreted by the **daemon**, never by the client. From inside a devcontainer,
`-v /workspaces/repo/courses/x:/work` means nothing to the host daemon and
silently mounts an empty directory. So `devcontainer.json` exports
`STC_HOST_ROOT=${localWorkspaceFolder}` and `bind_source()` in `scripts/stc`
rewrites workspace paths back to host paths.

It also pins editor behaviour that would otherwise corrupt fixtures:
`files.eol: "\n"` and `files.insertFinalNewline: false`.

### Language-server editing

`stc shell` and `stc test` are enough to compile and grade, but they give no
inline diagnostics. If you want rust-analyzer or clangd while writing, copy
`.devcontainer/course.example.json` into `courses/<slug>/.devcontainer/` and
open that folder in a container. It's safe to commit — the grader only reads
`.shipthatcode.json`, the entrypoint and `tests/`.

Note that single-file courses have no `Cargo.toml`/`compile_commands.json`, so
language servers need a nudge; the example file documents the rust-analyzer
`detachedFiles` settings for exactly this.

**Do not** add a real build manifest to satisfy a language server. The executor
compiles the bare entrypoint, and a `Cargo.toml` changes how the code has to be
structured. That's `AGENTS.md` rule 4.

## Costs

First `stc test` for a language pulls its image (~200 MB–1.5 GB), then it's
cached. Per-run overhead after that is ~1s of container start on top of compile
time. Images are shared across courses in the same language.

To pre-pull before going offline: `stc lang <slug>`.

## When something breaks

| Symptom | Cause |
|---|---|
| `the docker daemon is not responding` | Docker Desktop isn't running |
| Tests fail, `expected:`/`got:` look identical | CRLF. Check `.gitattributes` survived; make sure you ran via `stc`, not a host compiler |
| `bad interpreter: /usr/bin/env bash^M` | `run_tests.sh` got CRLF-ified; `.gitattributes` pins it to LF |
| Empty `/work` in the container | Running inside a devcontainer without `STC_HOST_ROOT` set |
| `no image mapped for language 'x'` | Add it to `scripts/lib/langmap.sh` |
| `can't run locally: …` | Expected for sql/prolog/kotlin/basic — write it, publish, grade on the site |
