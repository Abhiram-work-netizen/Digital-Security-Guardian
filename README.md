# 🛡️ Digital Literacy Guardian

> A **privacy-first digital safety assistant** that monitors real digital behavior, detects threats, and teaches secure online habits — all from your pocket.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-4.x-000000?logo=express&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📖 Overview

**Digital Literacy Guardian (DLG)** is a mobile application built with **Flutter** and powered by a **Node.js/Express** backend. It helps users stay safe online through:

- **Real-time link & file scanning** against malware databases
- **Phishing text analysis** using pattern-matching heuristics
- **Digital literacy scores** and weekly behavioral insights
- **Interactive lessons, quizzes, and gamified achievements**
- **Notification monitoring** to flag suspicious alerts on-device

The entire experience is designed to be educational, giving users not just warnings but understanding of *why* something is risky.

---

## ✨ Features

### 🔗 Link Scanner
Multi-layer threat analysis for any URL:
| Layer | Engine | API Key Required? |
|-------|--------|:-:|
| 1 | Smart Heuristic Analysis (typosquatting, leetspeak, TLD, etc.) | ❌ |
| 2 | URLhaus — abuse.ch malware database | ❌ |
| 3 | DNS Resolution Check | ❌ |
| 4 | VirusTotal | ✅ (free) |
| 5 | Google Safe Browsing | ✅ (free) |

### 📄 File Scanner
Upload any file for analysis — checks file-type risk, SHA-256 hash against URLhaus, and optional VirusTotal lookup.

### 📝 Text Phishing Analyzer
Paste a suspicious message and get an instant risk breakdown detecting urgency tactics, credential phishing, fake rewards, fear-based language, and more.

### 📊 Digital Literacy Score
A composite score calculated from your alert history, quiz performance, and completed lessons — with weekly insights and trends.

### 🎮 Gamification
Unlock achievements and track progress through learning milestones.

### 🔔 Smart Notification Analyzer
On-device analysis of incoming notifications to identify potentially harmful or phishing content.

### 🎓 Learning Hub
Curated lessons, tips, and interactive quizzes covering topics like password safety, social engineering, and privacy best practices.

### 🔒 Privacy Panel
Review and manage document verification and privacy-related settings.

---

## 🏗️ Architecture

```
digital_literacy_guardian/
├── lib/                          # Flutter app source
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # MaterialApp & routing
│   ├── data/                     # Local storage (Hive)
│   ├── models/                   # Data models
│   │   ├── achievement.dart
│   │   ├── learning_models.dart
│   │   ├── literacy_score.dart
│   │   ├── risk_alert.dart
│   │   ├── safety_tip.dart
│   │   ├── test_models.dart
│   │   └── weekly_insight.dart
│   ├── providers/                # State management (Provider)
│   │   ├── alert_provider.dart
│   │   ├── gamification_provider.dart
│   │   ├── insight_provider.dart
│   │   ├── learning_provider.dart
│   │   ├── score_provider.dart
│   │   └── tests_provider.dart
│   ├── services/                 # Business logic & APIs
│   │   ├── api_service.dart
│   │   ├── insight_generator.dart
│   │   ├── link_checker.dart
│   │   ├── notification_analyzer.dart
│   │   ├── notification_service.dart
│   │   ├── scoring_engine.dart
│   │   └── tips_repository.dart
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart
│   │   ├── link_checker_screen.dart
│   │   ├── document_verify_screen.dart
│   │   ├── alerts_screen.dart
│   │   ├── insights_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── tests_screen.dart
│   │   ├── tips_screen.dart
│   │   ├── lesson_viewer_screen.dart
│   │   ├── privacy_panel_screen.dart
│   │   ├── permission_screen.dart
│   │   └── onboarding_screen.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── animated_navigation_bar.dart
│   │   ├── gradient_background.dart
│   │   ├── insight_chart.dart
│   │   ├── interactive_labs.dart
│   │   ├── risk_alert_card.dart
│   │   ├── scale_tap.dart
│   │   ├── score_gauge.dart
│   │   └── tip_card.dart
│   └── utils/                    # Theme & constants
│       ├── app_theme.dart
│       └── constants.dart
├── backend/                      # Node.js API server
│   ├── src/main.js               # Express server & all endpoints
│   ├── package.json
│   └── .env.example              # Environment variable template
├── assets/                       # App assets (icons, images)
└── pubspec.yaml                  # Flutter dependencies
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.10 |
| Dart SDK | ≥ 3.10 |
| Node.js | ≥ 18 |
| npm | ≥ 9 |
| Android Studio / VS Code | Latest |

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/digital-literacy-guardian.git
cd digital-literacy-guardian
```

### 2. Set Up the Backend

```bash
cd backend
cp .env.example .env       # Edit .env with your API keys (optional)
npm install
npm start                  # Starts on http://localhost:3000
```

> **Note:** The backend works out-of-the-box without any API keys — three scanning engines (Heuristics, URLhaus, DNS) are free and keyless. Add VirusTotal and Google Safe Browsing keys for enhanced detection.

### 3. Set Up the Flutter App

```bash
# From the project root
flutter pub get
flutter run
```

---

## ⚙️ Environment Variables

Create a `backend/.env` file from the template:

| Variable | Description | Required? |
|----------|-------------|:-:|
| `PORT` | Server port (default: `3000`) | ❌ |
| `VIRUSTOTAL_API_KEY` | [VirusTotal](https://www.virustotal.com/gui/join-us) API key | ❌ |
| `GOOGLE_SAFE_BROWSING_KEY` | [Google Safe Browsing](https://developers.google.com/safe-browsing) API key | ❌ |

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/scan/link` | Multi-layer URL threat scan |
| `POST` | `/scan/file` | File upload & hash analysis |
| `POST` | `/scan/text` | Phishing text pattern detection |
| `GET`  | `/health` | Server status & engine availability |

### Example — Scan a Link

```bash
curl -X POST http://localhost:3000/scan/link \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

---

## 🧰 Tech Stack

### Frontend (Mobile)
- **Flutter** — Cross-platform UI framework
- **Provider** — State management
- **Hive** — Lightweight local storage
- **fl_chart** — Interactive data visualizations
- **flutter_local_notifications** — On-device notification handling
- **Google Fonts** — Modern typography

### Backend (API)
- **Node.js + Express** — REST API server
- **Helmet** — HTTP security headers
- **express-rate-limit** — Request throttling (30 req/min)
- **Multer** — File upload handling
- **URLhaus API** — Real-world malware URL database
- **VirusTotal API** — Comprehensive file & URL scanning
- **Google Safe Browsing API** — Browser-level threat detection

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ to make the internet safer for everyone.
</p>
