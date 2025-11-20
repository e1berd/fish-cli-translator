function translate --argument src_dst text
    if not string match -q "*:*" $src_dst
        echo "Usage: translate ru:en \"текст\""
        return 1
    end
    set src (string split ":" $src_dst)[1]
    set dst (string split ":" $src_dst)[2]
    set cache_file "$HOME/.cache/translate_cache.json"
    if not test -f $cache_file
        echo "{}" > $cache_file
    end
    set key (string escape --style=url "$src_dst|$text")
    set cached (jq -r --arg k "$key" '.[$k] // empty' $cache_file)
    if test -n "$cached"
        echo $cached
        return
    end
    set encoded_text (string escape --style=url $text)
    set response (curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$src&tl=$dst&dt=t&q=$encoded_text")
    set result (echo $response | jq -r '.[0][0][0]')
    jq --arg k "$key" --arg v "$result" '. + {($k): $v}' $cache_file > $cache_file.tmp
    mv $cache_file.tmp $cache_file
    echo $result
end
