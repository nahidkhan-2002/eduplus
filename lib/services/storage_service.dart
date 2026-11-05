import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evaluation.dart';
import '../models/routine.dart';
import '../models/semester.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _keyIsLoggedIn = 'edupulse_is_logged_in';
  static const String _keyUserData = 'edupulse_user_data';
  static const String _keySemesters = 'edupulse_semesters_v1';
  static const String _keyEvaluations = 'edupulse_evaluations_v1';
  static const String _keyRoutine = 'edupulse_routine_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Auth Session ---
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> saveUserSession(UserModel user) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserData, jsonEncode(user.toJson()));
  }

  UserModel? getUserSession() {
    final raw = _prefs.getString(_keyUserData);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyUserData);
  }

  // --- Semesters & Subjects ---
  Future<void> saveSemesters(List<Semester> semesters) async {
    final rawList = semesters.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySemesters, jsonEncode(rawList));
  }

  List<Semester> getSemesters() {
    final raw = _prefs.getString(_keySemesters);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Semester.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Evaluations ---
  Future<void> saveEvaluations(List<ScriptEvaluation> evaluations) async {
    final rawList = evaluations.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyEvaluations, jsonEncode(rawList));
  }

  List<ScriptEvaluation> getEvaluations() {
    final raw = _prefs.getString(_keyEvaluations);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ScriptEvaluation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Routine ---
  Future<void> saveRoutine(StudyRoutine routine) async {
    await _prefs.setString(_keyRoutine, jsonEncode(routine.toJson()));
  }

  StudyRoutine? getRoutine() {
    final raw = _prefs.getString(_keyRoutine);
    if (raw == null) return null;
    try {
      return StudyRoutine.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

