class PomodoroSlot {
  final String id;
  final String timeLabel;
  final String subjectName;
  final String topic;
  final String slotType; // 'Focus Drill', 'Active Recall', 'Practice Exam', 'Spaced Review'
  final int durationMinutes;
  final bool isCompleted;
  final String priority; // 'High', 'Medium', 'Standard'

  const PomodoroSlot({
    required this.id,
    required this.timeLabel,
    required this.subjectName,
    required this.topic,
    required this.slotType,
    required this.durationMinutes,
    required this.isCompleted,
    required this.priority,
  });

  PomodoroSlot copyWith({
    String? id,
    String? timeLabel,
    String? subjectName,
    String? topic,
    String? slotType,
    int? durationMinutes,
    bool? isCompleted,
    String? priority,
  }) {
    return PomodoroSlot(
      id: id ?? this.id,
      timeLabel: timeLabel ?? this.timeLabel,
      subjectName: subjectName ?? this.subjectName,
      topic: topic ?? this.topic,
      slotType: slotType ?? this.slotType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timeLabel': timeLabel,
        'subjectName': subjectName,
        'topic': topic,
        'slotType': slotType,
        'durationMinutes': durationMinutes,
        'isCompleted': isCompleted,
        'priority': priority,
      };

  factory PomodoroSlot.fromJson(Map<String, dynamic> json) => PomodoroSlot(
        id: json['id'] as String? ?? 'p_slot',
        timeLabel: json['timeLabel'] as String? ?? '09:00 - 09:50 AM',
        subjectName: json['subjectName'] as String? ?? 'Core Study',
        topic: json['topic'] as String? ?? 'General Topic',
        slotType: json['slotType'] as String? ?? 'Focus Drill',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 50,
        isCompleted: json['isCompleted'] as bool? ?? false,
        priority: json['priority'] as String? ?? 'High',
      );
}

class SpacedRepetitionItem {
  final String id;
  final String subjectName;
  final String concept;
  final String stage; // 'Day 1: Encoding', 'Day 3: Rapid Recall', 'Day 7: Problem Solving', 'Day 14: Exam Synthesis'
  final String scheduledDate;
  final bool isCompleted;
  final int retentionRate;

  const SpacedRepetitionItem({
    required this.id,
    required this.subjectName,
    required this.concept,
    required this.stage,
    required this.scheduledDate,
    required this.isCompleted,
    required this.retentionRate,
  });

  SpacedRepetitionItem copyWith({
    String? id,
    String? subjectName,
    String? concept,
    String? stage,
    String? scheduledDate,
    bool? isCompleted,
    int? retentionRate,
  }) {
    return SpacedRepetitionItem(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      concept: concept ?? this.concept,
      stage: stage ?? this.stage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      retentionRate: retentionRate ?? this.retentionRate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectName': subjectName,
        'concept': concept,
        'stage': stage,
        'scheduledDate': scheduledDate,
        'isCompleted': isCompleted,
        'retentionRate': retentionRate,
      };

  factory SpacedRepetitionItem.fromJson(Map<String, dynamic> json) =>
      SpacedRepetitionItem(
        id: json['id'] as String? ?? 'sr_item',
        subjectName: json['subjectName'] as String? ?? 'Subject',
        concept: json['concept'] as String? ?? 'Concept',
        stage: json['stage'] as String? ?? 'Day 1: Encoding',
        scheduledDate: json['scheduledDate'] as String? ?? 'Today',
        isCompleted: json['isCompleted'] as bool? ?? false,
        retentionRate: (json['retentionRate'] as num?)?.toInt() ?? 85,
      );
}

class StudyRoutine {
  final String id;
  final DateTime createdAt;
  final List<String> weakestSubjects;
  final double dailyStudyHours;
  final DateTime targetExamDate;
  final double goalCgpa;
  final List<PomodoroSlot> pomodoroSlots;
  final List<SpacedRepetitionItem> spacedRepetitionItems;
  final List<String> actionableTips;
  final int streakDays;

  const StudyRoutine({
    required this.id,
    required this.createdAt,
    required this.weakestSubjects,
    required this.dailyStudyHours,
    required this.targetExamDate,
    required this.goalCgpa,
    required this.pomodoroSlots,
    required this.spacedRepetitionItems,
    required this.actionableTips,
    this.streakDays = 5,
  });

  int get completedSlotsCount =>
      pomodoroSlots.where((slot) => slot.isCompleted).length;

  double get completionPercentage => pomodoroSlots.isEmpty
      ? 0.0
      : (completedSlotsCount / pomodoroSlots.length) * 100;

  double get completedHours {
    final completedMinutes = pomodoroSlots
        .where((s) => s.isCompleted)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
    return completedMinutes / 60.0;
  }

  StudyRoutine copyWith({
    String? id,
    DateTime? createdAt,
    List<String>? weakestSubjects,
    double? dailyStudyHours,
    DateTime? targetExamDate,
    double? goalCgpa,
    List<PomodoroSlot>? pomodoroSlots,
    List<SpacedRepetitionItem>? spacedRepetitionItems,
    List<String>? actionableTips,
    int? streakDays,
  }) {
    return StudyRoutine(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      weakestSubjects: weakestSubjects ?? this.weakestSubjects,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      targetExamDate: targetExamDate ?? this.targetExamDate,
      goalCgpa: goalCgpa ?? this.goalCgpa,
      pomodoroSlots: pomodoroSlots ?? this.pomodoroSlots,
      spacedRepetitionItems:
          spacedRepetitionItems ?? this.spacedRepetitionItems,
      actionableTips: actionableTips ?? this.actionableTips,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'weakestSubjects': weakestSubjects,
        'dailyStudyHours': dailyStudyHours,
        'targetExamDate': targetExamDate.toIso8601String(),
        'goalCgpa': goalCgpa,
        'pomodoroSlots': pomodoroSlots.map((s) => s.toJson()).toList(),
        'spacedRepetitionItems':
            spacedRepetitionItems.map((s) => s.toJson()).toList(),
        'actionableTips': actionableTips,
        'streakDays': streakDays,
      };

  factory StudyRoutine.fromJson(Map<String, dynamic> json) => StudyRoutine(
        id: json['id'] as String? ?? 'routine_1',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        weakestSubjects: (json['weakestSubjects'] as List<dynamic>? ?? [])
            .map((s) => s.toString())
            .toList(),
        dailyStudyHours:
            (json['dailyStudyHours'] as num?)?.toDouble() ?? 4.0,
        targetExamDate: json['targetExamDate'] != null
            ? DateTime.tryParse(json['targetExamDate'] as String) ??
                DateTime.now().add(const Duration(days: 30))
            : DateTime.now().add(const Duration(days: 30)),
        goalCgpa: (json['goalCgpa'] as num?)?.toDouble() ?? 3.85,
        pomodoroSlots: (json['pomodoroSlots'] as List<dynamic>? ?? [])
            .map((s) => PomodoroSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
        spacedRepetitionItems:
            (json['spacedRepetitionItems'] as List<dynamic>? ?? [])
                .map((s) =>
                    SpacedRepetitionItem.fromJson(s as Map<String, dynamic>))
                .toList(),
        actionableTips: (json['actionableTips'] as List<dynamic>? ?? [])
            .map((t) => t.toString())
            .toList(),
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 5,
      );
}
