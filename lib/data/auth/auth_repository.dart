import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';

import '../db/db_config.dart';
import 'auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  });

  Future<AuthResult> login({
    required String phoneNumber,
    required String password,
  });
}

class MysqlAuthRepository implements AuthRepository {
  String _mapDbError(Object error) {
    final raw = error.toString();
    if (raw.contains('caching_sha2_password')) {
      return 'MySQL auth plugin is unsupported. Use a mysql_native_password user for this app.';
    }
    if (raw.contains('Access denied')) {
      return 'Access denied. Check DB username/password and MySQL user permissions.';
    }
    if (raw.contains("Unknown database 'driver_rule'")) {
      return "Database 'driver_rule' does not exist.";
    }
    if (raw.contains("Table 'driver_rule.users' doesn't exist")) {
      return "Table 'users' was not found in database 'driver_rule'.";
    }
    if (raw.contains('SocketException')) {
      return 'Cannot reach MySQL server. Check host/port and that MySQL is running.';
    }
    return 'Database operation failed.';
  }

  Future<MySQLConnection> _createConnection() async {
    final connection = await MySQLConnection.createConnection(
      host: DbConfig.host,
      port: DbConfig.port,
      userName: DbConfig.userName,
      password: DbConfig.password,
      databaseName: DbConfig.databaseName,
    );
    await connection.connect();
    return connection;
  }

  @override
  Future<AuthResult> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    MySQLConnection? connection;
    try {
      connection = await _createConnection();
      final exists = await connection.execute(
        'SELECT user_id FROM users WHERE phone_number = :phone LIMIT 1',
        {'phone': phoneNumber},
      );

      if (exists.rows.isNotEmpty) {
        return const AuthResult(
          isSuccess: false,
          message: 'Phone number already registered.',
        );
      }

      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
      await connection.execute(
        '''
        INSERT INTO users (full_name, phone_number, password)
        VALUES (:fullName, :phone, :passwordHash)
        ''',
        {
          'fullName': fullName,
          'phone': phoneNumber,
          'passwordHash': passwordHash,
        },
      );

      return const AuthResult(
        isSuccess: true,
        message: 'Registration successful.',
      );
    } catch (error, stackTrace) {
      debugPrint('Register error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return AuthResult(
        isSuccess: false,
        message: 'Register failed. ${_mapDbError(error)}',
      );
    } finally {
      await connection?.close();
    }
  }

  @override
  Future<AuthResult> login({
    required String phoneNumber,
    required String password,
  }) async {
    MySQLConnection? connection;
    try {
      connection = await _createConnection();
      final result = await connection.execute(
        '''
        SELECT user_id, full_name, password
        FROM users
        WHERE phone_number = :phone
        LIMIT 1
        ''',
        {'phone': phoneNumber},
      );

      if (result.rows.isEmpty) {
        return const AuthResult(
          isSuccess: false,
          message: 'Account not found.',
        );
      }

      final userData = result.rows.first.assoc();
      final savedPassword = userData['password'];

      if (savedPassword == null) {
        return const AuthResult(
          isSuccess: false,
          message: 'Invalid phone number or password.',
        );
      }

      final isBcryptHash =
          savedPassword.startsWith(r'$2a$') ||
          savedPassword.startsWith(r'$2b$') ||
          savedPassword.startsWith(r'$2y$');

      final isPasswordMatch = isBcryptHash
          ? BCrypt.checkpw(password, savedPassword)
          : password == savedPassword;

      if (!isPasswordMatch) {
        return const AuthResult(
          isSuccess: false,
          message: 'Invalid phone number or password.',
        );
      }

      return AuthResult(
        isSuccess: true,
        message: 'Welcome back ${userData['full_name'] ?? ''}'.trim(),
      );
    } catch (error, stackTrace) {
      debugPrint('Login error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return AuthResult(
        isSuccess: false,
        message: 'Login failed. ${_mapDbError(error)}',
      );
    } finally {
      await connection?.close();
    }
  }
}
