################################################################################
# Advanced Pokemon Level Balancing
# By Benitex
################################################################################

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  difficulty = $game_variables[LevelScalingSettings::WILDVARIABLE] 

  # Make all wild Pokémon shiny while a certain Switch is ON (see Pokemon Essentials Settings script).
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end

  if difficulty > 0
    scaleLevel(pokemon, difficulty)
  end
}

Events.onTrainerPartyLoad += proc { |_sender, trainer|
  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
    difficulty = $game_variables[LevelScalingSettings::TRAINERVARIABLE]
    if difficulty > 0
      for pokemon in trainer[0].party
        scaleLevel(pokemon, difficulty)
      end
    end
  end
}

def scaleLevel(pokemon, difficulty)
  new_level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

  # Difficulty modifiers
  if $game_variables[difficulty] == 1       # Easy
    new_level += rand(2) - 2
  elsif $game_variables[difficulty] == 2    # Normal
    new_level += rand(2)
  else                                      # Hard
    new_level += rand(3) + 3
  end

  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  pokemon.level = new_level
  pokemon.calc_stats
  pokemon.reset_moves
end
