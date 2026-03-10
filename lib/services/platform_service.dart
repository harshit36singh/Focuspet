import 'package:flutter/services.dart';

/// Platform channel for Android-specific functionality
/// Communicates with native Android code for:
/// - Overlay window permission
/// - Accessibility service status
/// - Foreground service control
/// - App usage monitoring
class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.project.focuspet/native');

  // ══════════════════════════════════════════════════════════════════════
  //  PERMISSION CHECKS
  // ══════════════════════════════════════════════════════════════════════

  /// Check if overlay permission is granted
  Future<bool> canDrawOverlays() async {
    try {
      final result = await _channel.invokeMethod<bool>('canDrawOverlays');
      return result ?? false;
    } catch (e) {
      print('Error checking overlay permission: $e');
      return false;
    }
  }

  /// Request overlay permission (opens settings)
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      print('Error requesting overlay permission: $e');
    }
  }

  /// Check if accessibility service is enabled
  Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } catch (e) {
      print('Error checking accessibility: $e');
      return false;
    }
  }

  /// Request accessibility permission (opens settings)
  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      print('Error requesting accessibility: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SERVICE CONTROL
  // ══════════════════════════════════════════════════════════════════════

  /// Start the pet overlay service
  Future<void> startPetService() async {
    try {
      await _channel.invokeMethod('startPetService');
    } catch (e) {
      print('Error starting pet service: $e');
    }
  }

  /// Stop the pet overlay service
  Future<void> stopPetService() async {
    try {
      await _channel.invokeMethod('stopPetService');
    } catch (e) {
      print('Error stopping pet service: $e');
    }
  }

  /// Check if pet service is running
  Future<bool> isPetServiceRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPetServiceRunning');
      return result ?? false;
    } catch (e) {
      print('Error checking service status: $e');
      return false;
    }
  }

  /// Show pet overlay
  Future<void> showPet() async {
    try {
      await _channel.invokeMethod('showPet');
    } catch (e) {
      print('Error showing pet: $e');
    }
  }

  /// Hide pet overlay
  Future<void> hidePet() async {
    try {
      await _channel.invokeMethod('hidePet');
    } catch (e) {
      print('Error hiding pet: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  APP MONITORING
  // ══════════════════════════════════════════════════════════════════════

  /// Get list of installed user apps
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps');
      if (result == null) return [];
      
      return result.map((app) {
        return InstalledApp(
          packageName: app['packageName'] as String,
          appName: app['appName'] as String,
        );
      }).toList();
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  /// Update monitored apps in native service
  Future<void> updateMonitoredApps(Set<String> packageNames) async {
    try {
      await _channel.invokeMethod('updateMonitoredApps', {
        'packages': packageNames.toList(),
      });
    } catch (e) {
      print('Error updating monitored apps: $e');
    }
  }

  /// Update pet settings in native service
  Future<void> updatePetSettings({
    required String petType,
    required int interruptDelayMin,
    required int walkDelaySec,
    required int reactDelaySec,
    required bool alwaysActive,
  }) async {
    try {
      await _channel.invokeMethod('updatePetSettings', {
        'petType': petType,
        'interruptDelayMin': interruptDelayMin,
        'walkDelaySec': walkDelaySec,
        'reactDelaySec': reactDelaySec,
        'alwaysActive': alwaysActive,
      });
    } catch (e) {
      print('Error updating pet settings: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  SYSTEM INFO
  // ══════════════════════════════════════════════════════════════════════

  /// Get status bar height
  Future<double> getStatusBarHeight() async {
    try {
      final result = await _channel.invokeMethod<double>('getStatusBarHeight');
      return result ?? 24.0;
    } catch (e) {
      print('Error getting status bar height: $e');
      return 24.0;
    }
  }
}

/// Model for installed app info
class InstalledApp {
  final String packageName;
  final String appName;

  InstalledApp({
    required this.packageName,
    required this.appName,
  });
}