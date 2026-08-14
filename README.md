# shipthatcode courses

My worked solutions to courses on [shipthatcode.com](https://shipthatcode.com) —
one folder per course, each keeping the platform's exact starter layout.

No language toolchain is installed on this machine. Everything compiles and runs
in a throwaway Docker container whose image is chosen from the course's own
metadata, so the toolchain always matches whatever the course teaches.

```bash
scripts/stc status                        # what's here and where it stands
scripts/stc test rust-fundamentals 01     # run lesson 01's tests in a container
```

## Requirements

Docker, and git. That's the whole list — `stc` supplies every compiler.

On Windows use `scripts\stc.cmd` from PowerShell, `scripts/stc` from Git Bash or
WSL, or open the repo in the devcontainer.

## Layout

```
AGENTS.md            instructions for any coding agent -- the source of truth
CLAUDE.md            pointer to AGENTS.md (as are .cursorrules and
.cursorrules         .github/copilot-instructions.md)
courses.json         registry: slug, language, entrypoint, mirror, progress
courses/<slug>/      one course, starter layout preserved at its own root
scripts/stc          the helper CLI; scripts/lib/langmap.sh maps language -> image
.devcontainer/       thin hub container (no toolchains) + a per-course template
docs/                see below
notes/               lesson notes -- gitignored, deliberately
.zips/               original starter downloads, kept for `stc sync`
```

## Docs

| | |
|---|---|
| [docs/platform.md](docs/platform.md) | How shipthatcode works: the stdin/stdout executor, `.shipthatcode.json`, grading, and why there's no API |
| [docs/workflow.md](docs/workflow.md) | Starting a course, the per-lesson loop, taking upstream updates |
| [docs/environment.md](docs/environment.md) | Why Docker and not Nix; host vs devcontainer; troubleshooting |
| [docs/publishing.md](docs/publishing.md) | Monorepo here, root-correct mirrors for the grader, via `git subtree split` |
| [docs/roadmap.md](docs/roadmap.md) | Which courses I'm taking, in which language, and why |

## `stc`

| Command | |
|---|---|
| `stc unpack <zip>` | Unpack a downloaded starter into `courses/<slug>/` |
| `stc test <slug> [nn]` | Run the course's tests in its own container |
| `stc shell <slug>` | Interactive shell in that course's toolchain |
| `stc status` | Every course: language, lessons, git state, mirror |
| `stc sync <slug> <zip>` | Take an upstream course update (replaces `tests/` only) |
| `stc remote <slug> [url]` | Get/set the public grading mirror |
| `stc publish <slug>` | Subtree-split the course and force-push to its mirror |
| `stc note <slug> <nn-lesson>` | Create/append an untracked note under `notes/` |
| `stc lang <slug>` | Show and pre-build the container image |

## Two things that will bite you

**Tests are compared byte for byte,** and this repo is edited on Windows. Git
would rewrite `tests/*.out` to CRLF on checkout and every test would fail for
invisible reasons. `.gitattributes` pins the fixtures to `-text` and `stc` runs
everything in Linux. Don't remove either.

**Each course is graded from a repo *root*.** That's why this monorepo publishes
each course as a separate root-correct mirror instead of linking itself. See
[docs/publishing.md](docs/publishing.md).

## Courses

| Course | Language | Lessons | Status |
|---|---|---|---|
| [rust-fundamentals](courses/rust-fundamentals) | Rust | 15 | in progress — 1/15 |

Planned, with the reasoning: [docs/roadmap.md](docs/roadmap.md).

---

Course *solutions* here are mine. The courses, lesson text and test fixtures
belong to [shipthatcode.com](https://shipthatcode.com); no lesson content is
reproduced in this repository (see [notes/README.md](notes/README.md)).
