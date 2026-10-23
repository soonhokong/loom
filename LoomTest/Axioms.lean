import Loom
import Lean.Util.CollectAxioms

/-!
Audit the transitive axiom dependencies of Loom declarations. This checks the
proof trust boundary; it does not establish the correctness of a client's
language semantics or discharge hypotheses in generic algebra theorems.
-/

open Lean Elab Command in
run_cmd do
  let environment ← getEnv
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut checked : Nat := 0
  for (name, _) in environment.constants.toList do
    let some index := environment.getModuleIdxFor? name | continue
    let owner := environment.header.moduleNames[index.toNat]!
    unless `Loom |>.isPrefixOf owner do continue
    for axiomName in ← collectAxioms name do
      unless allowed.contains axiomName do
        throwError "{name} depends on unexpected axiom {axiomName}"
    checked := checked + 1
  if checked == 0 then
    throwError "The axiom audit found no Loom declarations"
  logInfo m!"Checked transitive axiom dependencies of {checked} Loom declarations"
