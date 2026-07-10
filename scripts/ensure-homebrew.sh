#!/usr/bin/env bash
set -euo pipefail

if [[ -x /opt/homebrew/bin/brew ]]; then
  exit 0
fi

export NONINTERACTIVE=1
/bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "Homebrew installation did not create /opt/homebrew/bin/brew" >&2
  exit 1
fi
