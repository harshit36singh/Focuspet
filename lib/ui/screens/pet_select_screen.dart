import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../../domain/pet_type.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pet_sprite_widget.dart';

class PetSelectScreen extends StatelessWidget {
  const PetSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Consumer<PetSelectViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            // Title bar
            Container(
              padding: EdgeInsets.only(
                top: statusBarHeight + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              decoration: const BoxDecoration(
                color: PixelTheme.bg,
                border: Border(
                  bottom: BorderSide(color: PixelTheme.accent, width: 6),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '█ FOCUS PET █',
                    style: PixelTheme.pixelFont(
                      size: 20,
                      weight: FontWeight.bold,
                      color: PixelTheme.accent,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PixelSectionLabel('CHOOSE YOUR PET'),
                    const SizedBox(height: 12),
                    _buildPetGrid(vm),
                    const PixelDivider(),
                    const PixelSectionLabel('APPEAR AFTER'),
                    const SizedBox(height: 10),
                    PixelBigValue('${vm.interruptDelayMinutes} MIN'),
                    const SizedBox(height: 10),
                    _buildStepper(
                      value: vm.interruptDelayMinutes,
                      min: 1,
                      max: 60,
                      step: 1,
                      unit: 'min',
                      onChanged: vm.setInterruptDelay,
                    ),
                    const PixelDivider(),
                    const PixelSectionLabel('BEHAVIOUR TIMERS'),
                    const SizedBox(height: 10),
                    _buildTimerRow(
                      'START WALKING AFTER',
                      vm.walkDelaySeconds,
                      'sec',
                      vm.setWalkDelay,
                    ),
                    const SizedBox(height: 10),
                    _buildTimerRow(
                      'REACT/ATTACK AFTER',
                      vm.reactDelaySeconds,
                      'sec',
                      vm.setReactDelay,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetGrid(PetSelectViewModel vm) {
    final pets = vm.allPets;
    
    return Column(
      children: [
        for (int row = 0; row < (pets.length + 1) ~/ 2; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (int col = 0; col < 2; col++)
                  if (row * 2 + col < pets.length)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: col == 0 ? 8 : 0),
                        child: _buildPetCard(
                          vm,
                          pets[row * 2 + col],
                        ),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPetCard(PetSelectViewModel vm, PetType pet) {
    final isSelected = vm.selectedPet == pet;

    return PixelCard(
      fillColor: isSelected ? const Color(0xFF1A1A28) : PixelTheme.surface,
      borderColor: isSelected ? PixelTheme.accent : PixelTheme.border,
      selected: isSelected,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      onTap: () => vm.selectPet(pet),
      child: Column(
        children: [
          // Live sprite
          SizedBox(
            width: 64,
            height: 64,
            child: PetSpriteWidget(
              petType: pet,
              state: PetAnimState.idle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pet.displayName,
            style: PixelTheme.pixelFont(
              size: 10,
              weight: FontWeight.bold,
              color: isSelected ? PixelTheme.accent : PixelTheme.textSecondary,
              letterSpacing: 0.15,
            ).copyWith(
              shadows: isSelected ? [
                const Shadow(
                  offset: Offset(1, 1),
                  color: PixelTheme.shadow,
                ),
              ] : [],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Text(
              '▲ ACTIVE',
              style: PixelTheme.pixelFont(
                size: 8,
                weight: FontWeight.bold,
                color: PixelTheme.accent,
              ).copyWith(shadows: []),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepper({
    required int value,
    required int min,
    required int max,
    required int step,
    required String unit,
    required Function(int) onChanged,
  }) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _buildStepButton('-', () {
            if (value > min) onChanged(value - step);
          }),
          Expanded(
            child: Center(
              child: Text(
                '$value $unit',
                style: PixelTheme.pixelFont(
                  size: 15,
                  weight: FontWeight.bold,
                  color: PixelTheme.textPrimary,
                ).copyWith(shadows: []),
              ),
            ),
          ),
          _buildStepButton('+', () {
            if (value < max) onChanged(value + step);
          }),
        ],
      ),
    );
  }

  Widget _buildStepButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          label,
          style: PixelTheme.pixelFont(
            size: 24,
            weight: FontWeight.bold,
            color: PixelTheme.accent,
          ).copyWith(shadows: []),
        ),
      ),
    );
  }

  Widget _buildTimerRow(
    String label,
    int value,
    String unit,
    Function(int) onChanged,
  ) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelSectionLabel(label),
          const SizedBox(height: 8),
          _buildStepper(
            value: value,
            min: 10,
            max: 600,
            step: 10,
            unit: unit,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}