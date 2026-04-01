# My Game

A 2D platformer built with Godot 4.4 (Forward Plus).

## Gameplay

You play as a warrior navigating through 4 levels filled with enemies, hazards, and collectibles. The game features a save system — progress is preserved at campfire save points, and dying resets you to your last save.

### Controls

| Action | Key |
|--------|-----|
| Move Left / Right | `A` / `D` or Arrow Keys |
| Jump | `Space` |
| Roll | `R` |
| Interact | `W` |

### Features

- 4 levels with portal-based transitions
- Enemies: Slimes (patrol back and forth) and Mushrooms (pursue and attack the player)
- Collectibles: Coins (preserved on save, lost on death)
- Interactive objects: Levers that open/close doors
- Save points: Campfires that save position, coins, health, and current level
- Kill zones: Pits and water that instantly kill the player
- HUD displaying health and coin count
- Parallax scrolling backgrounds
- Sound effects (jump, coin, hurt, explosion, save) and background music
- Roll mechanic with a smaller hitbox to dodge attacks

## Project Structure

```
scenes/          Level scenes, player, enemies, items, and UI
scripts/         GDScript files for game logic
assets/
  sprites/       Character, enemy, tileset, and item sprites
  backgrounds/   Parallax background layers
  sounds/        Sound effects (.wav)
  music/         Background music (.mp3)
  fonts/         PixelOperator bitmap font
```

## Running

Open the project in Godot 4.4 and press F5 (or the Play button).
