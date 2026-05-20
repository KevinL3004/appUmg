class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Datos del usuario logueado
  String? username;
  String? role;
  int? employeeId;

  void saveSession({
    required String username,
    required String role,
    int? employeeId,
  }) {
    this.username = username;
    this.role = role;
    this.employeeId = employeeId;
  }

  void clearSession() {
    username = null;
    role = null;
    employeeId = null;
  }

  bool get isLoggedIn => username != null;
}