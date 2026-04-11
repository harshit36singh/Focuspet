import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

import 'data/app_preferences.dart';
import 'services/platform_service.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await AppPreferences.init();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // ✅ auto disable in release
      builder: (context) => FocusPetApp(prefs: prefs),
    ),
  );
}

class FocusPetApp extends StatelessWidget {
  final AppPreferences prefs;

  const FocusPetApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppPreferences>.value(value: prefs),
        Provider<PlatformService>(create: (_) => PlatformService()),
      ],
      child: MaterialApp(
        title: 'Focus Pet',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,

        // ✅ Device Preview integration
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,

        home: const MainScreen(),
      ),
    );
  }
}