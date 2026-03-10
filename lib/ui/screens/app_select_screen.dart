import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/app_select_viewmodel.dart';
import '../theme/pixel_theme.dart';

class AppSelectScreen extends StatelessWidget {
  const AppSelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Consumer<AppSelectViewModel>(
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
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: PixelTheme.accent,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 120,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PixelSectionLabel('MONITORED APPS'),
                          const SizedBox(height: 6),
                          Text(
                            'Pet appears when you open\nany of these apps.',
                            style: PixelTheme.pixelFont(
                              size: 11,
                              color: PixelTheme.textSecondary,
                            ).copyWith(shadows: []),
                          ),
                          const SizedBox(height: 16),
                          if (vm.installedApps.isEmpty)
                            Text(
                              'No user apps found.',
                              style: PixelTheme.pixelFont(
                                size: 11,
                                color: PixelTheme.textSecondary,
                              ).copyWith(shadows: []),
                            )
                          else
                            ...vm.installedApps.map((app) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildAppRow(vm, app),
                              );
                            }),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppRow(AppSelectViewModel vm, app) {
    final isMonitored = vm.isAppMonitored(app.packageName);

    return PixelCard(
      fillColor: isMonitored ? const Color(0xFF1A1A28) : PixelTheme.surface,
      borderColor: isMonitored ? PixelTheme.accent : PixelTheme.border,
      selected: isMonitored,
      padding: const EdgeInsets.all(14),
      onTap: () => vm.toggleApp(app.packageName),
      child: Row(
        children: [
          // App icon placeholder
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: PixelTheme.border,
              border: Border.all(color: PixelTheme.accent, width: 2),
            ),
            child: Center(
              child: Text(
                app.appName[0].toUpperCase(),
                style: PixelTheme.pixelFont(
                  size: 16,
                  weight: FontWeight.bold,
                  color: PixelTheme.accent,
                ).copyWith(shadows: []),
              ),
            ),
          ),

          // App name
          Expanded(
            child: Text(
              app.appName.toUpperCase(),
              style: PixelTheme.pixelFont(
                size: 12,
                weight: FontWeight.bold,
                color: isMonitored ? PixelTheme.textPrimary : PixelTheme.textSecondary,
                letterSpacing: 0.05,
              ).copyWith(
                shadows: isMonitored ? [
                  const Shadow(
                    offset: Offset(1, 1),
                    color: PixelTheme.shadow,
                  ),
                ] : [],
              ),
            ),
          ),

          // Checkbox
          PixelCheckbox(
            checked: isMonitored,
          ),
        ],
      ),
    );
  }
}