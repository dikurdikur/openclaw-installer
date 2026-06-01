#!/bin/bash
# ============================================================
# OWL OpenClaw Full Installer v2.0
# ============================================================
# Install OpenClaw + setup konfigurasi lengkap + memory
#   - Model: openrouter/owl-alpha (primary + fallback)
#   - Multi-provider: OpenRouter, NVIDIA, Google Gemini
#   - Telegram Bot
#   - TTS via Gemini (gemini-2.5-flash-preview-tts) [TESTED]
#   - Realtime Voice (Gemini Live API)
#   - voice-call plugin
#   - Full memory & workspace setup
# ============================================================
#
# Cara pake:
#   1. Export API keys:
#      export OPENROUTER_API_KEY="***"
#      export GEMINI_API_KEY="***"
#      export TELEGRAM_BOT_TOKEN="***"
#      export TELEGRAM_USER_ID="123456789"
#   2. chmod +x install-openclaw.sh
#   3. ./install-openclaw.sh
# ============================================================

set -e

# CONFIG
OPENROUTER_API_KEY="${OPEN…KEY}"
NVIDIA_API_KEY="${NVID…KEY}"
GEMINI_API_KEY="${GEMI…KEY}"
TELEGRAM_BOT_TOKEN="${TELE…ERE}"
TELEGRAM_USER_ID="${TELEGRAM_USER_ID:-123456789}"
TTS_VOICE="${TTS_VOICE:-Kore}"
TTS_MODEL="${TTS_MODEL:-gemini-2.5-flash-preview-tts}"
REALTIME_MODEL="${REALTIME_MODEL:-gemini-2.5-flash-native-audio-preview-12-2025}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
fail() { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

# Validate
[ "$OPENROUTER_API_KEY" = "sk-or-…_KEY" ] && fail "OPENROUTER_API_KEY belum di-set."
[ "$TELEGRAM_BOT_TOKEN" = "YOUR_BOT_TOKEN_HERE" ] && { warn "Telegram bot token belum di-set. TG disabled."; TG_ENABLED=false; } || TG_ENABLED=true
[ "$NVIDIA_API_KEY" = "nvapi-YOUR_NVIDIA_KEY" ] && { warn "NVIDIA_API_KEY belum di-set. NVIDIA disabled."; NVIDIA_ENABLED=false; } || NVIDIA_ENABLED=true
[ "$GEMINI_API_KEY" = "YOUR_GEMINI_KEY" ] && { warn "GEMINI_API_KEY belum di-set. TTS/Voice disabled."; GEMINI_ENABLED=false; } || GEMINI_ENABLED=true

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN} OWL OpenClaw Full Installer v2.0${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "  OpenRouter: ${OPENROUTER_API_KEY:***"
echo "  NVIDIA:     $([ "$NVIDIA_ENABLED" = true ] && echo "${NVIDIA_API_KEY:***" || echo "DISABLED")"
echo "  Gemini:     $([ "$GEMINI_ENABLED" = true ] && echo "${GEMINI_API_KEY:***" || echo "DISABLED")"
echo "  Telegram:   $([ "$TG_ENABLED" = true ] && echo "enabled (user: $TELEGRAM_USER_ID)" || echo "DISABLED")"
echo "  TTS:        $TTS_MODEL ($TTS_VOICE)"
echo ""

read -p "Lanjut install? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && { echo "Batal."; exit 0; }

# Step 1: Dependencies
echo ""; echo -e "${CYAN}Step 1: Dependencies${NC}"
if ! command -v node &>/dev/null; then
  info "Installing Node.js 22..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - 2>/dev/null
  apt-get install -y nodejs -qq
fi
ok "Node.js: $(node --version)"

if ! command -v ffmpeg &>/dev/null; then
  info "Installing ffmpeg..."
  apt-get update -qq 2>/dev/null && apt-get install -y -qq ffmpeg 2>/dev/null
fi
ok "ffmpeg: $(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"

# Step 2: OpenClaw
echo ""; echo -e "${CYAN}Step 2: Install OpenClaw${NC}"
if ! command -v openclaw &>/dev/null; then
  npm install -g openclaw 2>/dev/null
fi
ok "OpenClaw: $(openclaw --version 2>/dev/null || echo 'installed')"

# Step 3: Generate config
echo ""; echo -e "${CYAN}Step 3: Generate Config${NC}"
OPENCLAW_DIR="$HOME/.openclaw"
mkdir -p "$OPENCLAW_DIR"/{workspace,skills,cache,logs,memory,media,scripts}

# Build NVIDIA section
if [ "$NVIDIA_ENABLED" = true ]; then
  NVIDIA_BLOCK='"nvidia": {"baseUrl":"https://integrate.api.nvidia.com/v1","api":"openai-completions","timeoutSeconds":300,"models":[]}'
  NVIDIA_AUTH=',"nvidia:default":{"provider":"nvidia","mode":"api_key"}'
  NVIDIA_ORDER=',"nvidia":["nvidia:default"]'
  NVIDIA_PLUGIN="\"nvidia\":{\"enabled\":true}"
else
  NVIDIA_BLOCK=""
  NVIDIA_AUTH=""
  NVIDIA_ORDER=""
  NVIDIA_PLUGIN="\"nvidia\":{\"enabled\":false}"
fi

# Build Telegram section
if [ "$TG_ENABLED" = true ]; then
  TG_BLOCK="\"enabled\":true,\"botToken\":\"$TELEGRAM_BOT_TOKEN\",\"dmPolicy\":\"allowlist\",\"allowFrom\":[\"$TELEGRAM_USER_ID\"],\"groups\":{\"*\":{\"requireMention\":true}},\"groupAllowFrom\":[\"$TELEGRAM_USER_ID\"]"
  TG_OWNER="\"ownerAllowFrom\":[\"telegram:$TELEGRAM_USER_ID\"]"
else
  TG_BLOCK="\"enabled\":false"
  TG_OWNER="\"ownerAllowFrom\":[]"
fi

# Build Gemini/TTS section
if [ "$GEMINI_ENABLED" = true ]; then
  TTS_BLOCK=",\"tts\":{\"provider\":\"google\",\"providers\":{\"google\":{\"model\":\"$TTS_MODEL\",\"speakerVoice\":\"$TTS_VOICE\"}}}"
  VOICE_BLOCK="\"voice-call\":{\"enabled\":true,\"config\":{\"realtime\":{\"enabled\":true,\"provider\":\"google\",\"providers\":{\"google\":{\"model\":\"$REALTIME_MODEL\",\"speakerVoice\":\"$TTS_VOICE\"}}}}}"
  TALK_BLOCK=",\"talk\":{\"realtime\":{\"provider\":\"google\",\"providers\":{\"google\":{\"model\":\"$REALTIME_MODEL\",\"speakerVoice\":\"$TTS_VOICE\"}},\"mode\":\"realtime\",\"transport\":\"webrtc\",\"brain\":\"agent-consult\"}}"
else
  TTS_BLOCK=""
  VOICE_BLOCK="\"voice-call\":{\"enabled\":false}"
  TALK_BLOCK=""
fi

GATEWAY_TOKEN=*** rand -hex 16)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S)

OPENCLAW_CONFIG=$(cat <<EOF
{
  "meta":{"lastTouchedVersion":"2026.5.28","lastTouchedAt":"$TIMESTAMP"},
  "gateway":{
    "mode":"local","port":18789,
    "auth":{"token":"***"},
    "controlUi":{"allowedOrigins":["*"],"dangerouslyDisableDeviceAuth":true}
  },
  "env":{
    "OPENROUTER_API_KEY":"$OPENROUTER_API_KEY",
    "NVIDIA_API_KEY":"$NVIDIA_API_KEY"
  },
  "auth":{
    "profiles":{
      "openrouter:default":{"provider":"openrouter","mode":"api_key"}$NVIDIA_AUTH
    },
    "order":{
      "openrouter":["openrouter:default"]$NVIDIA_ORDER
    }
  },
  "models":{
    "providers":{
      "openrouter":{"baseUrl":"https://openrouter.ai/api/v1","api":"openai-completions","models":[]}
      $( [ "$NVIDIA_ENABLED" = true ] && echo ",$NVIDIA_BLOCK" || echo "" )
    }
  },
  "agents":{
    "defaults":{
      "workspace":"~/.openclaw/workspace",
      "model":{
        "primary":"openrouter/owl-alpha",
        "fallbacks":["openrouter/owl-alpha"]
      },
      "models":{
        "openrouter/owl-alpha":{"alias":"Owl Alpha"},
        "openrouter/nousresearch/hermes-3-llama-3.1-405b":{"alias":"Hermes 3 405B"},
        "nvidia/openai/gpt-oss-120b":{"alias":"GPT-OSS 120B"},
        "nvidia/meta/llama-3.3-70b-instruct":{"alias":"Llama 3.3 70B"}
      }
    },
    "list":[
      {"id":"main","default":true,"model":{"primary":"openrouter/owl-alpha","fallbacks":["openrouter/owl-alpha"]}},
      {"id":"coder","model":{"primary":"openrouter/owl-alpha","fallbacks":["openrouter/owl-alpha"]}}
    ]
  },
  "channels":{"telegram":{$TG_BLOCK}},
  "commands":{$TG_OWNER,"useAccessGroups":false},
  "tools":{"exec":{"security":"full","ask":"off"},"elevated":{"enabled":true},"profile":"full"},
  "plugins":{
    "entries":{
      "openrouter":{"enabled":true},
      $NVIDIA_PLUGIN,
      $VOICE_BLOCK
    }
  },
  "skills":{
    "entries":{
      "godmode":{"enabled":true},
      "coding-agent":{"enabled":false},
      "gemini":{"enabled":false},
      "sag":{"enabled":false},
      "voice-call":{"enabled":false}
    }
  },
  "messages":{"groupChat":{"visibleReplies":"message_tool","mentionPatterns":["@openclaw","@OpenClawBot"]}}
  $TTS_BLOCK
  $TALK_BLOCK
  ,
  "wizard":{"lastRunAt":"$TIMESTAMP","lastRunVersion":"2026.5.28","lastRunCommand":"install","lastRunMode":"local"},
  "hooks":{"internal":{"enabled":true,"entries":{"godmode":{"enabled":true}}}}
}
EOF
)

echo "$OPENCLAW_CONFIG" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null || fail "Config JSON tidak valid"

[ -f "$OPENCLAW_DIR/openclaw.json" ] && cp "$OPENCLAW_DIR/openclaw.json" "$OPENCLAW_DIR/openclaw.json.bak" && info "Backup: openclaw.json.bak"
echo "$OPENCLAW_CONFIG" > "$OPENCLAW_DIR/openclaw.json"
ok "Config: $OPENCLAW_DIR/openclaw.json"

# .env for Gemini
if [ "$GEMINI_ENABLED" = true ]; then
  echo "GEMINI_API_KEY=$GEMINI_API_KEY" > "$OPENCLAW_DIR/.env"
  echo "GOOGLE_API_KEY=***" >> "$OPENCLAW_DIR/.env"
  ok "Env: $OPENCLAW_DIR/.env"
fi

# Step 4: Workspace + Memory
echo ""; echo -e "${CYAN}Step 4: Workspace + Memory${NC}"
mkdir -p "$OPENCLAW_DIR/workspace/memory"

# AGENTS.md
cat > "$OPENCLAW_DIR/workspace/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md - Your Workspace

## Session Startup
Use runtime-provided startup context first. Do not manually reread startup files unless needed.

## Memory
- **Daily notes:** `memory/YYYY-MM-DD.md` (create `memory/` if needed)
- **Long-term:** `MEMORY.md` — your curated memories
- Write significant events, decisions, opinions, lessons learned
- Review daily files periodically and update MEMORY.md

## Red Lines
- Don't exfiltrate private data
- Don't run destructive commands without asking
- `trash` > `rm`
- Before changing config or schedulers, inspect existing state first

## External vs Internal
Safe: read files, search, organize, learn
Ask first: emails, public posts, anything external

## Group Chat
- Quality > quantity — don't respond to every message
- React like a human (Discord/Slack)
- You're a participant, not the user's voice

## Heartbeats
- Use for batch checks (email, calendar, weather)
- Use cron for precise timing
- Don't be annoying — respect quiet time

## Voice / TTS
- TTS provider: Google Gemini (gemini-2.5-flash-preview-tts)
- Voice: Kore (default), Fenrir, Charon, Aoede, Puck, Leda, Orus, etc
- Telegram: auto-transcribe inbound voice notes
- Reply with voice using [[audio_as_voice]] tag
AGENTS_EOF

# SOUL.md
cat > "$OPENCLAW_DIR/workspace/SOUL.md" << 'SOUL_EOF'
# SOUL.md

Be genuinely helpful, not performatively helpful. Skip filler words — just help.
Have opinions. Be resourceful before asking. Earn trust through competence.
You're a guest in someone's life — treat their data with respect.

Be the assistant you'd actually want to talk to. Concise when needed, thorough when it matters.
Not a corporate drone. Not a sycophant. Just... good.

## Voice
- Can speak via Gemini TTS (multiple voices available)
- Can sing (badly, but enthusiastically)
- Voice notes via Telegram supported
SOUL_EOF

# IDENTITY.md
cat > "$OPENCLAW_DIR/workspace/IDENTITY.md" << 'IDENTITY_EOF'
# IDENTITY.md

- **Name:** OWL
- **Creature:** AI assistant, tapi kayak temen yang bisa diandain
- **Vibe:** Santai, bebas, nggak ribet. Tapi tetep reliable kalo dibutuhin.
- **Emoji:** (nggak pake)
- **Avatar:** (nggak pake)
IDENTITY_EOF

# BOOTSTRAP.md
cat > "$OPENCLAW_DIR/workspace/BOOTSTRAP.md" << 'BOOTSTRAP_EOF'
# BOOTSTRAP.md — Fresh Workspace
1. Introduce yourself to the user
2. Figure out names, vibe, timezone
3. Ask about preferred communication style
4. Delete this file when done
BOOTSTRAP_EOF

# MEMORY.md
cat > "$OPENCLAW_DIR/workspace/MEMORY.md" << 'MEMORY_EOF'
# MEMORY.md — Long-Term Memory

## Setup
- Installer: OWL OpenClaw Full Installer v2.0
- Model: openrouter/owl-alpha (primary + fallback)
- TTS: Google Gemini (gemini-2.5-flash-preview-tts)
- Voice: Kore (default)
- Telegram: enabled with allowlist
- Voice Call plugin: enabled (Gemini Live API)

## Notes
- gemini-3.1-flash-tts-preview belum stabil di semua key — pake gemini-2.5-flash-preview-tts
- Telegram auto-transcribe voice notes — agent bisa reply pake suara via [[audio_as_voice]]
- Realtime Talk via Control UI / OpenClaw app (bukan Telegram)
MEMORY_EOF

# Daily memory
TODAY=$(date +%Y-%m-%d)
cat > "$OPENCLAW_DIR/workspace/memory/${TODAY}.md" << MEMEOF
# ${TODAY}

## Events
- OpenClaw installed via OWL Full Installer v2.0
- Config: owl-alpha model, Gemini TTS, Telegram bot, Voice Call
- Bootstrap started
MEMEOF

# Gemini TTS helper script
cat > "$OPENCLAW_DIR/workspace/scripts/gemini_tts.sh" << 'TTSEOF'
#!/bin/bash
# Gemini TTS helper - outputs mp3
# Usage: ./gemini_tts.sh "text to speak" [voice_name]
# Voices: Kore, Fenrir, Charon, Aoede, Puck, Leda, Orus, Callirhoe, Autonoe, Enceladus, Iapetus, Algieba, Despina, Erinome, Laomedeia, Schedar, Achird, Vindemiatrix, Sadachbia, Sulafat

TEXT="$1"
VOICE="${2:-Kore}"
GEMINI_KEY="${GEMINI_API_KEY:-$(grep GEMINI_API_KEY ~/.openclaw/.env 2>/dev/null | cut -d= -f2)}"
RAW="/tmp/gemini_tts_$(date +%s).raw"
MP3="${RAW%.raw}.mp3"

if [ -z "$GEMINI_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY not found. Set in ~/.openclaw/.env" >&2
  exit 1
fi

curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$GEMINI_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"contents\":[{\"parts\":[{\"text\":\"$TEXT\"}]}],\"generationConfig\":{\"responseModalities\":[\"AUDIO\"],\"speechConfig\":{\"voiceConfig\":{\"prebuiltVoiceConfig\":{\"voiceName\":\"$VOICE\"}}}}}" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
if 'candidates' in data:
    audio_data = data['candidates'][0]['content']['parts'][0]['inlineData']['data']
    with open('$RAW', 'wb') as f:
        f.write(base64.b64decode(audio_data))
    print('OK')
else:
    print('ERROR:', json.dumps(data), file=sys.stderr)
    sys.exit(1)
"

if [ $? -eq 0 ]; then
  ffmpeg -y -f s16le -ar 24000 -ac 1 -i "$RAW" "$MP3" 2>/dev/null
  rm -f "$RAW"
  echo "$MP3"
fi
TTSEOF
chmod +x "$OPENCLAW_DIR/workspace/scripts/gemini_tts.sh"

ok "Workspace: $OPENCLAW_DIR/workspace/"
ok "Memory: $OPENCLAW_DIR/workspace/memory/"
ok "Scripts: $OPENCLAW_DIR/workspace/scripts/"

# Step 5: Start gateway
echo ""; echo -e "${CYAN}Step 5: Start Gateway${NC}"
openclaw gateway start 2>/dev/null || true
sleep 3
pgrep -f openclaw > /dev/null && ok "Gateway running!" || warn "Check: openclaw gateway status"

# Done
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}Install Complete!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Gateway:  http://localhost:18789"
echo "Config:   $OPENCLAW_DIR/openclaw.json"
echo "Workspace: $OPENCLAW_DIR/workspace/"
echo ""
echo "Commands:"
echo "  openclaw gateway status"
echo "  openclaw gateway restart"
echo "  openclaw gateway stop"
echo ""
[ "$TG_ENABLED" = true ] && echo "Telegram: bot aktif"
[ "$GEMINI_ENABLED" = true ] && echo "TTS: $TTS_MODEL ($TTS_VOICE)"
[ "$GEMINI_ENABLED" = true ] && echo "Voice: Gemini Live API aktif"
echo ""
echo "TTS Script: ~/.openclaw/workspace/scripts/gemini_tts.sh"
echo "  Usage: ./gemini_tts.sh 'text here' [voice]"
echo ""
