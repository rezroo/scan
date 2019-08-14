#!/bin/bash -ex

HOOK_PREFIX="_run_"
declare -A FUNC_ARGS
declare -A ENABLED_HOOKS
HOOK_ORDER=()

# Only these hooks will run in this order
function hook_order(){
  HOOK_ORDER=$@
}

function enable_hooks(){
  for hook in $@; do
    ENABLED_HOOKS["${hook}"]=1
  done;
}

# Enable hook and set its arguments
function set_hook() {
  if [ -z ${1+_} ]; then
    echo "set_hook expects at least 1 argument" >&2
    exit
  fi

  hook=$1
  enable_hooks $hook
  if [ ${2+_} ]; then
    FUNC_ARGS["${hook}"]="${@:2}"
  fi
}

function run_hooks() {
  declare -A FUNC_STACK
  for func in ${HOOK_ORDER[*]}; do
    # Precaution so we don't run a hook more than once 
    if [ ${FUNC_STACK[$func]+_} ]; then
      continue;
    fi

    # Only run hooks we want to
    if [ -z ${ENABLED_HOOKS[$func]+_} ]; then
      continue;
    fi

    $HOOK_PREFIX$func ${FUNC_ARGS[$func]}
  
    FUNC_STACK["${func}"]=1
  done;
}
