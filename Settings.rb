#===============================================================================
# Automatic Level Scaling Settings
# By Benitex
#===============================================================================

module LevelScalingSettings
  # These two above are the variable that controls battle's difficulty
  # (You can set both of them to be the same)
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  # If evolution levels are not defined when creating a difficulty, these are the default values used
  AUTOMATIC_EVOLUTIONS = true
  DEFAULT_FIRST_EVOLUTION_LEVEL = 20
  DEFAULT_SECOND_EVOLUTION_LEVEL = 40

  # Scales levels but takes original level differences into consideration
  # Don't forget to set random_increase values to 0 when using this setting
  PROPORTIONAL_SCALING = false

  # You can add your own difficulties here, using the function "Difficulty.new(id, fixed_increase, random_increase, first_evolution_level, second_evolution_level)"
  #   "id" is the value stored in TRAINER_VARIABLE or WILD_VARIABLE, defines the active difficulty
  #   "fixed_increase" is a pre defined value that increases the level (optional)
  #   "random_increase" is a random value that increases the level (optional)
  # Note that these variables can also store negative values
  DIFICULTIES = [
    Difficulty.new(id: 1, fixed_increase: -2, random_increase: 2),  # Easy
    Difficulty.new(id: 2, random_increase: 2),                      # Medium
    Difficulty.new(id: 3, fixed_increase: 3, random_increase: 3),   # Hard
    Difficulty.new(id: 4),                                          # Avarage
    Difficulty.new(id: 5, fixed_increase: -2, random_increase: 5),  # Standard Essentials

    # You can use the following function to change some other settings for a specific difficulty too.
    # All arguments are optional. You can use this for a specific battle, for example.
    # DifficultySettings.new(update_moves:, first_evolution_level:, second_evolution_level:)
    #   "update_moves" can be set to false if you don't want moves to be updated after setting the new level and stage
    #   "first_evolution_level" is the level required for pokemon that don't evolve by level to get to the mid form
    #   "second_evolution_level" is the level required for pokemon that don't evolve by level to get to the final form
    Difficulty.new(id:6, settings: DifficultySettings.new( update_moves: false, first_evolution_level: 10, second_evolution_level: 10 ))
  ]

end
