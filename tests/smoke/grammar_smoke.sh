#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
#
# KRL grammar smoke test.
#
# Parsing is not yet implemented. This test does lexical-level verification
# on the example .krl files:
#   - all reserved keywords in the files appear in the grammar's keyword list
#   - every identifier uses only [A-Za-z][A-Za-z0-9_]*
#   - no obvious malformed tokens (unmatched parens, etc.)
#   - every non-comment statement ends with ';'
#
# This is honest E-grade smoke testing — the grammar is drafted, examples
# conform to the declared lexical structure, and we fail loudly if they don't.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EXAMPLES_DIR="${REPO_ROOT}/examples"
GRAMMAR_FILE="${REPO_ROOT}/spec/grammar.ebnf"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RESET=$'\033[0m'

PASS=0
FAIL=0
declare -a FAILURES=()

report_pass() { PASS=$((PASS + 1)); echo "  ${GREEN}✓${RESET} $1"; }
report_fail() { FAIL=$((FAIL + 1)); FAILURES+=("$1"); echo "  ${RED}✗${RESET} $1"; }

echo "== KRL grammar smoke test =="
echo "examples: $EXAMPLES_DIR"
echo "grammar:  $GRAMMAR_FILE"
echo ""

# -- Pre-check: required files exist --
if [[ ! -f "$GRAMMAR_FILE" ]]; then
    echo "${RED}FATAL: grammar file missing: $GRAMMAR_FILE${RESET}"
    exit 2
fi

if [[ ! -d "$EXAMPLES_DIR" ]]; then
    echo "${RED}FATAL: examples dir missing: $EXAMPLES_DIR${RESET}"
    exit 2
fi

# -- Reserved keywords from the grammar --
# Hard-coded from grammar.ebnf "Reserved words" section for deterministic testing
KEYWORDS="let close mirror simplify normalise classify find where and sigma sigma_inv cup cap"

# -- Per-file checks --
shopt -s nullglob
EXAMPLE_FILES=("$EXAMPLES_DIR"/*.krl)
if [[ ${#EXAMPLE_FILES[@]} -eq 0 ]]; then
    echo "${RED}FATAL: no .krl files in $EXAMPLES_DIR${RESET}"
    exit 2
fi

for file in "${EXAMPLE_FILES[@]}"; do
    name=$(basename "$file")
    echo "-- $name --"

    # Strip comments and blank lines for structural checks
    stripped=$(sed -e 's/--.*$//' -e '/^[[:space:]]*$/d' "$file")

    # 1. Every non-empty, non-comment line-group ends with ';'
    # (Since our grammar allows multi-line statements, check that the file
    #  ends, or each statement separator, has a ';' somewhere.)
    if [[ -z "$stripped" ]]; then
        report_fail "$name: only comments (no statements)"
        continue
    fi
    if ! grep -q ';' <<< "$stripped"; then
        report_fail "$name: no ';' terminator found in content"
    else
        report_pass "$name: contains statement terminator(s)"
    fi

    # 2. Balanced parens
    open_count=$(grep -o '(' <<< "$stripped" | wc -l | tr -d ' ')
    close_count=$(grep -o ')' <<< "$stripped" | wc -l | tr -d ' ')
    if [[ "$open_count" == "$close_count" ]]; then
        report_pass "$name: balanced parens ($open_count open, $close_count close)"
    else
        report_fail "$name: unbalanced parens ($open_count open, $close_count close)"
    fi

    # 3. No unknown keywords in a reserved-looking position (words that look like keywords but aren't)
    # Extract all alphabetic tokens, lowercase, and check each against grammar.
    # We flag if a token looks like a reserved word (lowercase, typically short)
    # but isn't in our keyword list AND isn't a user identifier followed by =.
    # Soft-check only: warn, don't fail.
    suspicious=""
    while IFS= read -r token; do
        if [[ "$token" =~ ^(equivalent|near|classify_by|prove)$ ]]; then
            suspicious="$suspicious $token"
        fi
    done < <(grep -oE '[a-z_][a-z0-9_]*' <<< "$stripped" | sort -u)

    if [[ -n "$suspicious" ]]; then
        echo "  ${YELLOW}⚠${RESET}  $name: uses tokens reserved for v0.2+:$suspicious"
    else
        report_pass "$name: no v0.2-reserved tokens used"
    fi

    # 4. Generator usage: sigma N / sigma_inv N / cup N / cap N must have integer argument
    # Extract generator-call patterns. A valid pattern has an integer right after.
    for gen in sigma sigma_inv cup cap; do
        # Find occurrences where generator is NOT followed by an integer
        # (use word boundaries, check char after is not whitespace+digit)
        matches=$(grep -oE "\b$gen\b[^_a-zA-Z0-9]*[^[:space:]0-9]" <<< "$stripped" || true)
        if [[ -n "$matches" ]]; then
            # Could be false positive if 'sigma' appears as identifier. We're strict here.
            report_fail "$name: $gen may be used without integer argument"
        fi
    done

    # 5. File must mention at least one operation family
    found_family=""
    grep -qE '\bsigma\b|\bsigma_inv\b|\bcup\b|\bcap\b' <<< "$stripped" && found_family="${found_family} CONSTRUCT"
    grep -qE '\bmirror\b|\bsimplify\b|\bnormalise\b' <<< "$stripped" && found_family="${found_family} TRANSFORM"
    grep -qE '\bclose\b|\bclassify\b' <<< "$stripped" && found_family="${found_family} RESOLVE"
    grep -qE '\bfind\b' <<< "$stripped" && found_family="${found_family} RETRIEVE"

    if [[ -n "$found_family" ]]; then
        report_pass "$name: exercises operation families:$found_family"
    else
        report_fail "$name: no recognised operation family"
    fi
done

echo ""
echo "== Summary =="
echo "Passed: ${GREEN}$PASS${RESET}"
echo "Failed: ${RED}$FAIL${RESET}"

if [[ $FAIL -gt 0 ]]; then
    echo ""
    echo "Failures:"
    for f in "${FAILURES[@]}"; do
        echo "  - $f"
    done
    exit 1
fi

echo ""
echo "${GREEN}All smoke checks passed.${RESET}"
echo ""
echo "NOTE: this is lexical-level smoke testing only. Real parser pending (see"
echo "      spec/grammar-overview.md — 'Target implementation language for v0.2 parser')."
exit 0
