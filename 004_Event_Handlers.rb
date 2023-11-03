#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
EventHandlers.add(:on_wild_pokemon_created, :automatic_level_scaling,
  proc { |pokemon|
    id = pbGet(LevelScalingSettings::WILD_VARIABLE)
    next if id == 0
    AutomaticLevelScaling.setDifficulty(id)

    AutomaticLevelScaling.setNewLevel(pokemon)
    AutomaticLevelScaling.setSettings if AutomaticLevelScaling.settings[:temporary] # reset settings
  }
)

# Activates script when a trainer pokemon is created
EventHandlers.add(:on_trainer_load, :automatic_level_scaling,
  proc { |trainer|
    id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
    next if !trainer || id == 0
    AutomaticLevelScaling.setDifficulty(id)

    avarage_level = 0
    trainer.party.each { |pokemon| avarage_level += pokemon.level }
    avarage_level /= trainer.party.length

    for pokemon in trainer.party do
      AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
    end
    AutomaticLevelScaling.setSettings if AutomaticLevelScaling.settings[:temporary] # reset settings
  }
)

# Updates partner's pokemon levels after battle
EventHandlers.add(:on_end_battle, :update_partner_levels,
  proc { |_decision, _canLose|
    id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
    next if !$PokemonGlobal.partner || id == 0

    avarage_level = 0
    $PokemonGlobal.partner[3].each { |pokemon| avarage_level += pokemon.level }
    avarage_level /= $PokemonGlobal.partner[3].length

    for pokemon in $PokemonGlobal.partner[3] do
      AutomaticLevelScaling.setNewLevel(pokemon, pokemon.level - avarage_level)
    end
    AutomaticLevelScaling.setSettings if AutomaticLevelScaling.settings[:temporary] # reset settings
  }
)
