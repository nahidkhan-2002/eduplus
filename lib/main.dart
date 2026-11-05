import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/evaluation_provider.dart';
import 'providers/gpa_provider.dart';
import 'providers/routine_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local storage
  final storageService = await StorageService.init();

  runApp(EduPulseApp(storageService: storageService));
}

class EduPulseApp extends StatelessWidget {
  final StorageService storageService;

  const EduPulseApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(storageService),
        ),
        ChangeNotifierProvider<GpaProvider>(
          create: (_) => GpaProvider(storageService),
        ),
        ChangeNotifierProvider<EvaluationProvider>(
          create: (_) => EvaluationProvider(storageService),
        ),
        ChangeNotifierProvider<RoutineProvider>(
          create: (_) => RoutineProvider(storageService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'EduPulse AI - Student Result Analysis & Devin AI Diagnosis',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: auth.isLoggedIn ? const MainShellScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
