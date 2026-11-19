function extract --description 'Extract archives by extension (into the current folder)'
    test (count $argv) -gt 0; or begin; echo 'uso: extract ARQUIVO...' >&2; return 1; end
    for f in $argv
        if not test -f $f
            echo "extract: '$f' não existe" >&2; continue
        end
        switch (string lower -- $f)
            case '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz2' '*.tar.xz' '*.txz' '*.tar.zst' '*.tzst' '*.tar'
                tar -xf $f
            case '*.zip' '*.jar'
                unzip -q $f
            case '*.7z' '*.rar'
                7z x $f
            case '*.gz'
                gunzip -k $f
            case '*.bz2'
                bunzip2 -k $f
            case '*.xz'
                unxz -k $f
            case '*.zst'
                unzstd $f
            case '*'
                echo "extract: não sei abrir '$f'" >&2
        end
    end
end
