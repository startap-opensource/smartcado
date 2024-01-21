import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:smartcado/libraries/db_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class SqliteInitialization {
  static initializeSqliteDatabase() {
    WidgetsFlutterBinding.ensureInitialized();
    setupSqliteForWindowsAndLinux();
    DatabaseHandler().setupDatabase();
  }

  static setupSqliteForWindowsAndLinux() {
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = null;
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}