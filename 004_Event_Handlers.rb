#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  id = pbGet(LevelScalingSettings::WILD_VARIABLE)
  next if id == 0
  AutomaticLevelScaling.difficulty = id

  if AutomaticLevelScaling.settings[:use_map_level_for_wild_pokemon]
    pokemon.scale(AutomaticLevelScaling.getMapLevel($game_map.map_id))
  else
    pokemon.scale
  end
}

# Activates script when a trainer pokemon is created
Events.onTrainerPartyLoad += proc { |_sender, trainer|
  id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  next if !trainer || id == 0
  AutomaticLevelScaling.difficulty = id
  trainer = trainer[0]

  if AutomaticLevelScaling.settings[:save_trainer_parties] && AutomaticLevelScaling.battledTrainer?(trainer.key)
    AutomaticLevelScaling.scaleToPreviousTrainerParty(trainer)
    next
  end

  avarage_level = 0
  trainer.party.each { |pokemon| avarage_level += pokemon.level }
  avarage_level /= trainer.party.length

  for pokemon in trainer.party do
    if AutomaticLevelScaling.settings[:proportional_scaling]
      difference_from_average = pokemon.level - avarage_level
      pokemon.scale(AutomaticLevelScaling.getScaledLevel + difference_from_average)
    else
      pokemon.scale
    end
  end

  if AutomaticLevelScaling.settings[:save_trainer_parties]
    AutomaticLevelScaling.savePreviousTrainerParty(trainer.key, trainer.party)
  end
}

# Updates partner's pokemon levels after battle
Events.onEndBattle += proc { |_sender, e|
  id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  next if !$PokemonGlobal.partner || id == 0

  avarage_level = 0
  $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
  avarage_level /= $PokemonGlobal.partner[3].length

  for pokemon in $PokemonGlobal.partner[3] do
    if AutomaticLevelScaling.settings[:proportional_scaling]
      difference_from_average = pokemon.level - avarage_level
      pokemon.scale(AutomaticLevelScaling.getScaledLevel + difference_from_average)
    else
      pokemon.scale
    end
  end
}

# Resets settings after battle if they are temporaray
Events.onEndBattle += proc { |_sender, e|
  if AutomaticLevelScaling.settings[:temporary]
    AutomaticLevelScaling.setSettings
  end
}

#  Set map level when player enters a map
Events.onMapChange += proc { |_sender, e|
  next if !AutomaticLevelScaling.settings[:use_map_level_for_wild_pokemon]
  next if $PokemonGlobal.map_levels.has_key?($game_map.map_id)
  $PokemonGlobal.map_levels[$game_map.map_id] = AutomaticLevelScaling.getScaledLevel
}
