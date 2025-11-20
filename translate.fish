function translate --argument src_dst text
    if not string match -q "*:*" $src_dst
        echo "Usage: translate ru:en \"текст\""
        return 1
    end

    set src (string split ":" $src_dst)[1]
    set dst (string split ":" $src_dst)[2]

    set encoded_text (string escape --style=url $text)
    set response (curl -s "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$src&tl=$dst&dt=t&q=$encoded_text")

    echo $response | jq -r '.[0][0][0]'
end
