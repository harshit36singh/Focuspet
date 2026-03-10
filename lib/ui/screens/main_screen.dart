import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_preferences.dart';
import '../../services/platform_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/pixel_theme.dart';
import 'home_screen.dart';
import 'pet_select_screen.dart';
import 'app_select_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<AppPreferences>();
    final platform = context.read<PlatformService>();

    // Create ViewModels
    final homeVM = HomeViewModel(prefs: prefs, platform: platform);
    final petSelectVM = PetSelectViewModel(prefs: prefs, platform: platform);
    final appSelectVM = AppSelectViewModel(prefs: prefs, platform: platform);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _selectedIndex,
            children: [
              ChangeNotifierProvider.value(
                value: homeVM,
                child: const HomeScreen(),
              ),
              ChangeNotifierProvider.value(
                value: petSelectVM,
                child: const PetSelectScreen(),
              ),
              ChangeNotifierProvider.value(
                value: appSelectVM,
                child: const AppSelectScreen(),
              ),
            ],
          ),

          // Floating pixel nav bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildFloatingNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNav() {
    return Container(
      decoration: BoxDecoration(
        color: PixelTheme.navBg,
        border: Border.all(color: PixelTheme.accent, width: 5),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: PixelTheme.shadow.withOpacity(0.5),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('▲', 'HOME', 0),
            _buildNavItem('♦', 'PET', 1),
            _buildNavItem('●', 'APPS', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.only(
            bottom: isSelected ? 2 : 4,
            top: isSelected ? 4 : 0,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? PixelTheme.surface : PixelTheme.navBg,
            border: isSelected 
                ? Border.all(color: PixelTheme.accent, width: 3)
                : null,
            borderRadius: BorderRadius.zero,
            boxShadow: isSelected ? [] : [
              BoxShadow(
                color: PixelTheme.shadow,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(
                  fontSize: 26,
                  color: isSelected ? PixelTheme.accent : PixelTheme.textSecondary,
                  shadows: isSelected ? [
                    Shadow(
                      color: PixelTheme.accent.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ] : [],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: PixelTheme.pixelFont(
                  size: 9,
                  weight: FontWeight.bold,
                  color: isSelected ? PixelTheme.accent : PixelTheme.textSecondary,
                  letterSpacing: 0.2,
                ).copyWith(
                  shadows: [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}