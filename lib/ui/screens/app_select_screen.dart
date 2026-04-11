import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/app_theme.dart';

class AppSelectScreen extends StatefulWidget {
  const AppSelectScreen({Key? key}) : super(key: key);
  @override
  State<AppSelectScreen> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState extends State<AppSelectScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Opens a bento-styled dialog when an app row is tapped
  void _showAppDialog(
      BuildContext context, AppSelectViewModel vm, dynamic app) {
    final monitored = vm.isAppMonitored(app.packageName);
    final name = app.appName as String;
    final pkg = app.packageName as String;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.forest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _AppIcon(iconBase64: app.iconBase64, appName: name),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APP', style: AppTheme.tileLabel),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900,
                              color: AppTheme.onDark, letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Package tile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cream2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PACKAGE', style: AppTheme.tileLabelDark),
                    const SizedBox(height: 4),
                    Text(
                      pkg,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: AppTheme.grey5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Status tile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: monitored
                      ? AppTheme.forest.withOpacity(0.08)
                      : AppTheme.cream2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: monitored ? AppTheme.forest : AppTheme.lineColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      monitored
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: monitored ? AppTheme.forest : AppTheme.grey5,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      monitored ? 'Currently monitoring' : 'Not monitoring',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: monitored ? AppTheme.forest : AppTheme.grey5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Action button
              GestureDetector(
                onTap: () {
                  vm.toggleApp(pkg);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: monitored ? AppTheme.rust : AppTheme.forest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    monitored ? 'Remove from Monitoring' : 'Add to Monitoring',
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppTheme.white, letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Center(
                  child: Text('Cancel',
                      style: TextStyle(
                        fontSize: 13, color: AppTheme.grey5,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final pad = AppTheme.hPad(context);
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Consumer<AppSelectViewModel>(
      builder: (context, vm, _) {
        final filtered = _query.isEmpty
            ? vm.installedApps
            : vm.installedApps
                .where((a) =>
                    a.appName.toLowerCase().contains(_query.toLowerCase()) ||
                    a.packageName.toLowerCase().contains(_query.toLowerCase()))
                .toList();
        final count = vm.monitoredApps.length;

        return Container(
          color: AppTheme.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: top + 12),

              // ── FocusPet banner ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.forest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Text('FOCUSPET',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900,
                            color: AppTheme.onDark, letterSpacing: 3.0,
                          )),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? AppTheme.rust
                              : AppTheme.onDark.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('selected',
                                style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w600,
                                  color: AppTheme.white, letterSpacing: 1.0,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Search tile ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cream2,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.lineColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 18, color: AppTheme.grey5),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppTheme.black, letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search apps...',
                            hintStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500,
                              color: AppTheme.grey5.withOpacity(0.6),
                            ),
                          ),
                          cursorColor: AppTheme.forest,
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _ctrl.clear();
                            setState(() => _query = '');
                          },
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.lineColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 13, color: AppTheme.grey5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── App list ───────────────────────────────────────────────
              Expanded(
                child: vm.isLoading
                    ? _loader()
                    : filtered.isEmpty
                        ? _empty(_query.isNotEmpty)
                        : isTablet
                            ? _tabletGrid(vm, filtered, pad)
                            : _phoneList(vm, filtered, pad),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tablet: 2-column grid of app tiles
  Widget _tabletGrid(
      AppSelectViewModel vm, List<dynamic> apps, double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.5,
        ),
        itemCount: apps.length,
        itemBuilder: (ctx, i) => _row(vm, apps[i], i),
      ),
    );
  }

  // Phone: single list
  Widget _phoneList(
      AppSelectViewModel vm, List<dynamic> apps, double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: apps.length,
        itemBuilder: (ctx, i) => _row(vm, apps[i], i),
      ),
    );
  }

  Widget _loader() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.forest),
            ),
            SizedBox(height: 14),
            Text('Loading apps...', style: AppTheme.metaLabel),
          ],
        ),
      );

  Widget _empty(bool searching) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppTheme.cream2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 28, color: AppTheme.grey5),
            ),
            const SizedBox(height: 16),
            Text(
              searching ? 'No Results.' : 'No Apps.',
              style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900,
                color: AppTheme.black, letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              searching ? 'Try a different term' : 'No launchable apps found',
              style: AppTheme.metaLabel,
            ),
          ],
        ),
      );

  Widget _row(AppSelectViewModel vm, dynamic app, int index) {
    final monitored = vm.isAppMonitored(app.packageName);
    final tileColors = [AppTheme.cream2, AppTheme.bg, AppTheme.mint];
    final bgColor = monitored
        ? AppTheme.forest.withOpacity(0.08)
        : tileColors[index % tileColors.length];

    return GestureDetector(
      onTap: () => _showAppDialog(context, vm, app),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: monitored
              ? Border.all(color: AppTheme.forest, width: 1.5)
              : Border.all(color: AppTheme.lineColor, width: 1),
        ),
        child: Row(
          children: [
            _AppIcon(iconBase64: app.iconBase64, appName: app.appName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppTheme.black, letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    monitored
                        ? '● Monitoring'
                        : app.packageName.split('.').last,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          monitored ? FontWeight.w700 : FontWeight.w400,
                      color: monitored ? AppTheme.forest : AppTheme.grey5,
                      letterSpacing: monitored ? 0.3 : 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Tap hint arrow
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: monitored
                    ? AppTheme.forest
                    : AppTheme.grey5.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final String? iconBase64;
  final String appName;
  const _AppIcon({required this.iconBase64, required this.appName});

  @override
  Widget build(BuildContext context) {
    if (iconBase64 != null && iconBase64!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            base64Decode(iconBase64!),
            width: 40, height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letter(),
          ),
        );
      } catch (_) {}
    }
    return _letter();
  }

  Widget _letter() {
    final colors = [
      AppTheme.rust, AppTheme.mustard, AppTheme.forest,
      AppTheme.clay, AppTheme.olive, AppTheme.sage,
    ];
    final color = colors[appName.isNotEmpty
        ? appName.codeUnitAt(0) % colors.length
        : 0];
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        appName.isNotEmpty ? appName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.white,
        ),
      ),
    );
  }
}