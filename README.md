# Verho
A simple transition system to load levels in a non-blocking way.

[Verho 2D JRPG Demonstration]() [TODO]

[Verho Point-and-Click Demonstration]() [TODO]

## A Simple GDScript Example

## What Does Vehro NOT Do?

Verho does not manage your scenes for you. As this is meant to be a generic framework, Verho has no notion of scenes beyond Nodes. Specific signals, such as `scene_added` and `scene_loaded`, can help you prepare for a new scene. You are in charge of saving your own scenes and information. If you so desire, you can wrap your scene requests in another manager of your desire if you wish to preserve some scenes in memory. Verho, itself, forgets what the prior scene was once it has been loaded to the scene.

## Export Notes

[TODO]

## Projects Using Verho

- HEAD HONCHO (2.0) - HANGOVER SUNSHINE (Verho 2.0)
- [BRAINWORM - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/brainworm) (Verho 1.1)
- [FRANKEN JUDGE - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/franken-judge) (Verho 1.1)
- [KALEIDOKILL - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/kaleidokill) (Verho 1.0)
- [DEFCON JUNIOR - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/defcon-junior) (Verho 1.0)

## What's To Come
- C# bindings

## For Godot 4.0 - 4.3
For Godot 4.0 - 4.3, we recommend using Verho 1.1, as Verho 2.0 and on utilize typed `Dictionary`-ies in GDScript. It is no longer maintained, but works in a similar way to the audio manager Resonate.

## For Godot 3.X
Verho is untested on versions of Godot prior to 4.0. Use at your own risk and desire.

### With Love,
Mica / HANGOVER SUNSHINE
