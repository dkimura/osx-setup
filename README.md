# macOS setup

Apple Silicon Mac のセットアップを `mise bootstrap` で管理する。宣言はすべて `mise.toml` にある。

## 新しい Mac

先に macOS を更新し、Xcode Command Line Tools を入れる。

```bash
sudo softwareupdate --install --recommended
xcode-select --install
```

`mise` をインストールして、このリポジトリを clone する。

```bash
curl https://mise.run | sh
git clone https://github.com/dkimura/osx-setup.git
cd osx-setup
```

変更内容を確認してから適用する。

```bash
~/.local/bin/mise trust
~/.local/bin/mise bootstrap --dry-run
~/.local/bin/mise bootstrap --yes
```

初回実行では Homebrew のインストールとログインシェルの変更でパスワードを求める場合がある。完了後にログインし直す。

## 既存の Mac

`status` はファイルや macOS 設定を書き換えない。

```bash
mise trust
mise bootstrap status
mise bootstrap --dry-run
```

差分を確認したら適用する。

```bash
mise bootstrap --yes
```

注意点:

- `config.fish` と `.gitconfig` は marker で囲んだブロックだけを更新する。ブロック外のローカル設定と秘密値はそのまま残る。秘密値はこのリポジトリへ追加しない。
- brew で入れた既存の Cask は初回適用時に mise が再インストールする。以後は `brew upgrade --cask` ではなく mise で更新する。
- Dock や Finder の defaults 変更は `killall Dock` / `killall Finder` か再ログインまで反映されない。

## 更新

Formula・Cask と `mise` 管理ツールを更新する。

```bash
mise bootstrap packages upgrade --yes
mise upgrade
```

brew で直接入れた Formula を宣言へ取り込む。

```bash
mise bootstrap packages import --manager brew
git diff -- mise.toml
```

宣言外の Formula は `mise bootstrap packages prune --manager brew` で削除する（実行前に `--dry-run`）。Cask の prune は未対応のため、`brew list --cask` を `mise.toml` と見比べて `brew uninstall --cask <name>` で手動削除する。
