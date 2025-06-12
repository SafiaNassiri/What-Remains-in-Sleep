# What Remains in Sleep

**What Remains in Sleep** is a 2D narrative puzzle-horror game made in Godot. You wake up in a strange, looping place with no memory of how you got there. Something is wrong. Time is stuck. The walls remember things you do not.

## About the Game

In *What Remains in Sleep*, you play as a lost soul trapped in a shifting, looping memory. Explore a haunted interior space where each run reveals more about your past. Interact with objects to uncover memory fragments, collect hidden items, and piece together the story before the loop resets again.

- **Memory-driven exploration**: Pick up items tied to emotional memories.
- **Loop mechanic**: The environment changes subtly with each loop.
- **Dark narrative**: Each clue brings you closer to the truth — and the tragedy.
- **Environmental storytelling**: Some objects only whisper to you. Others offer tangible fragments of the past.

---

## Controls

- **WASD / Arrow Keys** – Move
- **E / Enter** – Interact
- **Esc** – Exit game (in development)

---

## Development

- Built with [Godot Engine](https://godotengine.org/)  
- Art assets: Top-down pixel tileset from itch.io 
- SFX / Music: 

### Structure

res://
│
├── fonts/ #Fonts used
├── scenes/
│ ├── main.tscn # Core game scene
│ ├── player.tscn # Player scene
│ ├── item.tscn # Collectible item
│ ├── room_end_trigger.tscn #Ending trigger
│
├── scripts/
│ ├── EntranceBlock.gd #Prevents player from elaving the 'house'
│ ├── ExitBloxk.gd #Prevents player from exiting the 'house' and servers as end game trigger
│ ├── main.gd # Game loop logic and item spawning
│ ├── player.gd # Player movement and interaction
│ ├── item.gd # Collectible item logic
│ ├── interactable.gd # Handles static or triggerable object behavior
│ ├── ui.gd #Scripts for handling dialogue box and item collection
│
├── Sprites&TileMaps/ # Art assets
└── README.md

---

## Features

- Object interactions that either:
  - Display a cryptic message (`interact_type = "message"`)
  - Reveal hidden collectible items (`interact_type = "reveal_item"`)
- Persistent item collection tracking
- UI panel showing gathered memory fragments
- Hidden story revealed over multiple runs

---

## TODO

- [ ] Add end sequence once all memory items are collected
- [ ] Additional rooms and looping variations
- [ ] Audio feedback (ambience, item SFX, music)
- [ ] Polished UI animations
- [ ] Full memory log screen

---

## Inspirations

- *Gone Home*
- *What Remains of Edith Finch*
- *Silent Hill* (narrative unease & isolation)
- *Anatomy* by Kitty Horrorshow

---

## License

This game is a student/personal project. Not for commercial use unless stated otherwise.

---

## “Time of death: 14:35... but time never left.”

