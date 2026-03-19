import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _ch =
      MethodChannel('com.project.focuspet/native');

  // ── Permissions ───────────────────────────────────────────────────────
  Future<bool> canDrawOverlays() async {
    try {
      return await _ch.invokeMethod<bool>('canDrawOverlays') ?? false;
    } catch (_) { return false; }
  }

  Future<void> requestOverlayPermission() async {
    try { await _ch.invokeMethod('requestOverlayPermission'); } catch (_) {}
  }

  Future<bool> isAccessibilityEnabled() async {
    try {
      return await _ch.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } catch (_) { return false; }
  }

  Future<void> requestAccessibilityPermission() async {
    try { await _ch.invokeMethod('requestAccessibilityPermission'); } catch (_) {}
  }

  // ── Service control ───────────────────────────────────────────────────
  Future<void> startPetService() async {
    try { await _ch.invokeMethod('startPetService'); } catch (_) {}
  }

  Future<void> stopPetService() async {
    try { await _ch.invokeMethod('stopPetService'); } catch (_) {}
  }

  Future<bool> isPetServiceRunning() async {
    try {
      return await _ch.invokeMethod<bool>('isPetServiceRunning') ?? false;
    } catch (_) { return false; }
  }

  Future<void> showPet() async {
    try { await _ch.invokeMethod('showPet'); } catch (_) {}
  }

  Future<void> hidePet() async {
    try { await _ch.invokeMethod('hidePet'); } catch (_) {}
  }

  // ── App monitoring — now fetches icons like BeatSocial ────────────────
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final result = await _ch.invokeMethod<List>('getInstalledApps');
      if (result == null) return [];
      return result.map((a) {
        final map = Map<String, dynamic>.from(a as Map);
        return InstalledApp(
          packageName: map['packageName'] as String? ?? '',
          appName: map['appName'] as String? ?? '',
          iconBase64: map['icon'] as String?,
        );
      }).toList();
    } catch (_) { return []; }
  }

  Future<void> updateMonitoredApps(Set<String> packages) async {
    try {
      await _ch.invokeMethod('updateMonitoredApps',
          {'packages': packages.toList()});
    } catch (_) {}
  }

  /// [petZoneStart] and [petZoneEnd] are 0.0–1.0 fractions of screen width.
  Future<void> updatePetSettings({
    required String petType,
    required int interruptDelayMin,
    required int walkDelaySec,
    required int reactDelaySec,
    required bool alwaysActive,
    double petZoneStart = 0.0,
    double petZoneEnd   = 1.0,
  }) async {
    try {
      await _ch.invokeMethod('updatePetSettings', {
        'petType':           petType,
        'interruptDelayMin': interruptDelayMin,
        'walkDelaySec':      walkDelaySec,
        'reactDelaySec':     reactDelaySec,
        'alwaysActive':      alwaysActive,
        'petZoneStart':      petZoneStart,
        'petZoneEnd':        petZoneEnd,
      });
    } catch (_) {}
  }

  // ── System info ───────────────────────────────────────────────────────
  Future<double> getStatusBarHeight() async {
    try {
      return await _ch.invokeMethod<double>('getStatusBarHeight') ?? 24.0;
    } catch (_) { return 24.0; }
  }
}

class InstalledApp {
  final String packageName;
  final String appName;
  final String? iconBase64;

  InstalledApp({
    required this.packageName,
    required this.appName,
    this.iconBase64,
  });
}