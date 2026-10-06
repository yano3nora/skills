---
name: gsheet
description: Google Sheets (spreadsheet) のセルを読み書きする。「この spreadsheet を読んで / 更新して / 行を足して」と言われたら、Google Drive connector ではなく gsheet コマンドを Bash で使う。
---

# gsheet

Google Drive connector は閲覧専用で、セル更新ができない。`gsheet` はサービスアカウントの鍵 JSON で Sheets REST API を直接叩く CLI。

## 認証

- 認証はサービスアカウントの鍵 JSON だけ。置き場は `~/.config/gsheet/key.json`
- 鍵が無いと `gsheet` が「鍵 JSON が無い」と出て止まる。作業を止め、ユーザに鍵 JSON をその場所に置いてもらう
    - gcloud のインストールやログインは提案しない。鍵 JSON を探し回らない、作らない、書かない。配置はユーザの作業
- 「GOOGLE_APPLICATION_CREDENTIALS が指す鍵 JSON を読めない」と出たら、環境変数が優先されている。既定パスに置いても直らない。ユーザに変数のパスを直すか外してもらう
    - この環境変数は別の鍵を一時的に使う上書き用。ユーザが指示したときだけ使う
    - 鍵の作り方と設定先は、この skill と同じ場所にある `README.md`。ユーザに案内する
- 403 は「スプシが鍵の client_email に共有されていない」が最有力。鍵 JSON の `client_email` を読んでユーザに伝え、編集者で共有を依頼する

## 使い方

`gsheet --help` を読んでから使う。出力は Sheets API の JSON そのまま。jq で整形する。

```bash
gsheet meta   <url|id>                       # sheet 名と行列数
gsheet get    <url|id> 'Sheet1!A1:C10'       # 値を取得
gsheet set    <url|id> 'Sheet1!B5' '[["Completed"]]'
gsheet append <url|id> 'Sheet1!A:C' '[["a","b","c"]]'
gsheet api    POST spreadsheets/<id>:batchUpdate '{"requests":[...]}'
```

## 手順

1. 書き込み前に `meta` と `get` で対象の sheet 名と range を確認する
2. 数式は `=SUM(A1:A3)` の文字列で渡す。`USER_ENTERED` で評価される
3. 初回や大きな変更は、ユーザにコピーした spreadsheet で試すことを提案する

## 注意

- Claude Code では `gsheet …` を単一コマンドとして Bash tool で呼ぶ。`cd` / パイプ / `&&` / リダイレクトで包まない
    - 理由: sandbox は `googleapis.com` への通信を拒否する。settings.json の `excludedCommands: ["gsheet *"]` はコマンド文字列全体が `gsheet …` のときだけ一致する
    - 出力の JSON はそのまま読む。jq で整形しない
    - `set` / `append` / `api` の JSON は 3 つ目の引数で渡す。`<<<` や `<` の stdin は使わない。理由: ヒアストリングも除外の一致から外れる
    - `dangerouslyDisableSandbox` は使わない。auto mode の classifier に止められる
- Windows の Codex は PowerShell で `gsheet.cmd` を呼ぶ。次の 3 つを守る
    - JSON はファイルに UTF-8 で書き、`'@<file>'` で渡す。例: `gsheet set <id> 'phases!A2' '@C:\Users\<name>\<project>\tmp\phases.json'`
        - 理由: 引数の JSON は PowerShell → cmd → bash で引用符が壊れる。先頭の `@` は PowerShell の splatting なので引用符で囲む
    - `<sheet>` は URL ではなく ID を渡す。引数に `&` を入れない。理由: cmd が `&` をコマンド区切りと解釈する
    - 日本語をコマンド引数に入れない。range の sheet 名だけは可
- 通信は 60 秒で打ち切り、`curl: (28)` で終了する。理由: ネットワークの一時遅延で数分返らないことがある
    - 自動 retry はしない。理由: `append` と `api` の POST は再実行で行が重複する
    - 打ち切り後に再実行するときは、先に `get` か `meta` で結果を確認する。打ち切り後もサーバ側で処理が続くことがある
    - 結果を確認できない `append` / `api` は再実行しない。ユーザに判断を委ねる
    - Bash tool の timeout は 150 秒以上にする。理由: token 取得と API 通信で各 60 秒かかる
- `set` は values の形だけ書く。range より小さい values を送っても、残りのセルは消えない
- 消すときは `""` を送る。`null` は既存値を保持する
- range を単一セルで渡すと、そこを左上として values の形に書く。`A1` に `[["a","b"]]` を送ると B1 も更新される
- ファイル名からの検索は Drive connector に任せる。`gsheet` は URL か ID だけを受ける
