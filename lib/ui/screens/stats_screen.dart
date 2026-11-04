import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/sticker.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final streak = vm.currentStreak;
    final best = vm.prefs.longestStreak;
    final pad = AppTheme.hPad(context);

    final String msg;
    if (streak == 0) {
      msg = "Every streak starts at day one. Let's go!";
    } else if (streak >= best) {
      msg = "This is your best streak ever. I'm so proud!";
    } else {
      msg = '${best - streak} more days to beat your record!';
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
          children: [
            Row(children: [
              RoundButton(icon: Icons.arrow_back_rounded, color: AppTheme.paper, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              Text('Our progress', style: AppTheme.display(26)),
            ]),
            const SizedBox(height: 20),
            Sticker(
              color: AppTheme.accent300,
              shadow: 5,
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Text('$streak', style: AppTheme.display(64).copyWith(height: 0.9)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('day streak!', style: AppTheme.display(22)),
                    Text('Your best is $best',
                        style: AppTheme.body(size: 13, weight: FontWeight.w700, color: AppTheme.accent800)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Sticker(
              color: AppTheme.sage200,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TIME SAVED', style: AppTheme.kicker(color: AppTheme.sage800)),
                const SizedBox(height: 2),
                Text(vm.formatTime(vm.totalTimeSavedSec), style: AppTheme.display(34)),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: StatTile(value: '${vm.sessionCount}', label: 'sessions', color: AppTheme.paper)),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  value: '${vm.monitoredApps.length}',
                  label: 'apps watched',
                  color: AppTheme.accent200,
                  labelColor: AppTheme.accent800,
                  tilt: -2,
                ),
              ),
            ]),
            const SizedBox(height: 28),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              petSprite(vm.selectedPetType, 72),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SpeechBubble(msg, fontSize: 14),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
