#!/usr/bin/env bash
#
# Verify SHA256 checksums for DuraShare specification release assets.
#
# Integrity only. Authenticity requires the signed git tag and detached .asc
# signatures (see scripts/verify-published-release.sh).
#
# Usage:
#   ./scripts/verify-checksums.sh --local CHECKSUMS.txt
#   ./scripts/verify-checksums.sh [--dir DIR] [version]
#
# Fail-closed: missing files, empty/unparseable CHECKSUMS.txt, path traversal,
# and zero hashed entries are errors. Success requires every listed file to
# exist and match.
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

REPO="${DURASHARE_REPO:-GRIFORTIS/durashare}"
LOCAL_CHECKSUMS=""
DIR=""
VERSION="latest"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/verify-checksums.sh --local CHECKSUMS.txt
  ./scripts/verify-checksums.sh [--dir DIR] [version]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      [[ $# -ge 2 ]] || { echo "Missing path for --local" >&2; exit 2; }
      LOCAL_CHECKSUMS="$2"
      shift 2
      ;;
    --dir)
      [[ $# -ge 2 ]] || { echo "Missing path for --dir" >&2; exit 2; }
      DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      VERSION="$1"
      shift
      ;;
  esac
done

if [[ -n "$LOCAL_CHECKSUMS" && "$VERSION" != "latest" ]]; then
  echo "Use either --local CHECKSUMS.txt or a release version, not both." >&2
  exit 2
fi

hash_file() {
  sha256sum -- "$1" | awk '{print tolower($1)}'
}

is_unsafe_filename() {
  local name="$1"
  if [[ "$name" == /* || "$name" == ~* || "$name" == *:* ]]; then
    return 0
  fi
  if [[ "$name" == *..* ]]; then
    return 0
  fi
  return 1
}

# Historical v0.7.0 CHECKSUMS.txt listed staging paths (release-assets/NAME).
# Resolve those only when dirname is exactly "release-assets" and NAME exists
# in the verification directory. Never rewrite other prefixes.
resolve_listed_file() {
  local root="$1"
  local listed="$2"
  local candidate="$root/$listed"

  if [[ -f "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  local parent base
  parent=$(dirname -- "$listed")
  base=$(basename -- "$listed")
  if [[ "$parent" == "release-assets" && -f "$root/$base" ]]; then
    printf '%s\n' "$root/$base"
    return 0
  fi
  return 1
}

verify_checksums_file() {
  local checksums_file="$1"
  local root="$2"
  local line expected_hash listed actual_file actual_hash
  local passed=0 failed=0 missing=0 parsed=0

  if [[ ! -f "$checksums_file" ]]; then
    echo -e "${RED}✗${NC} CHECKSUMS file not found: $checksums_file" >&2
    return 1
  fi
  if [[ ! -s "$checksums_file" ]]; then
    echo -e "${RED}✗${NC} CHECKSUMS file is empty: $checksums_file" >&2
    return 1
  fi

  echo "🔍 Verifying checksums in $checksums_file"
  echo ""

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^([0-9A-Fa-f]{64})[[:space:]]+\*?(.+)$ ]]; then
      expected_hash=$(printf '%s' "${BASH_REMATCH[1]}" | tr 'A-F' 'a-f')
      listed="${BASH_REMATCH[2]}"
      listed="${listed#"${listed%%[![:space:]]*}"}"
      listed="${listed%"${listed##*[![:space:]]}"}"
    else
      echo -e "${RED}✗${NC} Unrecognized CHECKSUMS line (not GNU sha256sum format):"
      echo "   $line"
      failed=$((failed + 1))
      continue
    fi

    if [[ -z "$listed" ]] || is_unsafe_filename "$listed"; then
      echo -e "${RED}✗${NC} Unsafe or empty filename in CHECKSUMS.txt: ${listed:-<empty>}"
      failed=$((failed + 1))
      continue
    fi

    parsed=$((parsed + 1))

    if ! actual_file=$(resolve_listed_file "$root" "$listed"); then
      echo -e "${RED}✗${NC} $listed (not found under $root)"
      missing=$((missing + 1))
      continue
    fi

    actual_hash=$(hash_file "$actual_file")
    if [[ "$expected_hash" == "$actual_hash" ]]; then
      echo -e "${GREEN}✓${NC} $listed"
      passed=$((passed + 1))
    else
      echo -e "${RED}✗${NC} $listed"
      echo "   Expected: $expected_hash"
      echo "   Got:      $actual_hash"
      failed=$((failed + 1))
    fi
  done < "$checksums_file"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Results:"
  echo -e "  ${GREEN}Passed:${NC} $passed"
  echo -e "  ${RED}Failed:${NC} $failed"
  echo -e "  ${RED}Missing:${NC} $missing"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [[ "$parsed" -eq 0 ]]; then
    echo ""
    echo -e "${RED}✗ Checksum verification FAILED${NC}"
    echo "  CHECKSUMS.txt contained no hash entries."
    return 1
  fi
  if [[ "$failed" -gt 0 || "$missing" -gt 0 ]]; then
    echo ""
    echo -e "${RED}✗ Checksum verification FAILED${NC}"
    echo "  Listed files must all exist and match. Missing files are errors."
    return 1
  fi

  echo ""
  echo -e "${GREEN}✓ All checksums verified successfully!${NC}"
  echo "  The files match the published checksums."
  echo "  This alone does not prove authenticity; also verify the signed tag and detached signatures."
  return 0
}

echo "🔐 Verifying checksums for DuraShare Specification"
echo ""
echo "Note: checksum validation confirms file integrity only."
echo "For authenticity, also verify the signed git tag and any detached .asc signatures."
echo ""

if [[ -n "$LOCAL_CHECKSUMS" ]]; then
  if [[ ! -f "$LOCAL_CHECKSUMS" ]]; then
    echo -e "${RED}✗${NC} CHECKSUMS file not found: $LOCAL_CHECKSUMS" >&2
    exit 1
  fi
  checksums_abs=$(cd "$(dirname -- "$LOCAL_CHECKSUMS")" && pwd)/$(basename -- "$LOCAL_CHECKSUMS")
  root=$(dirname -- "$checksums_abs")
  verify_checksums_file "$checksums_abs" "$root"
  exit $?
fi

if [[ -z "$DIR" ]]; then
  DIR="."
fi
mkdir -p "$DIR"
DIR=$(cd "$DIR" && pwd)

if [[ "$VERSION" == "latest" ]]; then
  checksum_url="https://github.com/${REPO}/releases/latest/download/CHECKSUMS.txt"
else
  checksum_url="https://github.com/${REPO}/releases/download/${VERSION}/CHECKSUMS.txt"
fi

echo "📥 Downloading checksums for version: ${VERSION}"
echo "   URL: ${checksum_url}"
echo ""

if curl -fSL -o "${DIR}/CHECKSUMS.txt" "$checksum_url"; then
  echo -e "${GREEN}✓${NC} Downloaded CHECKSUMS.txt"
else
  echo -e "${RED}✗${NC} Failed to download checksums"
  echo "   Make sure the release exists and has checksums attached"
  exit 1
fi

echo ""
echo "📝 Checksums file content:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "${DIR}/CHECKSUMS.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

verify_checksums_file "${DIR}/CHECKSUMS.txt" "$DIR"
exit $?
