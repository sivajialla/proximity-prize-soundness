#!/usr/bin/env python3
"""
score_calc.py — a "what-if" calculator for the lower track.

You propose a radius (delta = P/Q). It tells you:
  - the score B that radius would earn,
  - whether the radius is in the legal range (the easy check),
  - how many errors it tolerates, and
  - whether it's below the Guruswami-Sudan "wall" (provable in principle) or
    at/above it (an open research problem).

This is the paper-first exploration: it costs nothing and needs no Lean build.

Usage:
  learn/score_calc.py 307121/1048576     # try a specific radius
  learn/score_calc.py                    # show reference points
"""
import sys, math
from fractions import Fraction

n = 262144                            # domain size 2^18 = number of check points
reps = 128                            # spot-check repetitions
min_rel = Fraction(131073, 262144)    # legal upper bound on the radius
gs_radius = 1 - math.sqrt(0.5)        # the Guruswami-Sudan wall (= score 64.00)
record = 6399                         # current promoted frontier (centibits)

def analyze(P, Q):
    d = Fraction(P, Q); df = float(d)
    bits = -reps * math.log2(1 - df)
    B = math.floor(bits * 100)
    errs = math.floor(df * n)
    legal = 0 < d < min_rel
    print(f"  radius delta   = {P}/{Q} = {df:.10f}")
    print(f"  SCORE          = 2^-{bits:.4f}  ->  B = {B}  (= {B/100:.2f} bits)")
    print(f"  in legal range = {'yes' if legal else 'NO'}  (need 0 < delta < {float(min_rel):.5f})")
    print(f"  errors allowed = {errs}   (of {n} points)")
    print(f"  vs the wall    = {'BELOW' if df < gs_radius else 'AT/ABOVE'} {gs_radius:.8f}")
    # Verdict: is this a viable improvement candidate?  (NOT the real referee —
    # even a PASS still requires you to WRITE the Lean proof and `yukon submit`.)
    if not legal:
        verdict = "FAIL - radius is outside the legal range"
    elif B == record:
        verdict = f"FAIL - ties the record ({record}); ties are rejected"
    elif B < record:
        verdict = f"FAIL - scores {B}, below the record {record}"
    elif df >= gs_radius:
        verdict = f"FAIL - scores {B} but is beyond the wall (needs unproven math)"
    else:
        verdict = f"PASS (in principle) - beats the record and is below the wall"
    print(f"  >> VERDICT     = {verdict}")

if __name__ == "__main__":
    if len(sys.argv) == 2 and "/" in sys.argv[1]:
        P, Q = (int(x) for x in sys.argv[1].split("/"))
        analyze(P, Q)
    else:
        refs = [("current record",          "307083/1048576"),
                ("first radius scoring 64.00","307121/1048576"),
                ("unique decoding (= 1/4)",   "262144/1048576")]
        for label, r in refs:
            print(f"\n### {label}")
            P, Q = (int(x) for x in r.split("/"))
            analyze(P, Q)
        print("\nTry your own:  learn/score_calc.py <P>/<Q>")
