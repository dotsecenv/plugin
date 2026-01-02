#!/usr/bin/env zsh
# dotsecenv shell plugin for zsh
# Automatically loads .env and .secenv files when entering directories
#
# Installation:
#   Source this file in your .zshrc:
#     source /path/to/dotsecenv.plugin.zsh
#
#   Or use a plugin manager (see README.md)

# Guard against multiple loading
[[ -n "$_DOTSECENV_ZSH_LOADED" ]] && return
_DOTSECENV_ZSH_LOADED=1

# Determine plugin directory
_DOTSECENV_PLUGIN_DIR="${0:A:h}"

# Source the shared core logic
if [[ -f "$_DOTSECENV_PLUGIN_DIR/_dotsecenv_core.sh" ]]; then
    source "$_DOTSECENV_PLUGIN_DIR/_dotsecenv_core.sh"
else
    echo "dotsecenv: error: _dotsecenv_core.sh not found" >&2
    return 1
fi

# Track the previous directory for change detection
typeset -g _DOTSECENV_PREV_PWD=""

# Hook function to process directory change (allows cd . to reload .secenv files)
_dotsecenv_chdir_hook() {
    local old_dir="$_DOTSECENV_PREV_PWD"
    _DOTSECENV_PREV_PWD="$PWD"
    _dotsecenv_on_cd "$old_dir" "$PWD"
}

# Wrap cd to trigger directory change processing
# (zsh's chpwd hook doesn't fire for cd . since directory doesn't technically change)
cd() {
    local __dotsecenv_errfile __dotsecenv_err __dotsecenv_ret
    __dotsecenv_errfile=$(mktemp)
    builtin cd "$@" 2>"$__dotsecenv_errfile"
    __dotsecenv_ret=$?
    if ((__dotsecenv_ret != 0)); then
        __dotsecenv_err=$(<"$__dotsecenv_errfile")
        print -u2 "cd: ${__dotsecenv_err#*: }"
    else
        _dotsecenv_chdir_hook
    fi
    rm -f "$__dotsecenv_errfile"
    return $__dotsecenv_ret
}

# Wrap pushd to trigger directory change processing
pushd() {
    local __dotsecenv_errfile __dotsecenv_err __dotsecenv_ret
    __dotsecenv_errfile=$(mktemp)
    builtin pushd "$@" 2>"$__dotsecenv_errfile"
    __dotsecenv_ret=$?
    if ((__dotsecenv_ret != 0)); then
        __dotsecenv_err=$(<"$__dotsecenv_errfile")
        print -u2 "pushd: ${__dotsecenv_err#*: }"
    else
        _dotsecenv_chdir_hook
    fi
    rm -f "$__dotsecenv_errfile"
    return $__dotsecenv_ret
}

# Wrap popd to trigger directory change processing
popd() {
    local __dotsecenv_errfile __dotsecenv_err __dotsecenv_ret
    __dotsecenv_errfile=$(mktemp)
    builtin popd "$@" 2>"$__dotsecenv_errfile"
    __dotsecenv_ret=$?
    if ((__dotsecenv_ret != 0)); then
        __dotsecenv_err=$(<"$__dotsecenv_errfile")
        print -u2 "popd: ${__dotsecenv_err#*: }"
    else
        _dotsecenv_chdir_hook
    fi
    rm -f "$__dotsecenv_errfile"
    return $__dotsecenv_ret
}

# Process current directory on plugin load (initial shell startup)
_dotsecenv_chdir_hook
echo "XASD"