# Automatic Level Scaling

This Pokemon Essentials v20 and v19 plugin will change wild and trainer pokemon levels according to the party pokemon levels. These pokemon are also going to evolve automatically depending on their level. You can choose between 3 initial difficulty options, but you can also easily create your difficulty options. All these features can also be disabled if you wish.

## Installation

To install this plugin, extract the zip file into your game project main/root folder.
Then, you should check if you're already using variables 99 and 100 in your game. These are the variables that control trainer and wild pokemon difficulty, respectively.
If you are already using these variables, go to the `Settings.rb` script and change the value to whichever variable you want to use to change the difficulty.
In `Settings.rb`, you can also create other difficulty options and disable automatic evolutions and updated movesets.

## How to use

### Selecting a difficulty

In order to change the difficulty, you should use an event to change the variable value according to the pre-defined difficulties. If you want to disable automatic level scaling, just set the variable value to 0. By default, all variable values are 0.

Here's an event showing some of the options to change difficulty:

![event](https://user-images.githubusercontent.com/64505839/168475608-3907a7fa-f401-4aec-a05d-8d1a9ffe41b6.png)

### Creating new difficulties

There are some pre-defined difficulties, but you can add your own new ones by using the function `Difficulty.new(id:, fixed_increase:, random_increase:` in `Settings.rb`.

* `id` is the value stored in `TRAINERVARIABLE` or `WILDVARIABLE`
* `random_increase` is a random value that increases the pokemon level
* `fixed_increase` is a pre-defined value that increases the pokemon level

Note that these variables can also store negative values. Setting them to 0 would have the same effect of calling `pbBalancedLevel($player.party)` and removing two from the avarage.

### Changing settings for a specific battle

You can use the following function to change some settings before a specific battle. Don't forget to change them back to the original settings after the battle. All arguments are optional and can be positioned in any order.

`AutomaticLevelScaling.setSettings(update_moves:, automatic_evolutions:, :proportional_scaling, first_evolution_level:, second_evolution_level:)`

* `update_moves` can be set to false if you don't want moves to be updated after setting the new level and stage
* `only_scale_if_higher` can be set to true if you want to use the original level when a player's pokemon level is lower than the original level
* `only_scale_if_lower` can be set to true if you want to use the original level when a player's pokemon level is higher than the original level
* `proportional_scaling` can be set to true if you want to scale levels but take original level differences into consideration
* `automatic_evolutions` can be set to false if you don't pokemon to automatically evolve if possible
* `first_evolution_level` is the level required for pokemon that don't evolve by level up to get to the mid form
* `second_evolution_level` is the level required for pokemon that don't evolve by level up to get to the final form

## Detailed credits

The one script I was inspired by the most is [Joltik's Advanced Pokemon Level Balancing + evolution](https://www.pokecommunity.com/showthread.php?t=409828), but the default Essentials random dungeon script was also important to make this script.
