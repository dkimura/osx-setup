fish_add_path --path --move --prepend /opt/homebrew/bin /opt/homebrew/sbin

if status is-interactive
  if not functions -q __starship_set_job_count
    starship init fish | source
  end

  function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
    bind \c] 'peco_select_ghq_repository'
  end

  alias g='cd (ghq root)/(ghq list | peco)'
  abbr -a or 'command or'

  if functions -q __agmsg_codex_path_prepend
    functions --erase __agmsg_codex_path_prepend
  end

  if test -d $HOME/.agents/bin
    fish_add_path --path --move --prepend $HOME/.agents/bin
  end

  if test -d $HOME/go/bin
    fish_add_path --path --move --append $HOME/go/bin
  end
end
