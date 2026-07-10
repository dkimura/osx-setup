#!/usr/bin/env fish

set -l fisher_path $HOME/.config/fish/functions/fisher.fish
set -l fisher_url https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
set -l plugins \
  catppuccin/fish \
  decors/fish-ghq \
  oh-my-fish/plugin-peco \
  yoshiori/fish-peco_select_ghq_repository

mkdir -p (dirname $fisher_path); or exit 1

if test -f $fisher_path
  /opt/homebrew/bin/fish --no-config -n $fisher_path
  or rm -f $fisher_path
end

if not test -f $fisher_path
  set -l fisher_tmp (mktemp "$fisher_path.XXXXXX"); or exit 1

  /usr/bin/curl --fail --silent --show-error --location $fisher_url --output $fisher_tmp
  or begin
    rm -f $fisher_tmp
    exit 1
  end

  mv $fisher_tmp $fisher_path
  or begin
    rm -f $fisher_tmp
    exit 1
  end
end

source $fisher_path
or begin
  rm -f $fisher_path
  exit 1
end

functions -q fisher; or exit 1
set -l installed_plugins (fisher list)

for plugin in $plugins
  if not contains -- $plugin $installed_plugins
    fisher install $plugin; or exit 1
  end
end
