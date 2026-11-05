import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _isLoggedIn = false;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    _initSession();
  }

  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initSession() {
    _isLoggedIn = _storageService.isLoggedIn();
    if (_isLoggedIn) {
      _currentUser = _storageService.getUserSession() ?? UserModel.demo();
    }
    notifyListeners();
  }

  /// Sign In with validation + Quick Demo Bypass (test / test)
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    // Quick demo bypass or standard credentials
    if ((trimmedUser.toLowerCase() == 'test' && trimmedPass == 'test') ||
        (trimmedUser.isNotEmpty && trimmedPass.length >= 4)) {
      _currentUser = UserModel(
        username: trimmedUser,
        fullName: trimmedUser == 'test' ? 'Alex Mercer' : trimmedUser,
        email: trimmedUser == 'test' ? 'alex.mercer@apex.edu' : '$trimmedUser@edu.ai',
        studentId: 'STU-2024-8842',
        department: 'Computer Science & Software Engineering',
        batch: 'Class of 2026',
        targetCgpa: 3.85,
      );
      _isLoggedIn = true;
      await _storageService.saveUserSession(_currentUser!);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Invalid credentials. Use test / test for instant Demo access.';
      notifyListeners();
      return false;
    }
  }

  /// Instant Demo 1-Click Bypass
  Future<bool> quickDemoLogin() async {
    return login('test', 'test');
  }

  /// Sign Up (creates local session)
  Future<bool> signUp({
    required String username,
    required String fullName,
    required String email,
    required String department,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (username.isEmpty || password.length < 4) {
      _isLoading = false;
      _errorMessage = 'Password must be at least 4 characters.';
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      username: username.trim(),
      fullName: fullName.trim().isNotEmpty ? fullName.trim() : username.trim(),
      email: email.trim().isNotEmpty ? email.trim() : '$username@edu.ai',
      studentId: 'STU-${DateTime.now().year}-${DateTime.now().millisecond}',
      department: department.trim().isNotEmpty ? department.trim() : 'Engineering',
      batch: 'Class of 2026',
      targetCgpa: 3.85,
    );
    _isLoggedIn = true;
    await _storageService.saveUserSession(_currentUser!);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Explicit Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _storageService.clearUserSession();
    _isLoggedIn = false;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

