# gsheet

Google Sheets のセルをサービスアカウントの鍵 JSON で読み書きする CLI。
Sheets REST API を `curl` で直接叩く。gcloud は実行時には要らない。
Agent 向けの使い方は `SKILL.md`。このファイルは人間向けのセットアップ手順。

## 利用者向け: セットアップ

前提: repo の `install.sh` を流し済み。`jq` が mise で入っている。

1. 管理者から鍵 JSON を受け取り、`~/.config/gsheet/key.json` に置く
    - Windows は `%USERPROFILE%\.config\gsheet\key.json`。git bash の `~` は `%USERPROFILE%` に解決される
    - 鍵は秘密鍵。チャットやメールで転送しない。受け取ったら元の共有先から消す
2. Windows だけ: `%USERPROFILE%\.local\bin` をユーザー環境変数 PATH に足す。PowerShell で次を流し、git bash と PowerShell を開き直す

    ```powershell
    [Environment]::SetEnvironmentVariable('Path', "$env:USERPROFILE\.local\bin;" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')
    ```

3. macOS の Claude Code で sandbox を使っている場合だけ: `~/.claude/settings.json` に除外を足す。理由: sandbox は `googleapis.com` への通信を拒否する

    ```json
    {
      "sandbox": {
        "excludedCommands": ["gsheet *"]
      }
    }
    ```

4. 動作確認。管理者が共有した spreadsheet で試す

    ```sh
    gsheet meta https://docs.google.com/spreadsheets/d/<id>/edit
    ```

    Windows は PowerShell からも確認する。Codex はこの経路で呼ぶ

    ```powershell
    gsheet meta <id>
    ```

## 利用者向け: 使い方

```sh
gsheet --help
gsheet meta   <url|id>                       # sheet 名と行列数
gsheet get    <url|id> 'Sheet1!A1:C10'       # 値を取得
gsheet set    <url|id> 'Sheet1!B5' '[["Completed"]]'
gsheet append <url|id> 'Sheet1!A:C' '[["a","b","c"]]'
```

- 触れるのは、鍵の `client_email` に共有された spreadsheet だけ。新しい spreadsheet を使うときは、そのアドレスを「編集者」で共有する

    ```sh
    jq -r .client_email ~/.config/gsheet/key.json
    ```

- 403 が出たら共有漏れが最有力
- 誰が書いたかは区別できない。全員が同じサービスアカウントとして書く
- 別の鍵を一時的に使うときだけ `GOOGLE_APPLICATION_CREDENTIALS` でパスを上書きする。shell 全体に立てない。理由: 他の Google SDK もこの変数を読む

## 管理者向け: 鍵を作る

鍵は 1 人 1 鍵にする。理由: 1 人の漏洩で全員分の権限が漏れない。退職や端末紛失時にその人の鍵だけ消せる。
Sheets API は無料で、請求先アカウントも要らない。gcloud は鍵を作る端末にだけ入れる。

```sh
brew install --cask gcloud-cli                                 # macOS
gcloud auth login
gcloud projects create <project-id>                            # 無ければ作る。Sheets 専用にしておく
gcloud services enable sheets.googleapis.com --project <project-id>
```

利用者ごとに:

```sh
gcloud iam service-accounts create gsheet-<user> --project <project-id>
gcloud iam service-accounts keys create gsheet-<user>.json \
  --iam-account=gsheet-<user>@<project-id>.iam.gserviceaccount.com
```

- 作った JSON を本人に渡す。渡し終えたら手元のファイルは消す
- 対象の spreadsheet を各サービスアカウントの `client_email` に「編集者」で共有する。Google グループにまとめて共有すると管理が楽
- 失効は `gcloud iam service-accounts keys delete` か、サービスアカウントごと削除する
- scope は `spreadsheets` だけ。Drive 全体には効かない
- 割り当て先 project の header は送らない。理由: 割り当て先は鍵の project に決まる。IAM の追加は要らない

## 設計メモ

- 実行時の依存は `curl`, `jq`, `openssl` だけ。理由: Windows でも SDK 無しで動かす
- `scripts/gsheet` は bash 3.2 で書く。理由: macOS の `/bin/bash` と git bash の両方で動かす
- `scripts/gsheet.cmd` は PowerShell / cmd からの入口。Windows の Codex は PowerShell でコマンドを実行する
    - `CHERE_INVOKING=1` を立てる。理由: login shell は HOME へ cd するので、相対の `@file` が読めなくなる
- values / body は `@<file>` でも渡せる。理由: PowerShell → cmd → bash の経路で JSON 引数の引用符が壊れる
- 秘密鍵は 600 の一時ファイルで openssl に渡し、JWT は stdin で curl に渡す。理由: git bash の openssl はプロセス置換を読めない。プロセス引数は他のプロセスから見える
- access token は cache しない。1 時間で切れる
- ファイル名からの検索はやらない。claude.ai の Google Drive connector に任せる
