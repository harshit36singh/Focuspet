import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../domain/pet_type.dart';
import '../theme/app_theme.dart';
import '../widgets/pet_sprite_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _nameCtrl;
  bool _editingName = false;
  bool _hasShownDialog = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<HomeViewModel>();
      _nameCtrl.text = vm.petName;
      await vm.checkPermissions();
      if (mounted && !vm.hasAllPermissions && !_hasShownDialog) {
        _hasShownDialog = true;
        _showPermissionDialog(vm);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _showPermissionDialog(HomeViewModel vm) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PermissionDialog(vm: vm),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<HomeViewModel>(builder: (_, vm, __) => _build(vm));
  }

  Widget _build(HomeViewModel vm) {
    final top = MediaQuery.of(context).padding.top;
    final pad = AppTheme.hPad(context);

    return Container(
      color: AppTheme.bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: top + 16),

            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _editingName
                        ? _nameField(vm)
                        : GestureDetector(
                            onTap: () {
                              _nameCtrl.text = vm.petName;
                              setState(() => _editingName = true);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good day,',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.grey5,
                                  ),
                                ),
                                Text(
                                  vm.petName.isEmpty ? 'FocusPet' : vm.petName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.black,
                                    letterSpacing: -1.2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Notification + avatar row
                  GestureDetector(
                    onTap: () {
                      if (!vm.hasAllPermissions) _showPermissionDialog(vm);
                    },
                    child: _BentoAvatar(
                      letter: vm.petName.isNotEmpty ? vm.petName[0] : 'F',
                      active: vm.isServiceRunning,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ══════════════════════════════════════════════════════════════
            // BENTO GRID ROW 1: Pet tile (large) + status tile (small)
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Big pet tile (forest green) ─────────────────────────
                  Expanded(
                    flex: 3,
                    child: _BentoTile(
                      color: AppTheme.forest,
                      height: 200,
                      radius: 20,
                      child: Stack(
                        children: [
                          // Label
                          Positioned(
                            top: 16, left: 16,
                            child: Text('MY PET', style: AppTheme.tileLabel),
                          ),
                          // Pet sprite centred
                          Center(
                            child: SizedBox(
                              width: 110, height: 110,
                              child: PetSpriteWidget(
                                petType: vm.selectedPetType,
                                state: PetAnimState.idle,
                              ),
                            ),
                          ),
                          // Pet name bottom
                          Positioned(
                            bottom: 16, left: 16,
                            child: Text(
                              vm.petName.isEmpty ? 'My Pet' : vm.petName,
                              style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800,
                                color: AppTheme.onDark, letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          // Heart
                          Positioned(
                            top: 14, right: 14,
                            child: Icon(Icons.favorite_rounded,
                                size: 18, color: AppTheme.rust),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Right column: status + delay tiles ─────────────────
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Service status tile
                        GestureDetector(
                          onTap: () async {
                            if (!vm.hasAllPermissions) {
                              _showPermissionDialog(vm);
                              return;
                            }
                            vm.isServiceRunning
                                ? await vm.stopService()
                                : await vm.startService();
                          },
                          child: _BentoTile(
                            color: vm.isServiceRunning ? AppTheme.rust : AppTheme.cream2,
                            height: 95,
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STATUS',
                                  style: vm.isServiceRunning
                                      ? AppTheme.tileLabel
                                      : AppTheme.tileLabelDark,
                                ),
                                const Spacer(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      vm.isServiceRunning ? 'ON' : 'OFF',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: vm.isServiceRunning
                                            ? AppTheme.onDark
                                            : AppTheme.black,
                                        letterSpacing: -1.0,
                                        height: 1.0,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      vm.isServiceRunning
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_filled_rounded,
                                      size: 26,
                                      color: vm.isServiceRunning
                                          ? AppTheme.onDark.withOpacity(0.7)
                                          : AppTheme.black.withOpacity(0.4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Delay tile
                        _BentoTile(
                          color: AppTheme.mustard,
                          height: 95,
                          radius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('APPEAR', style: AppTheme.tileLabel),
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${vm.interruptDelayMinutes}',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.white,
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text('min', style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: AppTheme.white, letterSpacing: 0.2,
                                    )),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.timer_rounded,
                                      size: 22, color: AppTheme.white),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ══════════════════════════════════════════════════════════════
            // BENTO GRID ROW 2: Apps count + always-on + perm
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                children: [
                  // Apps monitored tile
                  Expanded(
                    flex: 2,
                    child: _BentoTile(
                      color: AppTheme.olive,
                      height: 110,
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('WATCHING', style: AppTheme.tileLabel),
                          const Spacer(),
                          Text(
                            '${vm.monitoredApps.length}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.onDark,
                              letterSpacing: -2.0,
                              height: 0.9,
                            ),
                          ),
                          const Text('apps', style: TextStyle(
                            fontSize: 11, color: AppTheme.onDark,
                            fontWeight: FontWeight.w500,
                          )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Always-on toggle tile
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => vm.toggleAlwaysActive(),
                      child: _BentoTile(
                        color: vm.alwaysActive ? AppTheme.clay : AppTheme.mint,
                        height: 110,
                        radius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ALWAYS ON',
                              style: vm.alwaysActive
                                  ? AppTheme.tileLabel
                                  : AppTheme.tileLabelDark,
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  vm.alwaysActive ? 'Yes' : 'No',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: vm.alwaysActive
                                        ? AppTheme.onDark
                                        : AppTheme.black,
                                    letterSpacing: -1.0,
                                    height: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  vm.alwaysActive
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_outlined,
                                  size: 22,
                                  color: vm.alwaysActive
                                      ? AppTheme.white.withOpacity(0.7)
                                      : AppTheme.black.withOpacity(0.35),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Permissions tile
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        if (!vm.hasAllPermissions) _showPermissionDialog(vm);
                      },
                      child: _BentoTile(
                        color: vm.hasAllPermissions
                            ? AppTheme.sage
                            : AppTheme.rust.withOpacity(0.85),
                        height: 110,
                        radius: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERM',
                              style: AppTheme.tileLabel.copyWith(
                                color: AppTheme.onDark.withOpacity(0.8),
                              ),
                            ),
                            Icon(
                              vm.hasAllPermissions
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_rounded,
                              size: 28,
                              color: AppTheme.onDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ══════════════════════════════════════════════════════════════
            // BENTO GRID ROW 3: Monitored apps list tile (wide)
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _BentoTile(
                color: AppTheme.cream2,
                height: null,
                radius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'MONITORED APPS',
                          style: AppTheme.tileLabelDark,
                        ),
                        const Spacer(),
                        Icon(Icons.apps_rounded, size: 16,
                            color: AppTheme.black.withOpacity(0.4)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (vm.monitoredApps.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: AppTheme.grey5),
                            const SizedBox(width: 8),
                            Text('No apps selected', style: AppTheme.metaLabel),
                          ],
                        ),
                      )
                    else
                      ...vm.monitoredApps.take(4).map((pkg) {
                        final name = pkg.split('.').last;
                        final display = name.isEmpty
                            ? pkg
                            : name[0].toUpperCase() + name.substring(1);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.forest.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  display.isNotEmpty ? display[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800,
                                    color: AppTheme.forest,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(display,
                                    style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: AppTheme.black,
                                    )),
                              ),
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.olive,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    if (vm.monitoredApps.length > 4)
                      Text('+${vm.monitoredApps.length - 4} more',
                          style: AppTheme.metaLabel),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ══════════════════════════════════════════════════════════════
            // BENTO GRID ROW 4: Streak + quote tile
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                children: [
                  // Focus streak tile
                  Expanded(
                    flex: 2,
                    child: _BentoTile(
                      color: AppTheme.rust,
                      height: 100,
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FOCUS MODE', style: AppTheme.tileLabel),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                vm.isServiceRunning ? 'Active' : 'Idle',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.onDark,
                                  letterSpacing: -0.8,
                                  height: 1.0,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.onDark.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.pets,
                                    size: 18, color: AppTheme.onDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Quote/tip tile
                  Expanded(
                    flex: 3,
                    child: _BentoTile(
                      color: AppTheme.forest,
                      height: 100,
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TIP', style: AppTheme.tileLabel),
                          const SizedBox(height: 8),
                          const Text(
                            'Stay focused.\nYour pet is watching.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onDark,
                              height: 1.35,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameField(HomeViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameCtrl,
            autofocus: true,
            maxLength: 14,
            style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w900,
              color: AppTheme.black, letterSpacing: -1.0,
            ),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.black.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.forest, width: 2),
              ),
              contentPadding: const EdgeInsets.only(bottom: 2),
            ),
            cursorColor: AppTheme.forest,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            await vm.setPetName(_nameCtrl.text.trim());
            setState(() => _editingName = false);
          },
          child: Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: AppTheme.forest, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 18, color: AppTheme.onDark),
          ),
        ),
      ],
    );
  }
}

// ── Reusable bento tile ────────────────────────────────────────────────────
class _BentoTile extends StatelessWidget {
  final Color color;
  final double? height;
  final double radius;
  final Widget child;

  const _BentoTile({
    required this.color,
    required this.height,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

// ── Avatar bubble ──────────────────────────────────────────────────────────
class _BentoAvatar extends StatelessWidget {
  final String letter;
  final bool active;
  const _BentoAvatar({required this.letter, required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppTheme.forest,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.bg, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            letter.toUpperCase(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900,
              color: AppTheme.onDark,
            ),
          ),
        ),
        if (active)
          Positioned(
            right: 0, top: 0,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: AppTheme.rust,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Permission Dialog ──────────────────────────────────────────────────────
class _PermissionDialog extends StatefulWidget {
  final HomeViewModel vm;
  const _PermissionDialog({required this.vm});
  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final needsOverlay = !vm.hasOverlayPermission;

    return Dialog(
      backgroundColor: AppTheme.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACCESS', style: AppTheme.tileLabel),
                  const SizedBox(height: 4),
                  const Text('Needed.',
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: AppTheme.onDark, letterSpacing: -1.5, height: 1.0,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!vm.hasOverlayPermission)
              _permRow(Icons.layers_outlined, 'Display over apps',
                  'Show pet on top', vm.hasOverlayPermission),
            if (!vm.hasAccessibilityPermission)
              _permRow(Icons.accessibility_new_outlined, 'Accessibility',
                  'Detect monitored apps', vm.hasAccessibilityPermission),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loading ? null : _grant,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.rust,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                    : Text(
                        needsOverlay ? 'Grant Display' : 'Grant Accessibility',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: AppTheme.white, letterSpacing: -0.2,
                        )),
              ),
            ),
            if (vm.hasAllPermissions) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Center(
                  child: Text('Done',
                      style: TextStyle(fontSize: 13, color: AppTheme.grey5,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _permRow(IconData icon, String title, String sub, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cream2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.black.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppTheme.black)),
                Text(sub, style: AppTheme.metaLabel),
              ],
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: done ? AppTheme.olive : AppTheme.grey5,
          ),
        ],
      ),
    );
  }

  Future<void> _grant() async {
    final vm = widget.vm;
    setState(() => _loading = true);
    if (!vm.hasOverlayPermission) {
      await vm.requestOverlayPermission();
    } else {
      await vm.requestAccessibilityPermission();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    await vm.checkPermissions();
    if (mounted) {
      setState(() => _loading = false);
      if (vm.hasAllPermissions) Navigator.of(context).pop();
    }
  }
}