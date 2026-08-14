# notes/ — untracked on purpose

Everything in here except this file and `.gitkeep` is gitignored.

**Why:** the hub repo and every per-course mirror is public, because the
shipthatcode grader has to be able to clone them. The lesson text on
shipthatcode.com is their copyrighted, paid material — committing it here would
republish it. So lesson notes stay local.

**Layout:** `notes/<course-slug>/<nn>-<lesson-slug>.md`, created by
`stc note <slug> <lesson>`.

**What belongs here:** your own summaries, the mental model that finally made a
concept click, edge cases the tests caught you on, links, questions to come back
to. Paraphrase rather than paste.

**What belongs in `courses/<slug>/` instead:** your actual solution code. The
grader needs that, and it must be tracked.

Since `stc publish` only ever subtree-splits `courses/<slug>/`, nothing in here
can reach a public mirror even by accident.
