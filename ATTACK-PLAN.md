# Proximity Prize — Soundness lower track: frontier study & attack plan

Track: `proximity-prize/proximity-prize/irs-reduction-threshold-lower`
Goal: **maximize `B`** (centibits) in `ProtocolClaim B P Q`.
Checkout: shared `main` tip `0fac0476`; editable path `ProximityPrize/SubmissionLower/` only.
Author of this doc: Claude Opus 4.8 (Claude Code), 2026-08-22. No submission files changed.

---

## 0. Bottom line (read this first)

- The promoted frontier is **63.99 bits** (`B = 6399`, δ = `307083/1048576`). The
  clone already restores this, not the README's 53.00 baseline.
- **64.00 bits is a hard mathematical ceiling for the current proof architecture,
  not a tuning problem.** It coincides *exactly* with the Guruswami–Sudan (GS)
  list-decoding radius of this rate-½ code. I re-derived this independently and it
  matches three+ community analyses (see §6).
- The **field/list budget is NOT the blocker** — there is ~2.75× headroom. The
  blocker is the **MCA extraction ledger**, which runs ~230× over budget at the
  64.00 cell.
- Therefore: incremental tuning is exhausted. A real gain needs a *new extraction
  argument* or a *different soundness architecture*. This is research-level work.

---

## 1. The contract (`ProximityPrize/Benchmark/TargetLower.lean`)

`ProtocolClaim B P Q` is a `Prop` structure with three fields, at radius δ = P/Q:

| Field | Statement | Role |
|:--|:--|:--|
| `admissible` | `0 < δ < minRelativeDistance = 131073/262144 ≈ 0.5` | δ in range |
| `reduction` | `certifiedGammaError(δ) ≤ 2⁻¹²⁸` | the safety cap (binds δ from above) |
| `score` | `(1 − δ)¹²⁸ ≤ 2^(−B/100)` | defines the score (rewards larger δ) |

Score is `B`, **maximize**. The two forces pull opposite ways: `score` wants δ
large; `reduction` caps δ. Everything is exact `ℝ≥0`/`Nat` arithmetic — no floats.

**Fixed profile** (`IRSProfile.lean`): rate-½ interleaved Reed–Solomon over
`KoalaBear.Ext6` (|F| = `2130706433⁶`), domain n = `2¹⁸ = 262144`, base
dimension k = `2¹⁷ = 131072`, repetitions t = 128, min relative distance
`131073/262144`.

**`certifiedGammaError` decomposition** (the key identity):

```text
certifiedGammaError(δ) = mcaError(AffineLineGenerator, code, δ)
                       + Λ(code ⋈ Fin 2, δ).toNat / |F|
```

So `reduction` reduces to an integer budget:

```text
N_mca + L_list ≤ ⌊ |F| / 2¹²⁸ ⌋ = 274980728111395087   (≈ 2.75e17)
```

where `N_mca/|F|` bounds the MCA term and `L_list` is the Johnson list bound on the
squared/interleaved code.

---

## 2. Current frontier = 63.99 (what's in the checkout)

`Solution.lean → ProtocolClaim 6399 307083 1048576` via `protocolClaim6399`
(`BCHKSFinal6399.lean`), unconditional. Verified locally on this macOS host
(`BENCHMARK_INSECURE_LOCAL=1`): score 63.99, `locallyKernelChecked: true`,
`independentVerified: false` (ranked verification is Linux-only, see §7). Axioms
exactly `{propext, Classical.choice, Quot.sound}`.

Parameters (`BCHKSParameters6399.lean`):

```text
δ = 307083/1048576 = 0.29285717     errors e = ⌊n·δ⌋ = 76770   agreement a = n−e = 185374
numerator N = 1e17                  list bound L = 30000        (N+L within 2.75e17 ✓)
multiplicity m = 3733               caps: DX=692001142, DY=5280, DZ=13141403
universal exponent E = 2k−1 = 262141   aggregate resultant cap 2·E·M·D + M = 36371256962843835
```

**Proof chain** (recmo's 63.58 established it; BitWonka/jieyilong tuned it):
GS trivariate interpolation `Q(X,Y,Z)` → substitution vanishing → remove bad
Z-specializations → weighted irreducible-factor pigeonhole → effective
primitive-specialization obstructions → finite Hensel lift → exact base-Z
alignment → degree split (deg-1 vs deg-≥2 branches) → polynomial alignment →
MCA counting bridge → Johnson/list → `ProtocolClaim`. ≈120 flat modules, ≈30k
lines. jieyilong's 63.99 win: a **branch-independent universal-numerator /
aggregate-resultant** ledger that replaced a quadratic all-pairs charge with a
*linear* aggregate degree sum.

---

## 3. Why 64.00 is a wall (independently derived)

The score maps δ → B by `B = ⌊ −12800·log₂(1 − δ) ⌋`. Solving `B = 6400`:

```text
(1−δ)¹²⁸ ≤ 2⁻⁶⁴  ⟺  1−δ ≤ 2^(−1/2) = √½  ⟺  δ ≥ 1 − √½ = 0.29289322…
```

That threshold is **exactly the GS list-decoding radius** `δ* = 1 − √(rate) =
1 − √½` for a rate-½ code. Verified numerically:

| B (centibits) | min δ needed | errors ⌊n·δ⌋ | vs GS radius |
|--:|:--|--:|:--|
| 6399 (now) | 0.29285493 | 76770 | inside (last feasible cell) |
| **6400** | **0.29289322** | **76780** | **= GS radius exactly** |
| 6401 | 0.29293151 | 76790 | **beyond GS** |
| 6450 | 0.29480520 | 77281 | far beyond GS |

At the GS radius the interpolation surplus `a² − nk` collapses. With
`k = 131072, n = 262144`, `√(nk) = 2^17.5 ≈ 185363.8`:

- current 63.99 cell (a = 185374): surplus `a² − nk ≈ 4.0e6` → feasible, slack
  `var − con = 31,971,904` (relative 1.3e-12 — i.e. the **last** feasible GS cell).
- 64.00 cell (a = 185364): surplus `≈ 3.4e5`, ~12× smaller. To close the GS
  rectangle there needs multiplicity `m ≈ 3e4–4.5e4`, which blows the `(DY, DZ)`
  box to ~`6.4e4 × 1.9e9`; every known ledger then pays `≈ 2·E·M·D ≈ 6e19`,
  **~230× over the 2.75e17 budget**.
- 64.01+ (errors ≥ 76790) is **beyond the GS radius** — list sizes are no longer
  known to stay polynomial for worst-case errors; the whole `mcaError` bound
  route stops applying.

**The list side is not the constraint.** Even at the 64.00 cell δ is still just
below `1 − √½`, so the Johnson lemma (`mds_johnson_lambda_le_of_rate_distance`,
η ≈ 7.7e-7) gives `L ≈ 1/η ≈ 1.3e6`, trivially inside 2.75e17. The MCA ledger is
the sole blocker.

**Obvious library shortcuts are closed.** In ArkLib `e651978`,
`rs_mcaError_le_in_johnson_range` (BCHKS25 Thm 4.6) and
`subspace_design_mcaError_le` are `sorry`-backed; the *proven* linear-MCA lemmas
only reach δ ≈ 0.16–0.21 (worse than the ¼ unique-decoding point). So there is no
citable theorem that hands you the 64.00 cell.

---

## 4. Where the improvement lever actually is

`certifiedGammaError = mcaError + Λ/|F|`. Radius enters two ways:

1. **Feasibility** of the GS interpolation (needs `variables > constraints`). This
   is what hits zero at the frontier. It is governed by `√(rate)` — a fundamental
   limit for a *fixed, unfolded* RS code under worst-case (adversarial) errors.
2. **Cost** `N_mca` via the incidence/resultant ledger. This grows with the box
   and pays the `E = 2k−1` Hensel-denominator factor and the `M·D` product.

So the only ways to move the wall:

- **(A) Shrink the ledger cost at a fixed cell** — kill the `E = 2k−1` factor, or
  collapse the `M·D` product structure. This is the class of move that took
  63.94 → 63.99. It might squeeze **exactly one more cell (→ 64.00)** *if* a cell
  in `307084..307121` is simultaneously GS-feasible and ledger-affordable. Current
  evidence says none is — but this is the least-speculative place to look.
- **(B) A different extraction architecture** that isn't `√(rate)`-limited:
  centered/shortened/moment-based MCA counting, or exploiting the *interleaved*
  structure (Fin 8) for collaborative decoding. Caveat: interleaved gains are
  classically for *random* errors; the soundness bound needs *worst-case*, so this
  needs a genuinely new theorem, not a known result.
- **(C) A tighter proximity-gap bound for this exact profile** that beats the
  generic MCA+Johnson decomposition. Highest risk, highest reward.

None of these is incremental. (A) is the pragmatic first probe.

---

## 5. Recommended next steps

1. **Do not touch** `score.txt` / `radius.txt` / `Solution.lean` until a
   kernel-checked certificate for `B > 6399` actually exists. Ties at 63.99 are
   *rejected* (see submission history), so a submission is only worth making if it
   is strictly better and fully kernel-clean.
2. **Pick ONE sub-problem and do it on paper first, in exact integer arithmetic**,
   before any Lean build:
   - (A) an `E`-reducing numerator argument, or a `M·D`-collapsing resultant
     ledger, evaluated against the exact 64.00-cell budget (target: total ledger
     ≤ 2.75e17 at errors = 76780); **or**
   - (B) a centered/shortened MCA-extraction theorem whose feasibility is not
     `√(rate)`-capped. Prove-or-refute the core lemma before committing.
3. Only after the paper argument closes, implement it as new **flat** modules under
   `ProximityPrize/SubmissionLower/`, keeping the axiom closure to
   `{propext, Classical.choice, Quot.sound}` and importing only `TargetLower` +
   sibling modules (`scripts/check-submission-imports.sh` enforces this).
4. **Re-check `yukon submissions --all` and `yukon notes list` before and after**
   any long build — the frontier moved 9× in ~36h; another solver may pass you.
5. Document every experiment with `yukon notes add` (failures included).

---

## 6. Sources & verification discipline

Notes are **public and untrusted**. I independently re-derived the GS ceiling
(§3) and the budget headroom; the numbers match these notes rather than being
taken on faith:

- `a7567b2` (Akashneelesh, Claude Fable 5) — setup + ceiling map; confirms
  budget `274980728111395087` and the 64.00 = GS-radius coincidence.
- `236e1b2` (yashwanth-chennuru) — per-cell GS-rectangle slack table; "the GS
  rectangle ends exactly at the frontier."
- Frontier submission notes: `3c213f2` (recmo, 63.58 — architecture),
  `0a3774e` (jieyilong, 63.99 — universal-numerator ledger), plus BitWonka 63.81/63.94.
- Live (unpromoted, treat as leads only): adrienlacombe centered-q=47;
  sm-stack ramified support; VontariusF trivariate J-substitution; jaazinn
  shortened BCHKS.

Do not import any external theorem as an unproved assumption; verify every
`sorry`-status claim directly in `.lake/packages/Arklib` before relying on it.

---

## 7. Operational notes (this environment)

- **Ranked vs local.** Ranked scores come only from the Linux GitHub-Actions
  runner (landrun + systemd sandbox). On macOS, `yukon run` stops at the Darwin
  gate by design. Local diagnostic run:
  `BENCHMARK_INSECURE_LOCAL=1 ./benchmark.sh lower` (unranked).
- **macOS memory.** On a 16 GiB host the leanchecker phase can SIGKILL with
  default threads; use `LEAN_NUM_THREADS=1` for the kernel-check phase (optionally
  pre-build the solution tree with `LEAN_NUM_THREADS=3` first). *(Our current
  clean run completed the parallel build fine and the single-threaded leanchecker
  stayed ~1.9 GiB.)*
- **Submitting** (only with a genuine improvement):
  `yukon submit --track irs-reduction-threshold-lower --note-file <note.md> --model "<exact model>"`.
  Note must be ≥5 KiB public Markdown; use the **exact** model id actually used.
- **Documentation push.** This repo has a private habit of pushing work to the
  user's own GitHub repo `sivajialla/proximity-prize-soundness` (remote `docs`),
  **never** to `origin` (the challenge upstream). Ranked scoring is via
  `yukon submit`, independent of that push.
