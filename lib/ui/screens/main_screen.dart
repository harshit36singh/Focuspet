import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_preferences.dart';
import '../../services/platform_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'pet_select_screen.dart';
import 'app_select_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  late final HomeViewModel _homeVM;
  late final PetSelectViewModel _petVM;
  late final AppSelectViewModel _appVM;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<AppPreferences>();
    final platform = context.read<PlatformService>();
    _homeVM = HomeViewModel(prefs: prefs, platform: platform);
    _petVM = PetSelectViewModel(prefs: prefs, platform: platform);
    _appVM = AppSelectViewModel(prefs: prefs, platform: platform);
    _homeVM.onPermissionsGranted = () => _appVM.prefetchApps();
  }

  @override
  void dispose() {
    _homeVM.dispose();
    _petVM.dispose();
    _appVM.dispose();
    super.dispose();
  }

  void _onTab(int i) {
    setState(() => _idx = i);
    if (i == 2) _appVM.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          IndexedStack(
            index: _idx,
            children: [
              ChangeNotifierProvider.value(
                value: _homeVM,
                child: RepaintBoundary(
                  child: TickerMode(enabled: _idx == 0, child: const HomeScreen()),
                ),
              ),
              ChangeNotifierProvider.value(
                value: _petVM,
                child: RepaintBoundary(
                  child: TickerMode(enabled: _idx == 1, child: const PetSelectScreen()),
                ),
              ),
              ChangeNotifierProvider.value(
                value: _appVM,
                child: RepaintBoundary(
                  child: TickerMode(enabled: _idx == 2, child: const AppSelectScreen()),
                ),
              ),
            ],
          ),

          // ── Floating bento navbar ─────────────────────────────────────
          Positioned(
            bottom: bottomPad + 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.black.withOpacity(0.40),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _pill(0, Icons.home_rounded, Icons.home_outlined, 'Home', AppTheme.rust),
                    const SizedBox(width: 3),
                    _pill(1, Icons.pets, Icons.pets_outlined, 'Pet', AppTheme.mustard),
                    const SizedBox(width: 3),
                    _pill(2, Icons.apps_rounded, Icons.apps_outlined, 'Apps', AppTheme.sage),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(int i, IconData on, IconData off, String label, Color accent) {
    final active = _idx == i;
    return GestureDetector(
      onTap: () => _onTab(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 20 : 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? on : off, size: 18,
                color: active ? AppTheme.white : const Color(0xFF555555)),
            if (active) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppTheme.white, letterSpacing: -0.2,
              )),
            ],
          ],
        ),
      ),
    );
  }
}