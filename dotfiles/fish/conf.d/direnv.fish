if status is-interactive; and test -x /opt/homebrew/bin/direnv
  /opt/homebrew/bin/direnv hook fish | source
end
