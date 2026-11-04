import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/pet_type.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../theme/app_theme.dart';
import '../widgets/sticker.dart';

class PetSelectScreen extends StatefulWidget {
  const PetSelectScreen({super.key});
  @override
  State<PetSelectScreen> createState() => _PetSelectScreenState();
}

class _PetSelectScreenState extends State<PetSelectScreen> {
  PageController? _pc;
  double _page = 0;
  RangeValues? _dragZone; // live value while the slider is being dragged

  static const _presets = <(String, double, double)>[
    ('Full', 0.0, 1.0),
    ('Right ¾', 0.25, 1.0),
    ('Half', 0.5, 1.0),
    ('Left ¾', 0.0, 0.75),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pc == null) {
      final vm = context.read<PetSelectViewModel>();
      final i = vm.allPets.indexOf(vm.selectedPet);
      _page = i.toDouble();
      _pc = PageController(viewportFraction: 0.46, initialPage: i)
        ..addListener(() {
          final p = _pc!.page;
          if (p != null) setState(() => _page = p);
        });
    }
  }

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PetSelectViewModel>();
    final pets = vm.allPets;
    final sel = vm.selectedPet;
    final idx = pets.indexOf(sel);
    final name = niceName(sel.displayName);
    final pad = AppTheme.hPad(context);

    return ColoredBox(
      color: AppTheme.sage200,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 130),
          children: [
            Row(children: [
              Text('Pick a pal', style: AppTheme.display(28)),
              const Spacer(),
              StickerChip(label: speciesOf(sel), color: speciesColor(sel), tilt: -4),
            ]),
            const SizedBox(height: 14),
            SizedBox(
              height: 228,
              child: PageView.builder(
                controller: _pc,
                itemCount: pets.length,
                onPageChanged: (i) => vm.selectPet(pets[i]),
                itemBuilder: (_, i) => _petCard(pets[i], i, pets[i] == sel),
              ),
            ),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < pets.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == idx ? 26 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == idx ? AppTheme.ink : Colors.transparent,
                    border: Border.all(color: AppTheme.ink, width: 2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ]),
            const SizedBox(height: 20),
            Text('HOW ${name.toUpperCase()} BEHAVES', style: AppTheme.kicker()),
            const SizedBox(height: 10),
            StepperTile(
              label: 'Shows up after',
              value: vm.interruptDelayMinutes,
              unit: 'min',
              color: AppTheme.accent300,
              labelColor: AppTheme.accent800,
              onMinus: () => vm.setInterruptDelay((vm.interruptDelayMinutes - 1).clamp(1, 60).toInt()),
              onPlus: () => vm.setInterruptDelay((vm.interruptDelayMinutes + 1).clamp(1, 60).toInt()),
            ),
            const SizedBox(height: 10),
            StepperTile(
              label: 'Wanders for',
              value: vm.walkDelaySeconds,
              unit: 'sec',
              onMinus: () => vm.setWalkDelay((vm.walkDelaySeconds - 10).clamp(10, 600).toInt()),
              onPlus: () => vm.setWalkDelay((vm.walkDelaySeconds + 10).clamp(10, 600).toInt()),
            ),
            const SizedBox(height: 10),
            StepperTile(
              label: sel.hasAttack ? 'Pounces after' : 'Reacts after',
              value: vm.reactDelaySeconds,
              unit: 'sec',
              color: AppTheme.sage300,
              labelColor: AppTheme.sage800,
              onMinus: () => vm.setReactDelay((vm.reactDelaySeconds - 10).clamp(10, 600).toInt()),
              onPlus: () => vm.setReactDelay((vm.reactDelaySeconds + 10).clamp(10, 600).toInt()),
            ),
            const SizedBox(height: 22),
            _walkZone(vm, name),
          ],
        ),
      ),
    );
  }

  Widget _petCard(PetType p, int i, bool active) {
    final d = (_page - i).abs().clamp(0.0, 1.0);
    final scale = 1 - 0.22 * d; // side cards shrink to 78%
    return Center(
      child: Transform.scale(
        scale: scale,
        child: Sticker(
          color: active ? AppTheme.bg : AppTheme.sage300,
          shadow: active ? 5 : 3,
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          onTap: () => _pc!.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutBack),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppTheme.accent300 : AppTheme.sage200,
                border: Border.all(color: AppTheme.ink, width: 2.5),
              ),
              child: petSprite(p, 100),
            ),
            const SizedBox(height: 6),
            Text(niceName(p.displayName), style: AppTheme.display(22)),
            Text(speciesOf(p), style: AppTheme.body(size: 12, weight: FontWeight.w700, color: AppTheme.n700)),
          ]),
        ),
      ),
    );
  }

  Widget _walkZone(PetSelectViewModel vm, String name) {
    final z = _dragZone ?? RangeValues(vm.petZoneStart, vm.petZoneEnd);
    return Sticker(
      color: AppTheme.bg,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Walk zone', style: AppTheme.display(24)),
        const SizedBox(height: 4),
        Text("$name will only stroll inside the green part.",
            style: AppTheme.body(size: 14, weight: FontWeight.w600, color: AppTheme.n700)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in _presets)
            Builder(builder: (_) {
              final on = (z.start - p.$2).abs() < 0.01 && (z.end - p.$3).abs() < 0.01;
              return StickerChip(
                label: p.$1,
                color: on ? AppTheme.ink : AppTheme.paper,
                textColor: on ? AppTheme.bg : AppTheme.ink,
                onTap: () => vm.setPetZone(p.$2, p.$3),
              );
            }),
        ]),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 150,
            height: 230,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.ink, width: AppTheme.border),
              boxShadow: const [BoxShadow(color: AppTheme.ink, offset: Offset(5, 5))],
            ),
            child: LayoutBuilder(builder: (_, c) {
              final w = c.maxWidth;
              return Stack(children: [
                Positioned(
                  left: w * z.start,
                  width: w * (z.end - z.start),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.sage300,
                      border: Border.symmetric(vertical: BorderSide(color: AppTheme.ink, width: 2)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: w * (z.start + z.end) / 2 - 26,
                  child: petSprite(vm.selectedPet, 52, state: PetAnimState.walk),
                ),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 10,
            activeTrackColor: AppTheme.sage500,
            inactiveTrackColor: AppTheme.n300,
            thumbColor: AppTheme.ink,
            overlayColor: AppTheme.accent.withOpacity(0.15),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 12, elevation: 0, pressedElevation: 0),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            values: z,
            min: 0,
            max: 1,
            divisions: 20,
            onChanged: (v) {
              if (v.end - v.start < 0.1) return; // keep at least 10% wide
              setState(() => _dragZone = v);
            },
            onChangeEnd: (v) async {
              if (v.end - v.start >= 0.1) await vm.setPetZone(v.start, v.end);
              if (mounted) setState(() => _dragZone = null);
            },
          ),
        ),
        Center(
          child: StickerChip(
            label: '${(z.start * 100).round()}% – ${(z.end * 100).round()}%',
            color: AppTheme.sage300,
          ),
        ),
      ]),
    );
  }
}
