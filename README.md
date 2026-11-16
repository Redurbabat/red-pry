# Lumina – Fokus & Routinen (iOS 17+)

A native SwiftUI iPhone application with onboarding, daily routines, focus timer, progress statistics and local UserDefaults persistence.

## Local build (macOS)
Install Xcode 15+ and XcodeGen; then run:

```sh
brew install xcodegen
xcodegen generate --spec project.yml
open Lumina.xcodeproj
```

Bundle ID: `com.redurbabat.lumina`. Minimum iOS: 17.0.

## GitHub Actions IPA
Every push to `main` triggers `.github/workflows/build-ipa.yml`.
Open **Actions > Build Lumina iOS IPA > latest run > Artifacts > Lumina-UNSIGNED-IPA** to download the unsigned IPA archive.

**Important:** An unsigned IPA is *not directly installable* on a normal iPhone. It must be signed with a suitable certificate and provisioning profile (using Xcode or your signing workflow). No credentials or signing secrets are needed to produce the unsigned IPA.

The build is made using XcodeGen to generate the native Xcode project. The source code is included in `Lumina/`.
