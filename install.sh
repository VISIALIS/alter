#!/usr/bin/env bash
# Alter direct installer — CLI + MCP server (macOS / Linux).
#
# Usage:
#   curl -fsSL https://www.alter-evm.com/install.sh | bash
#
# Options (environment variables):
#   ALTER_INSTALL_DIR   Target directory (default: /usr/local/bin if writable, else ~/.local/bin)
#
# Windows: download the .exe binaries from https://github.com/VISIALIS/alter/releases

set -euo pipefail

REPO="VISIALIS/alter"
BASE_URL="https://github.com/${REPO}/releases/latest/download"

say()  { printf '\033[0;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[0;32m ✓ \033[0m%s\n' "$*"; }
fail() { printf '\033[0;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- Platform detection ------------------------------------------------------
os_name=$(uname -s)
case "$os_name" in
  Darwin) os_id="macos" ;;
  Linux)  os_id="linux" ;;
  *) fail "Unsupported OS: ${os_name}. On Windows, download the .exe binaries from https://github.com/${REPO}/releases" ;;
esac

arch_name=$(uname -m)
case "$arch_name" in
  arm64|aarch64) arch_id="arm64" ;;
  x86_64|amd64)  arch_id="x64" ;;
  *) fail "Unsupported architecture: ${arch_name}. Available builds: x64, arm64." ;;
esac

# --- Install directory -------------------------------------------------------
install_dir="${ALTER_INSTALL_DIR:-}"
if [ -z "$install_dir" ]; then
  if [ -d /usr/local/bin ] && [ -w /usr/local/bin ]; then
    install_dir="/usr/local/bin"
  else
    install_dir="${HOME}/.local/bin"
  fi
fi
mkdir -p "$install_dir"
[ -w "$install_dir" ] || fail "Cannot write to ${install_dir}. Set ALTER_INSTALL_DIR to a writable directory."

# --- Download and install ----------------------------------------------------
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for tool in alter-cli alter-mcp; do
  asset="${tool}-${os_id}-${arch_id}.tar.gz"
  say "Downloading ${asset} (latest release)..."
  curl -fsSL "${BASE_URL}/${asset}" -o "${tmp_dir}/${asset}" \
    || fail "Download failed for ${asset}. Check https://github.com/${REPO}/releases"
  tar -xzf "${tmp_dir}/${asset}" -C "$tmp_dir"
  [ -f "${tmp_dir}/${tool}" ] || fail "Archive ${asset} does not contain the expected ${tool} binary."
  install -m 0755 "${tmp_dir}/${tool}" "${install_dir}/${tool}"
  ok "${tool} installed to ${install_dir}/${tool}"
done

# --- Verify ------------------------------------------------------------------
say "Verifying..."
"${install_dir}/alter-cli" --version
"${install_dir}/alter-mcp" --version

case ":${PATH}:" in
  *":${install_dir}:"*) ;;
  *)
    printf '\n'
    say "Note: ${install_dir} is not in your PATH. Add it with:"
    printf '    export PATH="%s:$PATH"\n' "$install_dir"
    ;;
esac

printf '\n'
ok "Alter is ready. Try: alter-cli 0xdAC17F958D2ee523a2206206994597C13D831ec7"
