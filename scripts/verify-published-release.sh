#!/usr/bin/env bash
#
# Verify a published DuraShare GitHub Release end-to-end:
#   1. The six expected assets are present.
#   2. Detached signatures verify under the pinned GRIFORTIS OpenPGP fingerprint.
#   3. CHECKSUMS.txt hashes match the two PDFs (fail-closed).
#   4. WHITEPAPER.pdf and WHITEPAPER-vX.Y.Z.pdf are byte-identical.
#
# Usage:
#   ./scripts/verify-published-release.sh v0.7.1
#
# Requires: gh, gpg, sha256sum, curl. Does not use private keys.
#
set -euo pipefail

EXPECTED_FINGERPRINT="7921FD5694508DA4020E671F4CFE6248C57F15DF"
REPO="${GITHUB_REPOSITORY:-GRIFORTIS/durashare}"
ROOT="$(cd "$(dirname -- "$0")/.." && pwd)"
PUBLIC_KEY="${ROOT}/GRIFORTIS-PGP-PUBLIC-KEY.asc"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 vX.Y.Z" >&2
  exit 2
fi

TAG="$1"
if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid tag format: $TAG (expected vX.Y.Z)" >&2
  exit 2
fi

if [[ ! -f "$PUBLIC_KEY" ]]; then
  echo "Missing public key: $PUBLIC_KEY" >&2
  exit 1
fi

command -v gh >/dev/null || { echo "gh is required" >&2; exit 1; }
command -v gpg >/dev/null || { echo "gpg is required" >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "sha256sum is required" >&2; exit 1; }

expected_assets=(
  "WHITEPAPER.pdf"
  "WHITEPAPER.pdf.asc"
  "WHITEPAPER-${TAG}.pdf"
  "WHITEPAPER-${TAG}.pdf.asc"
  "CHECKSUMS.txt"
  "CHECKSUMS.txt.asc"
)

echo "Verifying published release ${TAG} in ${REPO}"
echo "Pinned fingerprint: ${EXPECTED_FINGERPRINT}"
echo ""

published_list=$(gh release view "$TAG" --repo "$REPO" --json assets --jq '.assets[].name')
if [[ -z "$published_list" ]]; then
  echo "No assets listed on ${TAG}" >&2
  exit 1
fi

missing=()
for f in "${expected_assets[@]}"; do
  if ! printf '%s\n' "$published_list" | grep -Fx -- "$f" >/dev/null; then
    missing+=("$f")
  fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Missing required release assets:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi
echo "OK: all six required assets are present"

workdir=$(mktemp -d)
cleanup() {
  rm -rf "$workdir"
  if [[ -n "${GNUPGHOME:-}" && "$GNUPGHOME" == "$workdir"* ]]; then
    :
  fi
}
trap cleanup EXIT

mkdir -p "$workdir/gnupg" "$workdir/assets"
chmod 700 "$workdir/gnupg"
export GNUPGHOME="$workdir/gnupg"

file_fpr=$(gpg --batch --with-colons --show-keys "$PUBLIC_KEY" | awk -F: '/^fpr:/{print $10; exit}')
if [[ "$file_fpr" != "$EXPECTED_FINGERPRINT" ]]; then
  echo "Public key file fingerprint mismatch:" >&2
  echo "  expected $EXPECTED_FINGERPRINT" >&2
  echo "  file     ${file_fpr:-<empty>}" >&2
  exit 1
fi

gpg --batch --import "$PUBLIC_KEY" >/dev/null 2>&1
imported_fpr=$(gpg --batch --with-colons --fingerprint | awk -F: '/^fpr:/{print $10; exit}')
if [[ "$imported_fpr" != "$EXPECTED_FINGERPRINT" ]]; then
  echo "Imported key fingerprint mismatch: ${imported_fpr:-<empty>}" >&2
  exit 1
fi
echo "OK: imported GRIFORTIS OpenPGP key"

gh release download "$TAG" --repo "$REPO" --dir "$workdir/assets"
for f in "${expected_assets[@]}"; do
  if [[ ! -f "$workdir/assets/$f" ]]; then
    echo "Download did not produce $f" >&2
    exit 1
  fi
done
echo "OK: downloaded required assets"

verify_detached() {
  local sig="$1"
  local file="$2"
  local status primary
  status=$(gpg --batch --status-fd 1 --verify "$sig" "$file" 2>/dev/null || true)
  primary=$(printf '%s\n' "$status" | awk '/^\[GNUPG:\] VALIDSIG / {print $12; exit}')
  if [[ "$primary" != "$EXPECTED_FINGERPRINT" ]]; then
    echo "Signature verification failed for $(basename "$file")" >&2
    echo "$status" >&2
    return 1
  fi
  echo "OK: $(basename "$sig") (VALIDSIG ${primary})"
}

verify_detached "$workdir/assets/CHECKSUMS.txt.asc" "$workdir/assets/CHECKSUMS.txt"
verify_detached "$workdir/assets/WHITEPAPER.pdf.asc" "$workdir/assets/WHITEPAPER.pdf"
verify_detached "$workdir/assets/WHITEPAPER-${TAG}.pdf.asc" "$workdir/assets/WHITEPAPER-${TAG}.pdf"

echo ""
if ! "${ROOT}/scripts/verify-checksums.sh" --local "$workdir/assets/CHECKSUMS.txt"; then
  exit 1
fi

hash_stable=$(sha256sum -- "$workdir/assets/WHITEPAPER.pdf" | awk '{print tolower($1)}')
hash_versioned=$(sha256sum -- "$workdir/assets/WHITEPAPER-${TAG}.pdf" | awk '{print tolower($1)}')
if [[ "$hash_stable" != "$hash_versioned" ]]; then
  echo "WHITEPAPER.pdf and WHITEPAPER-${TAG}.pdf are not identical:" >&2
  echo "  WHITEPAPER.pdf              $hash_stable" >&2
  echo "  WHITEPAPER-${TAG}.pdf       $hash_versioned" >&2
  exit 1
fi
echo "OK: both PDF filenames are the same bytes"

echo ""
echo "Published release ${TAG} verified:"
echo "  assets present, signatures match pinned fingerprint, checksums match, PDF pair identical."
