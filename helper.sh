#!/bin/bash -e

fatal() { echo "Fatal: $*" 1>&2; exit 1; }

usage() {
cat<<EOF
Usage: $0 COMMAND [ARGS]

Commands:
  import VERSION        import from upstream
  patch                 apply patches

EOF
exit 1
}

_FILES() {
cat<<EOF
codemirror.js
codemirror.css
mode/markdown/markdown.js
mode/gfm/gfm.js
addon/mode/overlay.js
addon/selection/active-line.js
addon/display/placeholder.js
addon/dialog/dialog.js
addon/search/searchcursor.js
keymap/vim.js
EOF
}

_import() {
    command -v curl >/dev/null || fatal "curl not found"
    local version="$1"
    [ "$version" ] || fatal "version not specified"
    local cm="https://cdnjs.cloudflare.com/ajax/libs/codemirror"
    for f in $(_FILES); do
        mkdir -p $(dirname $f)
        echo "* importing $f"
        curl -sfS "$cm/$version/$f" -o "$f" || fatal "an error occured"
    done
}

_patch() {
    command -v git >/dev/null || fatal "git not found"
    for patch in patches/*.patch; do
        echo "* applying $patch"
        git apply "$patch" || fatal "failed to apply patch"
    done
}

main() {
    cd $(dirname $(realpath $0))
    case $1 in
        ""|-h|--help|help)      usage;;
        import)                 shift; _import $@;;
        patch)                  _patch;;
        *)                      fatal "unrecognized command: $1";;
    esac
}

main "$@"
