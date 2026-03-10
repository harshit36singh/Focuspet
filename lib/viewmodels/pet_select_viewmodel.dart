import 'package:flutter/foundation.dart';
import '../data/app_preferences.dart';
import '../domain/pet_type.dart';
import '../services/platform_service.dart';

/// MVVM ViewModel for Pet Selection Screen
class PetSelectViewModel extends ChangeNotifier {
  final AppPreferences prefs;
  final PlatformService platform;

  PetSelectViewModel({
    required this.prefs,
    required this.platform,
  });

  // ══════════════════════════════════════════════════════════════════════
  //  GETTERS
  // ══════════════════════════════════════════════════════════════════════

  PetType get selectedPet => prefs.selectedPet;
  int get interruptDelayMinutes => prefs.interruptDelayMinutes;
  int get walkDelaySeconds => prefs.walkDelaySeconds;
  int get reactDelaySeconds => prefs.reactDelaySeconds;

  List<PetType> get allPets => PetType.values;

  // ══════════════════════════════════════════════════════════════════════
  //  ACTIONS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> selectPet(PetType pet) async {
    await prefs.setSelectedPet(pet);
    await _updateNativeSettings();
    notifyListeners();
  }

  Future<void> setInterruptDelay(int minutes) async {
    await prefs.setInterruptDelayMinutes(minutes);
    await _updateNativeSettings();
    notifyListeners();
  }

  Future<void> setWalkDelay(int seconds) async {
    await prefs.setWalkDelaySeconds(seconds);
    await _updateNativeSettings();
    notifyListeners();
  }

  Future<void> setReactDelay(int seconds) async {
    await prefs.setReactDelaySeconds(seconds);
    await _updateNativeSettings();
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════════════

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