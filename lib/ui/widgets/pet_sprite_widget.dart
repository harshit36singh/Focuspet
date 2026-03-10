import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focus_pet/domain/pet_type.dart';

/// Custom widget that renders horizontal sprite sheet animations
/// Nearest-neighbor scaling for pixel-perfect rendering
class PetSpriteWidget extends StatefulWidget {
  final PetType petType;
  final PetAnimState state;
  final bool facingRight;
  final VoidCallback? onAnimationFinished;

  const PetSpriteWidget({
    Key? key,
    required this.petType,
    required this.state,
    this.facingRight = true,
    this.onAnimationFinished,
  }) : super(key: key);

  @override
  State<PetSpriteWidget> createState() => _PetSpriteWidgetState();
}

class _PetSpriteWidgetState extends State<PetSpriteWidget> {
  ui.Image? _spriteSheet;
  int _currentFrame = 0;
  Timer? _animationTimer;
  
  int _frameCount = 0;
  int _frameDuration = 150;
  bool _loops = true;

  @override
  void initState() {
    super.initState();
    _loadSprite();
  }

  @override
  void didUpdateWidget(PetSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.petType != widget.petType || oldWidget.state != widget.state) {
      _loadSprite();
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _spriteSheet?.dispose();
    super.dispose();
  }

  Future<void> _loadSprite() async {
    _animationTimer?.cancel();
    _spriteSheet?.dispose();
    _currentFrame = 0;

    final String spritePath;
    switch (widget.state) {
      case PetAnimState.idle:
        spritePath = widget.petType.idleSprite;
        _frameCount = widget.petType.idleFrames;
        _frameDuration = 150;
        _loops = true;
        break;
      case PetAnimState.walk:
        spritePath = widget.petType.walkSprite;
        _frameCount = widget.petType.walkFrames;
        _frameDuration = 120;
        _loops = true;
        break;
      case PetAnimState.attack:
        if (widget.petType.attackSprite != null) {
          spritePath = widget.petType.attackSprite!;
          _frameCount = widget.petType.attackFrames;
          _frameDuration = 100;
          _loops = false;
        } else {
          // Fallback to idle if no attack animation
          spritePath = widget.petType.idleSprite;
          _frameCount = widget.petType.idleFrames;
          _frameDuration = 150;
          _loops = true;
        }
        break;
    }

    try {
      final data = await rootBundle.load(spritePath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        // Disable filtering for pixel-perfect rendering
        targetWidth: null,
        targetHeight: null,
      );
      final frame = await codec.getNextFrame();
      
      if (mounted) {
        setState(() {
          _spriteSheet = frame.image;
        });
        _startAnimation();
      }
    } catch (e) {
      print('Error loading sprite $spritePath: $e');
    }
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _frameDuration),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentFrame++;
          if (_currentFrame >= _frameCount) {
            if (_loops) {
              _currentFrame = 0;
            } else {
              _currentFrame = _frameCount - 1;
              timer.cancel();
              widget.onAnimationFinished?.call();
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_spriteSheet == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _SpritePainter(
        spriteSheet: _spriteSheet!,
        currentFrame: _currentFrame,
        frameWidth: widget.petType.frameSize,
        frameHeight: _spriteSheet!.height,
        facingRight: widget.facingRight,
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image spriteSheet;
  final int currentFrame;
  final int frameWidth;
  final int frameHeight;
  final bool facingRight;

  _SpritePainter({
    required this.spriteSheet,
    required this.currentFrame,
    required this.frameWidth,
    required this.frameHeight,
    required this.facingRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.none // Pixel-perfect, no interpolation
      ..isAntiAlias = false;

    final srcRect = Rect.fromLTWH(
      currentFrame * frameWidth.toDouble(),
      0,
      frameWidth.toDouble(),
      frameHeight.toDouble(),
    );

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (!facingRight) {
      canvas.save();
      canvas.scale(-1, 1);
      canvas.translate(-size.width, 0);
    }

    canvas.drawImageRect(spriteSheet, srcRect, dstRect, paint);

    if (!facingRight) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame ||
        oldDelegate.facingRight != facingRight;
  }
}