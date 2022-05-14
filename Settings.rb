module LevelScalingSettings
  # These two above are the variable that controls battle's difficulty
  TRAINER_VARIABLE = 99
  WILD_VARIABLE = 100

  # You can add your own difficulties here, using the function "Difficulty.new(id, random_increase, fixed_increase)"
  # "id" is the value stored in TRAINERVARIABLE or WILDVARIABLE
  # "random_increase" is a random value that increases the level
  # "fixed_increase" is a pre defined value that increases the level
  # Note that these variables can also store negative values
  DIFICULTIES = [
    Difficulty.new(1, 2, -2), # Easy
    Difficulty.new(2, 2, 0),  # Medium
    Difficulty.new(3, 3, 3)   # Hard
  ]

  AUTOMATIC_EVOLUTIONS = true
  UPDATE_MOVES = true

  TRADE_EVOLUTION_LEVEL = 40

end
