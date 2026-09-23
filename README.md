# macOS setup

Apple Silicon Mac のセットアップを `mise bootstrap` で管理する。宣言はすべて `mise.toml` にある。Homebrew 本体は使わない。Formula・Cask は mise が `/opt/homebrew` へ直接入れる。

## 新しい Mac

先に macOS を更新し、Xcode Command Line Tools を入れる。どちらも完了を待つ。

```bash
sudo softwareupdate --install --recommended
xcode-select --install
```

`mise` を入れ、このリポジトリを clone して適用する。

```bash
curl https://mise.run | sh
~/.local/bin/mise bootstrap \
  --from https://github.com/dkimura/osx-setup.git \
  --from-dir ~/Document/ghq/github.com/dkimura/osx-setup
```

`--dry-run` は付けない。サードパーティ tap の Formula を評価するには Ruby 3 が必要で、dry-run はそこで失敗する。適用時は mise が Ruby を用意する。

`/opt/homebrew` の作成、pkg インストーラ、ログインシェルの変更で mise がパスワードを求める。完了後にログインし直し、確認する。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
mise doctor project
mise bootstrap status
```

残りは手作業で行う。

- Karabiner-Elements を起動し、求められた権限を許可する。
- App Store にサインインし、App Store のアプリを入れる。

  ```bash
  mise bootstrap packages apply --manager mas
  ```

clone 先は動かさない。Karabiner の設定と `fish_plugins` はこのリポジトリへの symlink になっている。

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
- dry-run で `install cask` と表示された Cask は、mise が入れ直す。Homebrew が管理している Cask は mise の更新対象外なので、`brew upgrade --cask` で更新する。
- 実ファイルがある場所への symlink は上書きしない。中身を退避してから `mise dot apply <target> --force` で対象を絞って適用する。
- Dock や Finder の defaults 変更は `killall Dock` / `killall Finder` か再ログインまで反映されない。
- mise を brew で入れている場合は、`curl https://mise.run | sh` で入れ直してから `brew uninstall mise` する。

## 更新

Formula・Cask・App Store のアプリと、mise 本体・mise 管理ツールを更新する。

```bash
mise bootstrap packages upgrade --yes
mise self-update
mise upgrade
```

設定を変えたらリポジトリへ commit する。

- Fish プラグイン: `fisher install <plugin>` が `dotfiles/fish/fish_plugins` を書き換える。
- Karabiner: GUI での変更が `dotfiles/karabiner/karabiner.json` に入る。

宣言外の Formula は `mise bootstrap packages prune`、mise が入れた Cask は `mise bootstrap packages prune --manager brew-cask` で削除する（実行前に `--dry-run`）。pkg で入る Cask など、削除対象にならないものもある。
