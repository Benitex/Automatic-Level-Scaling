#===============================================================================
# Automatic Level Scaling Event Handlers
# By Benitex
#===============================================================================

# Activates script when a wild pokemon is created
EventHandlers.add(:on_wild_pokemon_created, :automatic_level_scaling,
  proc { |pokemon|
    id = pbGet(LevelScalingSettings::WILD_VARIABLE)
    next if id == 0
    AutomaticLevelScaling.difficulty = id
    pokemon.scale
  }
)

# Activates script when a trainer pokemon is created
EventHandlers.add(:on_trainer_load, :automatic_level_scaling,
  proc { |trainer|
    id = pbGet(LevelScalingSettings::TRAINER_VARIABLE)
    next if !trainer || id == 0
    AutomaticLevelScaling.difficulty = id

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
      if AutomaticLevelScaling.settings[:proportional_scaling]
        difference_from_average = pokemon.level - avarage_level
        pokemon.scale(AutomaticLevelScaling.getScaledLevel + difference_from_average)
      else
        pokemon.scale
      end
    end
  }
)

# Resets settings after battle if they are temporaray
EventHandlers.add(:on_end_battle, :reset_settings,
  proc { |_decision, _canLose|
    if AutomaticLevelScaling.settings[:temporary]
      AutomaticLevelScaling.setSettings
    end 
  }
)
