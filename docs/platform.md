# How shipthatcode.com actually works

Findings from inspecting the `rust-fundamentals` starter and the public pages,
2026-07-24. Recorded because almost none of it is documented on the site, and
the layout and tooling in this repo are consequences of it.

## The execution model

**Every exercise is one file, stdin in, stdout out, compared byte for byte.**

That is the whole contract. It holds for the fundamentals courses and — the
surprising part — for the systems courses too. "Build a Database" lesson 1 is
literally *"Build a tokenizer that reads SQL from stdin and outputs tokens in
`TYPE VALUE` format, one per line."*

Consequences worth internalising before choosing a course:

- There is no test framework, no assertion library, no `main()` harness.
- There is no networking, no filesystem, no qemu, no bare-metal boot. "Build an
  OS Kernel" teaches paging, GDT/IDT, context switching and scheduling as
  **simulations driven by stdin**. Excellent for the concepts; it will not
  produce a kernel that boots. See `docs/roadmap.md`.
- Debug output must go to **stderr**. Anything on stdout is compared.
- A trailing newline you didn't intend is a failing test.

## `.shipthatcode.json`

The starter's identity card, at the repo root:

```json
{
  "course": "rust-fundamentals",
  "language": "rust",
  "language_id": 73,
  "entrypoint": "main.rs",
  "version": 1,
  "content_hash": "fbe14a2385e94b8d",
  "lessons": [ { "slug": "hello-world", "tests_hash": "e70c2a0539c7" }, … ]
}
```

`language_id: 73` is the **Judge0** id for Rust. So the remote "executor" is
Judge0-shaped: compile the single entrypoint, pipe a fixture to stdin, diff
stdout. That also explains the one-file rule — Judge0 submissions are one
source file, so a `helper.rs` next to `main.rs` compiles locally and then fails
on the grader.

`stc` reads `language` and `entrypoint` from this file, which is why the
toolchain always matches the course without any per-course configuration.

## Grading and the repo-root requirement

The "work in your own editor" flow, from the starter's own README:

1. Download the starter zip.
2. Push it to a **new, empty, public** GitHub repo.
3. Paste that repo's URL once on the course page → **Link repo**.
4. Per lesson: commit, push, then click **Check my solution** — the platform
   clones your repo and grades it, *including hidden tests not in `tests/`*.

So a local green run is necessary but not sufficient.

Critically, the grader reads `.shipthatcode.json`, the entrypoint and `tests/`
**at the root of the linked repo**. There is no documented way to point it at a
subdirectory. That is the single constraint that shapes this repo: we keep a
monorepo for sanity and publish each course as a root-correct mirror via
`git subtree split`. See `docs/publishing.md`.

## Is there an API?

**No public API, and no CLI.** Checked:

- `https://api.shipthatcode.com/` → 404. No openapi spec, no route listing.
- Nothing on the site references an API, CLI, SDK, or GitHub org.
- The one public API endpoint in evidence is
  `https://api.shipthatcode.com/cert/<hash>.svg`, which serves the certificate
  badge embedded in each starter's README.

So the integration surface is **git plus a button**:

| Want to | Mechanism |
|---|---|
| Get a starter | Manual download while logged in (no URL to script) |
| Run tests | Local — `tests/*.in|*.out` + `run_tests.sh`, fully offline |
| Trigger grading | Manual click on the lesson page |
| Read progress | Only on the site; nothing machine-readable |
| Show a credential | The cert badge SVG |

That is why `stc` automates everything *around* the git loop and nothing about
grading itself: there is nothing there to automate. If they ever ship an API,
the place to wire it in is a new `stc` subcommand.

## `run_tests.sh`

The starter's own local runner, and it is **the same generic script for every
course** — it switches on a `LANG_SLUG` variable and knows how to compile and
run ~35 languages. Useful implications:

- The set of languages it handles tells you what the platform offers:
  c, cpp, rust, go, java, assembly, basic, cobol, csharp, d, fortran, kotlin,
  objc, pascal, vbnet, python, javascript, typescript, bash, clojure, elixir,
  erlang, fsharp, groovy, haskell, lisp, lua, ocaml, octave, perl, php, r, ruby,
  scala, swift, plus sql and prolog (which it refuses locally).
- `scripts/lib/langmap.sh` mirrors that list, mapping each language to a
  container image.
- It compiles to `.prog` in the course directory — hence those entries in
  `.gitignore`.

## The Windows line-ending trap

The starter README warns about this and it is worth restating, because the
failure looks like a logic bug:

> native Windows compilers write `\r\n`, so on byte-exact tests you can see
> local FAILs where the diff looks identical

Two guards in this repo, both load-bearing:

1. `.gitattributes` marks `tests/**/*.in` and `tests/**/*.out` as `-text`, so
   git never rewrites the fixtures on checkout.
2. `stc test` runs in a Linux container, so the compiler never emits CRLF in
   the first place.

Verified: on this machine, `stc test rust-fundamentals 01` reports a clean
`1 passed, 0 failed` for a correct solution.
