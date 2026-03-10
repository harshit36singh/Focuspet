import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../domain/pet_type.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pet_sprite_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        // Check if permissions are missing
        if (!vm.hasAllPermissions) {
          return _buildPermissionScreen(vm);
        }

        return _buildHomeContent(vm);
      },
    );
  }

  Widget _buildHomeContent(HomeViewModel vm) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // Retro title bar
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
              Expanded(
                child: Text(
                  '█ FOCUS PET █',
                  style: PixelTheme.pixelFont(
                    size: 20,
                    weight: FontWeight.bold,
                    color: PixelTheme.accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              _buildStatusIndicator(vm.isServiceRunning),
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
              bottom: 120, // Space for nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPetPreviewCard(vm),
                const SizedBox(height: 16),
                const PixelSectionLabel('STATS'),
                const SizedBox(height: 10),
                _buildStatsGrid(vm),
                const SizedBox(height: 16),
                const PixelSectionLabel('WATCHING'),
                const SizedBox(height: 10),
                _buildWatchingCard(vm),
                const SizedBox(height: 16),
                const PixelSectionLabel('KEEP PET ACTIVE'),
                const SizedBox(height: 10),
                _buildAlwaysActiveCard(vm),
                const SizedBox(height: 16),
                _buildServiceButton(vm),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool isRunning) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'STATUS:',
          style: PixelTheme.pixelFont(
            size: 9,
            color: PixelTheme.textSecondary,
            letterSpacing: 0.15,
          ).copyWith(shadows: []),
        ),
        const SizedBox(width: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '●',
            style: TextStyle(
              fontSize: 16,
              color: isRunning ? PixelTheme.accent3 : PixelTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetPreviewCard(HomeViewModel vm) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.accent,
      selected: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Live sprite preview
          SizedBox(
            width: 90,
            height: 90,
            child: PetSpriteWidget(
              petType: vm.selectedPetType,
              state: PetAnimState.idle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${vm.selectedPetType.emoji}  ${vm.selectedPetType.displayName}',
            style: PixelTheme.pixelFont(
              size: 15,
              weight: FontWeight.bold,
              color: PixelTheme.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'APPEARS AFTER  ${vm.interruptDelayMinutes}MIN',
            style: PixelTheme.pixelFont(
              size: 10,
              color: PixelTheme.textSecondary,
              letterSpacing: 0.1,
            ).copyWith(shadows: []),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(HomeViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '🔥${vm.currentStreak}',
            'STREAK',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            '${vm.sessionCount}',
            'SESSIONS',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            vm.formatTime(vm.totalTimeSavedSec),
            'SAVED',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          PixelBigValue(value),
          const SizedBox(height: 4),
          PixelSectionLabel(label),
        ],
      ),
    );
  }

  Widget _buildWatchingCard(HomeViewModel vm) {
    final apps = vm.monitoredApps.toList();

    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(16),
      child: apps.isEmpty
          ? Text(
              'No apps selected',
              style: PixelTheme.pixelFont(
                size: 11,
                color: PixelTheme.textSecondary,
              ).copyWith(shadows: []),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...apps.take(5).map((pkg) {
                  final appName = pkg.split('.').last.toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '> $appName',
                      style: PixelTheme.pixelFont(
                        size: 11,
                        color: PixelTheme.textPrimary,
                      ).copyWith(shadows: []),
                    ),
                  );
                }),
                if (apps.length > 5)
                  PixelSectionLabel('+${apps.length - 5} MORE'),
              ],
            ),
    );
  }

  Widget _buildAlwaysActiveCard(HomeViewModel vm) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(14),
      onTap: () => vm.toggleAlwaysActive(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALWAYS SHOW PET',
                  style: PixelTheme.pixelFont(
                    size: 12,
                    weight: FontWeight.bold,
                    color: PixelTheme.textPrimary,
                    letterSpacing: 0.05,
                  ).copyWith(shadows: []),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pet stays visible at all times',
                  style: PixelTheme.pixelFont(
                    size: 10,
                    color: PixelTheme.textSecondary,
                  ).copyWith(shadows: []),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: vm.alwaysActive ? PixelTheme.accent : PixelTheme.border,
              border: Border.all(color: PixelTheme.shadow, width: 3),
            ),
            child: Text(
              vm.alwaysActive ? 'ON' : 'OFF',
              style: PixelTheme.pixelFont(
                size: 14,
                weight: FontWeight.bold,
                color: vm.alwaysActive ? PixelTheme.bg : PixelTheme.textSecondary,
                letterSpacing: 0.1,
              ).copyWith(shadows: []),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(HomeViewModel vm) {
    return PixelButton(
      label: vm.isServiceRunning ? '[ STOP SERVICE ]' : '[ START SERVICE ]',
      color: vm.isServiceRunning ? PixelTheme.accent2 : PixelTheme.accent,
      onPressed: () async {
        if (vm.isServiceRunning) {
          await vm.stopService();
        } else {
          await vm.startService();
        }
      },
    );
  }

  Widget _buildPermissionScreen(HomeViewModel vm) {
    final String permType;
    final String permIcon;
    final String permTitle;
    final String permDesc;
    final VoidCallback onGrant;

    if (!vm.hasOverlayPermission) {
      permType = 'OVERLAY';
      permIcon = '◈';
      permTitle = 'OVERLAY\nACCESS NEEDED';
      permDesc = 'Required to show the pet\nover other apps';
      onGrant = vm.requestOverlayPermission;
    } else {
      permType = 'ACCESSIBILITY';
      permIcon = '⌖';
      permTitle = 'ACCESSIBILITY\nACCESS NEEDED';
      permDesc = 'Required to detect when\nyou open monitored apps';
      onGrant = vm.requestAccessibilityPermission;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 40,
        right: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            permIcon,
            style: PixelTheme.pixelFont(
              size: 56,
              color: PixelTheme.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            permTitle,
            style: PixelTheme.pixelFont(
              size: 20,
              weight: FontWeight.bold,
              color: PixelTheme.textPrimary,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            permDesc,
            style: PixelTheme.pixelFont(
              size: 12,
              color: PixelTheme.textSecondary,
            ).copyWith(shadows: []),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          PixelButton(
            label: '[ GRANT ACCESS ]',
            onPressed: onGrant,
          ),
        ],
      ),
    );
  }
}