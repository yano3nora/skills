# agent-skills

Claude Code と Codex で共用する [Agent Skills](https://agentskills.io) 置き場。
macOS と Windows (git bash) の両方で使う。

## Skills

| skill | 内容 | 依存 |
|---|---|---|
| `gsheet` | Google Sheets のセルを読み書きする CLI と、その使い方 | `curl`, `jq`, `openssl`, サービスアカウントの鍵 JSON |
| `show-me` | 図や擬似コードで今の話題を視覚化する | なし |
| `why-me` | 変更案を価値・必要性・実装の順に問い詰める | なし |

## Getting Started

前提: git、mise 経由の `jq`。Windows は git bash で流す。

```sh
git clone https://github.com/yano3nora/agent-skills.git ~/git/yano3nora/agent-skills
cd ~/git/yano3nora/agent-skills
./install.sh            # 全部入れる。./install.sh gsheet のように絞れる
```

`install.sh` がやること:

- `skills/<name>/` を `~/.claude/skills/<name>` と `~/.codex/skills/<name>` へコピーする
- `skills/<name>/scripts/*` を `~/.local/bin/` へコピーする
- 既存ファイルは `.bak.YYYYMMDDHHMMSS` に退避する。中身が同じなら触らない

入れた後は Claude Code / Codex を再起動する。skill ごとの追加設定は各 `skills/<name>/README.md` を読む。

- `gsheet`: 鍵 JSON の配置、Windows の PATH、macOS の sandbox 設定が要る。[skills/gsheet/README.md](skills/gsheet/README.md)

## Update

```sh
cd ~/git/yano3nora/agent-skills
git pull
./install.sh
```

## Layout

```
.
├── install.sh
└── skills/
    └── <name>/
        ├── SKILL.md        # Agent が読む
        ├── README.md       # 人間が読む (必要な skill だけ)
        └── scripts/        # ~/.local/bin に入るコマンド (必要な skill だけ)
```

- `SKILL.md` は Agent 向け、`README.md` は人間向け。混ぜない
- `scripts/` のコマンドは bash 3.2 で書く。理由: macOS の `/bin/bash` と git bash の両方で動かす
- PowerShell から呼ぶコマンドには `<name>.cmd` の入口を添える。理由: Windows の Codex は PowerShell でコマンドを実行する
- 社内の文脈 (特定の spreadsheet の運用ルールなど) はこの repo に書かない。社内 repo に別の skill として置き、この repo を参照する
