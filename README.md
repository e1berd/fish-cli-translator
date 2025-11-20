# Translatish - Fish Shell function for Google Translate API with caching

A simple, fast command-line translator for the Fish shell that uses Google's free Translate API (via the unofficial `translate.googleapis.com` endpoint) and caches results locally to avoid repeated requests and work faster/offline for repeated phrases.

## Installation

1. Save the function to your Fish configuration or functions directory:

```fish
mkdir -p ~/.config/fish/functions  &
  curl -o ~/.config/fish/functions/translate.fish https://raw.githubusercontent.com/e1berd/
translatish/main/translate.fish

# or just copy-paste the code into the file
```
2. Reload your shell or run:
```fish
source ~/.config/fish/functions/translate.fish
```
## Dependencies (must be installed):

- `curl`
- `jq` (for parsing JSON and managing cache)

On macOS:
```fish
brew install curl jq
```
On Linux (Debian/Ubuntu):
```fish
sudo apt install curl jq
```

## Usage
```fish
translate SRC:DST [text to translate]
```
- SRC – source language code (e.g., en, ru, de, ja). Use auto for auto-detection.
- DST – target language code.
- If no text is given as arguments, the function reads from stdin (useful with pipes).

## Examples
```fish
translate en:ru "Hello world"
# → Привет, мир

translate ru:en "Привет, как дела?"
# → Hi, how are you?

echo "Good morning" | translate en:fr
# → Bonjour

translate auto:es "Cómo estás"
# → How are you
```

## Piping multi-line text
```fish
cat myfile.txt | translate en:de
```

## Repeated translations (cached)
The second and subsequent calls with the exact same language pair and text are instant and work even offline because the result is stored in `~/.cache/translate_cache.json`.

## Cache
- Location: `~/.cache/translate_cache.json`
- Format: simple JSON object where keys are URL-escaped `"SRC:DST|text"` and values are translated strings.
- The cache grows indefinitely. If you want to clean it:
```fish
rm ~/.cache/translate_cache.json
# it will be recreated automatically on next use
```

## Notes / Limitations
- This uses Google's unofficial free API. It may stop working or be rate-limited at any time.
- No advanced features (detected language output, multiple translations, etc.) – only the first translation result is returned.
- No color output or pretty-printing – plain text result.

## License
MIT – feel free to modify and redistribute.
