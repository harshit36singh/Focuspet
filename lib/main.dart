import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/app_preferences.dart';
import 'services/platform_service.dart';
import 'ui/theme/pixel_theme.dart';
import 'ui/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app preferences
  final prefs = await AppPreferences.init();
  
  // Set system UI overlay style (transparent status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(FocusPetApp(prefs: prefs));
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
        theme: PixelTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}