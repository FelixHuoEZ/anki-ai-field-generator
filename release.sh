#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is required."
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: zip is required."
  exit 1
fi

ADDON_NAME="${ADDON_NAME:-AnkiSpark}"
ADDON_PACKAGE="${ADDON_PACKAGE:-ankispark}"
ADDON_CONFLICTS="${ADDON_CONFLICTS:-}"
VERSION="${1:-$(git describe --tags --always --dirty 2>/dev/null || date +%Y%m%d%H%M%S)}"
DIST_DIR="$ROOT_DIR/dist"
OUTPUT_FILE="$DIST_DIR/${ADDON_NAME}-${VERSION}.ankiaddon"

if [[ ! "$ADDON_PACKAGE" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Error: ADDON_PACKAGE must match ^[A-Za-z0-9._-]+$"
  exit 1
fi

INCLUDE_PATHS=(
  "__init__.py"
  "config"
  "core"
  "providers"
  "ui"
  "utils"
  "LICENSE"
  "README.md"
  "config.example.json"
  "config.example.zh.json"
  "requirements.txt"
)

PACKAGE_FILES=()
while IFS= read -r file; do
  if [[ -n "$file" ]]; then
    PACKAGE_FILES+=("$file")
  fi
done < <(git ls-files -- "${INCLUDE_PATHS[@]}" | sort -u)

if [[ ${#PACKAGE_FILES[@]} -eq 0 ]]; then
  echo "Error: no files selected for packaging."
  exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ankispark-release.XXXXXX")"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/ }"
  printf '%s' "$value"
}

MANIFEST_FILE="$TMP_DIR/manifest.json"
conflicts_json=""
if [[ -n "$ADDON_CONFLICTS" ]]; then
  IFS=',' read -r -a conflicts_arr <<< "$ADDON_CONFLICTS"
  for conflict in "${conflicts_arr[@]}"; do
    conflict="${conflict#"${conflict%%[![:space:]]*}"}"
    conflict="${conflict%"${conflict##*[![:space:]]}"}"
    if [[ -z "$conflict" ]]; then
      continue
    fi
    escaped_conflict="$(json_escape "$conflict")"
    if [[ -n "$conflicts_json" ]]; then
      conflicts_json+=", "
    fi
    conflicts_json+="\"$escaped_conflict\""
  done
fi

{
  printf '{\n'
  printf '  "package": "%s",\n' "$(json_escape "$ADDON_PACKAGE")"
  printf '  "name": "%s",\n' "$(json_escape "$ADDON_NAME")"
  printf '  "mod": %s' "$(date +%s)"
  if [[ -n "$conflicts_json" ]]; then
    printf ',\n  "conflicts": [%s]\n' "$conflicts_json"
  else
    printf '\n'
  fi
  printf '}\n'
} > "$MANIFEST_FILE"

echo "Running sensitive file checks..."

SENSITIVE_NAME_REGEX='(^|/)(config\.json|\.env(\..*)?|id_rsa|.*\.(pem|key|p12|pfx)|anki_ai_runtime\.log)$'
sensitive_name_hits=()
for file in "${PACKAGE_FILES[@]}"; do
  if [[ "$file" =~ $SENSITIVE_NAME_REGEX ]]; then
    sensitive_name_hits+=("$file")
  fi
done

if [[ ${#sensitive_name_hits[@]} -gt 0 ]]; then
  echo "Error: blocked sensitive file(s) detected in package list:"
  printf '  - %s\n' "${sensitive_name_hits[@]}"
  exit 1
fi

SECRET_SCAN_REGEX='(sk-ant-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9]{20,}|AIza[0-9A-Za-z_-]{20,}|(api[_-]?key|access[_-]?token|authorization)[[:space:]]*["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"']{16,})'
ALLOWLIST_REGEX='(REDACTED|redacted|your-|YOUR_|example|placeholder|dummy|sample|changeme|<REDACTED|YOUR_NOTE_TYPE_ID|已隐藏|HIDDEN|MASKED)'

secret_hits=()
while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    continue
  fi
  if [[ "$line" =~ $ALLOWLIST_REGEX ]]; then
    continue
  fi
  secret_hits+=("$line")
done < <(rg -n -I --with-filename --no-heading -e "$SECRET_SCAN_REGEX" "${PACKAGE_FILES[@]}" || true)

if [[ ${#secret_hits[@]} -gt 0 ]]; then
  echo "Error: possible secrets detected in tracked package files:"
  printf '  - %s\n' "${secret_hits[@]}"
  echo "Please redact them before release."
  exit 1
fi

echo "Sensitive checks passed."

mkdir -p "$DIST_DIR"
rm -f "$OUTPUT_FILE"
zip -q "$OUTPUT_FILE" "${PACKAGE_FILES[@]}"
zip -q -j "$OUTPUT_FILE" "$MANIFEST_FILE"

echo "Package created: $OUTPUT_FILE"
echo "Included files: $((${#PACKAGE_FILES[@]} + 1))"
echo "Manifest package: $ADDON_PACKAGE"
