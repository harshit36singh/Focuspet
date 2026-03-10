/// Pet animation states
enum PetAnimState {
  idle,
  walk,
  attack,
}

/// All selectable pets with their sprite configurations
enum PetType {
  dog1(
    displayName: 'HOUND',
    emoji: '🐕',
    idleSprite: 'assets/sprites/dog1_idle.png',
    walkSprite: 'assets/sprites/dog1_walk.png',
    attackSprite: 'assets/sprites/dog1_attack.png',
    idleFrames: 4,
    walkFrames: 6,
    attackFrames: 4,
    frameSize: 48,
  ),
  dog2(
    displayName: 'PUP',
    emoji: '🐶',
    idleSprite: 'assets/sprites/dog2_idle.png',
    walkSprite: 'assets/sprites/dog2_walk.png',
    attackSprite: 'assets/sprites/dog2_attack.png',
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 4,
    frameSize: 48,
  ),
  cat1(
    displayName: 'TABBY',
    emoji: '🐱',
    idleSprite: 'assets/sprites/cat1_idle.png',
    walkSprite: 'assets/sprites/cat1_walk.png',
    attackSprite: 'assets/sprites/cat1_attack.png',
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 4,
    frameSize: 48,
  ),
  cat2(
    displayName: 'SHADOW',
    emoji: '🐈',
    idleSprite: 'assets/sprites/cat2_idle.png',
    walkSprite: 'assets/sprites/cat2_walk.png',
    attackSprite: 'assets/sprites/cat2_attack.png',
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 4,
    frameSize: 48,
  ),
  rat1(
    displayName: 'RUSTY',
    emoji: '🐀',
    idleSprite: 'assets/sprites/rat1_idle.png',
    walkSprite: 'assets/sprites/rat1_walk.png',
    attackSprite: null,
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 0,
    frameSize: 32,
  ),
  rat2(
    displayName: 'SLATE',
    emoji: '🐁',
    idleSprite: 'assets/sprites/rat2_idle.png',
    walkSprite: 'assets/sprites/rat2_walk.png',
    attackSprite: null,
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 0,
    frameSize: 32,
  ),
  bird1(
    displayName: 'RAVEN',
    emoji: '🐦',
    idleSprite: 'assets/sprites/bird1_idle.png',
    walkSprite: 'assets/sprites/bird1_walk.png',
    attackSprite: null,
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 0,
    frameSize: 32,
  ),
  bird2(
    displayName: 'TEAL',
    emoji: '🦜',
    idleSprite: 'assets/sprites/bird2_idle.png',
    walkSprite: 'assets/sprites/bird2_walk.png',
    attackSprite: null,
    idleFrames: 4,
    walkFrames: 4,
    attackFrames: 0,
    frameSize: 32,
  );

  final String displayName;
  final String emoji;
  final String idleSprite;
  final String walkSprite;
  final String? attackSprite;
  final int idleFrames;
  final int walkFrames;
  final int attackFrames;
  final int frameSize;

  const PetType({
    required this.displayName,
    required this.emoji,
    required this.idleSprite,
    required this.walkSprite,
    required this.attackSprite,
    required this.idleFrames,
    required this.walkFrames,
    required this.attackFrames,
    required this.frameSize,
  });

  bool get hasAttack => attackSprite != null;
}