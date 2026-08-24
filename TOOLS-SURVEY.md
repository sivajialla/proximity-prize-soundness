# ArkLib tool survey — what a new `mcaError` bound may legally use

Purpose: inventory the ArkLib lemmas that could bound `mcaError` past the
63.99/64.00 wall, and separate **proven** building blocks from **`sorry`-backed**
dead ends. Pinned rev `e65197892890b8fd9b0dc05b8980273cf1d595cc`.

**Method / caveat.** Status below is from direct inspection of each declaration's
proof body (no literal `sorry`/`admit`). That is necessary but **not sufficient**:
a `sorry`-free lemma can still transitively call a `sorry`-backed one. The
*authoritative* check is `#print axioms <lemma>` (or ArkLib's `lake exe axiomsweep`),
which requires a build — see "Next check" below. ArkLib deliberately carries a
tracked `sorry` baseline (`scripts/axiom_baseline.json`), so transitivity is real.

## The target (recap)

The challenge's `reduction` obligation is, at radius δ:
`certifiedGammaError = mcaError(AffineLineGenerator, IRSProfile.code, δ) + Λ(δ)/|F| ≤ 2⁻¹²⁸`.
The list term Λ/|F| is negligible; the whole fight is bounding
`mcaError(AffineLineGenerator, IRSProfile.code, δ)` for δ ≳ 0.293.

`mcaError_interleaved_le` (proven, `ProximityGap/Errors.lean`) reduces this to the
**base** RS code: `mcaError(interleaved) ≤ mcaError(base RS)`. So the real target is
`mcaError(AffineLineGenerator, ReedSolomon.code domain 131072, δ)` for δ past the wall.

## Inventory of `mcaError`-bounding lemmas

| Lemma | Location | Status | Radius reach |
|:--|:--|:--|:--|
| `rs_mcaError_le_in_johnson_range` | `ProximityGap/CapacityBounds.lean` | ❌ **sorry** | (would be Johnson) |
| `subspace_design_mcaError_le` | `ProximityGap/CapacityBounds.lean` | ❌ **sorry** | (would be capacity) |
| `rs_mcaError_le_of_le_relUDR` | `ProximityGap/BCIKS20/EpsCa.lean` | ✅ proven | ≤ unique-decoding (0.25) — too weak |
| `linear_mcaError_le_one_point_five_johnson` | `.../CapacityBounds/JohnsonMca.lean` | ✅ proven | ~1.5×Johnson region only |
| `linear_mcaError_le_of_Lambda_le` | `Connections/.../GCXK25.lean` | ✅ proven | **caps exactly at the wall** (see below) |
| `mcaError_interleaved_le` | `ProximityGap/Errors.lean` | ✅ proven | (the interleaved→base bridge) |
| **`frs_mcaError_le`** | `.../CapacityBounds/Frs.lean:2012` | ✅ proven | **up to capacity `1−ρ−2/t`** ⟵ the only escape |

The two "obvious" shortcuts are `sorry`-backed dead ends (confirmed by direct
inspection, matching the public notes).

## Why the wall is baked into the proven general tool

`linear_mcaError_le_of_Lambda_le` (the mechanism the current 63.99 proof effectively
uses) states: given a list-size bound `Λ(C, δ) ≤ L` with **`δ < minDist/|ι| ≈ 0.5`**,

```
mcaError(AffineLineGenerator, C, 1 − √(1−δ+η)) ≤ (L²·δ·|ι| + 1/η)/|F|.
```

As `δ → 0.5⁻`, `η → 0⁺`, the certified radius `1 − √(1−δ+η) → 1 − √½ = 0.29289…` —
**exactly the wall.** The hypothesis `δ < minDist/|ι|` structurally forbids going
further. So no amount of tuning this lemma passes 64.00; the list side (`L ≤ ~1.4×10⁶`
affordable) is never the binding constraint.

## The one proven escape: folded Reed–Solomon (`frs_mcaError_le`)

```
theorem frs_mcaError_le (domain : ι ↪ F) (k s : ℕ) (ω : F)
  (hω : ω ≠ 0) (hω_gen : orderOf ω = |F|−1)                 -- ω generates F*
  (hadm : ReedSolomon.Folded.Admissible (domain img) s ω)
  (hcard : s·|ι| < |F|) (t : ℕ) (ht : 0 < t) (hs : 4t² < s) :
  mcaError (AffineLineGenerator F) (ReedSolomon.Folded.frsCode domain k s ω)
      (1 − ρ − 2/t)  ≤  ofReal((|ι|·t + 3t³)/|F|)     where ρ = k/(s·|ι|)
```

For rate ρ = ½, the certified radius is `0.5 − 2/t`, which **beats the wall for any
t ≥ 10** and approaches capacity 0.5 as t grows (folding factor s > 4t²; s·|ι| < |F|
holds trivially here since |F| ≈ 9.4×10⁵⁵). Numerically:

| fold s | max t (4t²<s) | radius 0.5−2/t | score (bits) |
|--:|--:|--:|--:|
| 512 | 11 | 0.318 | ~65.8 |
| 4096 | 31 | 0.435 | ~105 |
| 65536 | 127 | 0.484 | ~122 |

i.e. if this lemma applied to our code, scores of 65–120+ would be reachable — the
whole prize.

## The precise research question (vector ③)

`frs_mcaError_le` is about the **folded** RS code `frsCode domain k s ω`. The
challenge's `certifiedGammaError` is fixed to the **interleaved** code (→ base RS
code via `mcaError_interleaved_le`). So the open, well-posed target is:

> **Prove `mcaError(AffineLineGenerator, ReedSolomon.code domain 131072, δ)
> ≤ mcaError(AffineLineGenerator, frsCode domain' k s ω, δ)`** for a folding of the
> *same* smooth NTT domain (a multiplicative subgroup — it already has the ω-orbit
> structure folding needs), then invoke `frs_mcaError_le`.

Why it's plausible: the domain is a multiplicative subgroup of order 2¹⁸, so
`ω`-orbit folding is structurally available, and folded RS ⊂ interleaved RS is a
classical correspondence (Guruswami–Rudra / Krachkovsky).

Why it's hard / maybe false: folding regroups evaluation points, which changes the
**affine-line** family that `mcaError(AffineLineGenerator, …)` counts over. The
reduction must show the unfolded affine-line collisions are dominated by folded ones.
There may be a genuine **barrier** — see `ListDecodability/Bounds/LargeAlphabet/Barrier.lean`
(worst-case RS list-decoding past Johnson is impossible for *generic* codes; this
code must be shown special). If the barrier applies, 63.99 is optimal for this
certificate.

## Clean (sorry-free) toolboxes available to build the reduction

Direct `sorry` scan (occurrences / files):

| Directory | decls | sorry | note |
|:--|--:|--:|:--|
| `GuruswamiSudan` | 61 | **0** | full GS interpolation/root-counting |
| `JohnsonBound` | 77 | **0** | Johnson list-size bounds |
| `ReedSolomon` | 33 | **0** | RS + folded RS defns (`ReedSolomon.Folded`) |
| `ProximityGap/Folding` | 6 | **0** | fold-distance/ball lemmas |
| `ProximityGap/CapacityBounds` (subdir) | 10 | **0** | `frs_mcaError_le`, JohnsonMca, Powers |
| `ProximityGap` (top files) | 275 | 23 (9 files) | incl. the 2 sorry shortcuts |
| `ProximityGap/BCIKS20` | 108 | 17 (6 files) | partially sorry |
| `ListDecodability` | 179 | 6 (5 files) | mostly proven |

## Axiom check — DONE (confirmed clean ✅)

Ran `#print axioms` (see `learn/AxiomCheck.lean`) after building the folded-RS
module (`lake build …CapacityBounds.Frs`, 53s, negligible memory):

```
'CodingTheory.frs_mcaError_le'         depends on axioms: [propext, Classical.choice, Quot.sound]
'ProximityGap.mcaError_interleaved_le' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Both are **transitively axiom-clean** — exactly the three allowed axioms, no
`sorryAx`. So both the folded-RS capacity bound and the interleaved→base bridge are
**legally usable in a submission**. The folded-RS route is not blocked at the tooling
level; the remaining obstacle is purely the mathematical reduction (interleaved/base
→ folded affine-line MCA), plus ruling out the `LargeAlphabet/Barrier.lean`
impossibility.

Note: the Frs olean is *not* built by the default `ProximityPrize` target (it's
outside that import closure), so `lake build …CapacityBounds.Frs` is needed once
before any file importing it will elaborate.

## Barrier check — DONE (route NOT doomed ✅)

Read the two proven impossibility-flavored results:

- **`large_alphabet_lambda_lower` / `robust_minimum_distance_barrier`**
  (`ListDecodability/Bounds/LargeAlphabet.lean`, [ABF26]/[AGL23]/[BDG24]): list-decoding
  *near capacity* `ℓ/(ℓ+1)·(1−ρ−η)` **forces** `|F| ≥ 2^(α/η)`. This is a *large-alphabet
  requirement*, not an impossibility for us: our `|F| = p⁶ ≈ 9.4×10⁵⁵ ≈ 2¹⁸⁵` is exactly the
  huge alphabet the theorem says you need. It is *consistent with* folded RS beating the wall.
  (It does cap how far even folded RS can go: η ≳ α/185, so radii approaching capacity 0.5 are
  eventually blocked — but that ceiling is far above 64 bits, so it does not affect our goal.)
- **`linear_mcaError_ge_information_set`** (proven, `ProximityGap/InformationSetLowerBound.lean`):
  `mcaError(AffineLineGenerator, C, δ) ≥ ⌊δ·|ι|⌋/|F|` for `δ < minDist/|ι|`. At δ≈0.293 that is
  `≥ 76780/|F|` — about 3.5×10¹² **below** the budget ceiling `2.75×10¹⁷/|F|`. No obstruction.

**Verdict: no proven ArkLib impossibility blocks the folded-RS route.** Caveat: absence of a
proven barrier ≠ the reduction is true. `mcaError(plain base RS, δ) ≤ mcaError(folded RS, δ)`
could still be false mathematically — ArkLib simply contains no theorem settling it either way.
That remains the open crux.

## Bottom line

- Two "easy" mcaError shortcuts are `sorry`-backed — unusable.
- The proven general bound (`linear_mcaError_le_of_Lambda_le`) is capped at the wall
  by its own hypothesis `δ < minDist/|ι|`.
- Exactly one proven tool beats the wall: `frs_mcaError_le` (folded RS to capacity).
  Turning it into a lower-track win requires an **interleaved/base → folded RS
  reduction on the affine-line MCA** — a precise, grounded, but genuinely open
  problem, with a possible impossibility barrier to rule out first.
