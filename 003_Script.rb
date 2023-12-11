#===============================================================================
# Automatic Level Scaling
# By Benitex
#===============================================================================

class AutomaticLevelScaling
  @@selected_difficulty = Difficulty.new
  @@settings = {
    temporary: false,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_non_natural_evolutions: LevelScalingSettings::INCLUDE_NON_NATURAL_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER,
    update_moves: true
  }
  def self.settings
    return @@settings
  end

  def self.setDifficulty(id)
    if LevelScalingSettings::DIFFICULTIES[id] == nil
      raise _INTL("No difficulty with id \"{1}\" was provided in the DIFFICULTIES Hash of Settings.", id)
    else
      @@selected_difficulty = LevelScalingSettings::DIFFICULTIES[id]
    end
  end

  def self.getScaledLevel
    level = pbBalancedLevel($player.party) - 2 # pbBalancedLevel increses level by 2 to challenge the player

    # Difficulty modifiers
    level += @@selected_difficulty.fixed_increase
    if @@selected_difficulty.random_increase < 0
      level += rand(@@selected_difficulty.random_increase..0)
    elsif @@selected_difficulty.random_increase > 0
      level += rand(@@selected_difficulty.random_increase)
    end

    level = level.clamp(1, GameData::GrowthRate.max_level)

    return level
  end

  def self.setNewLevel(pokemon, difference_from_average = 0)
    new_level = AutomaticLevelScaling.getScaledLevel

    # Checks for only_scale_if_higher and only_scale_if_lower
    is_blocked_by_higher_level = @@settings[:only_scale_if_higher] && pokemon.level > new_level
    is_blocked_by_lower_level = @@settings[:only_scale_if_lower] && pokemon.level < new_level
    return if is_blocked_by_higher_level || is_blocked_by_lower_level

    # Proportional scaling
    if @@settings[:proportional_scaling]
      new_level += difference_from_average
      new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    end

    pokemon.level = new_level
    AutomaticLevelScaling.setNewStage(pokemon) if @@settings[:automatic_evolutions]
    pokemon.calc_stats
    pokemon.reset_moves if @@settings[:update_moves]
  end

  def self.setNewStage(pokemon)
    original_species = pokemon.species
    original_form = pokemon.form   # regional form
    evolution_stage = 0

    if @@settings[:include_previous_stages]
      pokemon.species = GameData::Species.get_species_form(pokemon.species, pokemon.form).get_baby_species # revert to the first stage
    else
      # Checks if the pokemon has evolved
      if pokemon.species != GameData::Species.get_species_form(pokemon.species, pokemon.form).get_baby_species
        evolution_stage = 1
      end
    end

    (2 - evolution_stage).times do |_|
      evolutions = GameData::Species.get_species_form(pokemon.species, pokemon.form).get_evolutions
      possible_evolutions = []
      for evolution in evolutions
        possible_evolutions.push(evolution) if evolution[1] != :None
      end

      # Checks if the species only evolves by natural methods
      only_evolves_by_natural_methods = true
      for evolution in possible_evolutions
        if !LevelScalingSettings::NATURAL_EVOLUTION_METHODS.include?(evolution[1])
          only_evolves_by_natural_methods = false
        end
      end
      return if !only_evolves_by_natural_methods && !@@settings[:include_non_natural_evolutions]

      if only_evolves_by_natural_methods
        if pokemon.check_evolution_on_level_up != nil
          pokemon.species = pokemon.check_evolution_on_level_up
        end

      else
        # Defines the evolution level according to the current stage
        level = @@settings[evolution_stage == 0 ? :first_evolution_level : :second_evolution_level]

        if pokemon.level >= level
          if possible_evolutions.length == 1      # Species with only one possible evolution
            pokemon.species = possible_evolutions[0][0]

          elsif possible_evolutions.length > 1    # Species with multiple possible evolutions
            pokemon.species = possible_evolutions.sample[0]
            # If the original species is a specific evolution, uses it instead of the random one
            for evolution in possible_evolutions do
              if evolution[0] == original_species
                pokemon.species = evolution[0]
              end
            end
          end
        end
      end

      pokemon.setForm(original_form)
      evolution_stage += 1
    end
  end

  def self.setTemporarySetting(setting, value)
    # Parameters validation
    case setting
    when "firstEvolutionLevel", "secondEvolutionLevel"
      if !value.is_a?(Integer)
        raise _INTL("\"{1}\" requires an integer value, but {2} was provided.",setting,value)
      end
    when "updateMoves", "automaticEvolutions", "includeNonNaturalEvolutions", "includePreviousStages", "proportionalScaling", "onlyScaleIfHigher", "onlyScaleIfLower"
      if !(value.is_a?(FalseClass) || value.is_a?(TrueClass))
        raise _INTL("\"{1}\" requires a boolean value, but {2} was provided.",setting,value)
      end
    else
      if setting.include?("_")
        raise _INTL("\"{1}\" is not a defined setting name. Try using camelCase instead of underscore_case.",setting)
      else
        raise _INTL("\"{1}\" is not a defined setting name.",setting)
      end
    end

    @@settings[:temporary] = true
    case setting
    when "updateMoves"
      @@settings[:update_moves] = value
    when "automaticEvolutions"
      @@settings[:automatic_evolutions] = value
    when "includeNonNaturalEvolutions"
      @@settings[:include_non_natural_evolutions] = value
    when "includePreviousStages"
      @@settings[:include_previous_stages] = value
    when "proportionalScaling"
      @@settings[:proportional_scaling] = value
    when "firstEvolutionLevel"
      @@settings[:first_evolution_level] = value
    when "secondEvolutionLevel"
      @@settings[:second_evolution_level] = value
    when "onlyScaleIfHigher"
      @@settings[:only_scale_if_higher] = value
    when "onlyScaleIfLower"
      @@settings[:only_scale_if_lower] = value
    end
  end

  def self.setSettings(
    temporary: false,
    update_moves: true,
    automatic_evolutions: LevelScalingSettings::AUTOMATIC_EVOLUTIONS,
    include_non_natural_evolutions: LevelScalingSettings::INCLUDE_NON_NATURAL_EVOLUTIONS,
    include_previous_stages: LevelScalingSettings::INCLUDE_PREVIOUS_STAGES,
    proportional_scaling: LevelScalingSettings::PROPORTIONAL_SCALING,
    first_evolution_level: LevelScalingSettings::DEFAULT_FIRST_EVOLUTION_LEVEL,
    second_evolution_level: LevelScalingSettings::DEFAULT_SECOND_EVOLUTION_LEVEL,
    only_scale_if_higher: LevelScalingSettings::ONLY_SCALE_IF_HIGHER,
    only_scale_if_lower: LevelScalingSettings::ONLY_SCALE_IF_LOWER
  )
    @@settings[:temporary] = temporary
    @@settings[:update_moves] = update_moves
    @@settings[:first_evolution_level] = first_evolution_level
    @@settings[:second_evolution_level] = second_evolution_level
    @@settings[:proportional_scaling] = proportional_scaling
    @@settings[:automatic_evolutions] = automatic_evolutions
    @@settings[:include_non_natural_evolutions] = include_non_natural_evolutions,
    @@settings[:include_previous_stages] = include_previous_stages
    @@settings[:only_scale_if_higher] = only_scale_if_higher
    @@settings[:only_scale_if_lower] = only_scale_if_lower
  end
end
