# AGENTS.md

Apple Silicon Mac 1台分の設定を `mise bootstrap` で宣言するリポジトリ。宣言は `mise.toml` に集約し、手順は README.md に書く。

## 前提

- mise は 2026.9.12 以上が必要（`min_version`）。PATH 上に別の mise があり得るので、作業前に `command -v mise` と `mise --version` を確認する。
- Homebrew 本体は使わない。`brew:` / `brew-cask:` は mise が `/opt/homebrew` へ直接入れる。`brew` コマンドや Homebrew のインストールを前提にした hook・スクリプト、`brew:mise` を足さない。
- 公開リポジトリなので、秘密値・トークン・個人のローカル設定を入れない。`config.fish` と `.gitconfig` は marker ブロックだけを管理し、ブロック外はマシンごとの領域として触らない。
- `mise.toml` に `[tools]` は書かない。リポジトリの `[tools]` はリポジトリ配下でしか有効にならず、マシン全体には適用されない。全体で使う CLI は `[bootstrap.packages]` に書き、Homebrew 本家にないものは `dotfiles/mise/osx-setup.toml` の `[tools]` に `github:` で書く。
- `auto_update` のような global_only の設定は、`mise.toml` の `[settings]` に書いても無視される。`dotfiles/mise/osx-setup.toml` に書き、`~/.config/mise/conf.d/` へリンクする。

## 構成

- `mise.toml`: パッケージ、macOS defaults、Dock、ログインシェル、dotfiles、bootstrap タスク、`doctor.checks`。
- `dotfiles/`: `[dotfiles]` の source。Karabiner はディレクトリごと、`fish_plugins` はファイルを symlink で管理する。GUI や `fisher install` の変更がそのままリポジトリの差分になる。Karabiner の `automatic_backups/`・`assets/` は `.gitignore` で除外している。

## 検証

変更後に実行する。どれも書き換えを伴わない。

```bash
mise bootstrap status
mise bootstrap --dry-run
mise doctor project
git diff --check
```

- `mise run bootstrap` と `mise bootstrap`（`--dry-run` なし）は検証ではない。Fish プラグインや dotfiles、macOS 設定を書き換える。頼まれていなければ実行しない。
- このマシンでの dry-run 成功は、新しい Mac での成功を意味しない。導入済みの Formula は定義の評価が省かれ、`status` も `installed` と表示する。新しい Mac での導入を確かめていない範囲は、報告で明記する。

## パッケージを足すとき

- サードパーティ tap は使わない。tap の Formula は mise がソースからビルドし、Ruby 3 やビルド用ツールが要る。新しい Mac では mo・ax の導入が失敗した。GitHub Releases にビルド済みバイナリがあれば、`dotfiles/mise/osx-setup.toml` に `github:owner/repo` で書く。
- tap の Cask も、mise の DSL が対応していない記述があると失敗する。github-nippou は `generate_completions_from_executable` が原因で外した。
- `[bootstrap.packages]` は種類ごとにアルファベット順を保つ。

## dotfiles を変えるとき

- `mise dot apply` と `mise bootstrap` は、対象を指定しないと宣言された dotfiles をすべて適用する。marker ブロックの外は残り、実ファイルを symlink に置き換える操作は拒否される。このマシンに適用するときは、`mise dot apply <target> --dry-run` で確かめてから対象を絞る。`--force` を使う前に既存ファイルを退避する。
- `mise dot add --source <相対パス>` は相対パスの symlink を作り、リンクが壊れる。追加後は `readlink <target>` と `test -e <target>` でリンク先が存在するか確かめ、壊れていれば `mise dot apply <target>` で作り直す。
- symlink の source を移動・改名すると、既存マシンのリンクが切れる。
- パッケージは dotfiles より先に入る。Karabiner のインストーラが `~/.config/karabiner` を先に作るため、新しい Mac では `--force-dotfiles` を付けて bootstrap する。
- `fisher update` は、取得に失敗したプラグインを `fish_plugins` から消す。bootstrap タスクはこれに備えて実行前の一覧を控え、変わっていたら元に戻して失敗させる。この処理は消さない。変えたときは、成功時に一覧が変わらないことと、失敗時に元に戻ることを確かめる。

## 文書とコミット

- README は日本語。手順を変えたら README も直す。
- コミットメッセージは英語（Conventional Commits）。
