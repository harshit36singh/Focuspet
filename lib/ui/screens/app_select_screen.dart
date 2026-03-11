import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/pixel_theme.dart';

class AppSelectScreen extends StatefulWidget {
  const AppSelectScreen({Key? key}) : super(key: key);

  @override
  State<AppSelectScreen> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState extends State<AppSelectScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Consumer<AppSelectViewModel>(
      builder: (context, vm, _) {
        // Filter apps by search query
        final filtered = _query.isEmpty
            ? vm.installedApps
            : vm.installedApps
                .where((a) =>
                    a.appName.toLowerCase().contains(_query.toLowerCase()) ||
                    a.packageName.toLowerCase().contains(_query.toLowerCase()))
                .toList();

        final monitoredCount = vm.monitoredApps.length;

        return Column(children: [
          PixelTitleBar(topPadding: top, title: 'FOCUS PET'),

          // ── Sub-header with count badge ──
          Container(
            color: PixelTheme.bgDark,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Text('●',
                  style: PixelTheme.pixelFont(
                      size: 9, color: PixelTheme.accent2)),
              const SizedBox(width: 9),
              Text('MONITORED APPS',
                  style: PixelTheme.pixelFont(
                      size: 8,
                      weight: FontWeight.bold,
                      color: PixelTheme.accent2)),
              const Spacer(),
              if (monitoredCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: PixelTheme.accent2,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black, offset: Offset(2, 2))
                    ],
                  ),
                  child: Text(
                    '$monitoredCount SELECTED',
                    style: PixelTheme.pixelFont(
                        size: 6,
                        color: PixelTheme.bg,
                        weight: FontWeight.bold,
                        shadows: []),
                  ),
                ),
            ]),
          ),

          // ── Search bar ──
          Container(
            color: PixelTheme.bg,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Container(
              decoration: BoxDecoration(
                color: PixelTheme.bgDark,
                border: Border.all(color: PixelTheme.border, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(3, 3))
                ],
              ),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '🔍',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: PixelTheme.pixelFont(
                        size: 9,
                        color: PixelTheme.textPrimary,
                        shadows: []),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      hintText: 'SEARCH APPS...',
                      hintStyle: PixelTheme.pixelFont(
                          size: 8,
                          color: PixelTheme.textSec,
                          shadows: []),
                    ),
                    cursorColor: PixelTheme.accent,
                    cursorWidth: 2,
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '✕',
                        style: PixelTheme.pixelFont(
                            size: 10,
                            color: PixelTheme.textSec,
                            shadows: []),
                      ),
                    ),
                  ),
              ]),
            ),
          ),

          // ── App list ──
          Expanded(
            child: vm.isLoading
                ? _buildLoader()
                : filtered.isEmpty
                    ? _buildEmpty(_query.isNotEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 110),
                        itemCount: filtered.length,
                        // Use a fixed item height for maximum scroll performance
                        itemExtent: 66,
                        itemBuilder: (context, i) =>
                            _appRow(vm, filtered[i], i),
                      ),
          ),
        ]);
      },
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _PixelSpinner(),
        const SizedBox(height: 16),
        Text('LOADING APPS...',
            style: PixelTheme.pixelFont(
                size: 9, color: PixelTheme.accent)),
      ]),
    );
  }

  Widget _buildEmpty(bool searching) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(searching ? '✕' : '?',
            style: PixelTheme.pixelFont(
                size: 32, color: PixelTheme.textSec)),
        const SizedBox(height: 12),
        Text(
          searching ? 'NO RESULTS FOR\n"${_query.toUpperCase()}"' : 'NO USER APPS FOUND',
          style: PixelTheme.t9sec,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _appRow(AppSelectViewModel vm, dynamic app, int index) {
    final monitored = vm.isAppMonitored(app.packageName);

    // Cycle accent colors for variety in the list
    const rowAccents = [
      PixelTheme.accent,
      PixelTheme.accent4,
      PixelTheme.accent3,
      PixelTheme.accent5,
    ];
    final accent = rowAccents[index % rowAccents.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => vm.toggleApp(app.packageName),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: monitored ? const Color(0xFF101020) : PixelTheme.surface,
            border: Border.all(
              color: monitored ? accent : PixelTheme.border,
              width: monitored ? 2 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(3, 3))
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            // Icon box — letter initial
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: monitored
                    ? accent.withOpacity(0.15)
                    : PixelTheme.bgDark,
                border: Border.all(
                  color: monitored ? accent : PixelTheme.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  app.appName.isNotEmpty
                      ? app.appName[0].toUpperCase()
                      : '?',
                  style: PixelTheme.pixelFont(
                    size: 12,
                    weight: FontWeight.bold,
                    color: monitored ? accent : PixelTheme.textSec,
                    shadows: [],
                  ),
                ),
              ),
            ),

            // App info
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      app.appName.toUpperCase(),
                      style: PixelTheme.pixelFont(
                        size: 8,
                        weight: FontWeight.bold,
                        color: monitored
                            ? PixelTheme.textPrimary
                            : PixelTheme.textSec,
                        shadows: [],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (monitored) ...[
                      const SizedBox(height: 3),
                      Text(
                        '▶ MONITORING',
                        style: PixelTheme.pixelFont(
                            size: 6, color: accent, shadows: []),
                      ),
                    ],
                  ]),
            ),

            // Checkbox
            PixelCheckbox(checked: monitored),
          ]),
        ),
      ),
    );
  }
}

// ── Simple pixel spinner ──────────────────────────────────────────────────
class _PixelSpinner extends StatefulWidget {
  @override
  State<_PixelSpinner> createState() => _PixelSpinnerState();
}

class _PixelSpinnerState extends State<_PixelSpinner> {
  int _frame = 0;
  static const _frames = ['◤', '◥', '◢', '◣'];

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _frame = (_frame + 1) % _frames.length);
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Text(
        _frames[_frame],
        style: PixelTheme.pixelFont(size: 28, color: PixelTheme.accent),
      );
}