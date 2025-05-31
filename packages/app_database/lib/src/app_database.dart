import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Cocktails extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get instructions => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get difficulty => intEnum<CocktailDifficulty>()();
  IntColumn get preparationTimeMinutes => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cocktailId => integer().references(Cocktails, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get amount => text()();
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
}

enum CocktailDifficulty { easy, medium, hard }

/// {@template app_database}
/// The drift-managed database configuration
/// {@endtemplate}
@DriftDatabase(tables: [Cocktails, Ingredients])
class AppDatabase extends _$AppDatabase {
  /// {@macro app_database}
  AppDatabase(super.e);

  /// {@macro app_database}
  AppDatabase.defaults({required String name})
    : super(
        driftDatabase(
          name: name,
          native: const DriftNativeOptions(shareAcrossIsolates: true),
          // TODO(Sizzle): Update the sqlite3Wasm and driftWorker paths to match the location of the files in your project if needed.
          // https://drift.simonbinder.eu/web/#prerequisites
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 2;
}
