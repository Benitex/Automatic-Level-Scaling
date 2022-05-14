################################################################################
# Advanced Pokemon Level Balancing
# By Benitex
################################################################################

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  difficulty = $game_variables[LevelScalingSettings::WILD_VARIABLE] 

  # Make all wild Pokémon shiny while a certain Switch is ON (see Pokemon Essentials Settings script).
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end

  if difficulty > 0
    setNewLevel(pokemon, difficulty)
  end
}

Events.onTrainerPartyLoad += proc { |_sender, trainer|
  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
    difficulty = $game_variables[LevelScalingSettings::TRAINER_VARIABLE]
    if difficulty > 0
      for pokemon in trainer[0].party
        setNewLevel(pokemon, difficulty)
      end
    end
  end
}

def setNewLevel(pokemon, selectedDifficulty)
  new_level = pbBalancedLevel($Trainer.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

  # Difficulty modifiers
  for difficulty in LevelScalingSettings::DIFICULTIES do
    if difficulty.id == selectedDifficulty
      new_level += rand(difficulty.random_increase) + difficulty.fixed_increase
    end
  end

  new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
  pokemon.level = new_level

  if LevelScalingSettings::AUTOMATIC_EVOLUTIONS
    setNewStage(pokemon)  # Evolution part
  end
  pokemon.calc_stats
  if LevelScalingSettings::UPDATE_MOVES
    pokemon.reset_moves    
  end
end

def setNewStage(pokemon)
  pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first evolution
  while pokemon.check_evolution_on_level_up != nil
    pokemon.species = pokemon.check_evolution_on_level_up
  end
  if pokemon.check_evolution_on_trade(self) && pokemon.level > LevelScalingSettings::TRADE_EVOLUTION_LEVEL
    pokemon.species = pokemon.check_evolution_on_trade(self)
  end
end

class Difficulty
  attr_accessor :id
  attr_accessor :random_increase
  attr_accessor :fixed_increase

  def initialize(id, random_increase, fixed_increase)
    @id = id
    @random_increase = random_increase
    @fixed_increase = fixed_increase
  end
end