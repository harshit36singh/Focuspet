import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pet_select_viewmodel.dart';
import '../../domain/pet_type.dart';
import '../theme/app_theme.dart';
import '../widgets/pet_sprite_widget.dart';

class PetSelectScreen extends StatefulWidget {
  const PetSelectScreen({Key? key}) : super(key: key);
  @override
  State<PetSelectScreen> createState() => _PetSelectScreenState();
}

class _PetSelectScreenState extends State<PetSelectScreen> {
  late PageController _ctrl;
  int _idx = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.52);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<PetSelectViewModel>();
      final idx = vm.allPets.indexOf(vm.selectedPet).clamp(0, vm.allPets.length - 1);
      if (!mounted) return;
      final old = _ctrl;
      _ctrl = PageController(viewportFraction: 0.52, initialPage: idx);
      old.dispose();
      setState(() {
        _idx = idx;
        _ready = true;
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _label(PetType p) => const {
        PetType.dog1: 'Dog 1', PetType.dog2: 'Dog 2',
        PetType.cat1: 'Cat 1', PetType.cat2: 'Cat 2',
        PetType.rat1: 'Rat 1', PetType.rat2: 'Rat 2',
        PetType.bird1: 'Bird 1', PetType.bird2: 'Bird 2',
      }[p] ?? p.name;

  String _species(PetType p) {
    if (p == PetType.dog1 || p == PetType.dog2) return 'Canine';
    if (p == PetType.cat1 || p == PetType.cat2) return 'Feline';
    if (p == PetType.rat1 || p == PetType.rat2) return 'Rodent';
    return 'Avian';
  }

  Color _speciesColor(PetType p) {
    if (p == PetType.dog1 || p == PetType.dog2) return AppTheme.rust;
    if (p == PetType.cat1 || p == PetType.cat2) return AppTheme.mustard;
    if (p == PetType.rat1 || p == PetType.rat2) return AppTheme.clay;
    return AppTheme.forest;
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final pad = AppTheme.hPad(context);
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Consumer<PetSelectViewModel>(
      builder: (context, vm, _) => Container(
        color: AppTheme.bg,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: isTablet ? 24 : 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: top + 12),

              // ── FocusPet banner ───────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.forest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Text('FOCUSPET',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900,
                            color: AppTheme.onDark, letterSpacing: 3.0,
                          )),
                      const Spacer(),
                      // Species badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _speciesColor(vm.allPets[_idx]),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _species(vm.allPets[_idx]).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: AppTheme.white, letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isTablet)
                _buildTabletLayout(vm, pad)
              else
                _buildPhoneLayout(vm, pad),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TABLET: all bento on one page, side by side
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildTabletLayout(PetSelectViewModel vm, double pad) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Carousel tile (takes more space)
          Expanded(
            flex: 3,
            child: _carouselTile(vm, w),
          ),
          const SizedBox(width: 10),
          // Right: steppers + walk zone stacked
          Expanded(
            flex: 2,
            child: Column(
              children: [
                  // 3 steppers row
                  Row(
                    children: [
                      Expanded(
                        child: _StepperTile(
                          color: AppTheme.rust, label: 'APPEAR',
                          value: vm.interruptDelayMinutes, unit: 'min',
                          min: 1, max: 60, step: 1,
                          onChanged: vm.setInterruptDelay,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StepperTile(
                          color: AppTheme.mustard, label: 'WALK',
                          value: vm.walkDelaySeconds, unit: 'sec',
                          min: 10, max: 600, step: 10,
                          onChanged: vm.setWalkDelay,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StepperTile(
                          color: AppTheme.olive, label: 'REACT',
                          value: vm.reactDelaySeconds, unit: 'sec',
                          min: 10, max: 600, step: 10,
                          onChanged: vm.setReactDelay,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Walk zone tile
                  _walkZoneTile(vm),
                ],
              ),
            ),
          ],
        ),
      );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PHONE: vertical stack, fills page
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildPhoneLayout(PetSelectViewModel vm, double pad) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: _carouselTile(vm, w),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              Expanded(
                child: _StepperTile(
                  color: AppTheme.rust, label: 'APPEAR',
                  value: vm.interruptDelayMinutes, unit: 'min',
                  min: 1, max: 60, step: 1,
                  onChanged: vm.setInterruptDelay,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StepperTile(
                  color: AppTheme.mustard, label: 'WALK',
                  value: vm.walkDelaySeconds, unit: 'sec',
                  min: 10, max: 600, step: 10,
                  onChanged: vm.setWalkDelay,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StepperTile(
                  color: AppTheme.olive, label: 'REACT',
                  value: vm.reactDelaySeconds, unit: 'sec',
                  min: 10, max: 600, step: 10,
                  onChanged: vm.setReactDelay,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: _walkZoneTile(vm),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _carouselTile(PetSelectViewModel vm, double w) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.forest,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('SELECT PET', style: AppTheme.tileLabel),
                const Spacer(),
                Text(
                  _label(vm.allPets[_idx]),
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppTheme.onDark, letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_ready)
            SizedBox(
              height: (w * 0.52).clamp(170.0, 240.0),
              child: PageView.builder(
                controller: _ctrl,
                itemCount: vm.allPets.length,
                onPageChanged: (i) {
                  setState(() => _idx = i);
                  vm.selectPet(vm.allPets[i]);
                },
                itemBuilder: (ctx, i) {
                  final pet = vm.allPets[i];
                  final isSel = i == _idx;
                  return AnimatedBuilder(
                    animation: _ctrl,
                    builder: (ctx, child) {
                      double scale = 1.0;
                      if (_ctrl.position.haveDimensions) {
                        final page = _ctrl.page ?? _idx.toDouble();
                        scale = (1.0 - (page - i).abs() * 0.22).clamp(0.78, 1.0);
                      } else {
                        scale = isSel ? 1.0 : 0.78;
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GestureDetector(
                      onTap: () => _ctrl.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.onDark.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSel
                                  ? AppTheme.onDark.withOpacity(0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 90, height: 90,
                                child: PetSpriteWidget(
                                  petType: pet, state: PetAnimState.idle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _label(pet),
                                style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900,
                                  color: isSel
                                      ? AppTheme.onDark
                                      : AppTheme.onDark.withOpacity(0.4),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                _species(pet),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.onDark.withOpacity(0.45),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            SizedBox(height: (w * 0.52).clamp(170.0, 240.0)),

          const SizedBox(height: 14),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(vm.allPets.length, (i) {
              final active = i == _idx;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.onDark
                      : AppTheme.onDark.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _walkZoneTile(PetSelectViewModel vm) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cream2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('WALK ZONE', style: AppTheme.tileLabelDark),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.forest,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${(vm.petZoneStart * 100).round()}%–${(vm.petZoneEnd * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppTheme.onDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _presets.map((p) {
                final label = p[0] as String;
                final ps = p[1] as double;
                final pe = p[2] as double;
                final active = (vm.petZoneStart - ps).abs() < 0.01 &&
                    (vm.petZoneEnd - pe).abs() < 0.01;
                return GestureDetector(
                  onTap: () => vm.setPetZone(ps, pe),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.forest : AppTheme.bg,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: active ? AppTheme.forest : AppTheme.lineColor,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: active ? AppTheme.onDark : AppTheme.grey5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _WalkBar(vm: vm),
          ],
        ),
      );

  static const _presets = [
    ['Full', 0.00, 1.00],
    ['Right ¾', 0.25, 1.00],
    ['Half', 0.25, 0.75],
    ['Left ¾', 0.00, 0.75],
  ];
}

// ── Stepper bento tile ─────────────────────────────────────────────────────
class _StepperTile extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final String unit;
  final int min, max, step;
  final Function(int) onChanged;

  const _StepperTile({
    required this.color, required this.label,
    required this.value, required this.unit,
    required this.min, required this.max, required this.step,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.tileLabel),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text('$value',
                  style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: AppTheme.white, letterSpacing: -1.5, height: 1.0,
                  )),
            ),
            Text(unit, style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppTheme.white, letterSpacing: 0.3,
            )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Btn(icon: Icons.remove, enabled: value > min,
                    onTap: () => onChanged(value - step)),
                _Btn(icon: Icons.add, enabled: value < max,
                    onTap: () => onChanged(value + step)),
              ],
            ),
          ],
        ),
      );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(enabled ? 0.25 : 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14,
              color: AppTheme.white.withOpacity(enabled ? 1.0 : 0.3)),
        ),
      );
}

// ── Walk zone bar ──────────────────────────────────────────────────────────
class _WalkBar extends StatefulWidget {
  final PetSelectViewModel vm;
  const _WalkBar({required this.vm});
  @override
  State<_WalkBar> createState() => _WalkBarState();
}

class _WalkBarState extends State<_WalkBar> {
  late double _s, _e;
  static const double _min = 0.10;

  @override
  void initState() {
    super.initState();
    _s = widget.vm.petZoneStart;
    _e = widget.vm.petZoneEnd;
  }

  @override
  void didUpdateWidget(_WalkBar old) {
    super.didUpdateWidget(old);
    if (old.vm.petZoneStart != widget.vm.petZoneStart ||
        old.vm.petZoneEnd != widget.vm.petZoneEnd) {
      _s = widget.vm.petZoneStart;
      _e = widget.vm.petZoneEnd;
    }
  }

  void _commit() => widget.vm.setPetZone(_s, _e);

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, c) => _bar(c.maxWidth));

  Widget _bar(double W) {
    const bH = 4.0;
    const hS = 24.0;
    return SizedBox(
      height: hS,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0, right: 0,
            child: Container(
              height: bH,
              decoration: BoxDecoration(
                color: AppTheme.lineColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: _s * W,
            width: (_e - _s) * W,
            child: Container(
              height: bH,
              decoration: BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: _s * W - hS / 2,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) =>
                  setState(() => _s = (_s + d.delta.dx / W).clamp(0.0, _e - _min)),
              onHorizontalDragEnd: (_) => _commit(),
              child: _handle(),
            ),
          ),
          Positioned(
            left: _e * W - hS / 2,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) =>
                  setState(() => _e = (_e + d.delta.dx / W).clamp(_s + _min, 1.0)),
              onHorizontalDragEnd: (_) => _commit(),
              child: _handle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() => Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppTheme.forest, shape: BoxShape.circle,
          border: Border.all(color: AppTheme.bg, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.forest.withOpacity(0.3),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
      );
}