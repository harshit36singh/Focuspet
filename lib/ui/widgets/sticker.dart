import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/pet_type.dart';
import '../theme/app_theme.dart';
import 'pet_sprite_widget.dart';

/// "HOUND" -> "Hound"
String niceName(String s) => s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();

String speciesOf(PetType p) {
  if (p.name.startsWith('dog')) return 'Canine';
  if (p.name.startsWith('cat')) return 'Feline';
  if (p.name.startsWith('rat')) return 'Rodent';
  return 'Avian';
}

Color speciesColor(PetType p) {
  if (p.name.startsWith('dog')) return AppTheme.accent400;
  if (p.name.startsWith('cat')) return AppTheme.accent300;
  if (p.name.startsWith('rat')) return AppTheme.surface;
  return AppTheme.sage400;
}

Widget petSprite(PetType type, double size, {PetAnimState state = PetAnimState.idle}) =>
    SizedBox(width: size, height: size, child: PetSpriteWidget(petType: type, state: state));

/// Outlined card with a hard offset shadow.
class Sticker extends StatelessWidget {
  const Sticker({
    super.key,
    required this.child,
    this.color = AppTheme.paper,
    this.padding = const EdgeInsets.all(14),
    this.radius = 22,
    this.shadow = 3,
    this.tilt = 0,
    this.borderColor = AppTheme.ink,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double shadow;
  final double tilt; // degrees
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: AppTheme.border),
        boxShadow: shadow > 0 ? [BoxShadow(color: AppTheme.ink, offset: Offset(shadow, shadow))] : null,
      ),
      child: child,
    );
    if (tilt != 0) box = Transform.rotate(angle: tilt * math.pi / 180, child: box);
    if (onTap != null) box = GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: box);
    return box;
  }
}

/// Chunky pill button that physically pushes down when pressed.
class PushButton extends StatefulWidget {
  const PushButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.color = AppTheme.accent600,
    this.textColor = Colors.white,
    this.fontSize = 20,
    this.depth = 6,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double depth;

  @override
  State<PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<PushButton> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final d = _down ? widget.depth / 3 : widget.depth;
    return Opacity(
      opacity: widget.onTap == null ? 0.45 : 1,
      child: GestureDetector(
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 70),
          padding: EdgeInsets.only(top: widget.depth - d, bottom: d),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.ink, width: AppTheme.border),
              boxShadow: [BoxShadow(color: AppTheme.ink, offset: Offset(0, d))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 22, color: widget.textColor),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.display(widget.fontSize, color: widget.textColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpeechBubble extends StatelessWidget {
  const SpeechBubble(
    this.text, {
    super.key,
    this.tailRight = false,
    this.tilt = 0,
    this.color = AppTheme.paper,
    this.fontSize = 15,
    this.shadow = 3,
    this.align = TextAlign.start,
  });

  final String text;
  final bool tailRight;
  final double tilt;
  final Color color;
  final double fontSize;
  final double shadow;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(22);
    const t = Radius.circular(6);
    Widget b = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: r,
          topRight: r,
          bottomLeft: tailRight ? r : t,
          bottomRight: tailRight ? t : r,
        ),
        border: Border.all(color: AppTheme.ink, width: AppTheme.border),
        boxShadow: shadow > 0 ? [BoxShadow(color: AppTheme.ink, offset: Offset(shadow, shadow))] : null,
      ),
      child: Text(text, textAlign: align, style: AppTheme.body(size: fontSize, weight: FontWeight.w700)),
    );
    if (tilt != 0) b = Transform.rotate(angle: tilt * math.pi / 180, child: b);
    return b;
  }
}

class StickerChip extends StatelessWidget {
  const StickerChip({
    super.key,
    required this.label,
    this.color = AppTheme.paper,
    this.textColor = AppTheme.ink,
    this.icon,
    this.tilt = 0,
    this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double tilt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget c = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.ink, width: 2.5),
        boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(2, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: textColor), const SizedBox(width: 4)],
        Text(label, style: AppTheme.body(size: 13, weight: FontWeight.w800, color: textColor)),
      ]),
    );
    if (tilt != 0) c = Transform.rotate(angle: tilt * math.pi / 180, child: c);
    if (onTap != null) c = GestureDetector(onTap: onTap, child: c);
    return c;
  }
}

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppTheme.bg,
    this.iconColor = AppTheme.ink,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.ink, width: AppTheme.border),
          boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(0, 3))],
        ),
        child: Icon(icon, size: size * 0.5, color: iconColor),
      ),
    );
  }
}

class StickerSwitch extends StatelessWidget {
  const StickerSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 58,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppTheme.accent600 : AppTheme.n300,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.ink, width: AppTheme.border),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppTheme.paper,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.ink, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label, this.color = AppTheme.bg, this.labelColor = AppTheme.n700, this.tilt = 0});
  final String value;
  final String label;
  final Color color;
  final Color labelColor;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: color,
      tilt: tilt,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(children: [
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: AppTheme.display(28))),
        const SizedBox(height: 2),
        FittedBox(fit: BoxFit.scaleDown, child: Text(label.toUpperCase(), style: AppTheme.kicker(color: labelColor))),
      ]),
    );
  }
}

class StepperTile extends StatelessWidget {
  const StepperTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.onMinus,
    required this.onPlus,
    this.color = AppTheme.bg,
    this.labelColor = AppTheme.n700,
  });

  final String label;
  final int value;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: color,
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTheme.body(size: 13, weight: FontWeight.w700, color: labelColor)),
            Text.rich(TextSpan(text: '$value ', style: AppTheme.display(24), children: [
              TextSpan(text: unit, style: AppTheme.display(14)),
            ])),
          ]),
        ),
        RoundButton(icon: Icons.remove_rounded, onTap: onMinus),
        const SizedBox(width: 8),
        RoundButton(icon: Icons.add_rounded, onTap: onPlus, color: AppTheme.accent600, iconColor: Colors.white),
      ]),
    );
  }
}

/// Pill text field used for naming the pet.
class NameField extends StatelessWidget {
  const NameField({super.key, required this.controller, this.hint = 'Name your pet'});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Sticker(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: 16,
            style: AppTheme.display(22),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: hint,
              hintStyle: AppTheme.display(22, color: AppTheme.n500),
            ),
          ),
        ),
        const Icon(Icons.edit_rounded, size: 18, color: AppTheme.ink),
      ]),
    );
  }
}

/// Pet on a round stage with a speech bubble and an optional name plate.
class PetStage extends StatelessWidget {
  const PetStage({
    super.key,
    required this.pet,
    required this.message,
    this.name,
    this.onRename,
    this.height = 300,
    this.stageColor = AppTheme.sage300,
  });

  final PetType pet;
  final String message;
  final String? name;
  final VoidCallback? onRename;
  final double height;
  final Color stageColor;

  @override
  Widget build(BuildContext context) {
    final circle = height * 0.77;
    return SizedBox(
      height: height,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          top: height - circle - 14,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stageColor,
                border: Border.all(color: AppTheme.ink, width: AppTheme.border),
                boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(6, 6))],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: name != null ? 44 : 28,
          left: 0,
          right: 0,
          child: Center(child: petSprite(pet, height * 0.58)),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: SpeechBubble(message, tilt: -2),
          ),
        ),
        if (name != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.05,
                child: GestureDetector(
                  onTap: onRename,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.ink, width: AppTheme.border),
                      boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(3, 3))],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(name!, style: AppTheme.display(22)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_rounded, size: 16, color: AppTheme.accent600),
                    ]),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
