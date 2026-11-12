#!/usr/bin/env bash
# ============================================================
# Auto Installation Linux Mint - Bootstrap
# Usage : ./bootstrap.sh (local), or ./bootstrap.sh local --check --diff pour un dry-run
# ============================================================

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ANSIBLE_DIR="${SCRIPT_DIR}/ansible"
PLAYBOOK="playbooks/complete_install.yml"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log_info()  { printf '%b[INFO]%b  %s\n'  "$GREEN"  "$NC" "$*"; }
log_warn()  { printf '%b[WARN]%b  %s\n'  "$YELLOW" "$NC" "$*" >&2; }
log_error() { printf '%b[ERROR]%b %s\n' "$RED"    "$NC" "$*" >&2; }

usage() { echo "Usage: $0 [local|remote] [options ansible-playbook]"; }


if [[ ! -d "${ANSIBLE_DIR}" ]]; then
  log_error "Ansible dir wasn't found (${SCRIPT_DIR})."
  exit 1
fi

MODE="${1:-local}"
case "$MODE" in
  local|remote) shift || true ;;
  -h|--help)    usage; exit 0 ;;
  *)            log_error "Mode invalide : $MODE"; usage; exit 1 ;;
esac

INVENTORY="inventories/${MODE}/hosts.yml"

if ! command -v ansible-playbook &>/dev/null; then
  log_warn "Ansible not found. Installating..."
  sudo apt-get update
  sudo apt-get install -y ansible ansible-lint
fi
log_info "$(ansible-playbook --version | sed -n 1p)"

cd "${ANSIBLE_DIR}"

[[ -f "$INVENTORY" ]] || { log_error "Inventory not found: $INVENTORY"; exit 1; }
[[ -f "$PLAYBOOK" ]] || { log_error "Playbook not found: $playbook"; exit 1; }

log_info "Launching playbook (mode : ${MODE})..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --ask-become-pass "$@"

log_info "Terminé."
