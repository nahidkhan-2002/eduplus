import 'package:flutter/foundation.dart';
import '../models/evaluation.dart';
import '../models/routine.dart';
import '../services/devin_ai_service.dart';
import '../services/storage_service.dart';

class RoutineProvider extends ChangeNotifier {
  final StorageService _storageService;

  StudyRoutine? _currentRoutine;
  bool _isGenerating = false;

  // Intake Form State
  List<String> _selectedWeakSubjects = [];
  double _dailyHours = 4.0;
  DateTime _targetExamDate = DateTime.now().add(const Duration(days: 35));
  double _goalCgpa = 3.85;

  RoutineProvider(this._storageService) {
    _loadFromStorage();
  }

  StudyRoutine? get currentRoutine => _currentRoutine;
  bool get isGenerating => _isGenerating;

  List<String> get selectedWeakSubjects => _selectedWeakSubjects;
  double get dailyHours => _dailyHours;
  DateTime get targetExamDate => _targetExamDate;
  double get goalCgpa => _goalCgpa;

  void _loadFromStorage() {
    _currentRoutine = _storageService.getRoutine();
    if (_currentRoutine == null) {
      // Generate default rich routine on first load
      _currentRoutine = DevinAiService.generatePersonalizedRoutine(
        weakestSubjects: ['Multivariable Calculus', 'Algorithm Complexity', 'Digital Systems'],
        dailyHours: 4.0,
        targetExamDate: DateTime.now().add(const Duration(days: 35)),
        goalCgpa: 3.85,
      );
      _storageService.saveRoutine(_currentRoutine!);
    }

    _selectedWeakSubjects = List.from(_currentRoutine!.weakestSubjects);
    _dailyHours = _currentRoutine!.dailyStudyHours;
    _targetExamDate = _currentRoutine!.targetExamDate;
    _goalCgpa = _currentRoutine!.goalCgpa;
    notifyListeners();
  }

  void updateIntake({
    List<String>? weakestSubjects,
    double? dailyHours,
    DateTime? targetExamDate,
    double? goalCgpa,
  }) {
    if (weakestSubjects != null) _selectedWeakSubjects = weakestSubjects;
    if (dailyHours != null) _dailyHours = dailyHours;
    if (targetExamDate != null) _targetExamDate = targetExamDate;
    if (goalCgpa != null) _goalCgpa = goalCgpa;
    notifyListeners();
  }

  void toggleWeakSubject(String subjectName) {
    if (_selectedWeakSubjects.contains(subjectName)) {
      if (_selectedWeakSubjects.length > 1) {
        _selectedWeakSubjects.remove(subjectName);
      }
    } else {
      _selectedWeakSubjects.add(subjectName);
    }
    notifyListeners();
  }

  /// Generate Routine with Devin AI
  Future<void> generateRoutine({List<WeakArea>? diagnosticWeakAreas}) async {
    _isGenerating = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));

    final routine = DevinAiService.generatePersonalizedRoutine(
      weakestSubjects: _selectedWeakSubjects,
      dailyHours: _dailyHours,
      targetExamDate: _targetExamDate,
      goalCgpa: _goalCgpa,
      weakAreas: diagnosticWeakAreas,
    );

    _currentRoutine = routine;
    await _storageService.saveRoutine(routine);

    _isGenerating = false;
    notifyListeners();
  }

  /// Toggle Pomodoro Slot Completion
  Future<void> toggleSlotCompletion(String slotId) async {
    if (_currentRoutine == null) return;

    final updatedSlots = _currentRoutine!.pomodoroSlots.map((slot) {
      if (slot.id == slotId) {
        return slot.copyWith(isCompleted: !slot.isCompleted);
      }
      return slot;
    }).toList();

    _currentRoutine = _currentRoutine!.copyWith(pomodoroSlots: updatedSlots);
    await _storageService.saveRoutine(_currentRoutine!);
    notifyListeners();
  }

  /// Toggle Spaced Repetition Item Completion
  Future<void> toggleSpacedRepetition(String itemId) async {
    if (_currentRoutine == null) return;

    final updatedItems = _currentRoutine!.spacedRepetitionItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();

    _currentRoutine = _currentRoutine!.copyWith(spacedRepetitionItems: updatedItems);
    await _storageService.saveRoutine(_currentRoutine!);
    notifyListeners();
  }

  /// Reset Daily Checklist (e.g. for a new study day)
  Future<void> resetDailyProgress() async {
    if (_currentRoutine == null) return;

    final updatedSlots = _currentRoutine!.pomodoroSlots
        .map((s) => s.copyWith(isCompleted: false))
        .toList();

    _currentRoutine = _currentRoutine!.copyWith(pomodoroSlots: updatedSlots);
    await _storageService.saveRoutine(_currentRoutine!);
    notifyListeners();
  }
}

