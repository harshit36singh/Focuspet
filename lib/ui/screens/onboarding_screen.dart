import 'package:flutter/material.dart';
import '../../domain/pet_type.dart';
import '../theme/app_theme.dart';
import '../widgets/sticker.dart';

/// First-run screen: name your pet.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.pet, required this.onDone});
  final PetType pet;
  final ValueChanged<String> onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = TextEditingController();
  static const _suggestions = ['Biscuit', 'Noodle', 'Pixel', 'Captain'];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppTheme.hPad(context);
    final name = _ctrl.text.trim();

    return Scaffold(
      backgroundColor: AppTheme.sage200,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 20, pad, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 40),
              child: IntrinsicHeight(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text('Meet your new focus buddy!', style: AppTheme.display(32)),
                  const SizedBox(height: 14),
                  PetStage(
                    pet: widget.pet,
                    message: name.isEmpty ? 'Hi! What should you call me?' : '$name? I love it!',
                    height: 270,
                    stageColor: AppTheme.accent300,
                  ),
                  const SizedBox(height: 14),
                  Text('My name is',
                      style: AppTheme.body(size: 13, weight: FontWeight.w800, color: AppTheme.n700)),
                  const SizedBox(height: 8),
                  NameField(controller: _ctrl),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final s in _suggestions)
                      StickerChip(
                        label: s,
                        color: name == s ? AppTheme.ink : AppTheme.bg,
                        textColor: name == s ? AppTheme.bg : AppTheme.ink,
                        onTap: () => _ctrl.text = s,
                      ),
                  ]),
                  const Spacer(),
                  const SizedBox(height: 20),
                  PushButton(
                    label: "That's me!",
                    onTap: name.isEmpty ? null : () => widget.onDone(name),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
