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

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final pad = AppTheme.hPad(context);

    return Consumer<AppSelectViewModel>(
      builder: (context, vm, _) {
        final filtered = _query.isEmpty
            ? vm.installedApps
            : vm.installedApps.where((a) =>
                a.appName.toLowerCase().contains(_query.toLowerCase()) ||
                a.packageName.toLowerCase().contains(_query.toLowerCase())).toList();
        final count = vm.monitoredApps.length;

        return Container(
          color: AppTheme.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: top + 16),

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Monitor Your',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500,
                                color: AppTheme.grey5,
                              )),
                          Text('Apps.',
                              style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w900,
                                color: AppTheme.black,
                                letterSpacing: -1.2, height: 1.0,
                              )),
                        ],
                      ),
                    ),
                    // Count bento badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: count > 0 ? AppTheme.rust : AppTheme.cream2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900,
                              color: count > 0 ? AppTheme.white : AppTheme.grey5,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'selected',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: count > 0
                                  ? AppTheme.white.withOpacity(0.8)
                                  : AppTheme.grey5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Bento search tile ────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.forest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 18, color: AppTheme.onDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppTheme.onDark, letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Search apps...',
                            hintStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500,
                              color: AppTheme.onDark.withOpacity(0.4),
                            ),
                          ),
                          cursorColor: AppTheme.onDark,
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
                              color: AppTheme.onDark.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded,
                                size: 13,
                                color: AppTheme.onDark.withOpacity(0.8)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── App list ─────────────────────────────────────────────────
              Expanded(
                child: vm.isLoading
                    ? _loader()
                    : filtered.isEmpty
                        ? _empty(_query.isNotEmpty)
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: pad),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) => _row(vm, filtered[i], i),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
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
    // Alternating tile colors for bento feel
    final tileColors = [AppTheme.cream2, AppTheme.bg, AppTheme.mint];
    final bgColor = monitored
        ? AppTheme.forest.withOpacity(0.08)
        : tileColors[index % tileColors.length];

    return GestureDetector(
      onTap: () => vm.toggleApp(app.packageName),
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
            // App icon
            _AppIcon(iconBase64: app.iconBase64, appName: app.appName),
            const SizedBox(width: 12),

            // Name + status
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
                    monitored ? '● Monitoring' : app.packageName.split('.').last,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: monitored ? FontWeight.w700 : FontWeight.w400,
                      color: monitored ? AppTheme.forest : AppTheme.grey5,
                      letterSpacing: monitored ? 0.3 : 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Bento-style checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: monitored ? AppTheme.forest : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: monitored ? AppTheme.forest : AppTheme.grey5,
                  width: 1.5,
                ),
              ),
              child: monitored
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: AppTheme.onDark)
                  : null,
            ),
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
    // Cycle through bento colors for letter avatars
    final colors = [AppTheme.rust, AppTheme.mustard, AppTheme.forest,
                    AppTheme.clay, AppTheme.olive, AppTheme.sage];
    final color = colors[appName.isNotEmpty
        ? appName.codeUnitAt(0) % colors.length
        : 0];

    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        appName.isNotEmpty ? appName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w900,
          color: AppTheme.white,
        ),
      ),
    );
  }
}