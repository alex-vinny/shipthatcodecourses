# Publishing: one monorepo, many root-correct mirrors

## The problem

The grader clones the repo URL you linked and expects to find
`.shipthatcode.json`, the entrypoint and `tests/` **at its root**. There's no
documented way to point it at a subdirectory.

A monorepo is still the right way to *work* — one clone, one history, one set of
tooling, shared docs and agent instructions. So the repo and the grader need
different views of the same files.

## The mechanism

`git subtree split` rewrites the history of one directory into a standalone
history whose root **is** that directory. Then force-push it:

```bash
git subtree split --prefix=courses/build-database -b _publish/build-database
git push --force mirror-build-database _publish/build-database:refs/heads/main
```

`stc publish <slug>` does this, plus the safety rails:

- Refuses if `courses/<slug>` has uncommitted or untracked changes — a split
  only sees committed history, so without this check you'd cheerfully publish
  stale code and then wonder why the grader disagrees with your local run.
- Deletes the temporary `_publish/<slug>` branch afterwards, so the monorepo
  doesn't accumulate them.
- Reminds you to link the URL on the course page the first time.

Mirror URLs are stored as **git remotes** named `mirror-<slug>`:

```bash
scripts/stc remote build-database https://github.com/<you>/stc-build-database.git
scripts/stc remote build-database        # read it back
```

Storing them in git config rather than `courses.json` means publishing never
depends on parsing JSON, and a stale registry can't misdirect a force-push.

## Rules that follow from this

1. **Mirrors are push-only and force-pushed.** Never commit into one; it will be
   overwritten without warning. All work happens in the monorepo.
2. **Mirrors are public**, because the grader must clone them. So nothing secret
   and nothing copyrighted may ever sit inside `courses/`. This is exactly why
   `notes/` lives at the hub root instead — a split of `courses/<slug>` cannot
   reach it.
3. **Each course needs its own mirror repo.** One repo per course, since each
   needs its own root.
4. **Link once per course.** After the first publish + link, the loop is just
   publish → click Check.
5. The per-course `README.md` from the starter (with its certificate badge)
   becomes the mirror's front page. That's a feature — leave it in place.

## Verifying a mirror looks right

```bash
git ls-tree --name-only mirror-build-database/main
# expect: .gitignore  .shipthatcode.json  README.md  main.c  run_tests.sh  tests
# NOT:    courses/    AGENTS.md    scripts/
```

If you see `courses/` there, the split didn't happen and you pushed the
monorepo — fix the remote and force-push a proper split.

## Alternatives that were rejected

- **A separate repo per course, no monorepo.** Grader-native, but then the
  tooling, docs and agent instructions have to be duplicated or submoduled into
  every course, and there's no single place to look.
- **Submodules.** Reproducible, but a submodule add/commit per course and
  constant detached-HEAD friction for something that buys nothing here.
- **A `git worktree` per mirror.** Same result as the split, more state to keep
  consistent on disk.

The split is stateless: nothing persists between publishes, so there's nothing
to get out of sync.
