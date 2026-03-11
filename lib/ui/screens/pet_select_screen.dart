import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../../domain/pet_type.dart';
import '../theme/pixel_theme.dart';
import '../widgets/pet_sprite_widget.dart';

class PetSelectScreen extends StatelessWidget {
  const PetSelectScreen({Key? key}) : super(key: key);

  static String _petLabel(PetType pet) {
    switch (pet) {
      case PetType.dog1:  return 'DOG 1';
      case PetType.dog2:  return 'DOG 2';
      case PetType.cat1:  return 'CAT 1';
      case PetType.cat2:  return 'CAT 2';
      case PetType.rat1:  return 'RAT 1';
      case PetType.rat2:  return 'RAT 2';
      case PetType.bird1: return 'BIRD 1';
      case PetType.bird2: return 'BIRD 2';
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Consumer<PetSelectViewModel>(
      builder: (context, vm, _) => Column(children: [
        PixelTitleBar(topPadding: top, title: 'FOCUS PET'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 14, right: 14, top: 4, bottom: 110),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('♦', 'CHOOSE YOUR PET', PixelTheme.accent4),
                  const SizedBox(height: 12),
                  _buildGrid(vm),
                  const PixelDivider(),

                  PixelSectionLabel('APPEAR AFTER', color: PixelTheme.accent5),
                  const SizedBox(height: 8),
                  PixelBigValue('${vm.interruptDelayMinutes} MIN'),
                  const SizedBox(height: 10),
                  _stepper(
                    value: vm.interruptDelayMinutes,
                    min: 1, max: 60, step: 1, unit: 'MIN',
                    onChanged: vm.setInterruptDelay,
                  ),
                  const PixelDivider(),

                  PixelSectionLabel('BEHAVIOUR TIMERS', color: PixelTheme.accent2),
                  const SizedBox(height: 12),
                  _timerRow('START WALKING AFTER', vm.walkDelaySeconds,
                      'SEC', vm.setWalkDelay),
                  const SizedBox(height: 10),
                  _timerRow('REACT / ATTACK AFTER', vm.reactDelaySeconds,
                      'SEC', vm.setReactDelay),
                  const PixelDivider(),

                  // ── Walk zone picker ──────────────────────────────────
                  PixelSectionLabel('WALK ZONE', color: PixelTheme.accent3),
                  const SizedBox(height: 6),
                  Text(
                    'Set how much of the status bar\nthe pet can walk across.',
                    style: PixelTheme.t8sec,
                  ),
                  const SizedBox(height: 14),
                  _ZonePicker(
                    zoneStart: vm.petZoneStart,
                    zoneEnd:   vm.petZoneEnd,
                    onChanged: (s, e) => vm.setPetZone(s, e),
                  ),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String icon, String label, Color color) {
    return PixelCard(
      fillColor: PixelTheme.bgDark,
      borderColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Text(icon, style: PixelTheme.pixelFont(size: 12, color: color)),
        const SizedBox(width: 10),
        Text(label,
            style: PixelTheme.pixelFont(
                size: 9, weight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _buildGrid(PetSelectViewModel vm) {
    final pets = vm.allPets;
    return Column(
      children: [
        for (int row = 0; row < (pets.length + 1) ~/ 2; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              for (int col = 0; col < 2; col++)
                if (row * 2 + col < pets.length)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col == 0 ? 10 : 0),
                      child: _petCard(vm, pets[row * 2 + col]),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
            ]),
          ),
      ],
    );
  }

  Widget _petCard(PetSelectViewModel vm, PetType pet) {
    final sel = vm.selectedPet == pet;
    return PixelCard(
      fillColor: sel ? const Color(0xFF12121E) : PixelTheme.surface,
      borderColor: sel ? PixelTheme.accent : PixelTheme.border,
      selected: sel,
      onTap: () => vm.selectPet(pet),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: PixelTheme.bgDark,
            border: Border.all(
              color: sel ? PixelTheme.accentDim : PixelTheme.borderDim,
              width: 2,
            ),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
          ),
          child: Center(
            child: SizedBox(
              width: 52, height: 52,
              child: PetSpriteWidget(petType: pet, state: PetAnimState.idle),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _petLabel(pet),
          style: PixelTheme.pixelFont(
            size: 8, weight: FontWeight.bold,
            color: sel ? PixelTheme.accent : PixelTheme.textSec,
            shadows: [],
          ),
          textAlign: TextAlign.center,
        ),
        if (sel) ...[
          const SizedBox(height: 5),
          Container(height: 2, width: 32, color: PixelTheme.accent),
          const SizedBox(height: 3),
          Text('▲ SELECTED',
              style: PixelTheme.pixelFont(
                  size: 6, color: PixelTheme.accent, shadows: [])),
        ],
      ]),
    );
  }

  Widget _stepper({
    required int value,
    required int min,
    required int max,
    required int step,
    required String unit,
    required Function(int) onChanged,
  }) {
    return PixelCard(
      fillColor: PixelTheme.bgDark,
      borderColor: PixelTheme.border,
      padding: EdgeInsets.zero,
      child: Row(children: [
        _stepBtn('◄', () { if (value > min) onChanged(value - step); }),
        Expanded(
          child: Center(
            child: Text('$value $unit',
                style: PixelTheme.pixelFont(
                    size: 13, weight: FontWeight.bold, color: PixelTheme.accent,
                    shadows: const [Shadow(offset: Offset(2,2), color: Colors.black)])),
          ),
        ),
        _stepBtn('►', () { if (value < max) onChanged(value + step); }),
      ]),
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: PixelTheme.border, width: 2)),
        ),
        child: Text(label,
            style: PixelTheme.pixelFont(
                size: 14, weight: FontWeight.bold, color: PixelTheme.accent)),
      ),
    );
  }

  Widget _timerRow(String label, int value, String unit, Function(int) onChanged) {
    return PixelCard(
      fillColor: PixelTheme.surface,
      borderColor: PixelTheme.border,
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: PixelTheme.t8sec),
        const SizedBox(height: 10),
        _stepper(value: value, min: 10, max: 600, step: 10,
            unit: unit, onChanged: onChanged),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  _ZonePicker
//  Interactive status-bar zone selector.
//  Two drag handles (left = zone start, right = zone end) on a pixel-art
//  status-bar mockup. Also shows quick-select preset buttons.
// ═══════════════════════════════════════════════════════════════════════════
class _ZonePicker extends StatefulWidget {
  final double zoneStart;
  final double zoneEnd;
  final void Function(double start, double end) onChanged;

  const _ZonePicker({
    Key? key,
    required this.zoneStart,
    required this.zoneEnd,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_ZonePicker> createState() => _ZonePickerState();
}

class _ZonePickerState extends State<_ZonePicker> {
  late double _start;
  late double _end;

  // Minimum zone width (10% of bar so handles don't overlap)
  static const double _minWidth = 0.10;

  // Presets: [label, start, end]
  static const _presets = [
    ['FULL',  0.00, 1.00],
    ['RIGHT ¾', 0.25, 1.00],
    ['HALF',  0.25, 0.75],
    ['LEFT ¾', 0.00, 0.75],
    ['¼ L',   0.00, 0.25],
    ['¼ R',   0.75, 1.00],
  ];

  @override
  void initState() {
    super.initState();
    _start = widget.zoneStart;
    _end   = widget.zoneEnd;
  }

  @override
  void didUpdateWidget(_ZonePicker old) {
    super.didUpdateWidget(old);
    if (old.zoneStart != widget.zoneStart || old.zoneEnd != widget.zoneEnd) {
      _start = widget.zoneStart;
      _end   = widget.zoneEnd;
    }
  }

  void _commit() => widget.onChanged(_start, _end);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Preset buttons ────────────────────────────────────────────────
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _presets.map((p) {
          final label = p[0] as String;
          final ps    = p[1] as double;
          final pe    = p[2] as double;
          final active = ((_start - ps).abs() < 0.01) &&
                         ((_end   - pe).abs() < 0.01);
          return GestureDetector(
            onTap: () {
              setState(() { _start = ps; _end = pe; });
              _commit();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: active ? PixelTheme.accent3 : PixelTheme.surface,
                border: Border.all(
                  color: active ? PixelTheme.accent3 : PixelTheme.border,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2))
                ],
              ),
              child: Text(
                label,
                style: PixelTheme.pixelFont(
                  size: 7,
                  weight: FontWeight.bold,
                  color: active ? PixelTheme.bg : PixelTheme.textSec,
                  shadows: [],
                ),
              ),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 18),

      // ── Bar + drag handles ────────────────────────────────────────────
      PixelCard(
        fillColor: PixelTheme.bgDark,
        borderColor: PixelTheme.border,
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Label row
          Row(children: [
            Text('STATUS BAR', style: PixelTheme.t7sec),
            const Spacer(),
            Text(
              '${(_start * 100).round()}% – ${(_end * 100).round()}%',
              style: PixelTheme.pixelFont(
                  size: 8, color: PixelTheme.accent3, shadows: []),
            ),
          ]),

          const SizedBox(height: 12),

          // The interactive bar
          LayoutBuilder(builder: (context, constraints) {
            final totalW = constraints.maxWidth;
            return _buildBar(totalW);
          }),

          const SizedBox(height: 20),

          // Width label
          Center(
            child: Text(
              'ZONE WIDTH: ${((_end - _start) * 100).round()}%',
              style: PixelTheme.pixelFont(
                  size: 8, weight: FontWeight.bold,
                  color: PixelTheme.accent, shadows: []),
            ),
          ),
        ]),
      ),

      const SizedBox(height: 10),

      // Fine-tune hint
      Text(
        'DRAG HANDLES TO FINE-TUNE',
        style: PixelTheme.pixelFont(
            size: 7, color: PixelTheme.textSec,
            letterSpacing: 0.3, shadows: []),
      ),
    ]);
  }

  Widget _buildBar(double totalW) {
    const barH     = 36.0;
    const handleW  = 18.0;
    const handleH  = 50.0;

    return SizedBox(
      height: handleH,
      child: Stack(clipBehavior: Clip.none, children: [

        // ── Full bar background (phone status bar mockup) ────────────────
        Positioned(
          top: (handleH - barH) / 2,
          left: 0, right: 0,
          child: Container(
            height: barH,
            decoration: BoxDecoration(
              color: PixelTheme.surface,
              border: Border.all(color: PixelTheme.border, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            // Decorative phone status bar icons on the right
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('▌▌ WiFi  ⬛ 100%',
                      style: PixelTheme.pixelFont(
                          size: 5, color: PixelTheme.textSec, shadows: [])),
                ),
              ],
            ),
          ),
        ),

        // ── Active zone highlight ────────────────────────────────────────
        Positioned(
          top: (handleH - barH) / 2 + 2,
          left:  _start * totalW + handleW / 2,
          width: (_end - _start) * totalW - handleW / 2,
          height: barH - 4,
          child: Container(
            color: PixelTheme.accent3.withOpacity(0.22),
          ),
        ),

        // ── Active zone border lines ─────────────────────────────────────
        Positioned(
          top: (handleH - barH) / 2,
          left:  _start * totalW + handleW / 2,
          width: (_end - _start) * totalW - handleW / 2,
          height: barH,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: PixelTheme.accent3, width: 2),
            ),
          ),
        ),

        // ── LEFT drag handle ─────────────────────────────────────────────
        Positioned(
          left: _start * totalW,
          top: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              setState(() {
                _start = (_start + d.delta.dx / totalW)
                    .clamp(0.0, _end - _minWidth);
              });
            },
            onHorizontalDragEnd: (_) => _commit(),
            child: _handle(isLeft: true),
          ),
        ),

        // ── RIGHT drag handle ────────────────────────────────────────────
        Positioned(
          left: _end * totalW - handleW,
          top: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (d) {
              setState(() {
                _end = (_end + d.delta.dx / totalW)
                    .clamp(_start + _minWidth, 1.0);
              });
            },
            onHorizontalDragEnd: (_) => _commit(),
            child: _handle(isLeft: false),
          ),
        ),
      ]),
    );
  }

  Widget _handle({required bool isLeft}) {
    const handleW = 18.0;
    const handleH = 50.0;
    return Container(
      width: handleW,
      height: handleH,
      decoration: BoxDecoration(
        color: PixelTheme.accent3,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arrow indicator
          Text(
            isLeft ? '◄' : '►',
            style: PixelTheme.pixelFont(
              size: 7, color: PixelTheme.bg, shadows: [],
            ),
          ),
          const SizedBox(height: 3),
          // Grip lines
          for (int i = 0; i < 3; i++) ...[
            Container(height: 2, width: 8, color: PixelTheme.bg.withOpacity(0.5)),
            const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }
}