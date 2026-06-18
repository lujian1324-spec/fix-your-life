# Sierro Flutter App

Flutter implementation for the Sierro energy storage monitoring app. The UI follows the provided `Sierro_Handoff` dark theme and keeps the copy in English.

## Environment

- Flutter 3.44.x
- Dart 3.12.x
- Android Studio with Android SDK
- Android SDK Platform 35 or newer
- Android SDK Build-Tools 36
- Android NDK `28.2.13676358`

Windows can build and run Android. iOS source is included, but iOS builds require Xcode on macOS.

## Run

```powershell
flutter pub get
flutter run
```

If Flutter is not in PATH on this machine:

```powershell
& 'C:\Users\Administrator\scoop\apps\flutter\current\bin\flutter.bat' pub get
& 'C:\Users\Administrator\scoop\apps\flutter\current\bin\flutter.bat' run
```

## Build Android Debug APK

```powershell
cd android
.\gradlew.bat assembleDebug --console=plain
```

The debug APK is generated at:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## OpenAPI Credentials

Do not hard-code production credentials in source. Pass them during build:

```powershell
flutter run --dart-define=SIERRO_APP_ID=your_app_id --dart-define=SIERRO_APP_SECRET=your_app_secret
```

Current test defaults:

- `SIERRO_BASE_URL`: `https://solar.siseli.com/openapis`
- `SIERRO_APP_ID`: configured from the customer's test AppID by default
- `SIERRO_DEMO_DTU_ID`: configured from the customer's test DTU by default

`SIERRO_APP_SECRET` intentionally defaults to empty. Pass it with `--dart-define` when running or building.

The signing implementation is in `lib/services/sierro_signer.dart`. The OpenAPI wrapper is in `lib/services/open_api_client.dart`.

`OpenApiClient.loginWithAccount` accepts the plain user password and sends `MD5(password)` to match the customer OpenAPI login requirement.

To enable automatic cloud sync during development, also pass a test account:

```powershell
flutter run `
  --dart-define=SIERRO_APP_SECRET=your_app_secret `
  --dart-define=SIERRO_TEST_ACCOUNT=jason1324 `
  --dart-define=SIERRO_TEST_PASSWORD=your_test_password
```

When these values are not provided, the app stays in local demo mode.

## Bluetooth Provisioning

Bluetooth UUIDs and Wi-Fi configuration commands from the provided BLE documents are implemented in `lib/services/bluetooth_provisioning.dart`.
