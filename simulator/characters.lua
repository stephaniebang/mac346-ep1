
local CHARACTERS = {}

-- Calculate character attack spped
local function attackSpeed(character, weapon)
  return character.spd - math.max(0, weapon.wt - character.str)
end

-- Check if table contains value
local function tableContainsValue(tbl, val)
  for _,v in pairs(tbl) do
    if v == val then
      return true
    end
  end

  return false
end

-- Create and calculate characters' stats from given units and weapons
function CHARACTERS.init(characters, weapons)
  local physicalWeapons = { 'sword', 'axe', 'lance', 'bow' }

  for k,_ in pairs(characters) do
    local character = characters[k]
    local weapon = weapons[character.weapon]

    character.weapon = weapon
    character.attackSpeed = attackSpeed(character, weapon)
    character.weapon.physical = tableContainsValue(physicalWeapons, weapon.kind)
  end

  return characters
end

return CHARACTERS
