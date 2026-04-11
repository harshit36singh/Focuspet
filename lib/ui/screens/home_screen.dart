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
  bool _hasShownDialog = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<HomeViewModel>();
      await vm.checkPermissions();
      if (!mounted) return;
      if (!vm.hasAllPermissions && !_hasShownDialog) {
        _hasShownDialog = true;
        _showPermissionDialog(vm);
      }
    });
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
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Container(
      color: AppTheme.bg,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: isTablet ? 24 : 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: top + 12),

            // ── FocusPet banner ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.forest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Text(
                      'FOCUSPET',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.onDark,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (!vm.hasAllPermissions) _showPermissionDialog(vm);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: vm.hasAllPermissions
                              ? AppTheme.onDark.withOpacity(0.15)
                              : AppTheme.rust,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              vm.hasAllPermissions
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              size: 12,
                              color: AppTheme.onDark,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              vm.hasAllPermissions ? 'READY' : 'SETUP',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onDark,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (isTablet)
              _buildTabletLayout(vm, pad)
            else
              _buildPhoneLayout(vm, pad),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TABLET: full bento grid, everything on one page
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTabletLayout(HomeViewModel vm, double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Column(
        children: [
          // Row 1: Pet (large) | Status + Delay | Watching + Always-on + Perm
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet tile
              Expanded(
                flex: 2,
                child: _petTile(vm),
              ),
              const SizedBox(width: 10),
              // Status + Delay stacked
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _statusTile(vm),
                    const SizedBox(height: 10),
                    _delayTile(vm),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Watching + Always + Perm stacked
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _watchingTile(vm),
                    const SizedBox(height: 10),
                    _alwaysTile(vm),
                    const SizedBox(height: 10),
                    _permTile(vm),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Monitored apps (wide) | Focus mode + Tip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _monitoredAppsTile(vm)),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _focusModeTile(vm),
                    const SizedBox(height: 10),
                    _tipTile(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PHONE: vertical bento, tightly packed
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPhoneLayout(HomeViewModel vm, double pad) {
    return Column(
      children: [
        // Row 1: Pet + (Status / Delay)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _petTile(vm)),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _statusTile(vm),
                    const SizedBox(height: 10),
                    _delayTile(vm),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Row 2: Watching + Always-on + Perm
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              Expanded(flex: 2, child: _watchingTile(vm)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _alwaysTile(vm)),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _permTile(vm)),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Row 3: Monitored apps wide tile
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: _monitoredAppsTile(vm),
        ),

        const SizedBox(height: 10),

        // Row 4: Focus mode + Tip
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              Expanded(flex: 2, child: _focusModeTile(vm)),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: _tipTile()),
            ],
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ── Tile builders ──────────────────────────────────────────────────────

  Widget _petTile(HomeViewModel vm) => _BentoTile(
        color: AppTheme.forest,
        height: 200,
        child: Stack(
          children: [
            Positioned(
              top: 16, left: 16,
              child: Text('MY PET', style: AppTheme.tileLabel),
            ),
            Center(
              child: SizedBox(
                width: 110, height: 110,
                child: PetSpriteWidget(
                  petType: vm.selectedPetType,
                  state: PetAnimState.idle,
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 16, right: 40,
              child: Text(
                vm.petName.isEmpty ? 'My Pet' : vm.petName,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppTheme.onDark, letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              top: 14, right: 14,
              child: const Icon(Icons.favorite_rounded,
                  size: 18, color: AppTheme.rust),
            ),
          ],
        ),
      );

  Widget _statusTile(HomeViewModel vm) => GestureDetector(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STATUS',
                  style: vm.isServiceRunning
                      ? AppTheme.tileLabel
                      : AppTheme.tileLabelDark),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomLeft,
                    child: Text(vm.isServiceRunning ? 'ON' : 'OFF',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                        color: vm.isServiceRunning ? AppTheme.onDark : AppTheme.black,
                        letterSpacing: -1.0, height: 1.0)))),
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
      );

  Widget _delayTile(HomeViewModel vm) => _BentoTile(
        color: AppTheme.mustard,
        height: 95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('APPEAR', style: AppTheme.tileLabel),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomLeft,
                  child: Text('${vm.interruptDelayMinutes}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                      color: AppTheme.white, letterSpacing: -1.5, height: 1.0)))),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('min', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  )),
                ),
                const Spacer(),
                const Icon(Icons.timer_rounded, size: 22, color: AppTheme.white),
              ],
            ),
          ],
        ),
      );

  Widget _watchingTile(HomeViewModel vm) => _BentoTile(
        color: AppTheme.olive,
        height: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WATCHING', style: AppTheme.tileLabel),
            const Spacer(),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text('${vm.monitoredApps.length}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900,
                  color: AppTheme.onDark, letterSpacing: -2.0, height: 0.9))),
            const Text('apps', style: TextStyle(
              fontSize: 11, color: AppTheme.onDark, fontWeight: FontWeight.w500,
            )),
          ],
        ),
      );

  Widget _alwaysTile(HomeViewModel vm) => GestureDetector(
        onTap: () => vm.toggleAlwaysActive(),
        child: _BentoTile(
          color: vm.alwaysActive ? AppTheme.clay : AppTheme.mint,
          height: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ALWAYS ON',
                  style: vm.alwaysActive
                      ? AppTheme.tileLabel
                      : AppTheme.tileLabelDark),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomLeft,
                    child: Text(vm.alwaysActive ? 'Yes' : 'No',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
                        color: vm.alwaysActive ? AppTheme.onDark : AppTheme.black,
                        letterSpacing: -1.0, height: 1.0)))),
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
      );

  Widget _permTile(HomeViewModel vm) => GestureDetector(
        onTap: () {
          if (!vm.hasAllPermissions) _showPermissionDialog(vm);
        },
        child: _BentoTile(
          color: vm.hasAllPermissions
              ? AppTheme.sage
              : AppTheme.rust.withOpacity(0.85),
          height: 110,
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
      );

  Widget _monitoredAppsTile(HomeViewModel vm) => _BentoTile(
        color: AppTheme.cream2,
        height: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('MONITORED APPS', style: AppTheme.tileLabelDark),
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
              // Horizontal scrollable app icon row
              SizedBox(
                height: 68,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.monitoredApps.length,
                  itemBuilder: (ctx, i) {
                    final pkg = vm.monitoredApps.elementAt(i);
                    final name = pkg.split('.').last;
                    final display = name.isEmpty
                        ? pkg
                        : name[0].toUpperCase() + name.substring(1);
                    final colors = [
                      AppTheme.rust, AppTheme.mustard, AppTheme.forest,
                      AppTheme.clay, AppTheme.olive, AppTheme.sage,
                    ];
                    final color = colors[pkg.isNotEmpty
                        ? pkg.codeUnitAt(0) % colors.length
                        : 0];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              display.isNotEmpty ? display[0] : '?',
                              style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 44,
                            child: Text(
                              display,
                              style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w600,
                                color: AppTheme.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );

  Widget _focusModeTile(HomeViewModel vm) => _BentoTile(
        color: AppTheme.rust,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FOCUS MODE', style: AppTheme.tileLabel),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomLeft,
                  child: Text(vm.isServiceRunning ? 'Active' : 'Idle',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                      color: AppTheme.onDark, letterSpacing: -0.8, height: 1.0)))),
                const Spacer(),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.onDark.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, size: 18, color: AppTheme.onDark),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _tipTile() => _BentoTile(
        color: AppTheme.forest,
        height: 100,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TIP', style: AppTheme.tileLabel),
            SizedBox(height: 8),
            Text(
              'Stay focused.\nYour pet is watching.',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.onDark, height: 1.35, letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
}

// ── Reusable bento tile ────────────────────────────────────────────────────
class _BentoTile extends StatelessWidget {
  final Color color;
  final double? height;
  final Widget child;

  const _BentoTile({
    required this.color,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      );
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACCESS', style: AppTheme.tileLabel),
                  SizedBox(height: 4),
                  Text('Needed.',
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
                    ? const SizedBox(
                        width: 18, height: 18,
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

  Widget _permRow(IconData icon, String title, String sub, bool done) =>
      Container(
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