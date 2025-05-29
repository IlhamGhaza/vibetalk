# VibeTalk

**VibeTalk** is a modern, cross-platform real-time chat application built with Flutter. It provides seamless communication across Android, iOS, Web, and Desktop platforms with Firebase integration for reliable backend services.

## 🚀 Features

- **Real-Time Messaging**: Instant message delivery with live synchronization
- **Cross-Platform Support**: Native performance on Android, iOS, Web, Windows, macOS, and Linux
- **User Authentication**: Secure email/password authentication system
- **Image Sharing**: Send and receive images through camera or gallery
- **Multi-Language Support**: Available in English, Indonesian, and Korean
- **Theme Customization**: Light and dark theme options
- **Profile Management**: Complete user profile editing capabilities
- **Firebase Integration**: Robust backend with Firestore, Authentication, and Storage

## 📋 Prerequisites

Before setting up VibeTalk, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher) - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Development Environment**:
  - [Android Studio](https://developer.android.com/studio) with Flutter and Dart plugins, OR
  - [Visual Studio Code](https://code.visualstudio.com/) with Flutter and Dart extensions
- **Platform-specific requirements**:
  - **Android**: Android SDK (API level 21 or higher)
  - **iOS**: Xcode 12.0 or higher (macOS only)
  - **Web**: Chrome browser for testing
  - **Desktop**: Platform-specific build tools

## 🛠️ Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/IlhamGhaza/vibetalk.git
cd vibetalk
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

VibeTalk requires Firebase for backend services. You have two options:

#### Option A: Use Test Account (Quick Start)
Skip Firebase setup and use the provided test credentials:
- **Email**: `ilham@admin.com`
- **Password**: `123456L@`

#### Option B: Setup Your Own Firebase Project
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Authentication (Email/Password)
   - Firestore Database
   - Storage
3. Download and place configuration files:
   - **Android**: Place `google-services.json` in `android/app/`
   - **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`
   - **Web**: Configure Firebase settings in `web/index.html`

### 4. Verify Installation

```bash
flutter doctor
```

Ensure all checkmarks are green for your target platforms.

## 🚀 Running the Application

### Check Available Devices

```bash
flutter devices
```

### Android

**Emulator:**
```bash
flutter run
```

**Physical Device:**
1. Enable Developer Options and USB Debugging
2. Connect device via USB
3. Run: `flutter run`

### iOS (macOS only)

**Simulator:**
```bash
flutter run -d ios
```

**Physical Device:**
1. Connect iPhone/iPad via USB
2. Trust the computer on device
3. Run: `flutter run -d ios`

### Web

```bash
flutter run -d chrome
```

**Alternative browsers:**
```bash
flutter run -d web-server --web-port=8080
```

### Desktop

**Enable desktop support (one-time setup):**
```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop  
flutter config --enable-linux-desktop
```

**Run on specific platforms:**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 🏗️ Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

**Automated Build Script:**
For Windows users, run the included batch script:
```bash
build_all.bat
```

## 📁 Project Structure

```
lib/
├── core/                 # Core utilities and themes
├── data/                 # Data layer (models, datasources)
├── presentation/         # UI layer (pages, widgets)
│   ├── auth/            # Authentication screens
│   ├── chat/            # Chat functionality
│   ├── conversation/    # Conversation list
│   └── profile/         # User profile management
├── assets/              # Images, fonts, and other assets
└── test/                # Unit and widget tests
```

## 🧪 Testing

**Run all tests:**
```bash
flutter test
```

**Run with coverage:**
```bash
flutter test --coverage
```

## 🌐 Supported Platforms

| Platform | Minimum Version | Status   |
| -------- | --------------- | -------- |
| Android  | API 21 (5.0)    | ✅ Stable |
| iOS      | iOS 11.0        | ✅ Stable |
| Web      | Modern browsers | ✅ Stable |
| Windows  | Windows 10      | ✅ Stable |
| macOS    | macOS 10.14     | ✅ Stable |
| Linux    | Ubuntu 18.04+   | ✅ Stable |

## 🔧 Troubleshooting

### Common Issues

**1. Firebase Configuration Error**
- Ensure configuration files are in correct directories
- Verify Firebase project settings match your app

**2. Build Failures**
- Run `flutter clean && flutter pub get`
- Check Flutter and Dart SDK versions
- Verify platform-specific requirements

**3. Permission Issues (Mobile)**
- Camera and storage permissions are handled automatically
- Check device settings if issues persist

**4. Web CORS Issues**
- Use `flutter run -d chrome --web-renderer html` for compatibility

### Getting Help

- Check [Flutter Documentation](https://flutter.dev/docs)
- Review [Firebase Documentation](https://firebase.google.com/docs)
- Open an issue on this repository

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ilham Ghaza**
- GitHub: [@IlhamGhaza](https://github.com/IlhamGhaza)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for reliable backend services
- Contributors and testers

---

**Note**: This application is for educational and demonstration purposes. For production use, implement additional security measures and follow platform-specific guidelines.
