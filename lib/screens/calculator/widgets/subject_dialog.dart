import 'package:flutter/material.dart';
import '../../../models/subject.dart';
import '../../../services/calculation_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/grade_badge.dart';

class SubjectDialog extends StatefulWidget {
  final Subject? initialSubject;
  final Function(String name, String code, double credits, double fullMarks, double obtainedMarks) onSave;

  const SubjectDialog({
    super.key,
    this.initialSubject,
    required this.onSave,
  });

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _creditsController;
  late TextEditingController _fullMarksController;
  late TextEditingController _obtainedMarksController;

  String _previewGrade = 'A+';
  double _previewPoint = 4.00;

  @override
  void initState() {
    super.initState();
    final init = widget.initialSubject;
    _nameController = TextEditingController(text: init?.name ?? '');
    _codeController = TextEditingController(text: init?.code ?? '');
    _creditsController = TextEditingController(text: (init?.creditHours ?? 3.0).toString());
    _fullMarksController = TextEditingController(text: (init?.fullMarks ?? 100.0).toString());
    _obtainedMarksController = TextEditingController(text: (init?.obtainedMarks ?? 85.0).toString());

    _updatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _fullMarksController.dispose();
    _obtainedMarksController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final obtained = double.tryParse(_obtainedMarksController.text) ?? 0.0;
    final full = double.tryParse(_fullMarksController.text) ?? 100.0;
    final result = CalculationService.calculateGradeAndPoint(obtained, full);
    setState(() {
      _previewGrade = result['grade'] as String;
      _previewPoint = result['point'] as double;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final credits = double.tryParse(_creditsController.text) ?? 3.0;
      final full = double.tryParse(_fullMarksController.text) ?? 100.0;
      final obtained = double.tryParse(_obtainedMarksController.text) ?? 0.0;

      widget.onSave(
        _nameController.text.trim(),
        _codeController.text.trim(),
        credits,
        full,
        obtained,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSubject != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Subject & Marks' : 'Add Subject to Semester'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Grade Preview Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.slateBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.slateBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Grade Calculated:',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GradeBadge(
                        letterGrade: _previewGrade,
                        gradePoint: _previewPoint,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Code
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name (e.g., Operating Systems)',
                    prefixIcon: Icon(Icons.menu_book, size: 18),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Code (e.g., CSE-311)',
                    prefixIcon: Icon(Icons.qr_code, size: 18),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Credit Hours with chips
                const Text(
                  'Credit Hours',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [1.0, 1.5, 2.0, 3.0, 4.0].map((cr) {
                    final isSel = (double.tryParse(_creditsController.text) ?? 3.0) == cr;
                    return ChoiceChip(
                      label: Text('$cr cr'),
                      selected: isSel,
                      onSelected: (selected) {
                        if (selected) {
                          _creditsController.text = cr.toString();
                          setState(() {});
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Marks Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fullMarksController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Full Marks',
                          prefixIcon: Icon(Icons.straighten, size: 18),
                        ),
                        onChanged: (_) => _updatePreview(),
                        validator: (val) {
                          final numVal = double.tryParse(val ?? '');
                          if (numVal == null || numVal <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _obtainedMarksController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Obtained Marks',
                          prefixIcon: Icon(Icons.check_circle_outline, size: 18),
                        ),
                        onChanged: (_) => _updatePreview(),
                        validator: (val) {
                          final numVal = double.tryParse(val ?? '');
                          if (numVal == null || numVal < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save Changes' : 'Add Subject'),
        ),
      ],
    );
  }
}
