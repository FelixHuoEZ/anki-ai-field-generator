# anki-ai-field-generator

This is not a standalone script, it's a plugin for Anki which can be downloaded here: https://ankiweb.net/shared/info/643253121

## Fork Notice

This repository is a fork of [rroessler1/anki-ai-field-generator](https://github.com/rroessler1/anki-ai-field-generator).
Compared with the upstream project, this fork adds:

- A reusable configuration store (`config_store.py`) that centralises all LLM profiles in `config.json` and auto-creates it when missing.
- Profiles that bind to multiple note types, carry text/image/speech provider choices, and keep the run dialog in sync with the configuration manager.
- A global configuration manager (`config_manager_dialog.py`) plus menu integration in both the card browser and the Anki Tools/Add-on settings flows.
- Contributor documentation (`AGENTS.md`) outlining repository structure, coding practices, and review expectations.

## Project Roles

- Original author: Ryan Roessler (rroessler1)
- Current maintainer for this fork: Felix Huo (saccohuo)
- Contributors: Ryan Roessler, Codex, Felix Huo

## Description

- This plugin allows you to use Large Language Models (LLMs) to add information to your Anki flashcards using the power of AI.
- Supports Claude (Anthropic), ChatGPT (OpenAI), Gemini (Google), and Deepseek models.
- Optional text-to-speech pipeline that fills audio fields with `[sound:]` tags generated via OpenAI or Gemini TTS.
- YouGlish/OAAD link helpers: map a source field (default `_word`) to target fields (default `_youglish`/`_oaad`) and batch-generate links from the browser menu or during runs; supports per-config accents and overwrite behavior.
- Auto-run new notes: when “Auto Run on New Notes” is enabled, newly added cards queue up for the same generation flow and can run silently in the background.
- Completely free! (You create your own API key and pay for LLM usage)

## Quickstart:
1. Install this plugin. (Open Anki. Tools -> Add-ons -> Get Addons -> Enter code: 643253121)
1. In the Card Browser, select the cards you want to modify (tip: Shift+Click to select many or Ctrl+A to select all)
1. You have a new menu option: Anki AI -> Update Your Flashcards with AI
1. Pick the configuration you want to run (or click **Manage…** to edit profiles), then review the prompts/mappings before launching.

### Sample Card Template (Front/Back + Styling)

Front:

```html
<div class="word big">{{_wordAudio}}{{_word}}</div>
```

Back:

```html
{{FrontSide}}
<hr id="answer">

{{#_phonType}}<div class="meta">{{_phonType}}{{#_phonetic}} · {{_phonetic}}{{/_phonetic}}</div>{{/_phonType}}

{{#_wordTran}}<div class="zh">{{_wordTran}}</div>{{/_wordTran}}
{{#_definition}}<div class="def">{{_definition}}</div>{{/_definition}}

<!-- OAAD / Youglish link area (full URL version) -->
{{#_oaad}}<div class="link"><a href="{{_oaad}}" target="_blank" rel="noopener">OAAD</a></div>{{/_oaad}}
{{#_youglish}}<div class="link"><a href="{{_youglish}}" target="_blank" rel="noopener">Youglish</a></div>{{/_youglish}}

{{#_sentenceMarked}}<div class="sentence">{{_sentenceAudio}}{{_sentenceMarked}}</div>{{/_sentenceMarked}}
{{#_sentenceTran}}<div class="tr">{{_sentenceTran}}</div>{{/_sentenceTran}}

{{#_examplesOrig}}
<div class="ex">
  {{_examplesOrig}}
  {{#_examplesTran}}<div class="ex-tr">{{_examplesTran}}</div>{{/_examplesTran}}
</div>
{{/_examplesOrig}}

{{#_notes}}<div class="notes">{{_notes}}</div>{{/_notes}}

{{#_image}}{{_image}}{{/_image}}
```

Styling:

```css
/* Card wrapper */
.card {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  font-size: 22px;
  line-height: 1.6;
  max-width: 680px;
  margin: 0 auto;
  padding: 18px 22px;
  background: #fdfdfd;
  border-radius: 10px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  text-align: left;
}

/* Answer separator */
#answer {
  margin: 12px 0 18px;
  border: none;
  border-top: 1px solid #e3e3e3;
}

/* Main word */
.word.big {
  display: block;
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 6px;
}

/* Meta info */
.meta {
  font-size: 16px;
  color: #888;
  margin-bottom: 8px;
}

/* Shared spacing */
.zh,
.def,
.ex,
.notes {
  margin: 8px 0;
}

.zh {
  font-weight: 600;
  color: #333;
}

.def {
  color: #444;
  padding-left: 10px;
  border-left: 3px solid #e3e3e3;
}

.sentence {
  margin: 10px 0 4px;
  padding: 8px 10px;
  background: #f7faff;
  border-radius: 6px;
}

.tr {
  color: #666;
  margin: 4px 0 10px;
  font-size: 0.9em;
}

.ex {
  padding: 8px 10px;
  background: #fafafa;
  border-radius: 6px;
  border-left: 3px solid #eee;
}

.ex-tr {
  color: #777;
  margin-top: 4px;
  margin-left: 0;
  font-size: 0.9em;
}

.notes {
  padding: 8px 10px;
  background: #fffaf0;
  border-radius: 6px;
  border-left: 3px solid #ffdd99;
  font-size: 0.9em;
}

img {
  max-width: 100%;
  height: auto;
  margin: 10px 0;
}

.link {
  margin: 6px 0;
  font-size: 0.9em;
}

.link a {
  text-decoration: none;
  border-bottom: 1px dashed #999;
}

.link a:hover {
  border-bottom-style: solid;
}

@media (max-width: 480px) {
  .card {
    font-size: 20px;
    padding: 14px 16px;
  }
  .word.big {
    font-size: 28px;
  }
}
```

### Configuration Profiles

- Open **Manage…** from the run window (or Tools → Anki AI → Manage Configurations) to edit profiles stored in `config.json`.
- Each profile can target specific note types. When selected cards fall outside the active profile, the run dialog and a warning popup prompt you to switch before generating content.
- Text, image, and speech generation now store separate provider/model choices. Use the drop-downs inside each section to pick OpenAI, Anthropic, Gemini, DeepSeek, or a custom endpoint.
- The runtime dialog reuses the same sections as the configuration manager—retry policy, text mappings, image prompts, and speech prompts—so what you preview while editing is exactly what you run.
- Switching providers in either window applies the same defaults (endpoint/model/voice/format) so the runtime and configuration manager stay in sync.
- YouGlish/OAAD setup: configure source/target fields and accent; browser menus offer “Open/Update YouGlish/OAAD Link” shortcuts, and batch runs will write links automatically.
- Auto-run new notes: check “Automatically run on newly added notes” to enqueue fresh cards into the background batch (optionally silent).

## Detailed Setup:

<details>
<summary><b>1. Create an API Key:</b></summary>
<br/>
For all of these you'll have to add a credit card and add a few dollars of credit first.

<br/>

<b>Claude (Anthropic):</b>

Sign up here: https://console.anthropic.com/dashboard

Then click "Get API Keys" and create a key.

<b>ChatGPT (OpenAI):</b>

Go here: https://platform.openai.com/

If you've never signed up for OpenAI before, click "Sign up".

Follow the prompts, and be sure to create an API key and also to add a credit card with a few dollars, otherwise it won't work.

<b>Gemini</b>

Go here: https://aistudio.google.com/app/apikey

And click the "Create API key" button.

<b>DeepSeek</b>

Sign up here: https://platform.deepseek.com/

Then click on "API Keys" and create a key.
</details>

<details>
<summary><b>2. Create a System Prompt:</b></summary>
<br/>
This is where you write specific instructions, examples, and do "prompt engineering".

This is <u>also</u> where you tell the model which output to return, which you'll need in Step 4.

Example System Prompt:

```
You are an experienced German teacher who is helping me practice grammar.
You will be provided with a German word.  Respond with:
-an "exampleSentence" at A2 or B1 level about 10-15 words long using the provided German word, and
-the "translation" of that sentence into English
```
In the above prompt, the model will return "exampleSentence" and "translation", which you'll use in step 4.

<details>
<summary><b>DeepSeek specific:</b></summary>

If you use DeepSeek, you must include an example JSON response in your System Prompt. Your prompt should look like this:

```
You are an experienced German teacher who is helping me practice grammar.  You will be provided with a German word.  Respond with:
-an "exampleSentence" at A2 or B1 level about 10-15 words long using the provided German word, and
-the "translation" of that sentence into English

EXAMPLE JSON OUTPUT:
{
    "exampleSentence": "Mein Bruder kommt aus den USA.",
    "translation": "My brother is from the USA."
}
```
</details>
</details>

<details>
<summary><b>3. Create a User Prompt:</b></summary>
<br/>
This is where you use Fields from your Cards by writing the field name surrounded by braces {}.

Example User Prompt:

```
{de_sentence}
```
</details>

<details>
<summary><b>4. Save the response to your Anki Cards:</b></summary>
<br/>
In the System Prompt, you told the LLM what information you want.

In our example it's an "exampleSentence" and a "translation", but you can ask the LLM for any information and call it whatever you want.

In the "Save the Output" part, match the information to Fields on your Cards. For example:

```
exampleSentence de_sentence
translation     en_sentence
```

In our example, the LLM returns:
- an "exampleSentence", which gets saved to the "de_sentence" field on our card
- a "translation", which gets saved to the "en_sentence" field on our card

</details>

> Tip: At runtime every mapped key must exist in the model response. Missing keys cause that note to be skipped and logged to `anki_ai_runtime.log`; the batch continues without crashing.

<details>
<summary><b>Optional: Generate audio from your fields</b></summary>
<br/>
Use the <em>Speech Generation Mapping</em> section in the settings dialog to map a source text field to the card field that should receive the audio tag. When the source field has content, the plugin calls the configured speech endpoint (OpenAI by default, Gemini when you select a Gemini TTS model) and stores the resulting file in Anki's media folder with a <code>[sound:...]</code> tag.

- Provide a speech API key dedicated to audio requests; the plugin does not reuse your main LLM key.
- Defaults target OpenAI (<code>gpt-4o-mini-tts</code>, <code>alloy</code>, <code>mp3</code>). To switch to Google Gemini, set the audio model (and optionally override the voice) to your Gemini setup (e.g., <code>gemini-2.5-flash-preview-tts</code>); the default voice is <code>Kore</code>.
- Gemini TTS currently returns 24kHz linear PCM; the plugin wraps it as <code>.wav</code>. Set the audio format field to <code>wav</code> (or leave blank to fall back to <code>wav</code>).
- The first field in each mapping provides the text to be spoken; the second field receives only the generated <code>[sound:...]</code> tag.
- Existing field contents are preserved; the new audio tag is appended on a new line if needed.
- Advanced: at the bottom of Settings you can set “Retry Attempts” and “Initial Retry Delay (seconds)” (default 50 / 5) to control automatic retries for text/image/audio; the delay doubles every 10 attempts (5s for attempts 1–10, 10s for 11–20, etc.).

<details>
<summary><b>Gemini 2.5 preset voices (2025-09-30)</b></summary>
<br/>
Zephyr — Bright; Puck — Upbeat; Charon — Informative; Kore — Firm; Fenrir — Excitable; Leda — Youthful; Orus — Firm; Aoede — Breezy; Callirrhoe — Easy-going; Autonoe — Bright; Enceladus — Breathy; Iapetus — Clear; Umbriel — Easy-going; Algieba — Smooth; Despina — Smooth; Erinome — Clear; Algenib — Gravelly; Rasalgethi — Informative; Laomedeia — Upbeat; Achernar — Soft; Alnilam — Firm; Schedar — Even; Gacrux — Mature; Pulcherrima — Forward; Achird — Friendly; Zubenelgenubi — Casual; Vindemiatrix — Gentle; Sadachbia — Lively; Sadaltager — Knowledgeable; Sulafat — Warm.

</details>

Run the add-on again whenever you want to refresh the audio files after changing settings.

<em>Live verification</em>: To sanity-check Gemini TTS locally, run `python -m tests.speech.run_gemini_tts_sample`, or set `GEMINI_API_KEY` and `RUN_GEMINI_TTS_LIVE_TEST=1` then execute `python -m unittest tests.speech.live_gemini_tts_test`.
</details>

### Google models & endpoint quick reference

| Purpose | Model | Summary | REST Endpoint Example |
| --- | --- | --- | --- |
| Image | `gemini-2.5-flash-image` | Stable 2.5 Flash image model focused on throughput/latency; default 1024×1024 output | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent` |
| Image | `gemini-2.5-flash-image-preview` | Preview channel with experimental improvements (more detail/control); endpoints/quotas may change | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image-preview:generateContent` |
| Image | `imagen-4.0-generate-001` | Imagen 4 standard tier; balances realism and illustration; supports up to 2048×2048 | `https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:generateContent` |
| Image | `imagen-4.0-ultra-generate-001` | Imagen 4 Ultra; higher fidelity for complex scenes; higher cost/latency | `https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-ultra-generate-001:generateContent` |
| Image | `imagen-4.0-fast-generate-001` | Imagen 4 Fast; trades detail for lowest latency/cost; good for drafts/batches | `https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-fast-generate-001:generateContent` |
| Audio | `gemini-2.5-flash-preview-tts` | Flash TTS preview emphasizing low latency/interactive use; outputs 24kHz PCM (wrapped as WAV) | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent` |
| Audio | `gemini-2.5-pro-preview-tts` | Pro TTS preview focusing on naturalness/long-form quality; slightly higher latency | `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro-preview-tts:generateContent` |

> Note: All endpoints use Google Generative Language REST API. If you override the endpoint, ensure the URL ends with `.../models/<MODEL>:generateContent`. Image calls must set `"responseModalities": ["IMAGE"]`; audio calls should set `"responseModalities": ["AUDIO"]` or include `speechConfig`.

## FAQ:

<details>
<summary><b>What is an API Key?</b></summary>
<br/>
An API Key is a secret unique identifier used to authenticate and authorize a user. So basically it identifies you with your account, so you can be charged for your usage.

**An API Key should never be shared with anyone.** Because then they can use your account and your saved credit.

If you accidentally "expose" your API key (text it to someone by accident or whatever), you can easily delete it and create a new one using the links listed above.

</details>
<details>
<summary><b>Which LLM should I use?</b></summary>
<br/>

**Answer quality:** they're all pretty good, and it depends more on your prompt engineering

**Speed:** Claude is the fastest, as it allows 50 calls per minute, whereas OpenAI only allows 3 per minute and 200 per day (from the beginner tier). Gemini has a nice free tier for the "Flash-Light Preview" model with 15 calls per minute and 1000 per day.

**Cost:** OpenAI's gpt-4o-mini model is currently the cheapest.

</details>
<details>
<summary><b>Why is the OpenAI model so slow / why am I getting rate-limited?</b></summary>
<br/>
Unfortunately when you first sign up for OpenAI you can only make 3 calls per minute (and 200 per day). The plugin handles this, sadly just by "pausing" for 20 seconds at a time.

Once you spend $5, then you can make 500 calls per minute. I don't know of any way to just automatically spend $5 to get to the next Tier.

</details>

<details>
<summary><b>Can I use this to generate new Anki cards?</b></summary>
<br/>
Not exactly - this plugin doesn’t create new Anki cards from scratch. However, you can import a list of words or phrases into a new deck (e.g., from an Excel sheet) and then use the plugin to automatically generate additional information for each card, such as:

- Definitions
- Example sentences
- Translations
- Usage tips

</details>

<details>
<summary><b>How much does it cost?</b></summary>
<br/>
This Add-on is free! See "Pricing" below for a more detailed breakdown of expected costs of using the LLMs.

</details>
<details>
<summary><b>What if I have questions, bug reports, or feature requests?</b></summary>
<br/>
Please submit them to the GitHub repo here: https://github.com/rroessler1/anki-ai-field-generator/issues

</details>
<details>
<summary><b>How can I support the creator of this plugin?</b></summary>
<br/>
I'd be very grateful! You can buy me a coffee here: https://buymeacoffee.com/rroessler

And please upvote it here: https://ankiweb.net/shared/info/643253121 , that helps other people discover it and encourages me to keep it maintained.
</details>

## Pricing

All the companies have models are relatively inexpensive, and have the pricing information on their website. But specifically:

- The cheapest models currently are Anthropic's claude-3-5-haiku, Google's gemini-2.5-flash-light-preview, DeepSeek's deepseek-chat, and OpenAI's gpt-4o-mini.
- More advanced models might cost quite a bit more.
- Pricing is based on number of tokens in the input and the output. A "token" is generally a few letters.
- I tested with the same prompt, and Claude uses 3x the number of tokens as OpenAI and Deepseek. This makes Claude more expensive.

<details>
<summary><b>Estimated Costs:</b></summary>
<br/>
Using the example prompts shown in the UI:

**OpenAI**: One flashcard uses 180 tokens, so 1 million tokens = 5500 cards = $0.15 USD

**DeepSeek**: One flashcard uses 195 tokens, so 1 million tokens = 5100 cards = $0.27 USD

**Claude**: One flashcard uses 660 tokens, so 1 million tokens = 1500 cards = $0.80 USD

So Claude is relatively more expensive, but it's the fastest. Once you are past the basic tier on OpenAI (once you spend $5), it becomes equivalently fast.

</details>

## Example Prompts and Use Case Ideas

This plugin is designed to be flexible so that with a bit of creativity you could create almost anything. But here are some example use cases:

<details>
<summary><b>Generate Example Sentences:</b></summary>

**System Prompt:**
```
You are an experienced German teacher who is helping me practice grammar.
You will be provided with a German word. Respond with:
-an "exampleSentence" at A2 or B1 level about 10-15 words long using the provided German word, and
-the "translation" of that sentence into English
```

**User Prompt:**
```
{de_word}
```

**Output Mapping:**
```
exampleSentence de_sentence
translation     en_sentence
```
- Change "de_sentence" and "en_sentence" in the dropdown boxes to whatever the Fields on your Cards are called.

</details>

<details>
<summary><b>Generate Cloze Deletions:</b></summary>

**System Prompt:**
```
You are an Anki plugin that helps users create Cloze deletions. You will be provided with a sentence.
Choose 1-3 key words or phrases and replace them using Anki's Cloze deletion format: {{c1::word or phrase}}.
If there are multiple deletions, use c1, c2, c3, etc.
Ensure that deletions are meaningful and not too easy.
```

**User Prompt:**
```
{sentence}
```

**Output Mapping:**
```
cloze_sentence  formatted_cloze_sentence
```
- Change "formatted_cloze_sentence" in the dropdown box to the Field where you want to store the Cloze version.

</details>

<details>
<summary><b>Summarize Information:</b></summary>

**System Prompt:**
```
You are an expert at summarizing complex information.
You will be provided with a passage of text.
Summarize it in 1-2 sentences while preserving the core meaning.
Keep the language clear and concise.
```

**User Prompt:**
```
{field_text}
```

**Output Mapping:**
```
summary  summarized_text
```
- Change "summarized_text" in the dropdown box to the Field where you want to store the summary.
</details>

<details>
<summary><b>Step-by-Step Derivations:</b></summary>

**System Prompt:**
```
You are a math and science tutor who explains concepts with step-by-step derivations.
You will be provided with a math or science problem.
Break it down into logical steps, explaining each step clearly.
Use LaTeX formatting for equations when necessary.
```

**User Prompt:**
```
{problem_statement}
```

**Output Mapping:**
```
derivation  step_by_step_solution
```
- Change "step_by_step_solution" in the dropdown box to the Field where you want to store the derivation.

</details>

<details>
<summary><b>Generate a Context-Rich Explanation:</b></summary>

**System Prompt:**
```
You are an expert language tutor helping students understand vocabulary in context.
You will be provided with:
- A target word or phrase
- An example sentence containing that word or phrase
- A definition of the word or phrase
- (Optional) A topic or category for additional context

Respond with:
- A revised version of the example sentence that sounds more natural and
  contextually appropriate.
- A brief explanation of the word or phrase in simple terms.
- A usage tip explaining when and how to use the word correctly.

```

**User Prompt:**
```
Word: {word}
Example Sentence: {example_sentence}
Definition: {definition}
Category (optional): {category}
```

**Output Mapping:**
```
refined_sentence  example_sentence
explanation       simple_explanation
usage_tip         usage_guidance
```
- Change "example_sentence," "simple_explanation," and "usage_guidance" in the dropdown boxes to match your Anki Card Fields.
- Note that this example would overwrite your current "example_sentence". This may or may not be desirable.

</details>
