# Automatic Level Scaling

This Pokemon Essentials v21, v20 and v19 plugin will change wild and trainer pokemon levels according to the party pokemon levels. These pokemon are also going to evolve automatically depending on their level. You can choose between 5 initial difficulty options, or easily create your own difficulty options. All these features can also be disabled if you wish.

## Installation

To install this plugin, extract the zip file from the [latest release](https://github.com/Benitex/Automatic-Level-Scaling/releases) into your game root folder.

Then, you should check if you're already using variables 99 and 100 in your game. These are the variables that control trainer and wild pokemon difficulty, respectively.
If you are already using these variables, go to the `Settings.rb` script and change the value to whichever variable you want to use to change the difficulty.

In `Settings.rb`, you can also change some options, create other difficulty options, and enable more complex conditions for level scaling.
This is everything you need to do to install the script, but you should also activate it by selecting a difficulty.

## How to use

### Selecting a difficulty

In order to change the difficulty, you should use an event to change the variable value according to the pre-defined difficulties. If you want to disable automatic level scaling, just set the variable value to 0. By default, all variable values are 0, so levels are not balanced unless you set these variables to one of the difficulties ids.

Here's an event showing some of the options to change difficulty:

![event](https://user-images.githubusercontent.com/64505839/168475608-3907a7fa-f401-4aec-a05d-8d1a9ffe41b6.png)

### Setting up gift pokemon, trades, fixed encounters

Whenever you find a field where you should insert a pokemon level (except for PBS), you can use the function `AutomaticLevelScaling.getScaledLevel` and the level will be automatically defined according to the currently selected difficulty.

## Advanced Options

### Creating new difficulties

There are some pre-defined difficulties, but you can add your own new ones by using the function `Difficulty.new(fixed_increase:, random_increase:)` in the DIFFICULTIES Hash in `Settings.rb`.

* `fixed_increase` is a pre defined value that is always added to the level avarage
* `random_increase` is a randomly selected value between 0 and the value provided

Note that these variables can also store negative values. Setting them to 0 would have the same effect as calling `pbBalancedLevel($player.party)` and removing two from the average.

### Changing settings for a specific battle

You can use the function `AutomaticLevelScaling.setTemporarySetting(setting, value)` to apply a temporary change to a setting for a specific battle, all changes will be reverted after the battle. This is a new way to change settings in v1.4, based on Essentials `setBattleRule` function. You can simply insert the setting name in the first parameter and the value defined in the second, you should call it multiple times if you want to apply multiple settings. You can still use the older `AutomaticLevelScaling.setSettings` function if you prefer though.

`AutomaticLevelScaling.setSettings` does not automatically revert changes after the next battle and they will be permanent until the game is closed or new changes are made. You can use the `temporary` parameter to revert the changes after the battle. If you don't use it, don't forget to change them back to the original settings after the battle or series of battles. All arguments are optional and can be positioned in any order, use a value of the type indicated after the parameter name.

`AutomaticLevelScaling.setSettings(temporary: boolean, update_moves: boolean, automatic_evolutions: boolean, include_previous_stages: boolean, proportional_scaling: boolean, first_evolution_level: Integer, second_evolution_level: Integer, only_scale_if_higher: boolean, only_scale_if_lower: boolean, saveTrainerParties: boolean, useMapLevelForWildPokemon: boolean)`

| Name | Description |
| ---- | ----------- |
| updateMoves | Set to false if you want to use the pre-defined moves in the PBS. |
| proportionalScaling | When true, Takes original level differences from the PBS into consideration when scaling levels. |
| automaticEvolutions | Set to false if you don't want pokemon to update their evolution stage. |
| includeNonNaturalEvolutions | Set to false if you want to disable evolution for pokemon that evolve with evolution stones, happiness, etc. You can see and change the natural methods in the NATURAL_EVOLUTION_METHODS array in Settings.rb. |
| includePreviousStages | When true, returns pokemon to their previous evolution stages if they did not reach their evolution level. |
| includeNextStages | If false, stops evolution at the species used in the function call (or defined in the PBS). In other words, you can set the maximum evolution of a pokemon in the wild or for a specific trainer. |
| firstEvolutionLevel | Select the level required for pokemon that don't evolve by level up to get to their mid-form. |
| secondEvolutionLevel | Select the level required for pokemon that don't evolve by level up to get to their final form. |
| onlyScaleIfHigher | When true, the script will only scale levels if the player is over-leveled. |
| onlyScaleIfLower | When true, the script will only scale levels if the player is under-leveled. |
| saveTrainerParties | When true, trainer parties will keep the same pokemon and levels of the first battle. (If the player gets defeated, the party will not be scaled again) |
| useMapLevelForWildPokemon | When first entering a map, the script will define a scaling level based on the player party and use this level for the map for the rest of the game. |
| temporary | Restores all settings to their default values after the next battle. Only possible in `setSettings` because `setTemporarySetting` enables this by default. |

**Warning**: `setTemporarySetting` uses camelCase for parameters and `setSettings` uses underscore_case.

## Detailed credits

You can credit Benitex, Joltik, and Umbreon if you use this plugin in your game. I wrote the script myself, but I was inspired by [Joltik's Advanced Pokemon Level Balancing + evolution](https://www.pokecommunity.com/showthread.php?t=409828), and the default Essentials random dungeon script.
