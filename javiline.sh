#!/usr/bin/env bash

# This is highly inspired (and copied) from bash-powerline
# https://github.com/riobard/bash-powerline

__javiline() {
    # Colorscheme
    RESET='\[\033[m\]'

    COLOR_CWD='\[\033[38;5;39m\]'
    COLOR_GIT='\[\033[38;5;71m\]'
    COLOR_SUCCESS='\[\033[38;5;121m\]'
    COLOR_FAILURE='\[\033[38;5;204m\]'

    SYMBOL_GIT_BRANCH='⑂'
    SYMBOL_GIT_MODIFIED='*'
    SYMBOL_GIT_PUSH='↑'
    SYMBOL_GIT_PULL='↓'
    PS_SYMBOL='$'

    __git_info() { 
        local git_eng="env LANG=C git"   # force git output in English to make our work easier

        # get current branch name
        local ref=$($git_eng symbolic-ref --short HEAD 2>/dev/null)

        if [[ -n "$ref" ]]; then
            # prepend branch symbol
            ref=$SYMBOL_GIT_BRANCH$ref
        else
            # get tag name or short unique hash
            ref=$($git_eng describe --tags --always 2>/dev/null)
        fi

        [[ -n "$ref" ]] || return  # not a git repo

        local marks

        # scan first two lines of output from `git status`
        while IFS= read -r line; do
            if [[ $line =~ ^## ]]; then # header line
                [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PUSH${BASH_REMATCH[1]}"
                [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PULL${BASH_REMATCH[1]}"
            else # branch is modified if output contains more lines after the header line
                marks="$SYMBOL_GIT_MODIFIED$marks"
                break
            fi
        done < <($git_eng status --porcelain --branch 2>/dev/null)  # note the space between the two <

        # print the git branch segment without a trailing newline
        printf " $ref$marks"
    }

    __kube_info(){
        # Using kubectl is WAAAY slower, so use this shit
        grep ^current-context ${KUBECONFIG:-~/.kube/config}|cut -d ' ' -f 2| tr -d \\n
    }

    ps1() {

        local symbol="$PS_SYMBOL"

        local cwd="$COLOR_CWD\w$RESET"

        __powerline_git_info="$(__git_info)"
        local git="$COLOR_GIT\${__powerline_git_info}$RESET"

        __kube_context="$(__kube_info)"
        [ "${__kube_context:0,-2}" == "st" ] \
            && COLOR_KUBE="$COLOR_SUCCESS"  \
            || COLOR_KUBE="$COLOR_FAILURE"
        local kube="($COLOR_KUBE\${__kube_context}$RESET) "

        PS1="$kube$cwd$git$symbol "
    }

    PROMPT_COMMAND="ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
}

__javiline
unset __javiline
