# VibeTalk

**VibeTalk** is a cross-platform chat application built with Flutter, supporting Android, iOS, Web, and Desktop platforms. It integrates with Firebase for real-time data synchronization and user authentication.

## Features

* **User Authentication**: Sign up and log in using email and password.
* **Real-Time Messaging**: Exchange messages instantly with other users.
* **Cross-Platform Support**: Compatible with Android, iOS, Web, Windows, macOS, and Linux.
* **Firebase Integration**: Utilizes Firebase services for backend functionalities.

## Prerequisites

Before setting up the project, ensure you have the following installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with Flutter and Dart plugins
* [Firebase CLI](https://firebase.google.com/docs/cli) (optional, for advanced Firebase configurations)

## Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/IlhamGhaza/vibetalk.git
   cd vibetalk
   ```

2. **Install Dependencies**

   Fetch the required packages:

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   Ensure you have the appropriate Firebase configuration files:

   * **Android**: Place `google-services.json` in `android/app/`.
   * **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`.
   * **Web**: Configure Firebase settings in `web/index.html` or use `firebase.json`.

   If you don't have these files, you can use the provided test account credentials below to log in.

## Running the Application

### Android / iOS

Ensure a simulator or physical device is connected, then run:

```bash
flutter run
```

### Web

To run the application in a web browser:

```bash
flutter run -d chrome
```

### Desktop (Windows/macOS/Linux)

Enable desktop support:

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

Then run:

```bash
flutter run -d windows  # Replace 'windows' with 'macos' or 'linux' as appropriate
```

## Test Account Credentials

You can log in using the following test account:

* **Email**: `ilham@admin.com`
* **Password**: `123456L@`

Alternatively, you can register a new account through the application's sign-up feature.

## Project Structure

* `lib/`: Main application source code.
* `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`: Platform-specific configurations.
* `assets/`: Contains images, fonts, and other assets.
* `test/`: Unit and widget tests.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the [MIT License](LICENSE).
