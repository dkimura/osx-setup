# macOS setup

## インストール

macOSを更新し、Xcode Command Line Toolsを入れる。どちらも完了するまで待つ。

```bash
sudo softwareupdate --install
xcode-select --install
```

システム設定 → プライバシーとセキュリティ → フルディスクアクセスで、使うターミナルをオンにし、⌘Qで終了して開き直す。フルディスクアクセスがないと、「視差効果を減らす」（`com.apple.universalaccess`）を書き込めずにbootstrapが止まる。

miseを入れ、このリポジトリをcloneして適用する。途中でパスワードを求められる。

```bash
curl https://mise.run | sh
~/.local/bin/mise bootstrap \
  --from https://github.com/dkimura/osx-setup.git \
  --from-dir ~/Document/ghq/github.com/dkimura/osx-setup \
  --force-dotfiles
```

Karabinerのインストーラは、dotfilesより先に`~/.config/karabiner`を作る。`--force-dotfiles`は、これをsymlinkで置き換えるために付ける。

適用が終わったら、ログインし直してから次の順に進める。

1. Karabiner-Elementsの権限を許可する。
2. 1Passwordにサインインし、設定 → 開発者（Settings → Developer）でSSH agentをオンにする。commitには1Passwordの鍵で署名するので、ここを済ませるまでcommitは失敗する。
3. App Storeにサインインする。
4. 次のコマンドで、agentが動いているかを確かめ、App Storeのアプリを入れる。

```bash
cd ~/Document/ghq/github.com/dkimura/osx-setup
mise doctor project
mise bootstrap packages apply --manager mas
```

SSHとcommitの署名には、どのMacも1Passwordにある同じ鍵を使う。公開鍵は`dotfiles/allowed_signers`の1行目と同じで、GitHubの認証用と署名用、ホストの`~/.ssh/authorized_keys`に一度登録すれば足りる。ホストのMacだけは、GitHubへのSSHとcommitの署名に専用の鍵を使う（[リモート接続](#リモート接続)）。

## リモート接続

別の端末からTailscale経由で、ホストのMacにSSH接続する。TailscaleはこのリポジトリでどのMacにも入る。

ホストにするMacでは、さらに次のとおり設定する。

1. システム設定 → 一般 → 共有で、リモートログインをオンにする。
2. システム設定 → エネルギーで、「ディスプレイがオフのときに自動でスリープさせない」をオンにする。
3. Tailscale.appにログインする。
4. commitの署名用に、1Passwordの外に専用の鍵を作ってGitHubに登録する。

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519_signing -C 'git signing (Mac mini)'
gh ssh-key add ~/.ssh/id_ed25519_signing.pub --type signing --title 'Mac mini signing'
printf '[user]\n\tsigningkey = ~/.ssh/id_ed25519_signing\n[gpg "ssh"]\n\tprogram = ssh-keygen\n' > ~/.gitconfig.local
```

`gh`のトークンに`admin:ssh_signing_key`がなければ、先に`gh auth refresh -h github.com -s admin:ssh_signing_key`を実行する。公開鍵は`dotfiles/allowed_signers`にも足す。

1Passwordの鍵で署名すると、commitのたびにホストの画面で承認が要る。1PasswordはMacの画面ロックに合わせてロックし、ロックすると承認も消えるので、リモートからは署名できない。`~/.gitconfig`の管理ブロックは最後に`~/.gitconfig.local`を読み込み、ホストではここで署名の鍵と`ssh-keygen`を指定する。ほかのMacにはこのファイルを置かない。

5. GitHubへのSSH用に、1Passwordの外に専用の鍵を作ってGitHubに登録する。

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519 -C 'github (Mac mini)'
gh ssh-key add ~/.ssh/id_ed25519.pub --title 'Mac mini'
```

`gh`のトークンに`admin:public_key`がなければ、先に`gh auth refresh -h github.com -s admin:public_key`を実行する。続けて、`~/.ssh/config`の管理ブロックより前に次を書く。

```
Host github.com
    IdentityAgent none
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

理由は署名と同じで、画面がロックされていると1Passwordの鍵ではSSHの認証も通らない。この設定がないと、sshは1Passwordの承認を1分近く待って`agent refused operation`を出し、そのあと`~/.ssh/id_ed25519`に切り替える。sshは先に書いた設定を優先するので、管理ブロックの`Host *`より前に置く。ほかのホストへのSSHは、これまでどおり1PasswordのSSH agentを使う。

## Docker

DockerはColimaのVMで動く。`colima`・`docker`・`docker-compose`・`docker-buildx`はFormulaで入る。

Colimaはログイン時にLaunchAgentから起動する。VMにはCPUを6個、メモリを12GiB割り当てる。bootstrapはplistを置くだけなので、Colimaが起動するのは次のログインからになる。起動の記録は`~/.colima/launchd.log`に残る。

【未確認】新しいMacの初回起動では、VMのイメージのダウンロードに時間がかかる想定だ。

## 更新

リポジトリの変更を反映し、パッケージ、ツール、macOSを更新する。

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

- `mise dot diff`で、dotfilesを適用すると消える変更がないかを先に確かめる。`direnv.fish`・`.gitignore_global`・ColimaのLaunchAgentはコピーで配るので、手元で足した行は`mise bootstrap`で上書きされる。残したい行は、リポジトリの`dotfiles/`に足してから適用する。
- 手元の実ファイルをsymlinkに置き換える適用は拒否される。そのファイルを退避してから、`mise dot apply <target> --force`で置き換える。
- `mise bootstrap`は、新しく宣言したパッケージを入れ、Fishプラグインを`fisher update`で更新する。取得に失敗したプラグインがあると、`fish_plugins`を元に戻して止まる。App Storeのアプリを入れるときは、パスワードを求められる。
- `mise bootstrap packages upgrade`は、入っているFormula・Cask・App Storeのアプリを最新にする。
- 宣言から外したFormulaは、`mise bootstrap packages prune`で消す。消したあとに残る空のディレクトリは、`mise run cleanup`で片付ける。
- `mise upgrade`は、`dotfiles/mise/config.toml`のツールを更新する。nodeは最新のLTSを追う。
- mise本体は`auto_update`で自動で更新される。すぐ上げたいときは`mise self-update`を実行する。
- claude・codex・Orcaは、それぞれ自分で更新する。

## 構成

```text
osx-setup/
├── mise.toml             # パッケージ・macOS設定・dotfiles・タスクの宣言
└── dotfiles/
    ├── allowed_signers   # ~/.config/git/allowed_signersにsymlink。手元でcommitの署名を検証する
    ├── fish/
    │   ├── config.fish   # ~/.config/fish/config.fishの管理ブロック
    │   ├── fish_plugins  # symlink。fisher installで書き換わる
    │   └── conf.d/direnv.fish # コピー
    ├── gitconfig         # ~/.gitconfigの管理ブロック。最後に~/.gitconfig.localを読み込む
    ├── gitignore_global  # ~/.gitignore_globalにコピー
    ├── karabiner/        # ~/.config/karabinerにディレクトリごとsymlink
    ├── launchd/          # ~/Library/LaunchAgentsにコピー。ログイン時にColimaを起動する
    ├── mise/config.toml  # ~/.config/mise/config.tomlにsymlink。miseの自動更新、ランタイム、Homebrew本家にないCLI
    └── ssh/config        # ~/.ssh/configの管理ブロック。1PasswordのSSH agentを使う
```

symlinkのリンク先はこのリポジトリにある。clone先を動かすとリンクが切れるので、動かさない。
