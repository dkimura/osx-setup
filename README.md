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

## スマートフォンからの接続

Moshi（iOS・Android）や別の Mac から Tailscale 経由で SSH・Mosh 接続し、ホストの Mac の herdr を操作する。Tailscale と mosh はどの Mac にも入る。

ホストにする Mac だけ、`-E server` を付けて bootstrap する。`mise.server.toml` も読み込まれ、moshi-hook が入り、`moshi-hook serve` が LaunchAgent で常駐する。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
mise bootstrap -E server
```

ホストでは、続けて次を手で行う。

1. システム設定 → 一般 → 共有 → リモートログインをオンにする。
2. システム設定 → エネルギーで、ディスプレイがオフのときに自動でスリープさせない。
3. Tailscale.app にログインする。
4. `moshi-hook set --first-run` で初期設定をする。bootstrap は対話が要るこの手順を飛ばす。
5. Moshi の Settings → Hooks でトークンを出し、ペアリングして Claude Code にフックを入れる。

```bash
moshi-hook pair --token <token>
moshi-hook install
```

`moshi-hook install` は `~/.claude/settings.json` を書き換える。ログは `~/Library/Logs/moshi-hook.log` に出る。

## 更新

リポジトリの変更を反映し、パッケージと mise を新しくする。ホストの Mac では `mise bootstrap` に `-E server` を付ける。

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
- claude・codex・herdr は、それぞれが自分で更新する。

## 構成

```text
osx-setup/
├── mise.toml             # パッケージ・macOS 設定・dotfiles・タスクの宣言
├── mise.server.toml      # -E server のときだけ読む、ホスト用の設定（moshi-hook）
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
