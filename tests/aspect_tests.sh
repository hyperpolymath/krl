#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RSR Standard Aspect Test Template
#
# Aspect tests validate cross-cutting architectural invariants that span
# the entire codebase. These are NOT functional tests — they verify that
# coding standards, safety rules, and structural contracts hold.
#
# Usage:
#   bash tests/aspect_tests.sh
#   just aspect
#
# Standard aspects (enable what applies to your project):
#   1. SPDX compliance — all source files have license headers
#   2. Dangerous patterns — no believe_me, assert_total, sorry, unsafeCoerce, etc.
#   3. ABI/FFI contract — declarations match exports
#   4. Thread safety — mutex in FFI modules
#   5. Error handling — no panic/unreachable in production paths

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
WARN=0

green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

pass() { green "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { red "  FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { yellow "  WARN: $1"; WARN=$((WARN + 1)); }

echo "═══════════════════════════════════════════════════════════════"
echo "  KRL — Aspect Tests (Cross-Cutting Concerns)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Aspect 1: SPDX License Headers
# ═══════════════════════════════════════════════════════════════════════
bold "Aspect 1: SPDX license headers"

MISSING_SPDX=0
while IFS= read -r -d '' f; do
    if ! head -5 "$f" | grep -q "SPDX-License-Identifier"; then
        warn "Missing SPDX header: $f"
        MISSING_SPDX=$((MISSING_SPDX + 1))
    fi
done < <(find src/ \( -name ".zig-cache" -o -name "zig-out" -o -name "build" \) -prune -o \
    -type f \( -name "*.rs" -o -name "*.zig" -o -name "*.res" -o -name "*.ex" -o -name "*.exs" -o -name "*.gleam" -o -name "*.idr" -o -name "*.sh" \) -print0 2>/dev/null)

if [ "$MISSING_SPDX" -eq 0 ]; then
    pass "All source files have SPDX headers"
else
    fail "$MISSING_SPDX files missing SPDX headers"
fi

# ═══════════════════════════════════════════════════════════════════════
# Aspect 2: Dangerous Patterns (BANNED)
# ═══════════════════════════════════════════════════════════════════════
bold "Aspect 2: Dangerous patterns"

# Source files only. Prose files (.adoc/.md) legitimately *name* the banned
# constructs in order to ban them; scanning them yields false positives.
SOURCE_FILES=()
while IFS= read -r -d '' f; do
    SOURCE_FILES+=("$f")
done < <(find src/ verification/ \( -name ".zig-cache" -o -name "zig-out" -o -name "build" \) -prune -o \
    -type f \( -name "*.idr" -o -name "*.zig" -o -name "*.lean" -o -name "*.v" \
       -o -name "*.hs" -o -name "*.rs" -o -name "*.ml" \) -print0 2>/dev/null)

# Comment lines legitimately *name* the banned constructs in order to ban them.
# Strip `file:line:` then any leading comment marker before judging a hit.
strip_comments() { grep -vE ':[0-9]+:[[:space:]]*(--|//|#|\(\*|\*)' || true; }

if [ "${#SOURCE_FILES[@]}" -eq 0 ]; then
    fail "No source files found under src/ or verification/ — aspect scan would be vacuous"
else
    # Idris2 dangerous patterns
    DANGEROUS_IDRIS=$({ grep -n 'believe_me\|assert_total\|really_believe_me' "${SOURCE_FILES[@]}" 2>/dev/null || true; } | strip_comments)
    if [ -n "$DANGEROUS_IDRIS" ]; then
        fail "Dangerous Idris2 patterns found:"
        echo "$DANGEROUS_IDRIS" | head -5
    else
        pass "No dangerous Idris2 patterns (believe_me, assert_total) in ${#SOURCE_FILES[@]} source files"
    fi

    # Coq/Lean/Haskell dangerous patterns
    DANGEROUS_PROOF=$({ grep -n '\bAdmitted\b\|\bsorry\b\|\bunsafeCoerce\b\|\bObj\.magic\b' "${SOURCE_FILES[@]}" 2>/dev/null || true; } | strip_comments)
    if [ -n "$DANGEROUS_PROOF" ]; then
        fail "Dangerous proof patterns found:"
        echo "$DANGEROUS_PROOF" | head -5
    else
        pass "No dangerous proof patterns (Admitted, sorry, unsafeCoerce) in ${#SOURCE_FILES[@]} source files"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════
# Aspect 3: ABI/FFI Contract (if applicable)
# ═══════════════════════════════════════════════════════════════════════
bold "Aspect 3: ABI/FFI contract"

ABI_DIR="src/interface/Abi"
FFI_DIR="src/interface/ffi"

if [ -d "$ABI_DIR" ] && [ -d "$FFI_DIR" ]; then
    # Idris2 declares the ABI surface; Zig implements it over the C ABI.
    # Zig uses bare `export fn` (not `pub export fn`) for C-ABI exports.
    ABI_FOREIGN=$(grep -h '%foreign' "$ABI_DIR"/*.idr 2>/dev/null | wc -l)
    FFI_EXPORTS=$(grep -h '^export fn' "$FFI_DIR"/src/*.zig 2>/dev/null | wc -l)

    if [ "${ABI_FOREIGN:-0}" -eq 0 ]; then
        fail "No %foreign declarations found in $ABI_DIR — ABI surface is empty"
    elif [ "$FFI_EXPORTS" -eq 0 ]; then
        fail "No 'export fn' found in $FFI_DIR/src — FFI implementation is empty"
    elif [ "$FFI_EXPORTS" -lt "$ABI_FOREIGN" ]; then
        fail "ABI/FFI mismatch: $ABI_FOREIGN %foreign declarations but only $FFI_EXPORTS Zig exports"
    else
        pass "ABI ($ABI_FOREIGN %foreign decls) covered by FFI ($FFI_EXPORTS exports)"
    fi
else
    fail "Expected ABI at $ABI_DIR and FFI at $FFI_DIR — one or both missing"
fi

# ═══════════════════════════════════════════════════════════════════════
# Aspect 4: Error Handling (no raw panic in production code)
# ═══════════════════════════════════════════════════════════════════════
# Uncomment for Rust projects:

# bold "Aspect 4: Error handling"
# UNWRAP_COUNT=$(grep -rn '\.unwrap()' src/ 2>/dev/null | grep -v "test" | grep -v "example" | wc -l)
# if [ "$UNWRAP_COUNT" -gt 20 ]; then
#     warn "$UNWRAP_COUNT .unwrap() calls in src/ — consider replacing with ? or expect()"
# else
#     pass "Acceptable unwrap count: $UNWRAP_COUNT"
# fi

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
if [ "$WARN" -gt 0 ]; then yellow "WARN=$WARN"; else echo "WARN=0"; fi
echo ""
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
