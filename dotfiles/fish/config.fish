fish_add_path --path --move --prepend $HOME/.local/bin /opt/homebrew/bin /opt/homebrew/sbin

if status is-interactive
  if not functions -q __starship_set_job_count
    starship init fish | source
  end

  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
    bind \c] 'peco_select_ghq_repository'
  end

  alias g='cd (ghq root)/(ghq list | peco)'

  if test -d $HOME/.agents/bin
    fish_add_path --path --move --prepend $HOME/.agents/bin
  end

  if test -d $HOME/go/bin
    fish_add_path --path --move --append $HOME/go/bin
  end
end
