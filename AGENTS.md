# AGENTS.md

Instructions for any coding agent working in this repo (Claude Code, Codex,
Cursor, Copilot, Aider, Gemini CLI, …). This file is the single source of
truth; the agent-specific files at the root are one-line pointers to it.

---

## 1. What this repo is

A monorepo of my worked solutions to courses on
[shipthatcode.com](https://shipthatcode.com). One folder per course under
`courses/`, each one an exact, unmodified starter layout from the platform
with my own code filled in.

```
.
├── AGENTS.md              <- you are here; source of truth
├── CLAUDE.md              <- pointer to this file
├── courses.json           <- registry: slug, language, entrypoint, mirror remote
├── courses/<slug>/        <- one course, starter layout preserved at ITS root
├── scripts/stc            <- the only tool you need; see §4
├── docs/                  <- platform mechanics, workflow, environment, publishing
├── notes/                 <- UNTRACKED lesson notes (see §6)
└── .zips/                 <- UNTRACKED original downloads, for `stc sync`
```

## 2. How the platform works (verified, 2026-07-24)

Read `docs/platform.md` for the full findings. The load-bearing facts:

- **Every exercise is stdin → stdout, compared byte for byte.** This holds even
  for the systems courses — "Build a Database" lesson 1 is *"Build a tokenizer
  that reads SQL from stdin and outputs tokens in `TYPE VALUE` format, one per
  line."* There is no qemu, no linking a real kernel, no test framework.
- **One entrypoint file per course**, named in `.shipthatcode.json`
  (`main.rs`, `main.c`, …). It grows across lessons; later lessons add to the
  same file rather than creating new ones.
- **`language_id` in `.shipthatcode.json` is a Judge0 language id** (73 = Rust),
  so the remote executor is Judge0-shaped: compile, pipe stdin, diff stdout.
- **There is no public API.** Grading is triggered by a button on the lesson
  page after it pulls your public repo. The only public API host is
  `api.shipthatcode.com/cert/<hash>.svg`, which serves the README badge.
- **Grading reads the repo ROOT** — `.shipthatcode.json`, the entrypoint and
  `tests/` must all sit at the root of whatever repo you linked. This is why
  §5 exists.

## 3. Hard rules

1. **Never edit anything under `courses/<slug>/tests/`.** Those are the
   platform's fixtures. A local FAIL means the solution is wrong, or it's the
   line-ending trap below — never "fix" the expected output.
2. **Never edit `courses/<slug>/.shipthatcode.json`.** It identifies the repo to
   the grader and carries content hashes. `stc sync` replaces it wholesale when
   a course is updated; nothing else should touch it.
3. **Never install a language toolchain on the host machine.** This is a work
   machine. Everything compiles and runs inside a throwaway Docker container
   that `stc` picks per course. If a tool is missing, add it to the language map
   in `scripts/lib/langmap.sh` — do not `apt install`, `rustup`, `winget` or
   `choco` anything outside a container.
4. **Write solutions only in the course's declared entrypoint.** Adding
   `helper.rs` next to `main.rs` will compile locally and fail on the executor,
   which only ever builds the one file.
5. **Byte-exactness is the whole game.** No trailing newline you didn't ask
   for, no debug prints to stdout (use stderr), no locale-dependent number
   formatting.
6. `run_tests.sh` inside each course is the platform's own runner and is
   preserved verbatim. Invoke it through `stc test`, which supplies the right
   container. Don't rewrite it.

### The line-ending trap

Tests are byte-exact and this repo is edited on Windows. Two guards are in
place, and both must stay:

- `.gitattributes` marks `tests/**/*.in|*.out` as `-text` so git never
  translates CRLF on checkout.
- `stc test` runs inside Linux, so the compiler never emits `\r\n`.

If you ever see a FAIL whose `expected:` and `got:` look identical, that is
this trap and not a logic bug.

## 4. The `stc` helper — use it instead of ad-hoc commands

`scripts/stc` is POSIX shell. On Windows run it from Git Bash, or use
`scripts\stc.cmd` from PowerShell, or just work inside the devcontainer.

| Command | What it does |
|---|---|
| `stc unpack <zip>` | Extract a downloaded starter into `courses/<slug>/`, drop any nested `.git`, register it in `courses.json`, archive the zip in `.zips/` |
| `stc test <slug> [nn]` | Run the course's own `run_tests.sh` in the correct language container. `nn` limits to one lesson, e.g. `stc test rust-fundamentals 03` |
| `stc shell <slug>` | Interactive shell in that course's toolchain container, cwd at the course root |
| `stc status` | Table of every registered course: language, lessons, dirty state, mirror remote |
| `stc sync <slug> <zip>` | Course was updated upstream: replace `tests/` and `.shipthatcode.json` from a fresh zip, keep my code untouched |
| `stc publish <slug>` | Subtree-split the course to a root-correct commit and force-push it to its grading mirror (see §5) |
| `stc note <slug> <lesson>` | Create/open an untracked note at `notes/<slug>/<lesson>.md`, reading stdin if piped |
| `stc lang <slug>` | Show (and pre-build, if needed) the container image for that course |

Prefer `stc` over reinventing a docker invocation. If it can't do something,
extend it rather than working around it.

## 5. Monorepo, but the grader needs repo roots

Everything lives in this one repo for day-to-day work. Because the grader
insists on reading a repo root (§2), publishing is a **subtree split**:

```
stc publish rust-fundamentals
  → git subtree split --prefix=courses/rust-fundamentals
  → force-push that history to the course's own public repo
  → paste that repo's URL once on the course page ("Link repo")
```

The mirror's root is the course folder, so the grader sees exactly the layout
it expects. Consequences to keep in mind:

- The mirror is **push-only and force-pushed**. Never commit into a mirror
  directly; it will be overwritten.
- The mirror is **public** (the grader must clone it). Nothing secret, and
  nothing copyrighted, may sit inside `courses/`.
- Mirror remotes are recorded per course in `courses.json`.
- A course is not gradeable until it has been published *and* linked once.

## 6. Lesson notes and copyright

`notes/` is gitignored and sits outside `courses/`, deliberately.

- **Do** put my own summaries, mental models, gotchas, and links there.
- **Do not** paste shipthatcode's lesson prose into any tracked file. This repo
  and every mirror is public; that would republish their paid material.
- When I paste a lesson into the chat and ask for it as markdown, write it to
  `notes/<slug>/<nn>-<lesson>.md` (untracked), never into `courses/`.

Because `stc publish` only ever splits `courses/<slug>/`, notes cannot leak
into a mirror even by accident.

## 7. Working on a lesson

1. Read the lesson on the site. Capture anything worth keeping via `stc note`.
2. Write the solution in `courses/<slug>/<entrypoint>`.
3. `stc test <slug> <nn>` until green, then `stc test <slug>` for the whole suite
   — later lessons must not regress earlier ones, since it's all one file.
4. Commit in this repo (normal monorepo commit).
5. `stc publish <slug>`.
6. Hit **Check my solution** on the lesson page. That runs hidden tests too, so
   a local pass is necessary but not sufficient.

Commit messages: `<slug>: lesson <nn> <short-slug>`, e.g.
`rust-fundamentals: lesson 09 ownership-and-borrowing`.

## 8. Conventions for agents

- **Don't solve ahead of me.** If I'm on lesson 09, don't fill in 10–15. The
  point of the repo is that I write the code. Explain, review, and unblock;
  write the solution only when I ask for it directly.
- Don't add a build system a course didn't ship with (no `Cargo.toml` for a
  single-file `rustc` course — the executor won't use it and it changes how the
  code must be structured).
- Don't `git push` anything without being asked. `stc publish` force-pushes;
  treat it as an explicit user action.
- Keep this repo's own tooling dependency-free: POSIX shell and Docker, nothing
  that needs installing on the host.
- New docs go in `docs/` and get a line in §1's tree and in `README.md`.
