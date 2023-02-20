#!/bin/bash

function trans-remember()
{
  local DEFAULT_REMEMBER_CSV='~/.local/etc/remember_word_list.csv'
  if [ -z "$1" ] ; then
    cat $DEFAULT_REMEMBER_CSV
    return 0
  fi

  if [ ! -w $DEFAULT_REMEMBER_CSV ] ; then
    echo "WORD, TRANS" > $DEFAULT_REMEMBER_CSV
  fi

  local trans_result="$(trans $1)"
  echo "\"$1\", \"$trans_result\"" >> $DEFAULT_REMEMBER_CSV
  echo "$trans_result"
}

trans-remember $@
