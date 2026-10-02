---
name: chrome-connect
description: chrome-devtools CLI をユーザが普段使っている Chrome 本体 (実タブ・ログイン状態・localStorage 込み) へ接続する。「chrome-devtools で確認して」「ブラウザで見て」「用意したタブで検証して」と言われたら、daemon が別ブラウザを立ち上げる前にまずこれを使う。CLI が未導入でも mise 経由で起動する。
---

# chrome-connect

chrome-devtools の daemon は既定で自前の空ブラウザを起動する。ユーザが用意したタブやログイン状態は見えない。`--autoConnect` でユーザの Chrome 本体へ接続する。

## 接続手順

```sh
chrome-devtools start --autoConnect
chrome-devtools list_pages
```

- 2 行に分けて実行する。理由: PowerShell 5.1 は `&&` を解釈しない
- 初回の `start` で Chrome が接続許可のダイアログを出す。ユーザに許可してもらう。許可待ちを接続失敗と誤認しない
- `list_pages` にユーザの実タブが並べば成功。目的のタブを `select_page <n>` して操作する
- 失敗したら「前提」を上から確認し、足りないものをユーザに依頼する
- この接続はユーザの全タブを操作できる。検証が終わったら `chrome-devtools stop` する

## 前提

1. Chrome 144 以上が起動していて、remote debugging が ON であること
    - ユーザに `chrome://inspect/#remote-debugging` を開いて有効化してもらう。「Server running at: 127.0.0.1:9222」の表示が目印
    - OFF のまま start すると `Could not connect to Chrome` で失敗する
2. `chrome-devtools --version` が 1.9.0 以上であること
    - 無い、または古い環境では mise 経由で起動する。初回は mise が自動 install する。理由: 1.7.0 では `start --autoConnect` で daemon が落ちた

        ```sh
        mise exec node@24 npm:chrome-devtools-mcp@latest -- chrome-devtools start --autoConnect
        ```

    - 以後の `list_pages` などもこの形で呼ぶ
    - Node は固定で渡す。理由: PATH の node に委ねると、古い Node を使う project で起動できない
    - mise も無い環境では https://mise.jdx.dev/ の導入をユーザに案内する

## 注意

- `curl http://127.0.0.1:9222/json/version` は 404 になる。疎通確認に使わない。理由: 新方式のサーバは HTTP discovery を提供しない
- 同じユーザの daemon は 1 つだけ。`start` は既存の daemon を置き換える
