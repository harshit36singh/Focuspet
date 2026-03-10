import 'package:shared_preferences/shared_preferences.dart';
import '../domain/pet_type.dart';

/// Data layer - wraps SharedPreferences
/// All persistent state lives here (MVVM pattern)
class AppPreferences {
  static const String _keySelectedPet = 'selected_pet';
  static const String _keyInterruptDelayMin = 'interrupt_delay_min';
  static const String _keyWalkDelaySec = 'walk_delay_sec';
  static const String _keyReactDelaySec = 'react_delay_sec';
  static const String _keyMonitoredApps = 'monitored_apps';
  static const String _keyAlwaysActive = 'always_active';
  static const String _keySessionCount = 'session_count';
  static const String _keyTotalTimeInterrupted = 'total_time_interrupted_sec';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyLastStreakDate = 'last_streak_date';

  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static Future<AppPreferences> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(prefs);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PET SETTINGS
  // ══════════════════════════════════════════════════════════════════════

  PetType get selectedPet {
    final name = _prefs.getString(_keySelectedPet) ?? 'dog1';
    try {
      return PetType.values.firstWhere(
        (p) => p.name == name,
        orElse: () => PetType.dog1,
      );
    } catch (e) {
      return PetType.dog1;
    }
  }

  Future<void> setSelectedPet(PetType pet) async {
    await _prefs.setString(_keySelectedPet, pet.name);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  TIMING SETTINGS
  // ══════════════════════════════════════════════════════════════════════

  int get interruptDelayMinutes => _prefs.getInt(_keyInterruptDelayMin) ?? 5;
  
  Future<void> setInterruptDelayMinutes(int value) async {
    await _prefs.setInt(_keyInterruptDelayMin, value);
  }

  int get walkDelaySeconds => _prefs.getInt(_keyWalkDelaySec) ?? 60;
  
  Future<void> setWalkDelaySeconds(int value) async {
    await _prefs.setInt(_keyWalkDelaySec, value);
  }

  int get reactDelaySeconds => _prefs.getInt(_keyReactDelaySec) ?? 120;
  
  Future<void> setReactDelaySeconds(int value) async {
    await _prefs.setInt(_keyReactDelaySec, value);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  MONITORED APPS
  // ══════════════════════════════════════════════════════════════════════

  Set<String> get monitoredApps {
    final list = _prefs.getStringList(_keyMonitoredApps) ?? [];
    return Set<String>.from(list);
  }

  Future<void> setMonitoredApps(Set<String> apps) async {
    await _prefs.setStringList(_keyMonitoredApps, apps.toList());
  }

  Future<void> addMonitoredApp(String packageName) async {
    final apps = monitoredApps;
    apps.add(packageName);
    await setMonitoredApps(apps);
  }

  Future<void> removeMonitoredApp(String packageName) async {
    final apps = monitoredApps;
    apps.remove(packageName);
    await setMonitoredApps(apps);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ALWAYS ACTIVE MODE
  // ══════════════════════════════════════════════════════════════════════

  bool get alwaysActive => _prefs.getBool(_keyAlwaysActive) ?? false;
  
  Future<void> setAlwaysActive(bool value) async {
    await _prefs.setBool(_keyAlwaysActive, value);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  STATS
  // ══════════════════════════════════════════════════════════════════════

  int get sessionCount => _prefs.getInt(_keySessionCount) ?? 0;
  
  Future<void> setSessionCount(int value) async {
    await _prefs.setInt(_keySessionCount, value);
  }

  Future<void> incrementSessionCount() async {
    await setSessionCount(sessionCount + 1);
  }

  int get totalTimeInterruptedSec => _prefs.getInt(_keyTotalTimeInterrupted) ?? 0;
  
  Future<void> setTotalTimeInterruptedSec(int value) async {
    await _prefs.setInt(_keyTotalTimeInterrupted, value);
  }

  Future<void> addTimeInterrupted(int seconds) async {
    await setTotalTimeInterruptedSec(totalTimeInterruptedSec + seconds);
  }

  int get currentStreak => _prefs.getInt(_keyCurrentStreak) ?? 0;
  
  Future<void> setCurrentStreak(int value) async {
    await _prefs.setInt(_keyCurrentStreak, value);
  }

  int get longestStreak => _prefs.getInt(_keyLongestStreak) ?? 0;
  
  Future<void> setLongestStreak(int value) async {
    await _prefs.setInt(_keyLongestStreak, value);
  }

  String get lastStreakDate => _prefs.getString(_keyLastStreakDate) ?? '';
  
  Future<void> setLastStreakDate(String date) async {
    await _prefs.setString(_keyLastStreakDate, date);
  }

  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (lastStreakDate == today) return;
    
    await setLastStreakDate(today);
    final newStreak = currentStreak + 1;
    await setCurrentStreak(newStreak);
    
    if (newStreak > longestStreak) {
      await setLongestStreak(newStreak);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════

  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final hrs = mins ~/ 60;
    if (hrs > 0) return '${hrs}h ${mins % 60}m';
    return '${mins}m';
  }
}