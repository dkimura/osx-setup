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

`--force-dotfiles` は、Karabiner のインストーラが先に作る `~/.config/karabiner` を symlink で置き換えるために付ける。

完了したらログインし直し、Karabiner-Elements の権限を許可する。App Store にサインインしてから、App Store のアプリを入れる。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
mise bootstrap packages apply --manager mas
```

## 構成

```text
osx-setup/
├── mise.toml             # パッケージ・macOS 設定・dotfiles・タスクの宣言
└── dotfiles/
    ├── fish/
    │   ├── config.fish   # ~/.config/fish/config.fish の管理ブロック
    │   ├── fish_plugins  # symlink。fisher install で書き換わる
    │   └── conf.d/direnv.fish
    ├── ghostty/config    # ~/.config/ghostty/config に symlink
    ├── karabiner/        # ~/.config/karabiner ごと symlink
    ├── mise/osx-setup.toml # mise の自動更新と、Homebrew 本家にない CLI（github: で入れる）
    ├── gitconfig         # ~/.gitconfig の管理ブロック
    └── gitignore_global
```

symlink のリンク先はこのリポジトリなので、clone 先は動かさない。
