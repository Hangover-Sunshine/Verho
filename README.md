# Verho
A simple transition system to load levels in a non-blocking way for Godot 4.4 and beyond!

[Verho 2D JRPG Demonstration]() [TODO]

[Verho Point-and-Click Demonstration]() [TODO]

## A Simple Scene Loading/Freeing Example

This section details a very simple implementation and use-case for Verho. For more interesting implementations, check out the section on projects using Verho and the above demonstartions! Here is a very simple implementation scenario to make Verho work, using both GUI buttons and keyboard inputs. Assume we have two scenes, `scene_one.tscn` and `scene_two.tscn`. Both scenes also have a requisite GDScript script attached to them, outlined here below. Assume we also have two transitions located in a directory `prefabs/transitions`: `black_fade.tscn` and `fancy_sahder_fade.tscn`.

scene_one.gd:
```
func _ready():
    Verho.added_scene.connect(_scene_added)

func _on_button_pressed():
    Verho.change_scene("res://scenes/scene_two.tscn", "res://prefabs/transitions/black_fade.tscn")

func _scene_added(new_scene):
    if new_scene != self:
        queue_free()

```

scene_two.gd:
```
func _ready():
    Verho.added_scene.connect(_scene_added)

func _input(event):
    if event.is_action_pressed("enter_pressed"):
        Verho.change_scene("res://scenes/scene_one.tscn", "res://prefabs/transitions/fancy_shader_fade.tscn")

func _scene_added(new_scene):
    if new_scene != self:
        queue_free()
```

There are three main elements to these scripts: connect, initiate load, and self-free. To begin, Verho emits four signals during scene loading: `faded_in`, `faded_out`, `loaded_scene(node)`, and `added_scene(node)`. `faded_in` and `faded_out` are emitted when the transition scene is finished fading in (that is, REVEALING the new scene) and out (HIDING the current scene). `loaded_scene` is emitted when the scene has been loaded into memory, and the ResourceLoader's job is finished; this is NOT indicating that the scene is in the scene tree yet, however. `loaded_scene` emits with it a reference to the scene that has just finished being loaded. `added_scene` is emitted when the newly loaded scene is added to the scene tree. Verho will add it as a child of the set `_parent_scene`. This `_parent_scene` can be set at any time; even just before loading a new scene! This can be useful if you want the scene to exist somewhere else in the scene tree, maybe loading a sub-level as a player explores a dungeon or as a sub-area for UI.

Both scripts choose to listen to the `added_scene` signal; once this is emitted, _then_ the scenes queue themselves to be freed if the scene being loaded is not itself (i.e., prevent it from freeing itself on loading). This can, of course, be handled elsewhere in as complex a manner as you desire. However, here we choose to simply remove the scene from the tree AND memory.

The next section deals with calling Verho to request a scene change. There are four provided, public methods for a user to call: `change_scene(scene:String, transition:String)`, `change_scenen(scene:String, transition:String)`, `change_scene_transn(scene:String, transition:String)`, and `change_scenen_transn(scene:String, transition:String)`. A method that includes an 'n' (e.g., scenen) indicates that the string inputted in that parameter is expected to be a nickname provided through the Verho sub-menu. If there is no 'n' in the method, then it expects a _fully qualified_ file path (e.g., `res://path/to/file/scene.tscn`) to the desired scene/transition. If you lack the `res://`, Verho will preprend it and use the provided path! `Verho.change_scene[n][_trans[n]]` can be called from anywhere in your project you expect a scene to change from!

The general flow of Verho is this: request scene to be loaded with a given transition -> transition is loaded (blocking) -> transition is directed to FADE OUT (`faded_out` is emitted on completion) -> transition completes, scene is then actually loading into memory (in the event you wish to display a progress bar) -> scene finished loading (`loaded_scene` is emitted) -> scene is added to tree (`added_scene` is emitted) -> transition is directed to FADE IN (`faded_in` is emitted on completion).

## Creating Custom Transitions

Verho has a base `Control` derived-type called `VerhoTransition` that it expects you to inherit your transition scripts from as a base. `VerhoTransition` has two base functions you _should_ override if you desire! These three functions are: `play_transition(direction:VerhoTransition.Direction)` and `loading_progress(percentage:float)`. `play_transition` is what `verho.gd` calls when it wants to fade in/out. What this actually does is entirely up to you! Feel free to add other functions for custom loading scenes, progress bars, mini-games, true facts about angler fish, etc.

__An important note:__ regardless of what you do, you __*MUST*__ call `is_finished()` in some fashion. You can do this either as a function, a timer expiring, or through an AnimationPlayer. The base `is_finished()` function fires off the `finished_transition` signal that Verho depends on to know when transitioning is complete! If you choose not to do that, then you need to fire off the `finished_transition` signal yourself with the proper direction that's been requested of you to load towards!

There is one advanced function, `is_finished()`, that you should only override if you feel confident you know what you are doing. `free_on_finished()` should not be overridden. This informs your transition to clean itself up in the event it is being overridden by something else - unlikely, but Verho wants to keep its memory impact as small as possible!

Below is an example of a simple fade transition using the AnimationPlayer:
```
extends VerhoTransition

func play_transition(direction:VerhoTransition.Direction):
	_direction = direction
	if direction == VerhoTransition.Direction.IN:
		$AnimationPlayer.play("in")
	else:
		$AnimationPlayer.play("out")
	##
##
```

When the animation player finishes playing either in or out, it calls `is_finished()`.

## What Does Verho NOT Do?

Verho does not manage your scenes for you. As this is meant to be a generic framework, Verho has no notion of scenes beyond Nodes. Specific signals, such as `scene_added` and `scene_loaded`, can help you prepare to close your old scene in exchange for a new scene. You are in charge of saving your own scenes and the requisite information. If you so desire, you can wrap your scene requests in another manager of your desire if you wish to preserve some scenes in memory. Verho, itself, forgets what the prior scene was once it has loaded the requested scene.

## Export Notes

For ensuring Verho is exported with your project, there are a few different ways you can have this set up. Obviously, the easiest method is to export every file in the project,
but this is not feasible for larger projects. So, whenever you see the "Filters to export non-resource files/folders, you should add:

`addons/verho/verho/*,`

to the text line. This will ensure Verho and its requisite files are properly exported with your project during builds/exports!

### Vehro Behaviors When Exporting

To minimize the size Verho adds to your fully exported project, Verho creates a binary blob file titled `verho.blob` in the `verho/` that is set as before. This binary blob is carefully organized to try and minimize the number of bytes existing in the project, rather than exporting the readable `verho.json` file that exists in the `resources/` folder. The binary blob will save on a number of bytes over the JSON save; however, if you are running from the editor, then the JSON file is used instead. Godot does not export the project when making a debug build from editor, so there's no guarantee your binary file is up-to-date until you export! This is all managed under `export_plugin.gd`.

Verho will also choose to clean up the binary file and remove poorly formed nickname/scene and nickname/transition pairs. These rules are quite simple: if no nickname is provided and/or no scene/transition path is provided, the pair is removed! Empty nicknames defeat the point of simplifying annoying paths and empty paths... Go nowhere! There's no point in having that information in memory if it just points to nowhere.

## Projects Using Verho

- HEAD HONCHO (2.0) - HANGOVER SUNSHINE (Verho 2.0)
- [BRAINWORM - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/brainworm) (Verho 1.1)
- [FRANKEN JUDGE - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/franken-judge) (Verho 1.1)
- [KALEIDOKILL - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/kaleidokill) (Verho 1.0)
- [DEFCON JUNIOR - HANGOVER SUNSHINE](https://hangoversunshine.itch.io/defcon-junior) (Verho 1.0)

## For Godot 4.0 - 4.3
For Godot 4.0 - 4.3, we recommend using Verho 1.1, as Verho 2.0 and on utilize typed `Dictionary`-ies in GDScript. It is no longer maintained, but works in a similar way to the audio manager: Resonate.

## For Godot 3.X
Verho is untested on versions of Godot prior to 4.0. Use at your own risk and desire.

### With Love,
Mica / HANGOVER SUNSHINE
