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
  // Pet name — stored locally and persisted via HomeViewModel
  late TextEditingController _nameCtrl;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeViewModel>();
      vm.checkPermissions();
      _nameCtrl.text = vm.petName;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        if (!vm.hasAllPermissions) return _buildPermissionScreen(vm);
        return _buildHome(vm);
      },
    );
  }

  // ── Main home layout ──────────────────────────────────────────────────
  Widget _buildHome(HomeViewModel vm) {
    final top = MediaQuery.of(context).padding.top;
    return Column(children: [
      PixelTitleBar(
        topPadding: top,
        title: 'FOCUS PET',
        trailing: _statusPill(vm.isServiceRunning),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 4, bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetHero(vm),
              const SizedBox(height: 14),
              PixelSectionLabel('STATS', color: PixelTheme.accent4),
              const SizedBox(height: 8),
              _buildStats(vm),
              const SizedBox(height: 14),
              PixelSectionLabel('WATCHING', color: PixelTheme.accent),
              const SizedBox(height: 8),
              _buildWatching(vm),
              const SizedBox(height: 14),
              PixelSectionLabel('SETTINGS', color: PixelTheme.accent5),
              const SizedBox(height: 8),
              _buildAlwaysActive(vm),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PixelButton(
                  label: vm.isServiceRunning
                      ? '■  STOP SERVICE'
                      : '▶  START SERVICE',
                  color: vm.isServiceRunning
                      ? PixelTheme.accent2
                      : PixelTheme.accent3,
                  onPressed: () async {
                    if (vm.isServiceRunning) {
                      await vm.stopService();
                    } else {
                      await vm.startService();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  // ── Pet hero card — centered sprite + editable name ───────────────────
  Widget _buildPetHero(HomeViewModel vm) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.accent,
      selected: true,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Column(children: [
        // Centered pet sprite
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: PixelTheme.bgDark,
              border:
                  Border.all(color: PixelTheme.accentDim, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(3, 3))
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 72,
                height: 72,
                child: PetSpriteWidget(
                  petType: vm.selectedPetType,
                  state: PetAnimState.idle,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Pet name — tap pencil to edit
        _editingName
            ? _buildNameField(vm)
            : _buildNameDisplay(vm),

        const SizedBox(height: 10),

        // Appears-after badge
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: PixelTheme.bgDark,
            border: Border.all(color: PixelTheme.border, width: 2),
          ),
          child: Text(
            '▶ APPEARS AFTER  ${vm.interruptDelayMinutes} MIN',
            style: PixelTheme.t8sec,
          ),
        ),
      ]),
    );
  }

  Widget _buildNameDisplay(HomeViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          vm.petName.isEmpty ? 'MY PET' : vm.petName.toUpperCase(),
          style: PixelTheme.pixelFont(
            size: 12,
            weight: FontWeight.bold,
            color: PixelTheme.accent,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            _nameCtrl.text = vm.petName;
            setState(() => _editingName = true);
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PixelTheme.surfaceHi,
              border: Border.all(color: PixelTheme.border, width: 2),
            ),
            child: Text(
              '✎',
              style: PixelTheme.pixelFont(
                  size: 10, color: PixelTheme.textSec, shadows: []),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(HomeViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            decoration: BoxDecoration(
              color: PixelTheme.bgDark,
              border: Border.all(color: PixelTheme.accent, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(3, 3))
              ],
            ),
            child: TextField(
              controller: _nameCtrl,
              autofocus: true,
              maxLength: 12,
              textCapitalization: TextCapitalization.characters,
              style: PixelTheme.pixelFont(
                  size: 10,
                  color: PixelTheme.accent,
                  shadows: []),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                border: InputBorder.none,
                hintText: 'NAME...',
                hintStyle: PixelTheme.pixelFont(
                    size: 9, color: PixelTheme.textSec, shadows: []),
              ),
              cursorColor: PixelTheme.accent,
              cursorWidth: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            await vm.setPetName(_nameCtrl.text.trim());
            setState(() => _editingName = false);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PixelTheme.accent,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(3, 3))
              ],
            ),
            child: Text(
              '✓',
              style: PixelTheme.pixelFont(
                  size: 10, color: PixelTheme.bg, shadows: []),
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────
  Widget _buildStats(HomeViewModel vm) {
    return Row(children: [
      Expanded(
          child: _statCard('🔥', vm.currentStreak.toString(), 'STREAK')),
      const SizedBox(width: 8),
      Expanded(
          child: _statCard('⚡', vm.sessionCount.toString(), 'SESSIONS')),
      const SizedBox(width: 8),
      Expanded(
          child: _statCard(
              '⏱', vm.formatTime(vm.totalTimeSavedSec), 'SAVED')),
    ]);
  }

  Widget _statCard(String icon, String value, String label) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Text(
          value,
          style: PixelTheme.pixelFont(
              size: 13, weight: FontWeight.bold, color: PixelTheme.accent),
        ),
        const SizedBox(height: 4),
        Text(label, style: PixelTheme.t7sec),
      ]),
    );
  }

  // ── Watching card ─────────────────────────────────────────────────────
  Widget _buildWatching(HomeViewModel vm) {
    final apps = vm.monitoredApps.toList();
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(12),
      child: apps.isEmpty
          ? Row(children: [
              Text('▶ ', style: PixelTheme.t9sec),
              Text('NO APPS SELECTED', style: PixelTheme.t9sec),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...apps.take(4).map((pkg) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Text('▶ ', style: PixelTheme.t9acc),
                        Expanded(
                          child: Text(
                            pkg.split('.').last.toUpperCase(),
                            style: PixelTheme.t9pri,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    )),
                if (apps.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '  + ${apps.length - 4} MORE',
                      style: PixelTheme.t8sec,
                    ),
                  ),
              ],
            ),
    );
  }

  // ── Always-active toggle ──────────────────────────────────────────────
  Widget _buildAlwaysActive(HomeViewModel vm) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(12),
      onTap: () => vm.toggleAlwaysActive(),
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALWAYS SHOW PET', style: PixelTheme.t9pri),
                const SizedBox(height: 5),
                Text('Pet stays visible at all times',
                    style: PixelTheme.t8sec),
              ]),
        ),
        const SizedBox(width: 12),
        PixelToggle(
            value: vm.alwaysActive, onTap: () => vm.toggleAlwaysActive()),
      ]),
    );
  }

  // ── Status pill ───────────────────────────────────────────────────────
  Widget _statusPill(bool running) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 7,
          height: 7,
          color: running ? PixelTheme.accent3 : PixelTheme.textSec),
      const SizedBox(width: 5),
      Text(
        running ? 'ON' : 'OFF',
        style: PixelTheme.pixelFont(
          size: 7,
          color: running ? PixelTheme.accent3 : PixelTheme.textSec,
          shadows: [],
        ),
      ),
    ]);
  }

  // ── Permission screen ─────────────────────────────────────────────────
  Widget _buildPermissionScreen(HomeViewModel vm) {
    final bool isOverlay = !vm.hasOverlayPermission;
    final top = MediaQuery.of(context).padding.top;
    return Column(children: [
      PixelTitleBar(topPadding: top, title: 'FOCUS PET'),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PixelCard(
                  fillColor: const Color(0xFF160808),
                  borderColor: PixelTheme.accent2,
                  selected: true,
                  padding: const EdgeInsets.all(22),
                  child: Column(children: [
                    Text(
                      isOverlay ? '◈' : '⌖',
                      style: const TextStyle(
                          fontSize: 44, color: PixelTheme.accent2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '!! WARNING !!',
                      style: PixelTheme.pixelFont(
                          size: 10,
                          color: PixelTheme.accent2,
                          weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isOverlay
                          ? 'OVERLAY ACCESS\nREQUIRED'
                          : 'ACCESSIBILITY\nREQUIRED',
                      style: PixelTheme.pixelFont(
                          size: 11,
                          weight: FontWeight.bold,
                          color: PixelTheme.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOverlay
                          ? 'Needed to show pet\nover other apps'
                          : 'Needed to detect\nmonitored apps',
                      style: PixelTheme.t8sec,
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PixelButton(
                    label: '▶ GRANT ACCESS',
                    onPressed: isOverlay
                        ? vm.requestOverlayPermission
                        : vm.requestAccessibilityPermission,
                  ),
                ),
              ]),
        ),
      ),
    ]);
  }
}