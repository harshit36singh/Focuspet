import 'package:shared_preferences/shared_preferences.dart';
import '../domain/pet_type.dart';

class AppPreferences {
  static const _kPet         = 'selected_pet';
  static const _kDelay       = 'interrupt_delay_min';
  static const _kWalk        = 'walk_delay_sec';
  static const _kReact       = 'react_delay_sec';
  static const _kApps        = 'monitored_apps';
  static const _kAlways      = 'always_active';
  static const _kSessions    = 'session_count';
  static const _kTime        = 'total_time_interrupted_sec';
  static const _kStreak      = 'current_streak';
  static const _kLongest     = 'longest_streak';
  static const _kStreakDate  = 'last_streak_date';
  static const _kPetName     = 'pet_name';
  static const _kZoneStart   = 'pet_zone_start'; // 0.0–1.0 fraction of screen width
  static const _kZoneEnd     = 'pet_zone_end';   // 0.0–1.0 fraction of screen width

  final SharedPreferences _p;
  AppPreferences(this._p);

  static Future<AppPreferences> init() async =>
      AppPreferences(await SharedPreferences.getInstance());

  // ── Pet ───────────────────────────────────────────────────────────────
  PetType get selectedPet {
    final n = _p.getString(_kPet) ?? 'dog1';
    return PetType.values.firstWhere((p) => p.name == n,
        orElse: () => PetType.dog1);
  }
  Future<void> setSelectedPet(PetType v) =>
      _p.setString(_kPet, v.name);

  // ── Pet name ──────────────────────────────────────────────────────────
  String get petName => _p.getString(_kPetName) ?? '';
  Future<void> setPetName(String v) => _p.setString(_kPetName, v);

  // ── Walk zone (fractions of screen width, 0.0–1.0) ───────────────────
  // Default: full status bar (0.0 → 1.0)
  double get petZoneStart => _p.getDouble(_kZoneStart) ?? 0.0;
  double get petZoneEnd   => _p.getDouble(_kZoneEnd)   ?? 1.0;
  Future<void> setPetZone(double start, double end) async {
    await _p.setDouble(_kZoneStart, start.clamp(0.0, 1.0));
    await _p.setDouble(_kZoneEnd,   end.clamp(0.0, 1.0));
  }

  // ── Timing ───────────────────────────────────────────────────────────
  int get interruptDelayMinutes => _p.getInt(_kDelay) ?? 5;
  Future<void> setInterruptDelayMinutes(int v) => _p.setInt(_kDelay, v);

  int get walkDelaySeconds => _p.getInt(_kWalk) ?? 60;
  Future<void> setWalkDelaySeconds(int v) => _p.setInt(_kWalk, v);

  int get reactDelaySeconds => _p.getInt(_kReact) ?? 120;
  Future<void> setReactDelaySeconds(int v) => _p.setInt(_kReact, v);

  // ── Monitored apps ────────────────────────────────────────────────────
  Set<String> get monitoredApps =>
      Set<String>.from(_p.getStringList(_kApps) ?? []);
  Future<void> setMonitoredApps(Set<String> v) =>
      _p.setStringList(_kApps, v.toList());
  Future<void> addMonitoredApp(String pkg) async {
    final s = monitoredApps..add(pkg);
    await setMonitoredApps(s);
  }
  Future<void> removeMonitoredApp(String pkg) async {
    final s = monitoredApps..remove(pkg);
    await setMonitoredApps(s);
  }

  // ── Always active ─────────────────────────────────────────────────────
  bool get alwaysActive => _p.getBool(_kAlways) ?? false;
  Future<void> setAlwaysActive(bool v) => _p.setBool(_kAlways, v);

  // ── Stats ─────────────────────────────────────────────────────────────
  int get sessionCount => _p.getInt(_kSessions) ?? 0;
  set sessionCount(int v) => _p.setInt(_kSessions, v);

  int get totalTimeInterruptedSec => _p.getInt(_kTime) ?? 0;
  set totalTimeInterruptedSec(int v) => _p.setInt(_kTime, v);

  int get currentStreak => _p.getInt(_kStreak) ?? 0;
  set currentStreak(int v) => _p.setInt(_kStreak, v);

  int get longestStreak => _p.getInt(_kLongest) ?? 0;
  set longestStreak(int v) => _p.setInt(_kLongest, v);

  String get lastStreakDate => _p.getString(_kStreakDate) ?? '';
  set lastStreakDate(String v) => _p.setString(_kStreakDate, v);

  // ── Helpers ───────────────────────────────────────────────────────────
  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    return '${m}m';
  }
}