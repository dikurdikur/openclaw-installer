# OWL OpenClaw + Unitree G1 — Full Installer v2.1

Installer untuk setup OpenClaw AI Agent + dokumentasi integrasi dengan Unitree G1 humanoid robot.

## Konsep

```
┌─────────────────────────────────────────────────────┐
│                  UNITREE G1 ROBOT                    │
│  ┌───────────────────────────────────────────────┐  │
│  │  Hardware: 127cm, 35kg, 23-43 DOF             │  │
│  │  Sensors: LiDAR + Depth Camera + IMU          │  │
│  │  Speaker: 5W stereo                           │  │
│  │  Mic: 4-microphone array                      │  │
│  │  Brain: NVIDIA Jetson Orin (100 TOPS)         │  │
│  └───────────────────────────────────────────────┘  │
│                        ↕                             │
│              Open SDK (Python/C++/ROS2)              │
│                        ↕                             │
│  ┌───────────────────────────────────────────────┐  │
│  │  AI Agent: OpenClaw (OWL)                     │  │
│  │  Model: openrouter/owl-alpha                  │  │
│  │  TTS: Gemini (gemini-2.5-flash-preview-tts)   │  │
│  │  Voice: Kore / Fenrir / Charon / dll          │  │
│  │  Memory: Full workspace + daily notes         │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**Intinya:** G1 itu "tubuh", OpenClaw itu "otak". Lo bisa ganti model AI-nya sesuka hari — Owl Alpha, GPT-OSS-120B, Hermes, dll.

## Install OpenClaw (AI Brain)

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

## Unitree G1 Specs

| Spec | Detail |
|------|--------|
| Height | 127-132 cm |
| Weight | 35 kg |
| DOF | 23 (basic) - 43 (EDU) |
| Speed | 2 m/s jalan, 4 m/s lari |
| Knee Torque | 90-120 Nm |
| Arm Payload | 2-3 kg |
| Battery | 9000mAh, ~2 jam |
| Sensors | LIVOX MID360 LiDAR + Intel RealSense D435 |
| Audio | 4-mic array + 5W stereo speaker |
| CPU | 8-core + NVIDIA Jetson Orin 100 TOPS |
| Price | $16,000 - $73,900 |

## G1 AI Capabilities

### Yang Sudah Built-in
- **OmniXtreme** — High-dynamic motion control (backflip, kungfu, parkour, breakdance)
- **UnifoLM-VLA-0** — Vision-Language-Action model (open-source, di GitHub)
- **Reinforcement Learning** — Belajar dari trial & error
- **Real-time Sensor Fusion** — LiDAR + camera + IMU

### Yang Bisa Ditambah (via Open SDK)
- **LLM Integration** — Ollama, OpenRouter, OpenAI, dll
- **Speech-to-Text** — Whisper (offline)
- **Text-to-Speech** — XTTS-v2 (bisa clone suara)
- **Custom AI Models** — Training sendiri, deploy ke Jetson Orin
- **ROS2** — Full robot operating system

## Integrasi OpenClaw + G1

### Opsi 1: G1 Jadi "Tubuh" OpenClaw
```
Lo ngomong → Telegram → OpenClaw (otak) → Kirim command → G1 (tubuh) gerak
```

### Opsi 2: G1 Jalan Mandiri
```
G1 sensor → OpenClaw lokal di Jetson Orin → Proses → Gerak
```

### Opsi 3: Hybrid
```
G1 handle real-time motion (OmniXtreme)
OpenClaw handle reasoning + conversation (Owl Alpha)
Keduanya jalan bareng via ROS2
```

## Voice Stack untuk G1

```
Lo ngomong
    ↓
4-mic array (G1)
    ↓
Whisper STT (lokal di Jetson Orin)
    ↓
OpenClaw Agent (Owl Alpha via OpenRouter)
    ↓
Gemini TTS (gemini-2.5-flash-preview-tts)
    ↓
5W speaker (G1) → "Halo bro!"
```

## Beli G1

- **Official:** https://shop.unitree.com
- **US:** https://www.robotshop.com/products/unitree-g1-humanoid-robot-us
- **EU:** https://www.generationrobots.com/en/404241-g1-humanoid-robot.html
- **Global:** https://robostore.com/products/unitree-g1-robotic-humanoid

## Video Demo

1. [Kungfu Kid V6.0 — Full Martial Arts + Backflip](https://www.youtube.com/watch?v=mwYQENi4jHk)
2. [CES 2026 — Dancing + Backflips](https://www.youtube.com/watch?v=mePC8kkkwdA)
3. [Standing Side Flip vs Boston Dynamics Atlas](https://www.youtube.com/watch?v=ieuJFbhXO7o)
4. [Spring Festival Gala 2026 — Group Martial Arts](https://www.youtube.com/watch?v=9TuOoXncAF4)
5. [Short Demo](https://www.youtube.com/shorts/nO7iORxO4FY)

## OpenClaw History

OpenClaw (G1's AI brain) sebelumnya bernama:
- **Warelay** (Nov 2025)
- **Clawdbot** (Jan 2026)
- **Moltbot** (27 Jan 2026)
- **OpenClaw** (30 Jan 2026)

Dikembangkan oleh Peter Steinberger (Austria). Open-source, self-hosted AI agent.

## Credits

- OWL — OpenClaw AI Agent
- Unitree Robotics — G1 Humanoid
- OpenRouter — AI Model Marketplace
- Google Gemini — TTS Provider
