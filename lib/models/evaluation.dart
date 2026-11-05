class PenaltyPinpoint {
  final String id;
  final String title;
  final double deduction;
  final String severity; // 'Critical', 'Moderate', 'Minor'
  final String stepReference; // e.g., 'Step 3 - Line 14'
  final String explanation;
  // Normalized coordinates (0.0 to 1.0) on the answer script canvas
  final double x;
  final double y;
  final double width;
  final double height;

  const PenaltyPinpoint({
    required this.id,
    required this.title,
    required this.deduction,
    required this.severity,
    required this.stepReference,
    required this.explanation,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'deduction': deduction,
        'severity': severity,
        'stepReference': stepReference,
        'explanation': explanation,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  factory PenaltyPinpoint.fromJson(Map<String, dynamic> json) => PenaltyPinpoint(
        id: json['id'] as String? ?? 'p1',
        title: json['title'] as String? ?? '',
        deduction: (json['deduction'] as num?)?.toDouble() ?? 0.0,
        severity: json['severity'] as String? ?? 'Moderate',
        stepReference: json['stepReference'] as String? ?? 'Step 1',
        explanation: json['explanation'] as String? ?? '',
        x: (json['x'] as num?)?.toDouble() ?? 0.1,
        y: (json['y'] as num?)?.toDouble() ?? 0.1,
        width: (json['width'] as num?)?.toDouble() ?? 0.3,
        height: (json['height'] as num?)?.toDouble() ?? 0.1,
      );
}

class WeakArea {
  final String id;
  final String topic;
  final String issue;
  final double penaltyScore;
  final String severity;
  final String remediation;

  const WeakArea({
    required this.id,
    required this.topic,
    required this.issue,
    required this.penaltyScore,
    required this.severity,
    required this.remediation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'issue': issue,
        'penaltyScore': penaltyScore,
        'severity': severity,
        'remediation': remediation,
      };

  factory WeakArea.fromJson(Map<String, dynamic> json) => WeakArea(
        id: json['id'] as String? ?? 'w1',
        topic: json['topic'] as String? ?? 'Topic',
        issue: json['issue'] as String? ?? 'Issue',
        penaltyScore: (json['penaltyScore'] as num?)?.toDouble() ?? 0.0,
        severity: json['severity'] as String? ?? 'Moderate',
        remediation: json['remediation'] as String? ?? '',
      );
}

class ScriptEvaluation {
  final String id;
  final DateTime createdAt;
  final String questionPaperTitle;
  final String subjectCode;
  final String presetId;
  final double totalMarks;
  final double scoredMarks;
  final double accuracyPercentage;
  final List<WeakArea> weakAreas;
  final List<PenaltyPinpoint> pinpoints;
  final List<String> recommendationNotes;
  final String? customQuestionImageName;
  final String? customScriptImageName;

  const ScriptEvaluation({
    required this.id,
    required this.createdAt,
    required this.questionPaperTitle,
    required this.subjectCode,
    required this.presetId,
    required this.totalMarks,
    required this.scoredMarks,
    required this.accuracyPercentage,
    required this.weakAreas,
    required this.pinpoints,
    required this.recommendationNotes,
    this.customQuestionImageName,
    this.customScriptImageName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'questionPaperTitle': questionPaperTitle,
        'subjectCode': subjectCode,
        'presetId': presetId,
        'totalMarks': totalMarks,
        'scoredMarks': scoredMarks,
        'accuracyPercentage': accuracyPercentage,
        'weakAreas': weakAreas.map((w) => w.toJson()).toList(),
        'pinpoints': pinpoints.map((p) => p.toJson()).toList(),
        'recommendationNotes': recommendationNotes,
        'customQuestionImageName': customQuestionImageName,
        'customScriptImageName': customScriptImageName,
      };

  factory ScriptEvaluation.fromJson(Map<String, dynamic> json) => ScriptEvaluation(
        id: json['id'] as String? ?? 'eval_1',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        questionPaperTitle: json['questionPaperTitle'] as String? ?? 'Evaluation',
        subjectCode: json['subjectCode'] as String? ?? 'ENG-101',
        presetId: json['presetId'] as String? ?? 'calculus_final',
        totalMarks: (json['totalMarks'] as num?)?.toDouble() ?? 50.0,
        scoredMarks: (json['scoredMarks'] as num?)?.toDouble() ?? 39.0,
        accuracyPercentage: (json['accuracyPercentage'] as num?)?.toDouble() ?? 78.0,
        weakAreas: (json['weakAreas'] as List<dynamic>? ?? [])
            .map((w) => WeakArea.fromJson(w as Map<String, dynamic>))
            .toList(),
        pinpoints: (json['pinpoints'] as List<dynamic>? ?? [])
            .map((p) => PenaltyPinpoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        recommendationNotes: (json['recommendationNotes'] as List<dynamic>? ?? [])
            .map((r) => r.toString())
            .toList(),
        customQuestionImageName: json['customQuestionImageName'] as String?,
        customScriptImageName: json['customScriptImageName'] as String?,
      );
}
