import 'package:flutter/foundation.dart';
import '../data/app_preferences.dart';
import '../services/platform_service.dart';

/// MVVM ViewModel for App Selection Screen
class AppSelectViewModel extends ChangeNotifier {
  final AppPreferences prefs;
  final PlatformService platform;

  List<InstalledApp> _installedApps = [];
  bool _isLoading = true;

  AppSelectViewModel({
    required this.prefs,
    required this.platform,
  }) {
    _loadInstalledApps();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GETTERS
  // ══════════════════════════════════════════════════════════════════════

  List<InstalledApp> get installedApps => _installedApps;
  bool get isLoading => _isLoading;
  Set<String> get monitoredApps => prefs.monitoredApps;

  bool isAppMonitored(String packageName) {
    return prefs.monitoredApps.contains(packageName);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ACTIONS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> toggleApp(String packageName) async {
    if (isAppMonitored(packageName)) {
      await prefs.removeMonitoredApp(packageName);
    } else {
      await prefs.addMonitoredApp(packageName);
    }
    await _updateNativeMonitoredApps();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadInstalledApps();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _loadInstalledApps() async {
    _isLoading = true;
    notifyListeners();

    try {
      final apps = await platform.getInstalledApps();
      // Sort alphabetically by app name
      apps.sort((a, b) => a.appName.compareTo(b.appName));
      _installedApps = apps;
    } catch (e) {
      print('Error loading apps: $e');
      _installedApps = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateNativeMonitoredApps() async {
    await platform.updateMonitoredApps(prefs.monitoredApps);
  }
}