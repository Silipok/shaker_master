<!-- filepath: /Users/dmitrymolchanov/learn/shaker_master/README.md -->
# shaker_master

Production-ready template for Flutter applications.

## Overview

This project serves as a comprehensive template for building robust and scalable Flutter applications. It follows a structured monorepo approach using Melos, separating concerns into a main application (`app`) and various local packages.

**Key Features:**

* **Monorepo Structure:** Organized with a root `pubspec.yaml` defining the workspace, an `app` directory for the main Flutter application, and a `packages` directory for shared modules.
* **State Management:** Utilizes `flutter_bloc` for predictable state management.
* **Networking:** Includes a `rest_client` package for handling API communications, with support for `http`, `cronet_http`, and `cupertino_http`.
* **Data Persistence:** Implements data storage solutions using `shared_preferences` for simple key-value storage and `drift` (with `drift_flutter`) for more complex local database needs via the `app_database` package.
* **Logging & Error Reporting:** Integrated `sentry_flutter` for crash reporting and a custom `logger` package for application logging.
* **Localization:** Supports internationalization using `intl` and `flutter_intl`, with translations managed in ARB files.
* **Code Generation:** Leverages `build_runner` and `flutter_gen_runner` for generating necessary code, such as for assets and localization.
* **Linting:** Enforces code quality with `sizzle_lints`.
* **Testing:** Set up for unit testing with `flutter_test` and `mockito`.

## Project Structure

```text
.
├── Makefile             # Main project tasks
├── pubspec.yaml         # Root workspace definition
├── README.md            # This file
├── app/                 # Main Flutter application
│   ├── pubspec.yaml     # App-specific dependencies and configuration
│   ├── lib/
│   │   └── main.dart    # Application entry point
│   └── ...
├── packages/            # Local packages
│   ├── analytics/
│   ├── app_database/
│   ├── logger/
│   └── rest_client/
└── scripts/             # Utility scripts
    ├── analyze.bash
    ├── bootstrap.bash
    ├── clean.bash
    ├── format.bash
    └── test.bash
```

## Getting Started

### Prerequisites

* Flutter SDK (version >=3.32.0 <4.0.0)
* Dart SDK (version >=3.7.0 <4.0.0)
* [Melos](https://melos.invertase.dev/) (for managing the monorepo - recommended for easier dependency management and script execution across packages)

### Installation & Setup

1. **Clone the repository:**

   ```bash
   git clone <your-repository-url>
   cd shaker_master
   ```

2. **Bootstrap the workspace (if using Melos):**
   If you have Melos installed globally:

   ```bash
   melos bootstrap
   ```

   Alternatively, you can run `flutter pub get` in each package and the app directory. The VS Code task "Get dependencies" (`flutter pub get`) can be run from the `app` directory.

3. **Run Code Generation:**
   This project uses code generation for various parts.
   The VS Code task "Run codegen" executes:

   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

   (Assuming `fvm` is used for Flutter version management. If not, you might run `dart run build_runner build --delete-conflicting-outputs` directly after ensuring you are in the `app` directory or the relevant package directory if generation is needed there.)


## Available Scripts & Tasks

This project includes several scripts and VS Code tasks to streamline development:

### VS Code Tasks (run via Command Palette > Tasks: Run Task)

* **Get dependencies:** Runs `flutter pub get` (typically within the `app` context).
* **Run codegen:** Executes `fvm dart run build_runner build --delete-conflicting-outputs`.
* **Format:** Formats Dart files using `find lib test -name '*.dart' ! -name '*.g.dart' | xargs dart format --fix -l 80`.
* **Run tests:** Runs `flutter test .`.

### Shell Scripts (in the `scripts/` directory)

* `analyze.bash`: Likely runs static analysis (e.g., `flutter analyze`).
* `bootstrap.bash`: Might be an alternative or more comprehensive bootstrapping script.
* `clean.bash`: For cleaning build artifacts (e.g., `flutter clean`).
* `format.bash`: For formatting the codebase.
* `test.bash`: For running tests.

Refer to the `Makefile` at the root for potentially more consolidated commands.

## Building the Application

Standard Flutter build commands can be used:

* **Debug:** `flutter run`
* **Release APK:** `flutter build apk --release`
* **Release AppBundle:** `flutter build appbundle --release`
* **iOS:** `flutter build ios --release` (requires macOS and Xcode)

## Core Packages

* **`app`**: The main Flutter application.
  * Entry point: `lib/main.dart` -> `src/feature/initialization/logic/startup.dart`
* **`packages/analytics`**: Handles analytics reporting (e.g., to Firebase).
* **`packages/app_database`**: Manages the local SQLite database using Drift.
* **`packages/logger`**: Provides logging utilities.
* **`packages/rest_client`**: A client for making REST API calls.

## Further Development

* **Adding new features:** Typically involves creating new feature modules within `app/lib/src/feature/`.
* **Modifying shared logic:** Update the relevant package in the `packages/` directory. Remember to run `melos bootstrap` or `flutter pub get` in dependent packages/app if you change package dependencies.
* **Localization:** Add new strings to `.arb` files in `app/lib/src/core/constant/localization/translations/` and run the localization generation tool (likely part of the codegen process or a separate script).

---

This README provides a starting point. Feel free to expand it with more specific details about your project's architecture, conventions, and deployment process.
