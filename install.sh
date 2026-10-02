#!/usr/bin/env bash
# install.sh - skills/* を Claude Code と Codex の skills ディレクトリへコピーする。
# skills/*/scripts/ 配下のコマンドは ~/.local/bin へコピーする。
# symlink は使わない。理由: Windows の symlink は開発者モードか管理者権限が要る。
# 既存ファイルは .bak.YYYYMMDDHHMMSS に退避する。中身が同じなら触らない。
# bash 3.2 で書く。理由: macOS の /bin/bash と Windows の git bash の両方で動かす。
#
# Usage:
#   ./install.sh            # 全部入れる
#   ./install.sh gsheet     # 名前で絞る
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
SKILL_DIRS=("$HOME/.claude/skills" "$HOME/.codex/skills")

info() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

place_path() {
  local src="$1"
  local dest="$2"
  local backup

  mkdir -p "$(dirname "$dest")"

  if [[ -d "$src" && -d "$dest" ]] && diff -rq "$src" "$dest" >/dev/null 2>&1; then
    info "unchanged: $dest"
    return 0
  fi
  if [[ -f "$src" && -f "$dest" ]] && cmp -s "$src" "$dest"; then
    info "unchanged: $dest"
    return 0
  fi

  # symlink も退避する。理由: dotfiles で symlink 運用している環境で、実体を消さずに切り替える。
  if [[ -e "$dest" || -L "$dest" ]]; then
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    info "backup: $dest -> $backup"
    mv "$dest" "$backup"
  fi

  cp -R "$src" "$dest"
  info "installed: $dest"
}

install_skill() {
  local name="$1"
  local src="$ROOT/skills/$name"
  local dir script

  [[ -f "$src/SKILL.md" ]] || die "skill not found: $name"

  for dir in "${SKILL_DIRS[@]}"; do
    place_path "$src" "$dir/$name"
  done

  # scripts/ は skill 本体にも残す。理由: SKILL.md から相対で読めるようにしておく。
  for script in "$src"/scripts/*; do
    [[ -f "$script" ]] || continue
    place_path "$script" "$BIN_DIR/$(basename "$script")"
    # .cmd は PowerShell 用の入口なので実行ビットは要らない。
    case "$script" in *.cmd) ;; *) chmod +x "$BIN_DIR/$(basename "$script")" ;; esac
  done
}

names=("$@")
if [[ ${#names[@]} -eq 0 ]]; then
  for dir in "$ROOT"/skills/*/; do
    names+=("$(basename "$dir")")
  done
fi

info "root: $ROOT"
for name in "${names[@]}"; do
  install_skill "$name"
done
info "done. restart Claude Code / Codex to pick up new skills."
