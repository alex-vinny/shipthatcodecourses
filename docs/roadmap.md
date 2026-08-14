# My roadmap

Written 2026-07-24 for a specific starting point, so the reasoning is here too —
if the starting point changes, the plan should.

**Where I'm starting:** professional TypeScript / C# / SQL Server developer, also
a computer engineering student. **What I want:** genuinely different ground from
what I already do, different *languages*, and the hard systems courses — kernel,
database, and the like. Not another course in something I use at work.

That last point is the whole filter. Two levers, and both should be pulled:

1. **The course** — pick systems internals over application-layer topics.
2. **The language** — the platform lets a course be a reason to write a language
   I'd never otherwise write. Wasting that by picking C# is the main trap.

## Read this first

Every exercise on the platform is **one file, stdin in, stdout out, byte-exact**
(see `docs/platform.md`). This is genuinely great for algorithms, data
structures, parsers, and state machines — which is most of what these courses
are. But it means:

- **"Build an OS Kernel" does not boot.** Paging, GDT/IDT, context switching and
  scheduling are taught as simulations driven by stdin. Superb for understanding
  and for exams; it produces no bootable image. If bare-metal is the real goal,
  this is the concepts layer, and it pairs with osdev.org or *Writing an OS in
  Rust* separately — it doesn't replace them.
- Same caveat, smaller, for the networked ones (Redis, Kafka, Raft): protocol
  and state-machine logic, not real sockets.

Knowing this up front is the difference between "this course was a revelation"
and "I expected qemu."

## The plan

### Phase 0 — finish `rust-fundamentals` · 15 lessons · already downloaded

Not a detour. Ownership, borrowing and lifetimes are the single biggest mental
shift available coming from C#: memory becomes explicit without becoming
dangerous. It's also the on-ramp to reading any systems codebase, and it's
short. Finishing it also means the whole toolchain here is proven before a
34-lesson course depends on it.

### Phase 1 — Build a Database · 34 lessons · **in C**

The highest-leverage course on the platform *for me specifically*, because I
already know SQL Server from the outside and this builds the inside: SQL
tokenizer → parser → B-tree pages → WAL recovery.

Everything that's currently folklore becomes mechanical — why an index helps and
when it doesn't, what a query plan is choosing between, what an isolation level
actually costs, why a write-heavy table behaves the way it does. That transfers
to the day job immediately, which makes it the easiest of these to justify the
hours for.

**In C, not C#.** A page-based storage engine is manual memory and explicit byte
layout; that *is* the subject. C is also the biggest single gap in my toolkit,
it's what the CE curriculum assumes, and it's the fluency Phase 2 needs. Rust is
the acceptable second choice if C feels like too much at once.

### Phase 2 — Build an OS Kernel · 24 lessons · **in C (and assembly)**

The one I actually wanted. Third rather than first, on purpose: by then C is
comfortable and I've built a parser and a state machine, and it lines up with the
OS and architecture courses in the degree — each makes the other easier.

Re-read the caveat above before starting so the scope is clear.

### Phase 3 — Build a Programming Language · 38 lessons · **in OCaml**

The biggest course, best last. Compilers is a CE staple, and the tokenizer and
parser muscle from Phase 1 transfers directly (lexer → parser → AST → eval).

**In OCaml** for two reasons: it's what real compilers are written in, and ML-family
functional programming with exhaustive pattern matching and algebraic data types
is a paradigm I have close to zero exposure to. Unexpected bonus — it's the same
set of ideas as TypeScript's type system with better syntax, so it makes me
sharper at something I use daily. Haskell is the more extreme version of the
same lesson if I want it.

### Between the big ones — Build Git · 18 lessons · in Rust

Short, finishes fast, and content-addressed storage is one of the genuinely
beautiful ideas in computing. I use git every day and would understand it
properly. Good palate cleanser between two 30-lesson courses.

## Wildcard, if I want the most alien thing available

**Build Kafka or Build a Raft KV Store, in Elixir or Erlang.** The actor model,
supervision trees and let-it-crash are the furthest thing from .NET on the
platform, and distributed-systems reasoning is the rarest skill in the catalogue.
Pick this over Phase 3 if consensus and replication appeal more than compilers.

## Deliberately skipping

- **`csharp-advanced`, the TypeScript courses, `sql-advanced`** — paying course
  time for what I already do professionally. This is the whole point of the
  filter.
- **Go, deprioritised.** Not a bad language, but with C# in hand it teaches
  syntax more than ideas: still garbage-collected, still high-level, and
  goroutines/channels map onto `async`/`await` and channels I already know.
  Worth it for job-market reasons, not for range. C, OCaml and Elixir all teach
  something C# cannot.
- **`build-docker` (Container Runtime), `build-redis`** — both good, both real
  candidates, just below the ones above. Redis if backend performance becomes
  the priority; container runtime now that Docker is part of my daily setup.

## Sequenced paths

The platform's own **Systems Engineer** (100h) and **Database Engineer** (110h)
paths roughly encode Phases 1–2. Worth checking whether following a path
unlocks anything, but the phase order above is chosen for my starting point
rather than a generic one.

## Effort, honestly

Phases 0–3 are ~111 lessons. At a realistic few lessons a week alongside a job
and a degree, that's about a year. The order is designed so that value lands
early — Phase 1 pays off at work within weeks — and so nothing is attempted
before its prerequisites are comfortable.

## Language selection

**Confirmed: the build courses offer a choice of language, at least for some.**
Build a Database does. It appears to vary per course rather than being uniform,
and the offered set isn't visible without logging in.

So the language column below is a *preference order*, not an assumption. For
each course, take the best available option from the offered list:

| Course | 1st choice | 2nd | 3rd | Avoid |
|---|---|---|---|---|
| Build a Database | C | Rust | C++ | C#, TypeScript, Go |
| Build an OS Kernel | C | Rust | C++ | anything managed |
| Build a Programming Language | OCaml | Haskell | Rust | C#, TypeScript |
| Build Git | Rust | C | Go | C#, TypeScript |
| Build Kafka / Raft KV | Elixir | Erlang | Rust | C#, TypeScript |

The "avoid" column is the discipline that makes this plan work: picking C# or
TypeScript because the course allows it converts a hard course into a
comfortable one and forfeits half the value.

As the offered sets become known they go in `courses.json` under the wishlist
entry's `languages`, so the decision is recorded rather than re-litigated.

## Language checklist

Tracking range as an explicit goal, not a side effect:

| Language | Status | Gets me |
|---|---|---|
| TypeScript, C#, SQL | already have | — |
| Rust | Phase 0, in progress | ownership, lifetimes, no-GC safety |
| C | Phase 1–2 | manual memory, pointers, byte layout, no runtime |
| Assembly | Phase 2 | registers, calling conventions, what the CPU sees |
| OCaml | Phase 3 | ML functional, ADTs, exhaustive matching |
| Elixir / Erlang | wildcard | actor model, supervision, fault tolerance |
