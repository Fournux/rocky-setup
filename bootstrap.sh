#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VAULT_PASSWORD_FILE="${VAULT_PASSWORD_FILE:-$ROOT_DIR/.vault-password}"
readonly ROOT_DIR VAULT_PASSWORD_FILE
cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage: ./bootstrap.sh <command>

Commands:
  deps    install ansible-core and the pinned Galaxy collections
  check   preview the playbook without changing the server
  run     configure the server
  lint    run Bash, YAML, and Ansible linters offline
  syntax  validate the playbook syntax
  help    display this help

Environment:
  VAULT_PASSWORD_FILE  vault password file used by run/check only
                       (default: <repository>/.vault-password)
USAGE
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Error: required command %s is missing. Run ./bootstrap.sh deps first.\n' "$1" >&2
    exit 1
  }
}

preflight_vault() {
  local vault_mode

  [[ -f "$VAULT_PASSWORD_FILE" && -r "$VAULT_PASSWORD_FILE" && -s "$VAULT_PASSWORD_FILE" ]] || {
    printf 'Error: run/check requires a non-empty, readable vault password file at %s (or set VAULT_PASSWORD_FILE).\n' "$VAULT_PASSWORD_FILE" >&2
    exit 1
  }

  vault_mode=$(stat -Lc '%a' "$VAULT_PASSWORD_FILE")
  (( (8#$vault_mode & 077) == 0 )) || {
    printf 'Error: vault password file permissions are too broad (%s); use chmod 0600 %s.\n' "$vault_mode" "$VAULT_PASSWORD_FILE" >&2
    exit 1
  }
}

command_name="${1:-help}"
if (( $# > 0 )); then
  shift
fi

case "$command_name" in
  deps)
    require pkexec
    pkexec dnf install -y ansible-core
    ansible-galaxy collection install --requirements-file requirements.yml
    ;;
  check)
    require ansible-playbook
    preflight_vault
    ansible-playbook site.yml --check --vault-password-file "$VAULT_PASSWORD_FILE" --ask-become-pass "$@"
    ;;
  run)
    require ansible-playbook
    preflight_vault
    ansible-playbook site.yml --vault-password-file "$VAULT_PASSWORD_FILE" --ask-become-pass "$@"
    ;;
  lint)
    require yamllint
    require ansible-lint
    require ansible-playbook
    echo '==> Checking Bash scripts...'
    bash -n bootstrap.sh
    if command -v shellcheck >/dev/null 2>&1; then
      shellcheck bootstrap.sh
    fi
    echo '==> Running yamllint...'
    yamllint .
    echo '==> Running Ansible syntax-check...'
    ansible-playbook site.yml --syntax-check
    echo '==> Running ansible-lint...'
    ansible-lint --offline
    ;;
  syntax)
    require ansible-playbook
    ansible-playbook site.yml --syntax-check
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
