# OWL OpenClaw Full Installer v2.0

One-command installer untuk setup OpenClaw dari awal dengan konfigurasi lengkap + memory.

## Fitur

- **Model:** `openrouter/owl-alpha` (primary + fallback)
- **Multi-provider:** OpenRouter, NVIDIA NIM
- **Telegram Bot** — auto-setup dengan allowlist
- **TTS via Gemini** — `gemini-2.5-flash-preview-tts` dengan voice Kore/Fenrir/dll
- **Realtime Voice / Talk** — Gemini Live API via WebRTC
- **Voice Call plugin** — realtime voice bridge via Google
- **Full workspace** — AGENTS.md, SOUL.md, IDENTITY.md, MEMORY.md, daily notes
- **Gemini TTS script** — helper buat generate suara dari terminal

## Quick Install

```bash
export OPENROUTER_API_KEY="***"
export GEMINI_API_KEY="***"
export TELEGRAM_BOT_TOKEN="***"
export TELEGRAM_USER_ID="123456789"

git clone https://github.com/dikurdikur/openclaw-installer.git
cd openclaw-installer
chmod +x install-openclaw.sh
./install-openclaw.sh
```

## Konfigurasi

| Komponen | Provider | Model | Voice |
|----------|----------|-------|-------|
| Chat | OpenRouter | `openrouter/owl-alpha` | — |
| TTS | Google Gemini | `gemini-2.5-flash-preview-tts` | Kore |
| Realtime Talk | Google Live API | `gemini-2.5-flash-native-audio-preview-12-2025` | Kore |

## TTS Voices

Kore (default), Fenrir, Charon, Aoede, Puck, Leda, Orus, Callirhoe, Autonoe, Enceladus, Iapetus, Algieba, Despina, Erinome, Laomedeia, Schedar, Achird, Vindemiatrix, Sadachbia, Sulafat

Ganti dengan `export TTS_VOICE=Fenrir` sebelum run installer.

## Struktur Workspace

```
~/.openclaw/
├── openclaw.json          # Main config
├── .env                   # GEMINI_API_KEY
├── workspace/
│   ├── AGENTS.md          # Agent instructions
│   ├── SOUL.md            # Personality
│   ├── IDENTITY.md        # Bot identity
│   ├── MEMORY.md          # Long-term memory
│   ├── BOOTSTRAP.md       # First-run setup
│   ├── memory/
│   │   └── YYYY-MM-DD.md  # Daily notes
│   └── scripts/
│       └── gemini_tts.sh  # TTS helper
```

## TTS Script Usage

```bash
cd ~/.openclaw/workspace/scripts

# Basic
./gemini_tts.sh "Halo bro, gue OWL"

# Custom voice
./gemini_tts.sh "Halo bro" Fenrir

# Output: /tmp/gemini_tts_XXXXX.mp3
```

## Telegram Voice Note

- Telegram bot auto-transcribe voice note yang masuk
- Agent bisa reply pake suara via `[[audio_as_voice]]` tag
- Android/iOS: klik icon mic di keyboard Telegram
- NOTE: Telegram tidak support realtime voice call (pake Control UI / OpenClaw app)

## Manual Setup

1. `npm install -g openclaw`
2. Copy `openclaw-config-template.json` → `~/.openclaw/openclaw.json`
3. Edit API keys
4. `echo "GEMINI_API_KEY=***" > ~/.openclaw/.env`
5. `openclaw gateway start`

## Requirements

- Ubuntu/Debian (Linux-based)
- Node.js 22+ (auto-installed)
- ffmpeg (auto-installed)
- API keys: OpenRouter, Gemini, Telegram Bot

## Troubleshooting

### TTS Error: API key not valid
Gunakan model `gemini-2.5-flash-preview-tts` (bukan `gemini-3.1-flash-tts-preview`).
Model 3.1 mungkin belum tersedia untuk semua key.

### Voice note tidak terima
- Pastikan bot Telegram sudah di-start (`/start`)
- Kirim dari HP (bukan desktop/web)
- Cek permission microphone di HP

### Gateway tidak start
```bash
openclaw gateway status
openclaw gateway restart
```

## Changelog

### v2.0
- Added full workspace setup (AGENTS.md, SOUL.md, IDENTITY.md, MEMORY.md)
- Added daily memory notes
- Added Gemini TTS helper script
- Added voice/TTS documentation
- Improved config template

### v1.1
- Fix TTS model ke gemini-2.5-flash-preview-tts
- Fix API key validation
- Simplified script

### v1.0
- Initial release

## Credits

Setup by OWL — OpenClaw AI Agent
