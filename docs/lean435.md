# Lean 4.35.0

The standalone core, native consumer, and optional mathlib adapter use Lean
4.35.0. The adapter pins mathlib's matching release. The root package has no
external Lake dependencies.

This update builds on the existing standalone port in commits `77bb89b` and
`5c9aae0`. It aligns the remaining consumer toolchains, updates the optional
adapter, and adds a transitive axiom audit to the regular test suite.

## Release review

The official notes reviewed are
[4.30](https://lean-lang.org/doc/reference/latest/releases/v4.30.0/),
[4.31](https://lean-lang.org/doc/reference/latest/releases/v4.31.0/),
[4.32](https://lean-lang.org/doc/reference/latest/releases/v4.32.0/),
[4.33](https://lean-lang.org/doc/reference/latest/releases/v4.33.0/),
[4.34](https://lean-lang.org/doc/reference/latest/releases/v4.34.0/), and
[4.35](https://lean-lang.org/doc/reference/latest/releases/v4.35.0/).

Important consequences for clients:

* The new `do` elaborator changes nested-action return scope. Write intended
  boundaries explicitly, and test control flow when migrating syntax extensions.
* `CCPO.csup` takes a chain proof. Use the order interface and its equations
  rather than depending on the implementation of the chosen supremum.
* Instance transparency is stricter. Prefer explicit instances and appropriate
  reducibility annotations to project-wide compatibility options.
* `Decidable` is Bool-backed. Use conditional equations instead of depending
  on its former representation.
* Lean's module system separates exported runtime definitions from metaprograms.
  Loom retains that separation; the native consumer checks it.
* `Lean.ofReduceBool` is removed. Native evaluation can introduce evaluation
  axioms. Such dependencies are rejected by Loom's axiom-audit test.
* `Std.WP` and `vcgen` provide newer verification infrastructure, including deep
  embeddings and framing. They are candidates for explicit client adapters.
  Loom's algebra laws are not automatically an adequacy theorem for such an
  adapter, and the intrinsic/VC-generation facilities remain experimental.
* Verification annotations such as intrinsic `assert` are erased. A language
  semantics must define its runtime assertions, traps, and undefined behavior
  explicitly.

For nondeterministic clients, candidate extraction and proof interpretation are
separate interfaces. Preserve the distinction between complete candidate sets,
partial candidate sets, and one selected execution. Likewise, a partial
correctness proof does not establish termination or exact program equivalence.

## Validation

The release checks are:

```sh
lake clean
lake build Loom Loom:static
lake test
lake env lean --run scripts/AuditDependencies.lean /tmp/loom-audit
lake -d tests/native clean
lake -d tests/native exe smoke
lake -d integrations/mathlib clean
lake -d integrations/mathlib test
```

During development, `lean-beam` can check and checkpoint individual modules.
Its server checkpoints do not replace the final batch build above. Stop Beam
owners before that clean validation.
