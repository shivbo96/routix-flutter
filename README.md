# Routix Flutter SDK 🚀

[![Pub Version](https://img.shields.io/pub/v/routix_flutter?color=blue&logo=dart)](https://pub.dev/packages/routix_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/github/actions/workflow/status/shivbo96/routix-flutter/test-sdk-flutter.yml?branch=main&logo=github)](https://github.com/shivbo96/routix-flutter/actions)

The official **Routix SDK** for Flutter. Empower your mobile application with industry-leading attribution, deep linking, and conversion measurement.

---

## 📖 Table of Contents
- [Features](#-features)
- [Installation](#-installation)
- [Android Setup](#android-setup)
- [iOS Setup](#ios-setup)
- [Usage](#-usage)
  - [Initialization](#1-initialize-the-sdk)
  - [Deep Link Resolution](#2-resolve-deep-links)
  - [Event Tracking](#3-track-conversion-events)
- [Support](#-support)
- [License](#-license)

---

## 🚀 Features

- **🎯 Precision Attribution**: Automatically resolve deep links using Android Install Referrer and iOS Fingerprinting.
- **📈 Conversion Tracking**: Measure `install`, `lead`, and `sale` events with high-fidelity metadata.
- **⚡ Lightweight & Fast**: Minimal footprint with zero external dependencies beyond standard networking and device info.
- **🛡️ Privacy Focused**: Designed to respect user privacy while maintaining attribution accuracy.

---

## 📦 Installation

Add `routix_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  routix_flutter: ^1.0.4
```

### Android Setup
To support Install Referrer attribution, ensure you have the following in your `android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.android.installreferrer:installreferrer:2.2'
}
```

### iOS Setup
No extra configuration is required for basic attribution. For enhanced accuracy using the clipboard fallback, ensure your `Info.plist` includes the necessary descriptions if your app accesses the clipboard for other purposes.

---

## 🛠️ Usage

### 1. Initialize the SDK
Initialize Routix in your `main()` function or as early as possible.

```dart
import 'package:routix_flutter/routix_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Routix.initialize(
    apiKey: 'your_workspace_api_key'
  );
  
  runApp(MyApp());
}
```

### 2. Resolve Deep Links (Deferred)
The `resolve()` method checks if the user arrived via a Routix link (e.g. from the App Store). It is idempotent—it handles the "first-open" logic automatically.

```dart
// enableClipboard: true significantly improves iOS accuracy
final match = await Routix.resolve(enableClipboard: true);

if (match != null && match.success) {
  print('Attributed to: ${match.shortCode}');
  // Access custom metadata set in the Routix dashboard
  final promo = match.metadata?['promo_code'];
}
```

### 3. Handle Deep Links (Direct)
Parses a direct deep link URL when the app is already installed. This is handled locally without hitting the network.

```dart
// Use a deep linking plugin like 'uni_links' to capture the incoming URL
String? initialLink = await getInitialLink();
if (initialLink != null) {
  final match = Routix.handleDeepLink(initialLink);
  if (match?.success == true) {
     print('Opened via: ${match?.shortCode}');
  }
}
```

### 4. Track Events
Tie conversion events directly to a campaign short code for ROI analysis.

```dart
await Routix.trackSale(
  'SUMMER_24',
  amount: 49.99,
  currency: 'USD',
  metadata: {'product_id': 'premium_pkg'}
);
```

### 5. Track Custom Events
Track workspace-level actions like signups or tutorial completions independent of any link.

```dart
await Routix.trackCustomEvent('user_signup', metadata: {'method': 'google'});
```

---

## 🤝 Support

- **Documentation**: [routix.link/docs](https://routix.link/docs/)
- **Issues**: Report bugs via the [GitHub Issue Tracker](https://github.com/shivbo96/routix-flutter/issues)
<!-- - **Community**: Join our [Discord Server](https://discord.gg/routix) -->

---

## 📄 License

This SDK is distributed under the **MIT License**. See [LICENSE](LICENSE) for more information.
