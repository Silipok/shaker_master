import 'package:shared_preferences/shared_preferences.dart';

/// Repository for authentication operations.
///
/// This repository manages authentication state using SharedPreferences.
/// It does NOT store credentials - the system password manager handles that
/// via Flutter's autofill APIs.
class AuthRepository {
  AuthRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _authStatusKey = 'is_authenticated';
  static const String _usernameKey = 'username';

  /// Performs login and saves authentication status.
  ///
  /// In a real app, this would validate credentials against a backend.
  /// For this demo, any non-empty credentials are accepted.
  Future<String> login(String username, String password) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username and password cannot be empty');
    }

    // Save authentication status
    await _prefs.setBool(_authStatusKey, true);
    await _prefs.setString(_usernameKey, username);

    return username;
  }

  /// Logs out the user by clearing authentication status.
  Future<void> logout() async {
    await _prefs.setBool(_authStatusKey, false);
    await _prefs.remove(_usernameKey);
  }

  /// Checks if user is currently authenticated.
  Future<bool> isAuthenticated() async {
    return _prefs.getBool(_authStatusKey) ?? false;
  }

  /// Gets the stored username if authenticated.
  Future<String?> getUsername() async {
    return _prefs.getString(_usernameKey);
  }
}
