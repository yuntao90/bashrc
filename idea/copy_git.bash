#!/bin/bash

function copy_git()
{
  local from to
  if [[ -z "$1" ]] ; then
    echo "Parameter FROM must be set" >&2
    return 1
  fi
  if [[ ! -d "${1}/.git" ]] ; then
    echo "FROM directory '$1' does not contains .git"
  fi
  from="$1"
  if [[ -z "$2" ]] ; then
    echo "Parameter TO must be set" >&2
    return 1
  fi
  to="$2"

  mkdir -p "$to/.git"

  local link_dirs="$(ls -d "$(realpath "$from")/.git/"*/)"
  for dir in "$link_dirs" ; do
    ln -sf $dir $to/.git/.
  done
  ln -sf $(realpath $from)/.git/config $to/.git/.
  ln -sf $(realpath $from)/.git/description $to/.git/.
  ln -sf $(realpath $from)/.git/packed-refs $to/.git/.
  cp $(realpath $from)/.git/index $to/.git/.
  cp $(realpath $from)/.git/HEAD $to/.git/.
}
