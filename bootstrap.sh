#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR
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
USAGE
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Error: required command %s is missing. Run ./bootstrap.sh deps first.\n' "$1" >&2
    exit 1
  }
}

case "${1:-help}" in
  deps)
    require pkexec
    pkexec dnf install -y ansible-core
    ansible-galaxy collection install --requirements-file requirements.yml
    ;;
  check)
    require ansible-playbook
    ansible-playbook site.yml --check --ask-become-pass
    ;;
  run)
    require ansible-playbook
    ansible-playbook site.yml --ask-become-pass
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
