#!/usr/bin/env bash
#
# safe-build.sh — low-impact Lean build for a 16 GB Mac.
#
# Builds ONE target with a capped thread count AND low CPU/IO priority, so your
# Mac stays responsive and does NOT swap-thrash the way a full `benchmark.sh`
# run does. Use this for the light "edit one file, check it" loop.
#
# Usage:
#   learn/safe-build.sh                                   # builds Solution (whole submission)
#   learn/safe-build.sh ProximityPrize.SubmissionLower.BCHKSParameters6399
#   LEAN_NUM_THREADS=1 learn/safe-build.sh <target>       # even gentler
#
# It will NOT run the full kernel-check (that's the memory-heavy part — let the
# competition's Linux servers do that via `yukon submit`).

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
export PATH="$HOME/.elan/bin:$HOME/.local/bin:$PATH"

target="${1:-ProximityPrize.SubmissionLower.Solution}"
threads="${LEAN_NUM_THREADS:-2}"   # 2 keeps memory well under 16 GB; use 1 to be safest

# Warn if free memory is already low, so you can close apps first.
free_pct="$(memory_pressure 2>/dev/null | awk -F: '/free percentage/{gsub(/[ %]/,"",$2);print $2}')"
if [[ -n "${free_pct:-}" && "${free_pct}" -lt 25 ]]; then
  echo "⚠️  Only ${free_pct}% memory free — consider closing other apps before building." >&2
fi

echo "Building '${target}' with LEAN_NUM_THREADS=${threads} at low priority (nice)…"
echo "(Ctrl-C any time; this only builds one target, not the full check.)"

# `nice -n 15` lowers CPU priority so your foreground apps stay smooth.
LEAN_NUM_THREADS="${threads}" nice -n 15 lake build "${target}"

echo "✅ Done — '${target}' built. Nothing else was run."
