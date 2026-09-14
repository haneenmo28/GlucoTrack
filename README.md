# GlucoTrack — Diabetes Self-Management App 🩸

<p align="center">
  <a href="Download GlucoTrack APK">
    <img src="https://img.shields.io/badge/Download-APK%20Direct-brightgreen?style=for-the-badge&logo=android" alt="Download APK" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey?style=for-the-badge" alt="Platform" />
  <img src="https://img.shields.io/badge/Status-Active%20Development-orange?style=for-the-badge" alt="Project Status" />
</p>

---

## 📱 About

**GlucoTrack** is a cross-platform diabetes self-management application built with **Flutter and Dart**.

The application is designed to help patients record, monitor, and analyze their blood glucose data while providing a dedicated experience for caregivers to stay connected with patients.

GlucoTrack supports two primary user roles:

* 🩸 **Patient**
* 👤 **Caregiver**

Each role has its own profile, personalized content, and role-specific functionality.

> 🚧 **GlucoTrack is actively under development.**
> The application already includes a functional set of core features, while additional features and improvements are continuously being developed.

GlucoTrack is an **independently designed and developed project**, built from the ground up as a practical Flutter application.

---

## ✨ Features

### 🔐 Authentication & Profiles

* User **Sign Up & Login**
* Dedicated **Patient Profile**
* Dedicated **Caregiver Profile**
* Personal information
* Health information
* Role-based application experience

---

### 👥 Patient–Caregiver Connection

GlucoTrack includes a dedicated system for connecting patients with caregivers.

* Connect a patient with a caregiver using a **unique connection code**
* Connect using a **QR Code**
* Caregivers can access information from connected patients
* Patients can manage their caregiver connection
* Patients can **disconnect from their caregiver at any time**
* Role-based access to patient information

---

### 🩸 Blood Glucose Tracking

Patients can record and manage their blood glucose readings.

* Add blood glucose readings
* Categorize readings according to their context
* Different reading types, including:

  * Before meals
  * After meals
  * Other supported reading types
* Store historical readings
* Review previous measurements
* Monitor glucose trends over time

---

### 📊 Analysis & Data Visualization

GlucoTrack provides visual and analytical tools to help users understand their recorded glucose data.

* Interactive glucose charts
* Historical data visualization
* Reading analysis
* Glucose trends
* Goal monitoring
* Visual summaries of recorded data

---

### 🎯 Goals

Patients can set and monitor personal glucose-related goals.

The application helps users follow their progress and keep track of their recorded readings in relation to their goals.

---

### 📄 Patient Reports & PDF Export

GlucoTrack provides a comprehensive patient report containing relevant recorded information.

Reports can be viewed by:

* The Patient
* The connected Caregiver

The application can also generate a **PDF report** containing organized patient and glucose information, making it easier to share relevant information during medical consultations.

---

### 🔔 Notifications

The application includes notifications designed to help users stay engaged with their tracking and daily health-management activities.

---

### 💡 Role-Based Tips

GlucoTrack includes a dynamic **Tips Box** on the home screen.

The tips are customized according to the user's role.

#### 🩸 Patient Tips

Patients receive tips related to diabetes self-management and their daily use of the application.

#### 👤 Caregiver Tips

Caregivers receive tips relevant to their role and supporting connected patients.

The application currently includes **50+ tips for each role**.

Tips are dynamic:

* A different tip can be displayed when the application is opened
* Users can tap the Tips Box to display another tip
* Tips are selected according to the user's role

---

### 🌙 Personalization & UI

* Dark Mode
* Light Mode
* Role-specific home screens
* Role-specific content
* Dynamic content
* Responsive UI
* User-focused interface

---

### 🌍 Localization

GlucoTrack supports:

* 🇬🇧 English
* 🇪🇬 Egyptian Arabic

The application is designed to provide a more accessible experience for users through localized content and interface elements.

---

## 💾 Data & Backend

### ☁️ Firebase

GlucoTrack integrates **Firebase** as part of its backend infrastructure for cloud-based functionality and data management.

### 💾 Local / Offline Storage

The application also uses local storage to support data persistence and allow important functionality to remain available when an internet connection is unavailable.

---

## 🛠️ Tech Stack

| Technology            | Usage                                  |
| --------------------- | -------------------------------------- |
| **Flutter**           | Cross-platform application development |
| **Dart**              | Application programming language       |
| **Firebase**          | Backend and cloud services             |
| **fl_chart**          | Data visualization and charts          |
| **easy_localization** | Localization and multilingual support  |
| **Local Storage**     | Offline/local data persistence         |
| **Git & GitHub**      | Version control and project management |
| **VS Code**           | Development environment                |

---

## 🧠 Technical Highlights

Developing GlucoTrack has provided practical experience in:

* Flutter application development
* Dart programming
* Authentication flows
* Multiple user roles
* Role-based UI and application logic
* Patient–caregiver relationship management
* QR code-based account connection
* Form handling and validation
* Local data persistence
* Firebase integration
* Data visualization
* PDF report generation
* Notifications
* Dynamic content
* Dark and light themes
* Localization
* Git & GitHub
* Cross-platform development

---

## 📂 Project Structure

```text
GlucoTrack/
├── android/
├── assets/
├── lib/
├── windows/
├── firebase.json
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

The main Flutter application code is located inside the `lib/` directory.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

* Flutter SDK
* Dart SDK
* Android Studio or another supported Flutter development environment
* Git

### Installation

1. Clone the repository:

```bash
git clone https://github.com/haneenmo28/GlucoTrack.git
```

2. Navigate to the project directory:

```bash
cd GlucoTrack
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

> **Note:** Firebase configuration may be required to run all backend-dependent functionality locally.

---

## 📦 APK

You can download and test the latest available Android APK directly:

<p align="center">
  <a href="https://github.com/haneenmo28/GlucoTrack/releases/download/v1.0.0-beta/app-release.apk">
    <img src="https://img.shields.io/badge/Download%20GlucoTrack%20APK-brightgreen?style=for-the-badge&logo=android" alt="Download GlucoTrack APK" />
  </a>
</p>

---

## 🚧 Roadmap

GlucoTrack is an actively developing project, and several new features are planned.

### 🤖 AI-Powered Meal Scanner

A planned AI-powered feature designed to help patients analyze their meals and receive personalized guidance.

Planned capabilities include:

* 📷 Meal scanning
* 🍽️ Food recognition
* 📊 Meal information analysis
* 🧠 AI-powered insights
* 🩸 Personalized guidance based on the patient's available health data

The goal is to provide patients with more personalized assistance when making food-related decisions.

> AI-generated guidance will be designed as supportive information and will not replace professional medical or nutritional advice.

---

### 👤 Expanded Caregiver Experience

The Caregiver side of GlucoTrack is still being actively expanded.

Planned improvements include:

* Enhanced caregiver dashboard
* More detailed patient monitoring
* Improved patient overview
* Additional caregiver-focused tools
* Improved interaction with patient reports and glucose data

---

### 📊 Advanced Analytics

Future development may include:

* More advanced glucose analysis
* Additional visualization options
* Improved goal tracking
* More personalized insights

---

### 🔔 Smarter Notifications

Future versions may include more personalized and context-aware notifications based on user activity and recorded data.

---

## 🎯 Project Goals

GlucoTrack aims to go beyond a basic glucose-tracking application by combining:

* 🩸 Blood glucose tracking
* 📊 Data visualization
* 👥 Patient–caregiver connectivity
* 🎯 Goal monitoring
* 📄 Structured reporting
* 📑 PDF generation
* 💾 Offline data handling
* ☁️ Firebase-backed functionality
* 💡 Role-based personalized content
* 🤖 Future AI-powered assistance

into one cross-platform application.

---

## 👩‍💻 About the Developer

**Haneen Mostafa**
Computer Science Student & Flutter Developer

GlucoTrack is an independently developed project that I designed and built using **Flutter and Dart**, with a focus on practical application development, user experience, data management, localization, and continuous feature development.

The project is continuously evolving as I explore and implement new technologies and ideas.

### 🔗 GitHub

https://github.com/haneenmo28

### 📌 Project Repository

https://github.com/haneenmo28/GlucoTrack

---

## ⚠️ Disclaimer

GlucoTrack is a personal software development project created for educational and portfolio purposes.

It is **not a medical device** and should not be considered a replacement for professional medical advice, diagnosis, or treatment.

---

## 📄 License

This project is developed for educational and portfolio purposes.
