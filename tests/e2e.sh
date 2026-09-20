#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RSR Standard E2E Test Template
#
# End-to-end tests validate the full pipeline: build → run → verify output.
# Customise this file for your project. Delete the examples that don't apply.
#
# Usage:
#   bash tests/e2e.sh
#   just e2e
#
# Merge requirements (STANDING): All 6 test categories must pass before merge:
#   P2P, E2E (this file), aspect, execution, lifecycle, benchmarks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0
SKIP=0

# ─── Colour helpers ──────────────────────────────────────────────────
green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

# ─── Assertion helpers ───────────────────────────────────────────────

# check <label> <expected-substring> <actual>
check() {
    local name="$1" expected="$2" actual="$3"
    if echo "$actual" | grep -q "$expected"; then
        green "  PASS: $name"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (expected '$expected', got '${actual:0:120}')"
        FAIL=$((FAIL + 1))
    fi
}

# check_status <label> <expected-http-status> <actual-http-status>
check_status() {
    local name="$1" expected="$2" actual="$3"
    if [ "$actual" = "$expected" ]; then
        green "  PASS: $name (HTTP $actual)"
        PASS=$((PASS + 1))
    else
        red "  FAIL: $name (expected HTTP $expected, got HTTP $actual)"
        FAIL=$((FAIL + 1))
    fi
}

# skip <label> <reason>
skip_test() {
    yellow "  SKIP: $1 ($2)"
    SKIP=$((SKIP + 1))
}

echo "═══════════════════════════════════════════════════════════════"
echo "  KRL — End-to-End Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─── Preflight ───────────────────────────────────────────────────────
bold "Preflight checks"

FFI_DIR="$PROJECT_DIR/src/interface/ffi"
ABI_DIR="$PROJECT_DIR/src/interface/Abi"

command -v zig >/dev/null 2>&1 || { red "zig not found — required to build the KRL FFI"; exit 1; }
green "  zig found: $(zig version)"

[ -f "$FFI_DIR/build.zig" ] || { red "missing $FFI_DIR/build.zig"; exit 1; }
green "  FFI build definition present"

echo ""

# ─── Section 1: FFI builds and its unit tests pass ───────────────────
bold "Section 1: Zig FFI pipeline"

if (cd "$FFI_DIR" && zig build test) >/dev/null 2>&1; then
    green "  PASS: zig build test"
    PASS=$((PASS + 1))
else
    red "  FAIL: zig build test"
    FAIL=$((FAIL + 1))
fi

if (cd "$FFI_DIR" && zig build) >/dev/null 2>&1 && [ -f "$FFI_DIR/zig-out/lib/libkrl.a" ]; then
    green "  PASS: static library libkrl.a produced"
    PASS=$((PASS + 1))
else
    red "  FAIL: static library libkrl.a not produced"
    FAIL=$((FAIL + 1))
fi

echo ""

# ─── Section 2: ABI surface is covered by the FFI ────────────────────
bold "Section 2: ABI/FFI correspondence"

ABI_FOREIGN=$(grep -h '%foreign' "$ABI_DIR"/*.idr 2>/dev/null | wc -l)
FFI_EXPORTS=$(grep -h '^export fn' "$FFI_DIR"/src/*.zig 2>/dev/null | wc -l)

if [ "$ABI_FOREIGN" -gt 0 ] && [ "$FFI_EXPORTS" -ge "$ABI_FOREIGN" ]; then
    green "  PASS: $ABI_FOREIGN %foreign declarations covered by $FFI_EXPORTS Zig exports"
    PASS=$((PASS + 1))
else
    red "  FAIL: ABI/FFI mismatch ($ABI_FOREIGN %foreign vs $FFI_EXPORTS exports)"
    FAIL=$((FAIL + 1))
fi

echo ""

# ─── Section 3: grammar smoke suite ──────────────────────────────────
bold "Section 3: KRL grammar smoke suite"

if bash "$PROJECT_DIR/tests/smoke/grammar_smoke.sh" >/dev/null 2>&1; then
    green "  PASS: grammar smoke suite"
    PASS=$((PASS + 1))
else
    red "  FAIL: grammar smoke suite"
    FAIL=$((FAIL + 1))
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
