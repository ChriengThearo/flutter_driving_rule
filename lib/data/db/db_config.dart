import 'dart:io';

class DbConfig {
  DbConfig._();

  static String get host {
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return '127.0.0.1';
  }
  static const int port = 3306;
  static const String userName = 'driver_app';
  static const String password = 'mysql';
  static const String databaseName = 'driver_rule';
}
