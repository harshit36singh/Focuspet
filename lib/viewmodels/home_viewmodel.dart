import 'package:flutter/foundation.dart';
import '../data/app_preferences.dart';
import '../domain/pet_type.dart';
import '../services/platform_service.dart';

/// MVVM ViewModel for Home Screen
class HomeViewModel extends ChangeNotifier {
  final AppPreferences prefs;
  final PlatformService platform;

  bool _isServiceRunning = false;
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;

  HomeViewModel({
    required this.prefs,
    required this.platform,
  }) {
    _checkPermissions();
    _checkServiceStatus();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GETTERS
  // ══════════════════════════════════════════════════════════════════════

  bool get isServiceRunning => _isServiceRunning;
  bool get hasOverlayPermission => _hasOverlayPermission;
  bool get hasAccessibilityPermission => _hasAccessibilityPermission;
  bool get hasAllPermissions => _hasOverlayPermission && _hasAccessibilityPermission;

  PetType get selectedPetType => prefs.selectedPet;
  int get interruptDelayMinutes => prefs.interruptDelayMinutes;
  int get sessionCount => prefs.sessionCount;
  int get currentStreak => prefs.currentStreak;
  int get totalTimeSavedSec => prefs.totalTimeInterruptedSec;
  bool get alwaysActive => prefs.alwaysActive;
  Set<String> get monitoredApps => prefs.monitoredApps;

  String formatTime(int seconds) => prefs.formatTime(seconds);

  // ══════════════════════════════════════════════════════════════════════
  //  ACTIONS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> checkPermissions() async {
    await _checkPermissions();
  }

  Future<void> requestOverlayPermission() async {
    await platform.requestOverlayPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkPermissions();
  }

  Future<void> requestAccessibilityPermission() async {
    await platform.requestAccessibilityPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkPermissions();
  }

  Future<void> startService() async {
    await platform.startPetService();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkServiceStatus();
  }

  Future<void> stopService() async {
    await platform.stopPetService();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkServiceStatus();
  }

  Future<void> toggleAlwaysActive() async {
    await prefs.setAlwaysActive(!prefs.alwaysActive);
    await _updateNativeSettings();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _checkPermissions();
    await _checkServiceStatus();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _checkPermissions() async {
    _hasOverlayPermission = await platform.canDrawOverlays();
    _hasAccessibilityPermission = await platform.isAccessibilityEnabled();
    notifyListeners();
  }

  Future<void> _checkServiceStatus() async {
    _isServiceRunning = await platform.isPetServiceRunning();
    notifyListeners();
  }

  Future<void> _updateNativeSettings() async {
    await platform.updatePetSettings(
      petType: prefs.selectedPet.name,
      interruptDelayMin: prefs.interruptDelayMinutes,
      walkDelaySec: prefs.walkDelaySeconds,
      reactDelaySec: prefs.reactDelaySeconds,
      alwaysActive: prefs.alwaysActive,
    );
  }
}