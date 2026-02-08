# AnkiSpark

> Fork of the original **anki-ai-field-generator** by [rroessler1](https://github.com/rroessler1/anki-ai-field-generator)

AnkiSpark is an Anki add-on for enriching notes with AI-generated
text, images, speech, and dictionary/video links.

AnkiWeb add-on page: https://ankiweb.net/shared/info/643253121

## Why this fork

This repository is a maintained fork of
[rroessler1/anki-ai-field-generator](https://github.com/rroessler1/anki-ai-field-generator)
with a stronger configuration system and a production-oriented runtime flow.

Main additions in this fork:

- Multi-profile config store in `config.json` (`config/config_store.py`)
- Profile scoping by note type
- Consistent runtime/config-manager UI sections
- Text/Image/Speech provider separation with per-provider API keys
- Auto-run queue for newly added notes
- Scheduled processing controls
- YouGlish and OAAD link generation with configurable source/target fields
- Field-update strategy with `Fill Empty`, `This Run`, and `Permanent` controls

## Key features

- **AI generation**: text, image, and speech pipelines in one run
- **Provider flexibility**: OpenAI, Claude, Gemini, DeepSeek, or custom endpoints
- **Profile management**: create, duplicate, delete, and activate named configs
- **Safe updates by default**: default behavior is `Fill Empty Only`
- **Overwrite controls**:
  - `Overwrite existing values by default (Permanent)`
  - `Overwrite existing values for this run only (This Run)`
- **Protected fields**:
  - `Permanent` protected fields (saved in config)
  - `This Run` protected fields (one-time only)
- **Conflict dialog**: choose overwrite / skip / abort when conflicts are detected
- **Auto queue**: process new notes in background when enabled
- **Scheduled runs**: periodic processing with query, batch limit, and daily cap
- **Link tools**: batch OAAD / YouGlish link updates from browser menu

## Install

1. Open Anki.
2. Go to `Tools -> Add-ons -> Get Add-ons...`.
3. Enter add-on code: `643253121`.
4. Restart Anki.

## Quick start

1. Open Anki Browser and select notes.
2. Open `Anki AI -> Update Your Flashcards with AI`.
3. Choose a configuration (or click `Manage...`).
4. Set provider credentials, prompts, and field mappings.
5. Run.

## Menu actions

From Browser menu `Anki AI`:

- `Update Your Flashcards with AI`
- `Manage AI Configurations`
- `Show Running Tasks`
- `Open YouGlish Link`
- `Update YouGlish Links (<active-config>)`
- `Open OAAD Link`
- `Update OAAD Links (<active-config>)`

## Field update strategy

Default behavior: **Fill Empty Only**.

Precedence (high to low):

1. Protected fields (`This Run` and `Permanent`) are never written
2. `Overwrite This Run`
3. `Overwrite by Config (Permanent)`
4. Legacy per-feature overwrite options (OAAD/YouGlish)
5. Fill empty only

Runtime save-back behavior:

- If you change **persistent** settings in the run panel, you are prompted to
  sync changes back to the active profile in `config.json`.
- `This Run` options are not persisted.

## Configuration model

A profile can include:

- Note type scope
- Text/image/speech providers and credentials
- Prompt mappings
- Retry strategy
- Auto-run and schedule options
- OAAD/YouGlish settings
- Field overwrite and protected field strategy

Profiles are stored in `config.json` at repository root.

Sanitized examples are provided in:

- `config.json.example` (English)
- `config.json.zh.example` (中文)

## Provider credentials

You need your own API keys and billing setup for providers.

Typical sources:

- OpenAI: https://platform.openai.com/
- Anthropic: https://console.anthropic.com/
- Gemini: https://aistudio.google.com/app/apikey
- DeepSeek: https://platform.deepseek.com/

## Development

### Setup

```bash
python3 -m pip install -r requirements-dev.txt
```

### Formatting and linting

```bash
./pre_checkin.sh
```

### Smoke tests

```bash
python3 -m unittest tests.speech.unit_gemini_tts_payload_test -v
python3 -m unittest tests.image.test_gemini_image -v
```

Note: image test is skipped if `GEMINI_API_KEY` is not set.

## Repository layout

- `__init__.py`: add-on entrypoint
- `core/`: runtime orchestration (`client_factory.py`, `note_processor.py`, `scheduler.py`)
- `ui/`: run window, config manager, progress dialog, shared widgets
- `providers/`: LLM and speech clients
- `config/`: settings, profile model/store, prompt and speech config
- `utils/`: helpers and shared exceptions
- `tests/`: smoke/unit tests
- `docs/`: requirements and implementation notes

## Known scope

- Desktop Anki add-on only
- OAAD integration is link-based (no dictionary body scraping)
- Some advanced scheduler features are still tracked in `docs/requirements.md`

## Contributing

- Follow style and workflow in `AGENTS.md`
- Keep changes scoped and testable
- Do not commit API keys or sensitive credentials

## Credits

- Original author: Ryan Roessler
- Fork maintainer: Felix Huo
- Contributors: Ryan Roessler, Felix Huo, Codex

## License

MIT (see `LICENSE`).
