module LevelScalingSettings
  # These two above are the variable that controls battle's difficulty
  TRAINERVARIABLE = 99
  WILDVARIABLE = 100

  # You can add your own difficulties here, using the function "Difficulty.new(id, random_increase, fixed_increase)"
  # "id" is the value stored in TRAINERVARIABLE or WILDVARIABLE
  # "random_increase" is a random value that increases the level
  # "fixed_increase" is a pre defined value that increases level
  # Note that these variables can also store negative values
  DIFICULTIES = [
    Difficulty.new(1, 2, -2), # Easy
    Difficulty.new(2, 2, 0),  # Medium
    Difficulty.new(3, 3, 3)   # Hard
  ]

end
