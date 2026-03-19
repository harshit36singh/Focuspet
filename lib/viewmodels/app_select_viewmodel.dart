import 'package:flutter/foundation.dart';
import '../data/app_preferences.dart';
import '../services/platform_service.dart';

/// MVVM ViewModel for App Selection Screen
class AppSelectViewModel extends ChangeNotifier {
  final AppPreferences prefs;
  final PlatformService platform;

  List<InstalledApp> _installedApps = [];
  bool _isLoading = false; // Start false — don't show spinner until explicitly triggered
  bool _hasFetched = false;

  AppSelectViewModel({
    required this.prefs,
    required this.platform,
  });

  // ══════════════════════════════════════════════════════════════════════
  //  GETTERS
  // ══════════════════════════════════════════════════════════════════════

  List<InstalledApp> get installedApps => _installedApps;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
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

  /// Called after permissions are granted to pre-warm the app list.
  /// Runs in the background — won't block the UI.
  Future<void> prefetchApps() async {
    if (_hasFetched || _isLoading) return;
    await _loadInstalledApps();
  }

  /// Called when the user navigates to the Apps tab (lazy load if needed).
  Future<void> ensureLoaded() async {
    if (!_hasFetched && !_isLoading) {
      await _loadInstalledApps();
    }
  }

  Future<void> refresh() async {
    _hasFetched = false;
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
      apps.sort((a, b) => a.appName.compareTo(b.appName));
      _installedApps = apps;
      _hasFetched = true;
    } catch (e) {
      debugPrint('Error loading apps: $e');
      _installedApps = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateNativeMonitoredApps() async {
    await platform.updateMonitoredApps(prefs.monitoredApps);
  }
}