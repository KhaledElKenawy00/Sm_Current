# 🖥️ Flutter SM Current App (Desktop)

A cross-platform **Flutter Desktop App** for user authentication using **SQLite (with FFI)**. This app demonstrates local sign-in and registration functionality, user profile display, and simple UI logic for login validation—all built with **MVP**.

---

## 🚀 Features

- 📦 Local user authentication with SQLite (using `sqflite_common_ffi`)
- 🔒 Login with validation
- 📝 Sign-up with unique username constraint
- 👤 Profile screen showing full user details
- ❌ Error message on failed login
- ✅ Stateless profile screen with navigation
- 🎯 Clean code architecture (split into SQLite, JSON, Components, Views)

---

## 📸 Preview

<p align="center">
  <img src="assets/Screenshot 2025-05-29 211224.png" alt="Login Screen" width="50%" style="margin-right: 10px;" />
  <img src="assets/Screenshot 2025-05-29 211250.png" alt="Profile Screen" width="50%" style="margin: 0 10px;" />
</p>

---

## 📁 Folder Structure

lib/
├── Components/ # Reusable UI components
│ ├── button.dart # Custom styled button
│ ├── colors.dart # App-wide color constants
│ └── textfield.dart # Custom styled input field
│
├── JSON/ # Model classes
│ └── users.dart # User model with serialization
│
├── SQLite/ # Local SQLite database logic
│ └── database_helper.dart # SQLite DB operations (insert, get, authenticate)
│
├── Views/ # App screens and pages
│ ├── login.dart # Login screen UI and logic
│ └── profile.dart # Profile screen UI
│
└── main.dart # App entry pointv


---

## 🛠️ Getting Started

### 1. Clone the repository

```bash
git https://github.com/KhaledElKenawy00/Sm_Current

cd Sm_Current

