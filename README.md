# EduPulse AI 🎓⚡
### An Advanced Student Result Analysis & Devin AI Diagnosis System

**EduPulse AI** is a production-quality, responsive, and aesthetically stunning Web & Mobile application built with Flutter & Dart. It provides students and academic evaluators with dynamic GPA/CGPA computation, realistic AI-driven exam script analysis with step-by-step penalty diagnostics, and personalized study routine generation.

The application is **100% self-contained**, running standalone with zero external server dependencies, and persists all sessions, transcripts, AI diagnoses, and study habits locally using `shared_preferences`.

---

## 🚀 Key Modules & Capabilities

### 1. 🎨 Modern Clean Educational Dashboard Theme
- **Palette**: Deep Slate (`#0A0E1A`), Electric Indigo (`#6366F1`), and Vibrant Cyan/Teal (`#14B8A6`, `#2DD4BF`).
- **Glassmorphism**: Frosted glass containers (`BackdropFilter` with blur, 1px glowing gradient borders, 16px corner radius).
- **Responsive Layout**: Desktop web multi-column view with sidebar navigation; seamless transition to bottom navigation on tablet and mobile viewports.

### 2. 🔐 Authentication & Quick Demo Bypass
- Complete Login and Student Registration forms with field validation.
- **Quick Demo Bypass**: Pre-fills or accepts exact demo credentials:
  * **Username**: `test`
  * **Password**: `test`
  * **1-Click Demo Login button** for immediate presentation access.
- Local session persistence: stays logged in across browser reloads or app restarts until explicitly signed out.

### 3. 📊 Module 1: Dynamic GPA & CGPA Engine
- **Semester Management**: Dynamically add, edit, or delete multiple semesters.
- **Subject Management**: Dynamically add, edit, or delete subjects per semester:
  * Subject Name & Code (e.g. `MATH-102 Multivariable Calculus`)
  * Credit Hours (`1.0`, `1.5`, `2.0`, `3.0`, `4.0`)
  * Full Marks & Obtained Marks
- **Automatic Calculations**:
  * Letter Grades (`A+`, `A`, `A-`, `B+`, `B`, `B-`, `C+`, `C`, `D`, `F`)
  * Grade Points (`4.00`, `3.75`, `3.50`, `3.25`, `3.00`, etc.)
  * Semester GPA: `Σ(Credit × Grade Point) / Σ(Total Credits)`
  * Cumulative CGPA: `Σ(Credit × Grade Point across all semesters) / Σ(All Credits)`
  * Academic Standing (`Summa Cum Laude Track`, `Dean's Honor List Track`, etc.)
  * Interactive **GPA Performance Trajectory line chart** (`fl_chart`).
- All entries are saved locally in real time.

### 4. 🧠 Module 2: Devin AI Script & Question Evaluation (Simulation)
- **Image Inputs**:
  * Upload custom Question Paper & Student Khata Answer Script via `file_picker` (supports PNG, JPG, PDF).
  * Or choose from 3 built-in realistic university presets (`MATH-102 Calculus`, `CSE-301 Algorithm Complexity`, `ECE-205 Digital Logic`).
- **Realistic 3-Phase Scanning Engine**:
  * **Phase 1**: *"Scanning handwriting & formulas..."* (0% - 35%)
  * **Phase 2**: *"Matching against question scoring rubric..."* (35% - 70%)
  * **Phase 3**: *"Generating gap diagnosis & step penalty breakdown..."* (70% - 100%)
- **Diagnostic Result Dashboard**:
  * Overall accuracy score (e.g. `77.0%`, `38.5 / 50 Marks`)
  * **Interactive Visual Script Inspector**: Authentically rendered student handwritten khata sheet with coordinate-mapped penalty bounding boxes.
  * **Penalty Pinpoints List**: Click any deduction to highlight the exact step and error on the script canvas.
  * **Weak Areas Breakdown**: Topic, issue description, severity tag (`Critical`, `Moderate`), and actionable remediation.
  * **Devin AI +15% Mark Recovery Roadmap**: Strategic rubric guidelines to recoup partial points on upcoming exams.
  * 1-Click **"Export to Routine Builder"** button.

### 5. ⏱️ Module 3: Devin AI Personalized Study Routine Builder
- **Intake Form**:
  * Weakest subjects (auto-suggested from GPA Engine or diagnostic evaluations).
  * Available daily study hours (`2 hrs`, `3 hrs`, `4 hrs`, `6 hrs`).
  * Target exam date & goal CGPA slider (`3.00` to `4.00`).
- **AI Routine Output**:
  * Structured daily & weekly timetable with **50-minute Pomodoro study slots**.
  * **Ebbinghaus Spaced Repetition Schedule** (Day 1 Encoding, Day 3 Rapid Recall, Day 7 Timed Problem Drill, Day 14 Exam Synthesis) with predicted memory retention rates.
  * Actionable study tips tailored directly to diagnosed exam mistakes.
  * Interactive daily study checklist: toggle slots completed, saved locally with active streak tracking.

### 6. ⚡ 1-Click "Load Sample Data" Button
- Always accessible from the top navigation bar and GPA Engine header.
- Instantly populates:
  * 3 Engineering Semesters with 12 graded subjects (Calculus, Data Structures, Algorithms, OS, DBMS, Digital Logic)
  * CGPA `3.79 / 4.00`
  * Complete Devin AI Calculus evaluation with 3 penalty pinpoints
  * Active 4-slot daily Pomodoro schedule with spaced repetition dates.

---

## 🛠️ Code Structure

```text
lib/
├── main.dart                                 # App entry point, MultiProvider & MaterialApp
├── theme/
│   └── app_theme.dart                        # Slate/Indigo/Teal palette, typography, frosted glass tokens
├── models/
│   ├── user_model.dart                       # Student profile & demo auth model
│   ├── subject.dart                          # Subject schema with credit, marks, grade, & point
│   ├── semester.dart                         # Semester schema with subjects, GPA, & credits
│   ├── evaluation.dart                       # Devin AI evaluation, pinpoints, & weak areas
│   └── routine.dart                          # Pomodoro slots, spaced repetition items, & daily progress
├── services/
│   ├── storage_service.dart                  # SharedPreferences local persistence engine
│   ├── calculation_service.dart              # University GPA/CGPA math & grading rules
│   └── devin_ai_service.dart                 # 3-phase scanning simulator & exam presets
├── providers/
│   ├── auth_provider.dart                    # Session & quick demo bypass state
│   ├── gpa_provider.dart                     # Semesters/subjects CRUD & live calculations
│   ├── evaluation_provider.dart              # Script scanning & pinpoint selection state
│   └── routine_provider.dart                 # Intake state & Pomodoro checklist controller
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart                 # Login with Quick Demo Bypass
│   │   └── signup_screen.dart                # Student registration form
│   ├── shell/
│   │   └── main_shell_screen.dart            # Responsive sidebar & mobile bottom nav shell
│   ├── dashboard/
│   │   └── dashboard_screen.dart             # Executive KPI metrics, chart & quick actions
│   ├── calculator/
│   │   ├── gpa_calculator_screen.dart        # Semester manager & subject data table
│   │   └── widgets/
│   │       ├── cgpa_chart.dart               # Bezier line trajectory chart
│   │       ├── semester_card.dart            # Semester accordion with subjects
│   │       └── subject_dialog.dart           # Add/Edit subject modal with live grade preview
│   ├── devin_ai_eval/
│   │   ├── devin_ai_eval_screen.dart         # Script evaluator & diagnostic dashboard
│   │   └── widgets/
│   │       ├── script_inspector.dart         # Canvas-rendered handwritten khata & overlays
│   │       ├── scan_progress_dialog.dart     # 3-phase animated radar scanner
│   │       └── penalty_chip.dart             # Severity-colored deduction cards
│   └── routine/
│       ├── routine_screen.dart               # Pomodoro timetable & spaced repetition
│       └── widgets/
│           ├── pomodoro_slot_tile.dart       # Interactive Pomodoro task tile
│           └── spaced_repetition_card.dart   # Memory curve review card
└── widgets/
    ├── glass_container.dart                  # BackdropFilter frosted glass component
    ├── stat_card.dart                        # KPI telemetry card with glowing accents
    ├── grade_badge.dart                      # Color-coded university grade pill
    ├── pulse_button.dart                     # Gradient pulse action button
    └── empty_state.dart                      # High-fidelity empty state indicator
```

---

## 🏃 Quick Start Guide

### Prerequisites
- Flutter SDK 3.x+ (installed in `C:\flutter\bin` or on your system PATH)
- Google Chrome (for Web) or Windows desktop developer support

### Run locally on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Windows Desktop
```bash
flutter run -d windows
```

### Run Tests
```bash
flutter test
```

### Build Web Release
```bash
flutter build web --release
```

---

## 📝 Demo Credentials
- **Username**: `test`
- **Password**: `test`
*(Or simply tap the **"1-Click Sign In"** button on the login screen).*
