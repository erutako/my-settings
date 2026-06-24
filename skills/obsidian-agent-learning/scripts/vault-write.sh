#!/usr/bin/env bash
# Safe vault write: existence check + locked atomic replace.
#
#   vault-write.sh --check <abs-path>     # prints NEW or UPDATE (no write)
#   vault-write.sh <abs-path> <<'EOF'     # locked atomic write (stdin = full body)
#   ...
#   EOF
#
# Locking serializes concurrent writes to the same path; atomic replace plus
# refusing " (N).md" conflict-copy paths avoids Obsidian duplicate files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=resolve-config.sh
source "$SCRIPT_DIR/resolve-config.sh"

LOCK_ROOT="$VAULT/.agent-locks"
TIMEOUT=60

usage() {
  echo "Usage:" >&2
  echo "  vault-write.sh --check <abs-path>" >&2
  echo "  vault-write.sh <abs-path>  # stdin = full file body" >&2
  exit 1
}

CHECK_ONLY=false
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) CHECK_ONLY=true; shift ;;
    -*) usage ;;
    *) TARGET="$1"; shift ;;
  esac
done

[[ -n "$TARGET" ]] || usage

case "$TARGET" in
  "$VAULT"/*) ;;
  *)
    echo "ERROR: target must be under vault: $VAULT" >&2
    exit 1
    ;;
esac

base="$(basename "$TARGET")"
if [[ "$base" =~ \ \([0-9]+\)\.md$ ]]; then
  echo "ERROR: refusing conflict-copy path (Obsidian duplicate): $TARGET" >&2
  echo "HINT: use the canonical path without ' (N)' suffix." >&2
  exit 1
fi

if $CHECK_ONLY; then
  if [[ -f "$TARGET" ]]; then
    echo "UPDATE"
  else
    echo "NEW"
  fi
  exit 0
fi

if command -v md5 >/dev/null 2>&1; then
  HASH=$(printf '%s' "$TARGET" | md5 -q)
elif command -v md5sum >/dev/null 2>&1; then
  HASH=$(printf '%s' "$TARGET" | md5sum | awk '{print $1}')
else
  HASH=$(printf '%s' "$TARGET" | cksum | awk '{print $1}')
fi

LOCK_DIR="$LOCK_ROOT/$HASH"
mkdir -p "$LOCK_ROOT"

acquire_lock() {
  local waited=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    if (( waited >= TIMEOUT )); then
      echo "ERROR: lock timeout (${TIMEOUT}s): $TARGET" >&2
      exit 1
    fi
    sleep 1
    waited=$((waited + 1))
  done
  {
    printf 'pid=%s\n' "$$"
    printf 'target=%s\n' "$TARGET"
    printf 'started=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$LOCK_DIR/meta"
}

release_lock() {
  rm -f "$LOCK_DIR/meta" 2>/dev/null || true
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

trap release_lock EXIT

acquire_lock

MODE="NEW"
[[ -f "$TARGET" ]] && MODE="UPDATE"

mkdir -p "$(dirname "$TARGET")"

TMP="${TARGET}.__agent_write.$$"
cat > "$TMP"
mv -f "$TMP" "$TARGET"

echo "${MODE}:${TARGET}"
