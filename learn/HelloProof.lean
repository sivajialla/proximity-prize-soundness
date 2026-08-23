/-
  A tiny, self-contained proof so you can watch Lean's checker in action.
  This file is NOT part of the competition submission — it's a safe sandbox.

  Run it with:   lake env lean learn/HelloProof.lean
  No output = every proof was accepted. An error = Lean found a gap.
-/

-- 1. The simplest kind of proof: "2 + 2 = 4". `rfl` means "both sides are
--    literally equal after computing". Lean computes 2+2, sees 4, accepts.
theorem two_plus_two : 2 + 2 = 4 := by rfl

-- 2. A proof with a tiny bit of reasoning. `omega` is a decision procedure
--    for arithmetic over integers/naturals — it proves this for EVERY n.
theorem le_example (n : Nat) : n ≤ n + 5 := by omega

-- 3. A proof that a statement holds for all natural numbers, by induction.
theorem add_zero_right (n : Nat) : n + 0 = n := by
  rfl
