#!/usr/bin/env bash
# Resolve VAULT and SCRIPT for obsidian-agent-learning.
#
# Bash (source):
#   source "<skill-dir>/scripts/resolve-config.sh"
#
# Any shell (recommended):
#   eval "$("<skill-dir>/scripts/resolve-config.sh")"
set -euo pipefail

_resolve_skill_dir() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  printf '%s' "$script_dir"
}

_load_config() {
  SKILL_DIR="${OBSIDIAN_AGENT_SKILL_DIR:-$(_resolve_skill_dir)}"
  CONFIG_FILE="${OBSIDIAN_AGENT_CONFIG:-$SKILL_DIR/config.local.yaml}"
  SCRIPT="${OBSIDIAN_AGENT_SCRIPT:-$SKILL_DIR/scripts/vault-write.sh}"
  VAULT="${OBSIDIAN_VAULT:-}"
  CONTENTS_MAP="${OBSIDIAN_CONTENTS_MAP:-}"

  if [[ -z "$VAULT" && -f "$CONFIG_FILE" ]]; then
    VAULT="$(grep -E '^vault:[[:space:]]*' "$CONFIG_FILE" | head -1 \
      | sed -E 's/^vault:[[:space:]]*//' | tr -d \"'')"
  fi

  if [[ -z "$VAULT" ]]; then
    echo "ERROR: vault path not configured." >&2
    echo "  Copy config.example.yaml → config.local.yaml and set vault:" >&2
    echo "  Or export OBSIDIAN_VAULT=/absolute/path/to/vault" >&2
    return 1 2>/dev/null || exit 1
  fi

  if [[ ! -d "$VAULT" ]]; then
    echo "ERROR: vault directory does not exist: $VAULT" >&2
    return 1 2>/dev/null || exit 1
  fi

  if [[ -z "$CONTENTS_MAP" && -f "$CONFIG_FILE" ]]; then
    CONTENTS_MAP="$( { grep -E '^contents_map:[[:space:]]*' "$CONFIG_FILE" || true; } | head -1 \
      | sed -E 's/^contents_map:[[:space:]]*//' | tr -d \"'')"
  fi
  # Default: root-level map of the learning tree.
  CONTENTS_MAP="${CONTENTS_MAP:-$VAULT/_contents-map.md}"
  case "$CONTENTS_MAP" in
    /*) ;;
    *) CONTENTS_MAP="$VAULT/$CONTENTS_MAP" ;;
  esac
}

_emit_exports() {
  printf "export SKILL_DIR=%q\n" "$SKILL_DIR"
  printf "export CONFIG_FILE=%q\n" "$CONFIG_FILE"
  printf "export SCRIPT=%q\n" "$SCRIPT"
  printf "export VAULT=%q\n" "$VAULT"
  printf "export CONTENTS_MAP=%q\n" "$CONTENTS_MAP"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _load_config
  _emit_exports
  exit 0
fi

_load_config
export SKILL_DIR CONFIG_FILE SCRIPT VAULT CONTENTS_MAP
