import 'dart:convert';

class SessionService {
  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  SessionService._internal();

  // Datos del usuario logueado
  String? username;
  String? password;
  String? role;
  int? employeeId;

  void saveSession({
    required String username,
    required String password,
    required String role,
    int? employeeId,
  }) {
    this.username = username;
    this.password = password;
    this.role = role;
    this.employeeId = employeeId;
  }

  void clearSession() {
    username = null;
    password = null;
    role = null;
    employeeId = null;
  }

  bool get isLoggedIn => username != null;

  String get basicAuth {
    return 'Basic ${base64Encode(
      utf8.encode('$username:$password'),
    )}';
  }
}