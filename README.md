# Fish Shell Translator

A simple and elegant fish shell function for quick text translation using Google Translate API.

## Features

- 🌐 Translate between any language pairs supported by Google Translate
- ⚡ Fast and lightweight - uses direct API calls
- 🎯 Simple and intuitive syntax
- 🛡️ URL-encodes text automatically for safe transmission
- 📋 Clean output using jq for JSON parsing

## Requirements

- `fish` shell
- `curl` - for making HTTP requests
- `jq` - for JSON parsing

## Installation

1. Save the function to your fish config file (`~/.config/fish/config.fish`) or as a separate function file.

2. The function code:
```fish
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
```

## Usage
```fish
translate SOURCE_LANG:TARGET_LANG "text to translate"
```

## Examples
```fish
# Russian to English
translate ru:en "Привет, мир!"

# English to Spanish
translate en:es "Hello, world!"

# English to French
translate en:fr "How are you today?"

# Spanish to German
translate es:de "Buenos días"
```

## Notes
- The function uses Google's public translate API
- Text is automatically URL-encoded for safety
- Requires internet connection
- Rate limits may apply with extensive use

## Troubleshooting
If you get an error, ensure:
- You have `curl` and `jq` installed
- The language code format is correct (source:target)
- You're connected to the internet
- The text is properly quoted
