# The daily workflow

## Starting a new course

1. Buy/open the course, hit **Work in your own editor**, download the starter zip.
   (There's no API — this step is manual and can't be scripted. See
   `docs/platform.md`.)
2. Unpack it into the monorepo:
   ```bash
   scripts/stc unpack ~/Downloads/build-database.zip
   ```
   This extracts to `courses/build-database/`, removes any nested `.git` (it
   would shadow the monorepo and break subtree publishing), archives the zip in
   `.zips/`, and prints a registry entry to paste into `courses.json`.
3. Pre-pull the toolchain image so the first test run isn't a surprise:
   ```bash
   scripts/stc lang build-database
   ```
4. Create an **empty, public** GitHub repo, then wire it up and publish once:
   ```bash
   git add courses/build-database courses.json
   git commit -m "build-database: starter"
   scripts/stc remote  build-database https://github.com/<you>/stc-build-database.git
   scripts/stc publish build-database
   ```
5. Paste that mirror URL on the course page → **Link repo**. One time, per course.

## Per lesson

```bash
# 1. read the lesson on the site; keep your own notes (untracked)
scripts/stc note build-database 03-btree-pages

# 2. write the solution in the ONE entrypoint the course declares
#    (courses/build-database/<entrypoint>) -- no extra files, no build manifest

# 3. this lesson's tests, then the whole suite
scripts/stc test build-database 03
scripts/stc test build-database

# 4. commit in the monorepo
git add courses/build-database
git commit -m "build-database: lesson 03 btree-pages"

# 5. push the root-correct mirror
scripts/stc publish build-database
```

Then click **Check my solution** on the lesson page. That runs **hidden tests
that aren't in `tests/`**, so a local pass is necessary but not sufficient.

### Why step 3 runs the full suite too

It's all one file. Lesson 12 routinely refactors something lesson 4 relied on,
and the grader always runs everything. Running only the current lesson is how
you discover a regression three lessons later.

## When a course is updated upstream

The course page will say your starter is out of date. Upstream's instruction is
to replace `tests/` wholesale and **never merge** it, because lesson numbering
can shift between versions. `stc sync` does exactly that:

```bash
scripts/stc sync build-database ~/Downloads/build-database-v2.zip
git -C . diff --stat -- courses/build-database    # review what moved
```

It replaces `tests/`, `.shipthatcode.json` and `run_tests.sh`, and leaves your
entrypoint alone. Lessons already completed stay completed.

## Checking where you are

```bash
scripts/stc status
```

```
COURSE                       LANGUAGE    ENTRYPOINT   LESSONS  GIT     MIRROR
rust-fundamentals            rust        main.rs      15       clean   https://github.com/…
build-database               c           main.c       34       dirty   unset
```

`courses.json` is the human-maintained side of this: `status`, `at`, and
`linked` are for your own tracking. Nothing in `stc` depends on it — mirrors
live in git remotes named `mirror-<slug>`, and language/entrypoint come from
`.shipthatcode.json` — so it can't silently break anything if it drifts.

## Working with an agent

`AGENTS.md` is the contract, and §8 is the part to keep enforcing: **the agent
shouldn't solve ahead of you.** The value of these courses is that you write the
code. Good uses of an agent here:

- "Explain what a WAL actually guarantees and why fsync placement matters."
- "My lesson 07 output differs on the 3rd test — walk me through why, don't fix it."
- "Review my B-tree split for edge cases the hidden tests would catch."
- "Turn the lesson I just pasted into notes." → lands in `notes/`, untracked.

## Publishing your notes

Don't, at least not the lesson text. `notes/` is gitignored and lives outside
`courses/` so it can't reach a public mirror. The reasoning is in
`notes/README.md`: the hub and every mirror must be public for the grader, and
the lesson prose is shipthatcode's paid material.
