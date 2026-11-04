import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/sticker.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User may have just granted a permission in system settings.
    if (state == AppLifecycleState.resumed) context.read<HomeViewModel>().checkPermissions();
  }

  String _message(HomeViewModel vm) {
    if (!vm.hasAllPermissions) return 'I need a couple of permissions first. Tap Setup!';
    if (vm.monitoredApps.isEmpty) return 'Pick some apps for me to watch in the Apps tab.';
    if (!vm.isServiceRunning) return "I'm napping. Tap the big button when you're ready to focus.";
    if (vm.currentStreak > 0) return '${vm.currentStreak} day streak! Let\'s keep it going!';
    return "On duty! I'll pop in after ${vm.interruptDelayMinutes} min on your watched apps.";
  }

  void _openStats(HomeViewModel vm) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(value: vm, child: const StatsScreen()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final name = vm.petName.isEmpty ? niceName(vm.selectedPetType.displayName) : vm.petName;
    final running = vm.isServiceRunning;
    final pad = AppTheme.hPad(context);

    return ColoredBox(
      color: AppTheme.accent200,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 130),
          children: [
            Row(children: [
              Text('FocusPet',
                  style: AppTheme.display(30).copyWith(
                      shadows: const [Shadow(color: AppTheme.accent400, offset: Offset(2, 2))])),
              const Spacer(),
              StickerChip(
                label: vm.hasAllPermissions ? 'Ready' : 'Setup',
                icon: vm.hasAllPermissions ? Icons.check_rounded : Icons.warning_amber_rounded,
                color: vm.hasAllPermissions ? AppTheme.sage300 : AppTheme.accent400,
                tilt: 4,
                onTap: vm.hasAllPermissions ? null : () => showPermissionSheet(context, vm),
              ),
            ]),
            const SizedBox(height: 16),
            PetStage(
              pet: vm.selectedPetType,
              name: name,
              message: _message(vm),
              onRename: () => _rename(context, vm, name),
            ),
            const SizedBox(height: 20),
            PushButton(
              label: running ? "I'm on watch!" : 'Start watching',
              icon: running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: running ? AppTheme.accent600 : AppTheme.sage500,
              textColor: running ? Colors.white : AppTheme.ink,
              onTap: () {
                if (!vm.hasAllPermissions) {
                  showPermissionSheet(context, vm);
                  return;
                }
                running ? vm.stopService() : vm.startService();
              },
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => _openStats(vm),
              child: Row(children: [
                Expanded(child: StatTile(value: '${vm.currentStreak}', label: 'day streak')),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    value: vm.formatTime(vm.totalTimeSavedSec),
                    label: 'saved',
                    color: AppTheme.sage200,
                    labelColor: AppTheme.sage800,
                    tilt: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: StatTile(value: '${vm.sessionCount}', label: 'sessions')),
              ]),
            ),
            const SizedBox(height: 16),
            Sticker(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Always on', style: AppTheme.body(weight: FontWeight.w800)),
                    Text('Keep watching in the background',
                        style: AppTheme.body(size: 13, color: AppTheme.n700)),
                  ]),
                ),
                StickerSwitch(value: vm.alwaysActive, onChanged: (_) => vm.toggleAlwaysActive()),
              ]),
            ),
            const SizedBox(height: 12),
            Text(
              vm.monitoredApps.isEmpty
                  ? 'No apps on the watch list yet'
                  : 'Watching ${vm.monitoredApps.length} apps · I pop in after ${vm.interruptDelayMinutes} min',
              style: AppTheme.body(size: 13, weight: FontWeight.w700, color: AppTheme.n700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, HomeViewModel vm, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      barrierColor: AppTheme.ink.withOpacity(0.45),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Sticker(
          color: AppTheme.bg,
          radius: 30,
          shadow: 6,
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('A new name?', style: AppTheme.display(26)),
            const SizedBox(height: 12),
            NameField(controller: ctrl),
            const SizedBox(height: 16),
            PushButton(label: 'Save', onTap: () => Navigator.pop(ctx, ctrl.text.trim())),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTheme.body(size: 14, weight: FontWeight.w800, color: AppTheme.n700)),
            ),
          ]),
        ),
      ),
    );
    if (result != null && result.isNotEmpty) await vm.setPetName(result);
  }
}

// ── Permission sheet ─────────────────────────────────────────────────────

void showPermissionSheet(BuildContext context, HomeViewModel vm) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppTheme.ink.withOpacity(0.45),
    builder: (_) => ChangeNotifierProvider.value(value: vm, child: const _PermissionSheet()),
  );
}

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final bottom = MediaQuery.of(context).padding.bottom;

    String label;
    VoidCallback onTap;
    if (!vm.hasOverlayPermission) {
      label = 'Grant Display';
      onTap = vm.requestOverlayPermission;
    } else if (!vm.hasAccessibilityPermission) {
      label = 'Grant Accessibility';
      onTap = vm.requestAccessibilityPermission;
    } else {
      label = 'All set!';
      onTap = () => Navigator.pop(context);
    }

    return Stack(children: [
      Container(
        margin: const EdgeInsets.only(top: 74),
        padding: EdgeInsets.fromLTRB(20, 22, 20, 20 + bottom),
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          border: Border(top: BorderSide(color: AppTheme.ink, width: AppTheme.border)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Align(alignment: Alignment.centerLeft, child: StickerChip(label: 'Almost ready', color: AppTheme.accent300, tilt: -3)),
          const SizedBox(height: 10),
          Text('Two quick favors', style: AppTheme.display(28)),
          const SizedBox(height: 6),
          Text('I need these so I can pop in when you need me.',
              style: AppTheme.body(size: 14, color: AppTheme.n700)),
          const SizedBox(height: 14),
          _PermRow(n: 1, title: 'Display over apps', sub: 'So I can show up on top', granted: vm.hasOverlayPermission),
          const SizedBox(height: 10),
          _PermRow(n: 2, title: 'Accessibility', sub: 'So I notice watched apps', granted: vm.hasAccessibilityPermission),
          const SizedBox(height: 16),
          PushButton(label: label, onTap: onTap),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe later', style: AppTheme.body(size: 14, weight: FontWeight.w800, color: AppTheme.n700)),
          ),
        ]),
      ),
      Positioned(top: 0, right: 26, child: petSprite(vm.selectedPetType, 84)),
    ]);
  }
}

class _PermRow extends StatelessWidget {
  const _PermRow({required this.n, required this.title, required this.sub, required this.granted});
  final int n;
  final String title;
  final String sub;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: granted ? AppTheme.sage200 : AppTheme.paper,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: granted ? AppTheme.sage500 : Colors.transparent,
            border: Border.all(color: AppTheme.ink, width: AppTheme.border),
          ),
          child: granted
              ? const Icon(Icons.check_rounded, size: 18, color: AppTheme.ink)
              : Text('$n', style: AppTheme.display(15)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTheme.body(weight: FontWeight.w800)),
            Text(sub, style: AppTheme.body(size: 13, color: granted ? AppTheme.sage800 : AppTheme.n700)),
          ]),
        ),
      ]),
    );
  }
}
