#!/usr/bin/env bash
# Fail-closed tests for scripts/verify-checksums.sh. No network.
set -euo pipefail

ROOT="$(cd "$(dirname -- "$0")/../.." && pwd)"
SCRIPT="${ROOT}/scripts/verify-checksums.sh"
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

pass_case() {
  local name="$1"
  shift
  if ! "$@" >"$WORKDIR/out.txt" 2>&1; then
    cat "$WORKDIR/out.txt" >&2
    fail "$name: expected success"
  fi
  echo "OK: $name"
}

fail_case() {
  local name="$1"
  shift
  if "$@" >"$WORKDIR/out.txt" 2>&1; then
    cat "$WORKDIR/out.txt" >&2
    fail "$name: expected failure"
  fi
  echo "OK: $name"
}

payload="${WORKDIR}/good.bin"
printf 'durashare-checksum-test\n' > "$payload"
good_hash=$(sha256sum -- "$payload" | awk '{print $1}')

# Matching file
dir1="${WORKDIR}/match"
mkdir -p "$dir1"
printf 'durashare-checksum-test\n' > "${dir1}/WHITEPAPER.pdf"
printf '%s  WHITEPAPER.pdf\n' "$good_hash" > "${dir1}/CHECKSUMS.txt"
pass_case "matching hash" "$SCRIPT" --local "${dir1}/CHECKSUMS.txt"

# Missing listed file
dir2="${WORKDIR}/missing"
mkdir -p "$dir2"
printf '%s  WHITEPAPER.pdf\n' "$good_hash" > "${dir2}/CHECKSUMS.txt"
fail_case "missing listed file" "$SCRIPT" --local "${dir2}/CHECKSUMS.txt"

# Empty CHECKSUMS
dir3="${WORKDIR}/empty"
mkdir -p "$dir3"
: > "${dir3}/CHECKSUMS.txt"
fail_case "empty checksums" "$SCRIPT" --local "${dir3}/CHECKSUMS.txt"

# Comment-only CHECKSUMS (zero hash entries)
dir4="${WORKDIR}/comments"
mkdir -p "$dir4"
printf '# nothing hashed\n' > "${dir4}/CHECKSUMS.txt"
fail_case "no hash entries" "$SCRIPT" --local "${dir4}/CHECKSUMS.txt"

# Mismatched hash
dir5="${WORKDIR}/mismatch"
mkdir -p "$dir5"
printf 'durashare-checksum-test\n' > "${dir5}/WHITEPAPER.pdf"
printf '%s  WHITEPAPER.pdf\n' "0000000000000000000000000000000000000000000000000000000000000000" > "${dir5}/CHECKSUMS.txt"
fail_case "hash mismatch" "$SCRIPT" --local "${dir5}/CHECKSUMS.txt"

# Path traversal
dir6="${WORKDIR}/traversal"
mkdir -p "$dir6"
printf '%s  ../WHITEPAPER.pdf\n' "$good_hash" > "${dir6}/CHECKSUMS.txt"
fail_case "path traversal" "$SCRIPT" --local "${dir6}/CHECKSUMS.txt"

# Historical release-assets/ prefix maps to basename in the same directory
dir7="${WORKDIR}/legacy-prefix"
mkdir -p "$dir7"
printf 'durashare-checksum-test\n' > "${dir7}/WHITEPAPER.pdf"
printf '%s  release-assets/WHITEPAPER.pdf\n' "$good_hash" > "${dir7}/CHECKSUMS.txt"
pass_case "legacy release-assets prefix" "$SCRIPT" --local "${dir7}/CHECKSUMS.txt"

# Unrecognized line
dir8="${WORKDIR}/garbage"
mkdir -p "$dir8"
printf 'not-a-checksum-line\n' > "${dir8}/CHECKSUMS.txt"
fail_case "unrecognized line" "$SCRIPT" --local "${dir8}/CHECKSUMS.txt"

echo "All verify-checksums fail-closed tests passed."
