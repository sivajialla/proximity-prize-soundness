# A beginner's walkthrough of this challenge

You don't need to be a mathematician to understand *how the machine works*. This
is the plain-English tour. (The hard math is in [`../ATTACK-PLAN.md`](../ATTACK-PLAN.md).)

## 1. What the game is

Everyone competes to prove **one** math claim, so airtightly that a computer
program called **Lean** verifies it with zero gaps. A valid proof earns a
**score** (a number of "bits"). Higher = better = higher on the leaderboard.

- Current world record: **63.99 bits**. Target to beat: **64.00**.
- You edit proof files, check them, and submit. A referee re-verifies your proof
  on official servers before your score counts.

## 2. What a "proof" and "checking" look like

See [`HelloProof.lean`](HelloProof.lean) — three tiny proofs. Check them with:

```sh
lake env lean learn/HelloProof.lean
```

**No output means every proof was accepted.** That silence is success.

What a *wrong* proof looks like (we tested this): claiming `2 + 2 = 5` makes Lean
stop with

```text
error: Tactic `rfl` failed: 2 + 2 is not definitionally equal to 5
```

And a "trust me" placeholder called `sorry` gets a warning — the competition
**bans `sorry`**, so any proof using it is rejected. The referee also requires the
proof to rest only on three basic, trusted assumptions (`propext`,
`Classical.choice`, `Quot.sound`) and nothing else.

## 3. The competition proof (the real thing)

The final answer is tiny and readable — `ProximityPrize/SubmissionLower/Solution.lean`:

```lean
theorem candidate : ProtocolClaim 6399 307083 1048576 :=
  protocolClaim6399
```

In words: "I claim a score of **6399** centibits (= 63.99 bits) at radius
**307083/1048576**, and here is the proof (`protocolClaim6399`)." That one proof
name pulls in ~30,000 lines of supporting math across ~120 files in the same
folder. The three things it must establish (from `Benchmark/TargetLower.lean`):

1. **the radius is in range** (a number between 0 and ~0.5),
2. **it's safe** — an error quantity stays below 2⁻¹²⁸ (the "soundness" part),
3. **the score matches** — the safety at that radius really is worth 63.99 bits.

The score itself lives in two plain text files you'd change if you had a better
proof: `score.txt` (`6399`) and `radius.txt` (`307083/1048576`).

## 4. The full loop (all via the `yukon` tool)

```sh
# See where you stand
yukon submissions --all          # the leaderboard + everyone's attempts
yukon notes list                 # other competitors' public research notes

# The work cycle
#  (1) edit files in ProximityPrize/SubmissionLower/
#  (2) check locally  (on this Mac, unranked — the real check is Linux-only):
BENCHMARK_INSECURE_LOCAL=1 ./benchmark.sh lower
#  (3) submit (only if you genuinely beat 63.99 — ties are rejected):
yukon submit --track irs-reduction-threshold-lower \
  --note-file my-note.md --model "<the exact model used>"
```

That's the entire mechanism. Setup (`yukon setup`) only has to be done once.

## 5. Why you can't just "try 64.00"

Beating 63.99 isn't tuning a number — 64.00 sits on a genuine mathematical wall
(the Guruswami–Sudan limit). Dozens of experts with top AI models have been stuck
there for days; every *tie* is rejected. It's an open research problem. Details
and the (long-shot) angles of attack are in [`../ATTACK-PLAN.md`](../ATTACK-PLAN.md).

## 6. Safe things to do while learning

- Read `Solution.lean` — it's 10 lines and shows the shape of a submission.
- Edit `learn/HelloProof.lean`, change a `4` to a `5`, re-run the check, watch Lean
  reject it. Change it back. You now understand the referee.
- `yukon submissions --all` and `yukon notes list` to watch the live competition.
- **Do not** edit `Solution.lean` / `score.txt` / `radius.txt` unless a real,
  checked improvement exists — a broken change just makes the current record stop
  verifying.

## 7. Running without slowing down a 16 GB Mac

The full check (`benchmark.sh`) is a memory bomb on a 16 GB machine — it can push
the Mac into heavy swap and make everything crawl (temporary, not damaging, but
annoying). Best practices:

1. **Don't run the full check locally.** The competition re-verifies every
   submission on its own Linux servers, so let `yukon submit` do the heavy work.
2. **For local checks, build only the file you changed, gently:**
   ```sh
   learn/safe-build.sh ProximityPrize.SubmissionLower.Solution
   ```
   This caps threads and lowers CPU priority so your Mac stays usable. It builds
   one target in seconds–minutes, not the whole 3,900-module closure.
3. **Never re-run `yukon setup`** — it's already done (the 8.6 GB `.lake` cache).
4. If you ever *must* run the full local check, always cap it:
   ```sh
   LEAN_NUM_THREADS=1 BENCHMARK_INSECURE_LOCAL=1 ./benchmark.sh lower
   ```
   Expect it to be slow (an hour+). `LEAN_NUM_THREADS=1` is the setting whose
   absence caused the earlier slowdown.
5. **For serious work, use a Linux machine with 32 GB+ RAM** (cloud VM /
   Codespaces) — a 16 GB Mac is under-spec'd for full Lean+ArkLib builds.
