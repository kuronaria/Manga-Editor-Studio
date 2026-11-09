# Echoes — Manga Editor Studio

A browser-based editor for translating manga pages by hand. It runs on top of
[manga-image-translator](https://github.com/zyddnys/manga-image-translator),
reusing its text detection, OCR and inpainting, and adds a manual editing layer
on top: select text regions, read and translate them, clean the original, and
typeset the translation.

> **Status: 0.1.0 (alpha).** This is a personal project and still rough. Expect
> bugs and breaking changes.

## What it does

- Open one or more pages (drag & drop or file picker), shown as a page queue.
- Manual box selection (two clicks: one corner, then the opposite corner).
- OCR with the local `manga-ocr` model (offline), or an OpenAI-compatible LLM
  ("Proxy") that returns OCR + romaji + translation in one call.
- **Auto-TL**: detect every bubble locally, then translate the whole page in a
  single LLM request.
- **Clean**: ML inpainting to remove the original text, plus a manual
  white / black / erase brush for touch-ups.
- **Typesetting**: font, size, line height, alignment, fill and outline.
- **Glossary**: fixed term translations (names, skills, terms) and honorific
  handling, injected into the LLM prompt. CSV import / export.
- Per-page layers (Base / Clean / Text) and PNG export.

## Requirements

- Python 3.x and the packages in `requirements.txt`.
- For translation: an API key and model for any OpenAI-compatible endpoint
  (OpenRouter, Gemini's OpenAI-compatible URL, DeepSeek, etc.). OCR with
  `manga-ocr` works offline, without a key.

## Setup

```bash
git clone https://github.com/kuronaria/Manga-Editor-Studio.git
cd Manga-Editor-Studio
python -m venv venv
venv\Scripts\pip install -r requirements.txt     # Windows
# venv/bin/pip install -r requirements.txt        # macOS / Linux
```

Optionally copy the env template if you want to use the built-in translators:

```bash
copy examples\Example.env .env                    # Windows
# cp examples/Example.env .env                     # macOS / Linux
```

## Run

```bash
venv\Scripts\python server\main.py                # Windows
# venv/bin/python server/main.py                   # macOS / Linux
```

Then open **http://127.0.0.1:8000/editor** in a browser. Change the port with
`--port` if needed.

## Translation setup (Proxy)

In the editor, click **Proxy** and fill in:

- **Base URL** — an OpenAI-compatible endpoint, e.g. `https://openrouter.ai/api/v1`.
- **API key** and **Model**.

These are kept only for the current browser tab. OCR and Auto-TL must be used
with the editor opened through the server (the `/editor` URL above), not from a
local `file://` path, so the browser can reach the backend.

## Notes

- `run.bat` / `run.sh` auto-pull from upstream; run `server/main.py` directly if
  you don't want that.
- Don't commit your `.env` — it holds your API key. It's already gitignored.

## Credits & license

Built on [manga-image-translator](https://github.com/zyddnys/manga-image-translator)
by zyddnys and contributors. This project keeps and is bound by that project's
license — see [`LICENSE`](LICENSE). All original manga-image-translator credits
apply.
