import 'package:flutter/foundation.dart';
import '../data/app_preferences.dart';
import '../domain/pet_type.dart';
import '../services/platform_service.dart';

class PetSelectViewModel extends ChangeNotifier {
  final AppPreferences prefs;
  final PlatformService platform;

  PetSelectViewModel({required this.prefs, required this.platform});

  // ── Getters ───────────────────────────────────────────────────────────
  PetType get selectedPet           => prefs.selectedPet;
  int     get interruptDelayMinutes => prefs.interruptDelayMinutes;
  int     get walkDelaySeconds      => prefs.walkDelaySeconds;
  int     get reactDelaySeconds     => prefs.reactDelaySeconds;
  double  get petZoneStart          => prefs.petZoneStart;
  double  get petZoneEnd            => prefs.petZoneEnd;

  List<PetType> get allPets => PetType.values;

  // ── Actions ───────────────────────────────────────────────────────────
  Future<void> selectPet(PetType pet) async {
    await prefs.setSelectedPet(pet);
    await _syncNative();
    notifyListeners();
  }

  Future<void> setInterruptDelay(int minutes) async {
    await prefs.setInterruptDelayMinutes(minutes);
    await _syncNative();
    notifyListeners();
  }

  Future<void> setWalkDelay(int seconds) async {
    await prefs.setWalkDelaySeconds(seconds);
    await _syncNative();
    notifyListeners();
  }

  Future<void> setReactDelay(int seconds) async {
    await prefs.setReactDelaySeconds(seconds);
    await _syncNative();
    notifyListeners();
  }

  Future<void> setPetZone(double start, double end) async {
    await prefs.setPetZone(start, end);
    await _syncNative();
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────
  Future<void> _syncNative() async {
    await platform.updatePetSettings(
      petType: prefs.selectedPet.name,
      interruptDelayMin: prefs.interruptDelayMinutes,
      walkDelaySec: prefs.walkDelaySeconds,
      reactDelaySec: prefs.reactDelaySeconds,
      alwaysActive: prefs.alwaysActive,
      petZoneStart: prefs.petZoneStart,
      petZoneEnd: prefs.petZoneEnd,
    );
  }
}