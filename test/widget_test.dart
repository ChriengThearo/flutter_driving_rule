import 'package:driving_rule/data/auth/auth_repository.dart';
import 'package:driving_rule/data/auth/auth_result.dart';
import 'package:driving_rule/features/auth/presentation/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login({
    required String phoneNumber,
    required String password,
  }) async {
    return const AuthResult(isSuccess: true, message: 'ok');
  }

  @override
  Future<AuthResult> register({
    required String phoneNumber,
    required String fullName,
    required String password,
  }) async {
    return const AuthResult(isSuccess: true, message: 'ok');
  }
}

void main() {
  testWidgets('Auth page starts in register mode with full name field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(repository: _FakeAuthRepository())),
    );

    expect(find.text('Register'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('Switching to login hides register-only fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(repository: _FakeAuthRepository())),
    );

    await tester.tap(find.text('Login').first);
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsNothing);
    expect(find.text('Confirm Password'), findsNothing);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
