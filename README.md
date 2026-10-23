# Standalone Loom

This checkout contains the standalone Loom core on **Lean 4.35.0** for clients such as
[Veil](https://github.com/verse-lab/veil). It provides monad
algebras, weakest-precondition semantics, nondeterministic computations, and
extraction to executable computations.

The full Loom framework and its Cashmere and Velvet case studies are available
on the [`master` branch](https://github.com/verse-lab/loom/tree/master).

## Using Loom

For local development, add this dependency to your `lakefile.lean`, adjusting
the path to this checkout:

```lean
require Loom from "../loom"
```

For Git consumption of this fork:

```lean
require Loom from git "https://github.com/soonhokong/loom.git" @ "master"
```

Pin the tested commit instead of the branch name in reproducible downstream
projects. The root library, native-consumer tests, and optional mathlib adapter
use Lean 4.35.0. The older `v4.32.0-for-veil` revision may still depend on mathlib.

Veil uses this entry point:

```lean
import Loom.MonadAlgebras.NonDetT'.ExtractList
```

`import Loom` exports the same core. The `Loom` library covers the root module
and all its submodules. CI checks the static library and a native consumer
executable with module precompilation enabled.

Extraction accepts `MultiExtractor.Candidates` and `PartialCandidates` supplied
by the caller. Veil already supplies these through its `Enumeration` interface.
The former automatic `FinEnum` fallback now lives in the separate
`integrations/mathlib` package; clients relying on it must add that package and
`import LoomMathlib.Candidates`. See its README for local and Git dependency setup.

Persistent logs now require `Loom.LogMonoid κ`; lists have a built-in instance.
Generic clients with a mathlib `Monoid κ` can explicitly use
`LoomMathlib.logMonoidOfMonoid κ`. Writer extraction now targets `Loom.WriterT`;
the integration package supplies conversions for mathlib writer computations.

## Build

Install [Lean via elan](https://github.com/leanprover/elan), then run:

```bash
lake build
lake build Loom:static
lake test
python3 scripts/check_foundations.py
```

`lake test` includes a transitive axiom audit of Loom declarations. Only
`propext`, `Classical.choice`, and `Quot.sound` are allowed. This checks proof
dependencies, not the correctness of a client's language model or the
discharge of hypotheses in generic theorems.

See [Lean 4.35 notes](docs/lean435.md) for the release review and client guidance.

The toolchain is pinned in `lean-toolchain`. The root package has no external
Lake dependencies and does not download or require external SMT solvers.

All Loom library modules, including generic algebras, WP/WLP, and extraction,
use Loom's own control and assertion interfaces. Generic complete lattices and
Boolean algebras remain supported, including proposition, dependent-function,
and continuation instances. Computational fixed points still use `Lean.Order`.

Assertions use Lean's `LE`, `Min`, and `Max` with the `Std.IsPartialOrder`,
`Std.LawfulOrderInf`, and `Std.LawfulOrderSup` laws. `Loom.Order` adds only
`CompleteLattice` and `CompleteBooleanAlgebra`, plus the scoped notation `⊤`,
`⊥`, `⊓`, `⊔`, `⨅`, `⨆`, `⇨`, and `ᶜ`.
`⌜p⌝` uses `Loom.Order.embed`; continuations use `Loom.Cont`/`Loom.ContT`.

Loom uses Lean's module system. Definitions are exposed; tactics, attributes,
and other metaprograms live in `meta` sections and import Lean only with
`meta import`. Non-module files can import Loom unchanged. An executable whose
import chain consists of modules therefore links no Lean elaborator code;
`tests/native` checks this for the extraction pipeline.

Existing consumers that import mathlib themselves must require it directly;
Veil's companion migration and full downstream validation remain deferred.

To inspect the compiled dependency graph after a build:

```bash
lake env lean --run scripts/AuditDependencies.lean /tmp/loom-audit
```

This writes the imported module list and a declaration-level TSV inventory.
See the [migration plan](docs/mathlib-removal-plan.md) and
[implementation progress](docs/mathlib-removal-progress.md).

## Source guide

- `Loom/MonadUtil.lean` and `Loom/SpecMonad.lean`: shared monad utilities and
  specification monads.
- `Loom/Control/`: standalone continuation, writer, and logging foundations.
- `Loom/Order/`: complete lattices and Boolean algebras over Lean's order classes.
- `Loom/MonadAlgebras/Defs.lean` and `Instances/`: monad algebras and instances
  for the supported effects.
- `Loom/MonadAlgebras/WP/`: weakest-precondition semantics, shared attributes,
  and simplification lemmas.
- `Loom/MonadAlgebras/NonDetT'/`: nondeterministic computations and extraction
  to executable computations, including the extraction tactics used by Veil.
