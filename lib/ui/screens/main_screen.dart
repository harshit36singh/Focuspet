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
  }

  @override
  void dispose() {
    _homeVM.dispose();
    _petVM.dispose();
    _appVM.dispose();
    super.dispose();
  }

  // Tab colours — each tab has its own accent
  static const _tabColors = [
    PixelTheme.accent,   // HOME — gold
    PixelTheme.accent4,  // PET  — cyan
    PixelTheme.accent2,  // APPS — pink
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: PixelTheme.bg,
      body: Stack(children: [
        // ── Screens ──────────────────────────────────────────────────────
        IndexedStack(
          index: _idx,
          children: [
            ChangeNotifierProvider.value(
              value: _homeVM,
              child: RepaintBoundary(
                child: TickerMode(
                  enabled: _idx == 0,
                  child: const HomeScreen(),
                ),
              ),
            ),
            ChangeNotifierProvider.value(
              value: _petVM,
              child: RepaintBoundary(
                child: TickerMode(
                  enabled: _idx == 1,
                  child: const PetSelectScreen(),
                ),
              ),
            ),
            ChangeNotifierProvider.value(
              value: _appVM,
              child: RepaintBoundary(
                child: TickerMode(
                  enabled: _idx == 2,
                  child: const AppSelectScreen(),
                ),
              ),
            ),
          ],
        ),

        // ── Floating Pixel Nav Bar ────────────────────────────────────────
        Positioned(
          left: 12,
          right: 12,
          bottom: bottomPad + 12,
          child: _buildNav(),
        ),
      ]),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: PixelTheme.navBg,
        // Chunky pixel border — accent color of selected tab
        border: Border.all(color: _tabColors[_idx], width: 2.5),
        // Hard drop shadow = 90s game window depth
        boxShadow: [
          BoxShadow(
              color: _tabColors[_idx].withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 0),
          const BoxShadow(
              color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(children: [
        _navItem(0, '▲', 'HOME'),
        _navDivider(),
        _navItem(1, '♦', 'PET'),
        _navDivider(),
        _navItem(2, '●', 'APPS'),
      ]),
    );
  }

  Widget _navDivider() => Container(
        width: 2,
        height: 64,
        color: PixelTheme.border,
      );

  Widget _navItem(int index, String icon, String label) {
    final active = _idx == index;
    final color = _tabColors[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _idx = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: active ? color.withOpacity(0.10) : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon — slightly larger when active
              Text(
                icon,
                style: TextStyle(
                  fontSize: active ? 20 : 16,
                  color: active ? color : PixelTheme.textDim,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: PixelTheme.pixelFont(
                  size: 7,
                  weight: FontWeight.bold,
                  color: active ? color : PixelTheme.textDim,
                  shadows: [],
                ),
              ),
              // Active underline bar
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 24,
                color: active ? color : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}