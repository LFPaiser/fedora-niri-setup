function mkcd --description 'Create a directory (and parents) and cd into it'
    test (count $argv) -eq 1; or begin; echo 'uso: mkcd PASTA' >&2; return 1; end
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end
