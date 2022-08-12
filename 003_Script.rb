#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  @@selectedDifficulty = Difficulty.new(id: 0)
  @@settings = {
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
    update_moves: true
  }

  def self.setDifficulty(id)
    for difficulty in LevelScalingSettings::DIFICULTIES do
      @@selectedDifficulty = difficulty if difficulty.id == id
    end
  end

  def self.setSettings(update_moves: true, automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS, proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING, first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL, second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL, only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER, only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER)
    @@settings[:update_moves] = update_moves
    @@settings[:first_evolution_level] = first_evolution_level
    @@settings[:second_evolution_level] = second_evolution_level
    @@settings[:proportional_scaling] = proportional_scaling
    @@settings[:automatic_evolutions] = automatic_evolutions
    @@settings[:only_scale_if_higher] = only_scale_if_higher
    @@settings[:only_scale_if_lower] = only_scale_if_lower
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    new_level = pbBalancedLevel($player.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player
    
    # Checks for only_scale_if_higher and only_scale_if_lower
    higher_level_block = @@settings[:only_scale_if_higher] && pokemon.level > pbBalancedLevel($player.party)
    lower_level_block = @@settings[:only_scale_if_lower] && pokemon.level < pbBalancedLevel($player.party)
    if !higher_level_block && !lower_level_block

      # Difficulty modifiers
      new_level += @@selectedDifficulty.fixed_increase
      if @@selectedDifficulty.random_increase < 0
        new_level += rand(@@selectedDifficulty.random_increase..0)
      elsif @@selectedDifficulty.random_increase > 0
        new_level += rand(@@selectedDifficulty.random_increase)
      end

      # Proportional scaling
      new_level += difference_from_average if @@settings[:proportional_scaling]

      new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
      pokemon.level = new_level

      # Evolution part
      AutomaticLevelScaling.setNewStage(pokemon) if @@settings[:automatic_evolutions]

      pokemon.calc_stats
      pokemon.reset_moves if @@settings[:update_moves]

    end
  end

  def self.setNewStage(pokemon)
    form = pokemon.form   # regional form
    pokemon.species = GameData::Species.get(pokemon.species).get_baby_species # revert to the first stage
    multiplePossibleForms = MultipleForms.hasFunction?(pokemon, "getForm") || MultipleForms.hasFunction?(pokemon, "getFormOnEggCreation")
    pokemon.setForm(form) if multiplePossibleForms

    2.times do |evolvedTimes|
      evolutions = GameData::Species.get(pokemon.species).get_evolutions(false)

      # Checks if the species only evolve by level up
      other_evolving_method = false
      evolutions.length.times { |i|
        if evolutions[i][1] != :Level
          other_evolving_method = true
        end
      }

      if !other_evolving_method   # Species that evolve by level up
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else  # For species with other evolving methods
        # Checks if the pokemon is in it's midform and defines the level to evolve
        level = evolvedTimes == 0 ? @@settings[:second_evolution_level] : @@settings[:second_evolution_level]

        if pokemon.level >= level
          if evolutions.length == 1                                 # Species with only one possible evolution
            pokemon.species = evolutions[0][0]
          elsif evolutions.length > 1
            if multiplePossibleForms && form < evolutions.length    # regional forms
              pokemon.species = evolutions[form][0]
            else                                                    # Species with multiple possible evolutions (the evolution is randomly defined)
              pokemon.species = evolutions[rand(0, evolutions.length - 1)][0]
            end
          end
        end
      end
    end
  end

end
