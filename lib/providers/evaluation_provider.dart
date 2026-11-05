import 'package:flutter/foundation.dart';
import '../models/evaluation.dart';
import '../services/devin_ai_service.dart';
import '../services/storage_service.dart';

class EvaluationProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<ScriptEvaluation> _evaluations = [];
  ScriptEvaluation? _currentEvaluation;

  String _selectedPresetId = 'calculus_math102';
  String? _customQuestionFileName;
  String? _customScriptFileName;

  // Scanning State
  bool _isScanning = false;
  int _currentPhaseIndex = 0; // 0, 1, 2
  double _scanProgress = 0.0; // 0.0 to 1.0
  String _phaseStatusText = '';

  // Active pinpoint highlighted in interactive inspector
  PenaltyPinpoint? _selectedPinpoint;

  EvaluationProvider(this._storageService) {
    _loadFromStorage();
  }

  List<ScriptEvaluation> get evaluations => List.unmodifiable(_evaluations);
  ScriptEvaluation? get currentEvaluation => _currentEvaluation;
  String get selectedPresetId => _selectedPresetId;
  String? get customQuestionFileName => _customQuestionFileName;
  String? get customScriptFileName => _customScriptFileName;

  bool get isScanning => _isScanning;
  int get currentPhaseIndex => _currentPhaseIndex;
  double get scanProgress => _scanProgress;
  String get phaseStatusText => _phaseStatusText;
  PenaltyPinpoint? get selectedPinpoint => _selectedPinpoint;

  static const List<String> scanPhases = [
    'Phase 1: Scanning handwriting, math tokens & diagram OCR...',
    'Phase 2: Matching against question scoring rubric & answer key...',
    'Phase 3: Generating gap diagnosis & step penalty breakdown...',
  ];

  void _loadFromStorage() {
    _evaluations = _storageService.getEvaluations();
    if (_evaluations.isNotEmpty) {
      _currentEvaluation = _evaluations.first;
    } else {
      // Default to initial calculus evaluation so presentation looks ready immediately
      final initial = DevinAiService.generateEvaluationForPreset('calculus_math102');
      _evaluations = [initial];
      _currentEvaluation = initial;
      _storageService.saveEvaluations(_evaluations);
    }
    notifyListeners();
  }

  void selectPreset(String presetId) {
    _selectedPresetId = presetId;
    _customQuestionFileName = null;
    _customScriptFileName = null;
    notifyListeners();
  }

  void setCustomQuestionFile(String filename) {
    _customQuestionFileName = filename;
    notifyListeners();
  }

  void setCustomScriptFile(String filename) {
    _customScriptFileName = filename;
    notifyListeners();
  }

  void selectPinpoint(PenaltyPinpoint? pinpoint) {
    _selectedPinpoint = pinpoint;
    notifyListeners();
  }

  /// Execute realistic 3-phase Devin AI Scanning Simulation
  Future<void> runDevinAiAnalysis({VoidCallback? onComplete}) async {
    if (_isScanning) return;

    _isScanning = true;
    _currentPhaseIndex = 0;
    _scanProgress = 0.05;
    _phaseStatusText = scanPhases[0];
    notifyListeners();

    // Phase 1: 0% -> 35%
    for (int p = 5; p <= 35; p += 6) {
      await Future.delayed(const Duration(milliseconds: 140));
      _scanProgress = p / 100.0;
      notifyListeners();
    }

    // Phase 2: 35% -> 70%
    _currentPhaseIndex = 1;
    _phaseStatusText = scanPhases[1];
    notifyListeners();
    for (int p = 38; p <= 70; p += 7) {
      await Future.delayed(const Duration(milliseconds: 160));
      _scanProgress = p / 100.0;
      notifyListeners();
    }

    // Phase 3: 70% -> 100%
    _currentPhaseIndex = 2;
    _phaseStatusText = scanPhases[2];
    notifyListeners();
    for (int p = 74; p <= 100; p += 7) {
      await Future.delayed(const Duration(milliseconds: 150));
      _scanProgress = p / 100.0;
      notifyListeners();
    }
    _scanProgress = 1.0;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    // Generate new evaluation model
    final newEval = DevinAiService.generateEvaluationForPreset(
      _selectedPresetId,
      customQName: _customQuestionFileName,
      customAName: _customScriptFileName,
    );

    _currentEvaluation = newEval;
    _selectedPinpoint = newEval.pinpoints.isNotEmpty ? newEval.pinpoints.first : null;

    final updated = List<ScriptEvaluation>.from(_evaluations)..insert(0, newEval);
    _evaluations = updated;
    await _storageService.saveEvaluations(_evaluations);

    _isScanning = false;
    notifyListeners();

    if (onComplete != null) {
      onComplete();
    }
  }

  void setCurrentEvaluation(ScriptEvaluation eval) {
    _currentEvaluation = eval;
    _selectedPinpoint = eval.pinpoints.isNotEmpty ? eval.pinpoints.first : null;
    notifyListeners();
  }
}
