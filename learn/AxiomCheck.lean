/-
  Authoritative axiom-cleanliness check for the folded-RS lead.
  Run:  lake env lean learn/AxiomCheck.lean
  A footprint of exactly {propext, Classical.choice, Quot.sound} = legally usable
  in a submission. If `sorryAx` appears, the lemma is transitively tainted.
-/
import ArkLib.Data.CodingTheory.ProximityGap.CapacityBounds.Frs
import ArkLib.Data.CodingTheory.ProximityGap.Errors

#print axioms CodingTheory.frs_mcaError_le
#print axioms ProximityGap.mcaError_interleaved_le
