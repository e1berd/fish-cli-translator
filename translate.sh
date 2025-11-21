translate() {
    command -v curl >/dev/null || { echo "Error: curl required" >&2; return 1; }
    command -v jq >/dev/null || { echo "Error: jq required" >&2; return 1; }

    local pair="$1"
    if [ -z "$pair" ] || [[ "$pair" != *:* ]]; then
      echo "Usage: translate SRC:DST [text]";
      return 1;
    fi

    local src="${pair%%:*}"
    local dst="${pair#*:}"
    shift

    local text
    if [[ $# -gt 0 ]]; then
        text="$*"
    elif [[ ! -t 0 ]]; then
        text=$(cat)
    else
        echo "Error: no text provided" >&2
        return 1
    fi

    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"

    if [ -z "$text" ]; then
        echo "Error: no text provided" >&2
        return 1
    fi

    local cache="$HOME/.cache/translate_cache.json"

    mkdir -p "$(dirname "$cache")"

    if [ ! -f "$cache" ]; then
      echo "{}" > "$cache"
    fi

    local key="$pair|$text"

    local cached
    cached=$(jq -r --arg k "$key" '.[$k] // empty' "$cache")
    if [ -n "$cached" ]; then
      echo "$cached"
      return
    fi

    local api_url="https://translate.googleapis.com/translate_a/single"

    local response
    response=$(curl -s --get \
        --data-urlencode "q=$text" \
        --data-urlencode "client=gtx" \
        --data-urlencode "sl=$src" \
        --data-urlencode "tl=$dst" \
        --data-urlencode "dt=t" \
        "$api_url")

    local translated
    translated=$(echo "$response" | jq -r '.[0][0][0] // empty')

    if [ -z "$translated" ]; then
      echo "Error: translation failed"
      return 1
    fi

    jq --arg k "$key" --arg v "$result" '. + {($k): $v}' "$cache" > "$cache.tmp" && mv "$cache.tmp" "$cache"

    echo "$translated"
}
