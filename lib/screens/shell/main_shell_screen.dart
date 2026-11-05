import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gpa_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../calculator/gpa_calculator_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../devin_ai_eval/devin_ai_eval_screen.dart';
import '../routine/routine_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gpa = context.watch<GpaProvider>();
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 850;

    final pages = [
      DashboardScreen(onNavigateTab: _navigateToTab),
      const GpaCalculatorScreen(),
      DevinAiEvalScreen(onNavigateToRoutine: () => _navigateToTab(3)),
      const RoutineScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'EduPulse',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.accentTeal),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  color: AppTheme.accentTealGlow,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Presentation Quick Action: "Load Sample Data"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await gpa.loadSampleData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sample Engineering Transcript & AI Analysis Loaded!'),
                      backgroundColor: AppTheme.accentTeal,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppTheme.warningAmber),
              label: const Text(
                'Load Sample Data',
                style: TextStyle(
                  color: AppTheme.warningAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // User Profile Pill & Logout
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.slateCardLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.slateBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primaryIndigo,
                  child: Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user?.fullName ?? 'Alex Mercer',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.textSecondary),
                  tooltip: 'Sign Out',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => auth.logout(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Desktop Navigation Sidebar
          if (isDesktop)
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: AppTheme.slateSurface,
                border: Border(right: BorderSide(color: AppTheme.slateBorder, width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildNavItem(
                    index: 0,
                    title: 'Executive Dashboard',
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                  ),
                  _buildNavItem(
                    index: 1,
                    title: 'GPA & CGPA Engine',
                    icon: Icons.calculate_outlined,
                    activeIcon: Icons.calculate_rounded,
                    tag: 'Module 1',
                  ),
                  _buildNavItem(
                    index: 2,
                    title: 'Devin AI Evaluation',
                    icon: Icons.psychology_outlined,
                    activeIcon: Icons.psychology_rounded,
                    tag: 'Module 2',
                  ),
                  _buildNavItem(
                    index: 3,
                    title: 'Personalized Routine',
                    icon: Icons.timer_outlined,
                    activeIcon: Icons.timer_rounded,
                    tag: 'Module 3',
                  ),
                  const Spacer(),
                  // Sidebar info card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: AppTheme.accentTealGlow),
                              SizedBox(width: 6),
                              Text(
                                'Local Data Engine',
                                style: TextStyle(
                                  color: AppTheme.accentTealGlow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'All semesters, script OCR & Pomodoros persisted locally.',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main Screen Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      // Mobile Bottom Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToTab,
              backgroundColor: AppTheme.slateSurface,
              indicatorColor: AppTheme.primaryIndigo.withValues(alpha: 0.3),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppTheme.accentTealGlow),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate, color: AppTheme.accentTealGlow),
                  label: 'GPA Engine',
                ),
                NavigationDestination(
                  icon: Icon(Icons.psychology_outlined),
                  selectedIcon: Icon(Icons.psychology, color: AppTheme.accentTealGlow),
                  label: 'Devin AI',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer, color: AppTheme.accentTealGlow),
                  label: 'Routine',
                ),
              ],
            ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    String? tag,
  }) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryIndigo.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryIndigo.withValues(alpha: 0.4) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? AppTheme.accentTealGlow : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentTeal.withValues(alpha: 0.2)
                          : AppTheme.slateCardLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? AppTheme.accentTealGlow : AppTheme.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
