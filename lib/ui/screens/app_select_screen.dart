import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/platform_service.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/sticker.dart';

final Map<String, Uint8List?> _iconCache = {};

Uint8List? _iconBytes(InstalledApp a) {
  final b = a.iconBase64;
  if (b == null || b.isEmpty) return null;
  return _iconCache.putIfAbsent(a.packageName, () {
    try {
      return base64Decode(b);
    } catch (_) {
      return null;
    }
  });
}

class AppSelectScreen extends StatefulWidget {
  const AppSelectScreen({super.key});
  @override
  State<AppSelectScreen> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState extends State<AppSelectScreen> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppSelectViewModel>();
    final n = vm.monitoredApps.length;
    final pad = AppTheme.hPad(context);

    final apps = vm.installedApps
        .where((a) => _q.isEmpty || a.appName.toLowerCase().contains(_q) || a.packageName.toLowerCase().contains(_q))
        .toList()
      ..sort((a, b) {
        final ma = vm.isAppMonitored(a.packageName), mb = vm.isAppMonitored(b.packageName);
        if (ma != mb) return ma ? -1 : 1;
        return a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
      });

    return ColoredBox(
      color: AppTheme.bg,
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Text('Watch list', style: AppTheme.display(28)),
                const Spacer(),
                StickerChip(label: '$n selected', color: n > 0 ? AppTheme.accent400 : AppTheme.paper, tilt: 3),
              ]),
              const SizedBox(height: 14),
              _searchField(),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(child: _body(vm, apps, pad)),
        ]),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.ink, width: AppTheme.border),
      ),
      child: Row(children: [
        const Icon(Icons.search_rounded, color: AppTheme.n700),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            style: AppTheme.body(weight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Find an app',
              hintStyle: AppTheme.body(weight: FontWeight.w600, color: AppTheme.n600),
            ),
          ),
        ),
        if (_q.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.ink),
            onPressed: () => setState(() {
              _search.clear();
              _q = '';
            }),
          ),
      ]),
    );
  }

  Widget _body(AppSelectViewModel vm, List<InstalledApp> apps, double pad) {
    if (vm.isLoading && vm.installedApps.isEmpty) {
      return _StateMessage(vm: vm, title: 'Loading apps...', sub: 'Sniffing around your phone');
    }
    if (apps.isEmpty) {
      return _q.isNotEmpty
          ? _StateMessage(vm: vm, title: 'No Results.', sub: 'Nothing matches "$_q"')
          : _StateMessage(vm: vm, title: 'No Apps.', sub: 'Pull down to try again', onRetry: vm.refresh);
    }

    final isTablet = MediaQuery.of(context).size.width >= 700;
    final padding = EdgeInsets.fromLTRB(pad, 0, pad, 130);

    if (isTablet) {
      return GridView.builder(
        padding: padding,
        itemCount: apps.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 124,
        ),
        itemBuilder: (_, i) => _AppTile(app: apps[i], monitored: vm.isAppMonitored(apps[i].packageName), compact: true, onTap: () => _showDetail(vm, apps[i])),
      );
    }
    return RefreshIndicator(
      color: AppTheme.accent600,
      onRefresh: vm.refresh,
      child: ListView.separated(
        padding: padding,
        itemCount: apps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _AppTile(app: apps[i], monitored: vm.isAppMonitored(apps[i].packageName), onTap: () => _showDetail(vm, apps[i])),
      ),
    );
  }

  Future<void> _showDetail(AppSelectViewModel vm, InstalledApp app) {
    return showDialog(
      context: context,
      barrierColor: AppTheme.ink.withOpacity(0.45),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<AppSelectViewModel>(builder: (ctx, vm, _) {
          final on = vm.isAppMonitored(app.packageName);
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.ink, width: AppTheme.border),
                boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(6, 6))],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: AppTheme.sage500,
                    border: Border(bottom: BorderSide(color: AppTheme.ink, width: AppTheme.border)),
                  ),
                  child: Row(children: [
                    _AppIcon(app: app, size: 56),
                    const SizedBox(width: 12),
                    Expanded(child: Text(app.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(26))),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('PACKAGE', style: AppTheme.kicker()),
                        const SizedBox(height: 2),
                        Text(app.packageName, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppTheme.ink)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? AppTheme.sage500 : AppTheme.n300,
                          border: Border.all(color: AppTheme.ink, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(on ? 'Currently monitoring' : 'Not monitoring', style: AppTheme.body(weight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 12),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      petSprite(vm.prefs.selectedPet, 52),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SpeechBubble(
                            on ? "Remove it and I'll stop showing up here." : "Add it and I'll keep an eye on it for you.",
                            fontSize: 13.5,
                            shadow: 0,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    PushButton(
                      label: on ? 'Remove from Monitoring' : 'Add to Monitoring',
                      color: on ? AppTheme.accent600 : AppTheme.sage500,
                      textColor: on ? Colors.white : AppTheme.ink,
                      fontSize: 17,
                      onTap: () async {
                        await vm.toggleApp(app.packageName);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: AppTheme.body(size: 14, weight: FontWeight.w800, color: AppTheme.n700)),
                    ),
                  ]),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app, required this.monitored, required this.onTap, this.compact = false});
  final InstalledApp app;
  final bool monitored;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = monitored
        ? Text('● Monitoring', style: AppTheme.body(size: 12.5, weight: FontWeight.w800, color: AppTheme.sage800))
        : Text(app.packageName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body(size: 12, color: AppTheme.n600));
    final title = Text(app.appName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.body(weight: FontWeight.w800));

    return Sticker(
      color: monitored ? AppTheme.sage200 : AppTheme.paper,
      borderColor: monitored ? AppTheme.ink : AppTheme.n300,
      shadow: monitored ? 3 : 0,
      padding: compact ? const EdgeInsets.all(10) : const EdgeInsets.fromLTRB(8, 8, 12, 8),
      onTap: onTap,
      child: compact
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _AppIcon(app: app),
              const SizedBox(height: 6),
              title,
              status,
            ])
          : Row(children: [
              _AppIcon(app: app),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, status])),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.ink),
            ]),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.app, this.size = 42});
  final InstalledApp app;
  final double size;

  static const _palette = [AppTheme.accent300, AppTheme.accent400, AppTheme.sage300, AppTheme.surface, AppTheme.accent200];

  @override
  Widget build(BuildContext context) {
    final bytes = _iconBytes(app);
    final letter = app.appName.isEmpty ? '?' : app.appName[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bytes == null ? _palette[app.packageName.hashCode.abs() % _palette.length] : AppTheme.paper,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: AppTheme.ink, width: 2.5),
      ),
      child: bytes != null
          ? Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true)
          : Text(letter, style: AppTheme.display(size * 0.4)),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.vm, required this.title, required this.sub, this.onRetry});
  final AppSelectViewModel vm;
  final String title;
  final String sub;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          petSprite(vm.prefs.selectedPet, 96),
          const SizedBox(height: 10),
          Text(title, style: AppTheme.display(24)),
          const SizedBox(height: 4),
          Text(sub, style: AppTheme.body(size: 14, color: AppTheme.n700)),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            SizedBox(width: 160, child: PushButton(label: 'Try again', fontSize: 16, depth: 4, onTap: () => onRetry!())),
          ],
        ]),
      ),
    );
  }
}
