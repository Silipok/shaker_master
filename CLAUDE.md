# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This is a **Dart workspace monorepo** (declared in the root `pubspec.yaml` under `workspace:`). The Flutter app lives in `app/`; shared code lives in path-referenced packages under `packages/`: `analytics`, `app_database` (Drift), `logger`, `rest_client`. Dependencies between them are `path:` references, so changes in a package are picked up immediately by the app.

Almost every command must be run from `app/` (or via the repo-root scripts that iterate over each pubspec). `flutter run`, `flutter test`, and build commands fail from repo root because root `pubspec.yaml` is a workspace-only manifest.

## Commands

Prefer the Makefile / scripts — they handle the workspace traversal that raw flutter commands don't.

| Task | Command |
| --- | --- |
| Install workspace deps | `make get` (or `flutter pub get` at repo root) |
| Full bootstrap (pub get + codegen in every package + l10n) | `make bootstrap` |
| Codegen (once / watch) | `make gen` / `make gen-watch` — runs `build_runner` with `-d` (delete-conflicting-outputs) |
| L10n only | `cd app && bash scripts/l10n.bash` (runs `dart run intl_utils:generate`) |
| Format every package | `bash scripts/format.bash` — `dart format --line-length 100`, skips `*.*.dart` generated files |
| Analyze every package | `bash scripts/analyze.bash` — runs `flutter analyze .` per package |
| Run all tests with coverage | `bash scripts/test.bash` — writes `reports/tests.json` |
| Single test | `cd app && flutter test test/src/path/to/foo_test.dart` |
| Run app | `cd app && flutter run` (VS Code launch configs also set `cwd` to `app/`) |
| Clean | `bash scripts/clean.bash` |

Note the line-length discrepancy: `scripts/format.bash` uses **100**, while the VS Code "Format" task uses **80**. The scripts are authoritative.

Runtime config is passed through `--dart-define`: `ENVIRONMENT` (or `FLUTTER_APP_FLAVOR`) resolves to `Environment.dev/staging/prod`; `SENTRY_DSN` enables Sentry when non-empty (see `app/lib/src/core/constant/application_config.dart`).

## Architecture

### Startup + Composition Root

Entry point is `app/lib/main.dart` → `startup()` in `app/lib/src/feature/initialization/logic/startup.dart`. The startup pipeline is non-trivial and worth reading before modifying initialization:

1. Build the app `Logger` (from the local `logger` package) and attach a `PrintingLogObserver` in non-release modes.
2. Wrap everything in `runZonedGuarded` with `logger.logZoneError` as the zone error handler, and wire `FlutterError.onError` + `PlatformDispatcher.onError` to the same logger. **Do not bypass this** — all uncaught errors are expected to flow through `Logger`.
3. Install `AppBlocObserver(logger)` and `Bloc.transformer = SequentialBlocTransformer`. Every bloc in the app runs sequentially by default.
4. `FlutterGemma.initialize(maxDownloadRetries: 3)` — on-device LLM, part of startup.
5. `composeDependencies(...)` produces a `CompositionResult { dependencies, millisecondsSpent }`. If it throws, `InitializationFailedApp` is rendered with an `onRetryInitialization` callback.
6. The tree is `RootContext → DependenciesScope → SettingsScope → WindowSizeScope → MaterialContext → MainPage`.

`composeDependencies` (in `composition_root.dart`) is the single place where app-wide singletons are constructed. Add new long-lived dependencies there, register them on `DependenciesContainer`, and retrieve them through `DependenciesScope.of(context)` (an `InheritedWidget`). Short-lived / feature-scoped deps should *not* go here.

### Testing the container

`DependenciesContainer` has a sibling `TestDependenciesContainer` (same file). Tests wrap widgets with `DependenciesScope` and pass a subclass of `TestDependenciesContainer` that overrides only the fields that test needs; any unprovided field throws via `noSuchMethod` with a helpful message. `ApplicationConfig` / `TestConfig` follow the same pattern. Do not add mocks inside `DependenciesContainer` itself.

### Feature layout

Under `app/lib/src/feature/<name>/`, the convention is `bloc/`, `data/`, `model/`, `widget/`, and (for features with their own startup work) `logic/`. Current features: `initialization`, `auth`, `home`, `settings`, `gemma_test`. `core/common/` holds cross-feature utilities (bloc observer/transformer, extensions, layout, error reporter) and `core/constant/` holds `ApplicationConfig`, generated assets, and localization.

### Localization

Strings live in ARB files under `app/lib/src/core/constant/localization/translations/`. `flutter_intl` generates `GeneratedLocalizations` into `app/lib/src/core/constant/localization/generated/` via `app/scripts/l10n.bash`. Generated code is excluded from analysis (`analysis_options.yaml`: `**/generated/**`, `**/*.*.dart`).

### Shader Lab

`app/lib/src/feature/shader_lab/` is a demo screen that drives `app/shaders/liquid_video_interactive.frag` from pointer events. Ripple physics live in pure Dart (`logic/curve_engine.dart`); each pointer event mutates the engine state and produces a `Snapshot` that the painter marshals into 52 fragment-shader uniforms. Per-frame animation is entirely in GLSL — the engine only runs on pointer events and on the ticker's `tick()` to prune expired ripples.

### Lints

Project uses `sizzle_lints` (pub package) for both analyzer rules and `dart_code_metrics`. When adding rules, extend `analysis_options.yaml` rather than duplicating.
