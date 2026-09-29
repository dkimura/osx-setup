# macOS setup

Apple Silicon Mac のセットアップを `mise bootstrap` で宣言する。Homebrew 本体は入れず、Formula と Cask も mise が `/opt/homebrew` へ直接入れる。

## インストール

macOS を更新し、Xcode Command Line Tools を入れる。どちらも完了を待つ。

```bash
sudo softwareupdate --install
xcode-select --install
```

mise を入れ、このリポジトリを clone して適用する。途中でパスワードを求められる。

```bash
curl https://mise.run | sh
~/.local/bin/mise bootstrap \
  --from https://github.com/dkimura/osx-setup.git \
  --from-dir ~/Document/ghq/github.com/dkimura/osx-setup \
  --force-dotfiles
```

`--force-dotfiles` は、Karabiner のインストーラが先に作る `~/.config/karabiner` を symlink で置き換えるために付ける。GitHub の SSH ホスト鍵は、`~/.ssh/known_hosts` に github.com がなければ GitHub の API から取って登録する。

完了したらログインし直し、Karabiner-Elements の権限を許可する。App Store にサインインしてから、App Store のアプリを入れる。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
mise bootstrap packages apply --manager mas
```

## リモート接続

別の端末から Tailscale 経由で、ホストの Mac に SSH 接続する。Tailscale はどの Mac にも入る。

SSH の鍵は 1Password に置き、ファイルとしては配らない。`~/.ssh/config` の管理ブロックで、どの Mac も 1Password の SSH agent を使う。各 Mac で 1Password にサインインし、設定 → 開発者で SSH agent をオンにする。サインインは自動化できないので手で行う。`mise doctor project` で、agent が動いているか確かめられる。同じ鍵で commit にも署名する（`~/.gitconfig` の管理ブロック）。公開鍵は、ホストの `~/.ssh/authorized_keys` と、GitHub の認証用・署名用の両方に登録する。

ホストにする Mac では、次を手で行う。

1. システム設定 → 一般 → 共有 → リモートログインをオンにする。
2. システム設定 → エネルギーで、ディスプレイがオフのときに自動でスリープさせない。
3. Tailscale.app にログインする。

## 更新

リポジトリの変更を反映し、パッケージと mise を新しくする。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
git pull
mise dot diff
mise bootstrap
mise bootstrap packages upgrade --dry-run
mise bootstrap packages upgrade
mise upgrade
sudo softwareupdate --install
```

- `mise dot diff` で、dotfiles の適用で消える変更がないか先に確かめる。`direnv.fish` と `.gitignore_global` はコピーで配るため、手元で足した行は `mise bootstrap` で上書きされる。残したい行は、リポジトリの `dotfiles/` に足してから適用する。
- `mise bootstrap` は、新しく宣言したパッケージを入れ、Fish プラグインを `fisher update` で更新する。App Store のアプリを入れるときはパスワードを求められる。
- `mise bootstrap packages upgrade` は、入っている Formula・Cask・App Store のアプリだけを最新にする。
- `mise upgrade` は、`dotfiles/mise/osx-setup.toml` に `github:` で書いた CLI を更新する。
- mise 本体は `auto_update` で自動で更新される。すぐ上げたいときは `mise self-update` を実行する。
- claude・codex は、それぞれが自分で更新する。Orca はアプリが自分で更新する。

## 構成

```text
osx-setup/
├── mise.toml             # パッケージ・macOS 設定・dotfiles・タスクの宣言
└── dotfiles/
    ├── allowed_signers   # ~/.config/git/allowed_signers に symlink。手元で commit の署名を検証する
    ├── fish/
    │   ├── config.fish   # ~/.config/fish/config.fish の管理ブロック
    │   ├── fish_plugins  # symlink。fisher install で書き換わる
    │   └── conf.d/direnv.fish
    ├── karabiner/        # ~/.config/karabiner ごと symlink
    ├── mise/osx-setup.toml # mise の自動更新と、Homebrew 本家にない CLI（github: で入れる）
    ├── gitconfig         # ~/.gitconfig の管理ブロック
    ├── gitignore_global
    └── ssh/config        # ~/.ssh/config の管理ブロック。1Password の SSH agent を使う
```

symlink のリンク先はこのリポジトリなので、clone 先は動かさない。
