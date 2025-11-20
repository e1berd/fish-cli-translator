function translate
    set usage "Usage:
  translate ru:en text
  translate ru:en (cat file)
  echo text | translate ru:en
  translate ru:en   # interactive mode
"

    if test (count $argv) -lt 1
        echo $usage
        return 1
    end

    set src_dst $argv[1]

    if not string match -q "*:*" $src_dst
        echo $usage
        return 1
    end

    set src (string split ":" $src_dst)[1]
    set dst (string split ":" $src_dst)[2]

    set text (string join " " $argv[2..-1])

    if test -z "$text"
        if not test -t 0
            set text (cat)
        else
            echo "Interactive mode ($src -> $dst), type 'exit' to quit:"
            while true
                read -P "> " line
                if test "$line" = "exit"
                    return 0
                end
                __translate_request "$src" "$dst" "$line"
            end
        end
    end

    __translate_request "$src" "$dst" "$text"
end

function __translate_request
    set src $argv[1]
    set dst $argv[2]
    set text $argv[3]

    set cache_dir ~/.cache/fish/translate
    mkdir -p $cache_dir

    set key (string join ":" $src $dst $text | md5)
    set cache_file "$cache_dir/$key.txt"

    if test -f $cache_file
        cat $cache_file
        return 0
    end

    set encoded_text (string escape --style=url $text)
    set response (curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$src&tl=$dst&dt=t&q=$encoded_text")

    set result (echo $response | jq -r '.[0][0][0]')

    if test -n "$result"
        echo $result | tee $cache_file
    else
        echo "Translation error"
    end
end
