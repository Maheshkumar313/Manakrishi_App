# Deploying Manakrishi App

This guide covers how to build and deploy your Flutter application for Android, Web, and Windows.

## 1. Android Deployment (APK / Play Store)

To distribute your app to Android phones:

### Build an APK (for direct installation)
Run the following command in your terminal:
```bash
flutter build apk --release
```
- **Output:** The APK file will be located at:  
  `build/app/outputs/flutter-apk/app-release.apk`
- You can copy this file to any Android phone and install it.

### Build an App Bundle (for Google Play Store)
If you want to publish to the Play Store, you need an App Bundle (.aab):
```bash
flutter build appbundle --release
```
- **Output:** `build/app/outputs/bundle/release/app-release.aab`
- Upload this file to the Google Play Console.

---

## 2. Web Deployment (Live Website)

To publish your app as a website:

### Build for Web
1. Run the build command:
   ```bash
   flutter build web --release
   ```
2. **Output:** The files will be in `build/web/`.

### Hosting Options
- **Firebase Hosting (Recommended):**
  1. Install Firebase tools: `npm install -g firebase-tools`
  2. Login: `firebase login`
  3. Init: `firebase init` (Select Hosting, choose `build/web` as directory)
  4. Deploy: `firebase deploy`

- **GitHub Pages / Netlify / Vercel:**
  - Simply upload the contents of `build/web/` to any static site host.

---

## 3. Windows Deployment

To create an installer for Windows:

```bash
flutter build windows --release
```
- **Output:** `build/windows/x64/runner/Release/`
- You will find the `manakrishi_app.exe` and necessary DLLs here. You can zip this folder and share it, or use a tool like **Inno Setup** to create a single setup file.

## Checklist Before Release
1. **Update Version:** Check `pubspec.yaml` and increment `version: 1.0.0+1`.
2. **Launcher Icon:** Ensure you have a good app icon (using `flutter_launcher_icons` package).
3. **App Name:** Verify the app name in `android/app/src/main/AndroidManifest.xml` (label) and `web/index.html` (title).
