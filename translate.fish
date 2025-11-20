function translate --argument-names src_dst
    if not set -q src_dst[1]
        echo "Usage: translate SRC:DST [text]"
        return 1
    end

    if not string match -q "*:*" $src_dst
        echo "Invalid language pair format. Use SRC:DST"
        return 1
    end

    set src (string split ":" $src_dst)[1]
    set dst (string split ":" $src_dst)[2]

    set text_to_translate ""

    if set -q argv[2]
        set text_to_translate $argv[2..-1]
    else if not isatty stdin
        while read -l line
            set text_to_translate $text_to_translate $line
        end
    end

    if test -z "$text_to_translate"
        echo "No text provided"
        return 1
    end

    set text_to_translate (string join " " $text_to_translate)
    set text_to_translate (string trim "$text_to_translate")

    set cache_file "$HOME/.cache/translate_cache.json"
    if not test -f $cache_file
        echo "{}" > $cache_file
    end

    set key (string escape --style=url "$src_dst|$text_to_translate")
    set cached (jq -r --arg k "$key" '.[$k] // empty' $cache_file)
    if test -n "$cached"
        echo $cached
        return
    end

    set encoded_text (string escape --style=url $text_to_translate)
    set response (curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$src&tl=$dst&dt=t&q=$encoded_text")
    set result (echo $response | jq -r '.[0][0][0]')
    jq --arg k "$key" --arg v "$result" '. + {($k): $v}' $cache_file > $cache_file.tmp
    mv $cache_file.tmp $cache_file
    echo $result
end
