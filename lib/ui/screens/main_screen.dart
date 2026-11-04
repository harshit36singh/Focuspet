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
import 'onboarding_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  late final AppPreferences _prefs;
  late final HomeViewModel _homeVM;
  late final PetSelectViewModel _petVM;
  late final AppSelectViewModel _appVM;
  late bool _named;

  @override
  void initState() {
    super.initState();
    _prefs = context.read<AppPreferences>();
    final platform = context.read<PlatformService>();
    _homeVM = HomeViewModel(prefs: _prefs, platform: platform);
    _petVM = PetSelectViewModel(prefs: _prefs, platform: platform);
    _appVM = AppSelectViewModel(prefs: _prefs, platform: platform);
    _homeVM.onPermissionsGranted = () => _appVM.prefetchApps();
    _named = _prefs.petName.isNotEmpty;
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

  bool get _isTablet => MediaQuery.of(context).size.width >= 700;

  @override
  Widget build(BuildContext context) {
    if (!_named) {
      return OnboardingScreen(
        pet: _prefs.selectedPet,
        onDone: (name) async {
          await _homeVM.setPetName(name);
          if (mounted) setState(() => _named = true);
        },
      );
    }
    return _isTablet ? _buildTablet() : _buildPhone();
  }

  // Tablet: all three screens side by side.
  Widget _buildTablet() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _appVM.ensureLoaded());
    Widget divider() => Container(width: AppTheme.border, color: AppTheme.ink);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Row(children: [
        Expanded(child: ClipRect(child: ChangeNotifierProvider.value(value: _homeVM, child: const HomeScreen()))),
        divider(),
        Expanded(child: ClipRect(child: ChangeNotifierProvider.value(value: _petVM, child: const PetSelectScreen()))),
        divider(),
        Expanded(child: ClipRect(child: ChangeNotifierProvider.value(value: _appVM, child: const AppSelectScreen()))),
      ]),
    );
  }

  // Phone: indexed stack + floating ink pill navbar.
  Widget _buildPhone() {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        IndexedStack(index: _idx, children: [
          ChangeNotifierProvider.value(
            value: _homeVM,
            child: TickerMode(enabled: _idx == 0, child: const HomeScreen()),
          ),
          ChangeNotifierProvider.value(
            value: _petVM,
            child: TickerMode(enabled: _idx == 1, child: const PetSelectScreen()),
          ),
          ChangeNotifierProvider.value(
            value: _appVM,
            child: TickerMode(enabled: _idx == 2, child: const AppSelectScreen()),
          ),
        ]),
        Positioned(
          bottom: bottomPad + 18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [BoxShadow(color: AppTheme.ink.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _pill(0, Icons.home_rounded, 'Home', AppTheme.accent),
                const SizedBox(width: 4),
                _pill(1, Icons.pets, 'Pet', AppTheme.sage400),
                const SizedBox(width: 4),
                _pill(2, Icons.apps_rounded, 'Apps', AppTheme.accent300),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _pill(int i, IconData icon, String label, Color color) {
    final active = _idx == i;
    return GestureDetector(
      onTap: () => _onTab(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: active ? 18 : 13, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: active ? AppTheme.ink : AppTheme.n300),
          if (active) ...[
            const SizedBox(width: 6),
            Text(label, style: AppTheme.display(15)),
          ],
        ]),
      ),
    );
  }
}
