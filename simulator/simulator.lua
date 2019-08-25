
local SIMULATOR = {}

-- Load modules
local CHARACTERS = require "characters"
local ROUND = require "round"

-- Get characters' hp
local function getHp(characters)
  local hps = {}

  for k,v in pairs(characters) do
    hps[k] = { hp = v.hp }
  end

  return hps
end

function SIMULATOR.run(scenario_input)
  -- Set seed
  math.randomseed(scenario_input.seed)
  -- Set characters
  local characters = CHARACTERS.init(scenario_input.units, scenario_input.weapons)

  for _,fight in pairs(scenario_input.fights) do
    local attacker = characters[fight[1]]
    local defender = characters[fight[2]]

    characters[fight[1]], characters[fight[2]] = ROUND.start(attacker, defender)
  end

  return getHp(characters)
end

return SIMULATOR
