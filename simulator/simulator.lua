
local SIMULATOR = {}


function printTable (tbl)
  for k,v in pairs(tbl) do
    if type(v) == 'table' then
      print(k .. ':')
      printTable(v)
    else
      print(k,v)
    end
  end
end


function random ()
  return math.ceil(math.random() * 100)
end


function copyTable (tbl)
  local copy = {}

  for k,v in pairs(tbl) do
    copy[k] = v
  end

  return copy
end


function tableContains (tbl, val)
  for k,v in pairs(tbl) do
    if v == val then
      return true
    end
  end

  return false
end


function triangleBonus (weapon, enemyWeapon)
  local weaponTable = {
    sword = { axe = 1, lance = -1 },
    axe = { sword = -1, lance = 1 },
    lance = { sword = 1, axe = -1 },
    wind = { thunder = 1, fire = -1 },
    thunder = { wind = -1, fire = 1 },
    fire = { wind = 1, thunder = -1 }
  }

  if weaponTable[weapon] and weaponTable[weapon][enemyWeapon] then
    return weaponTable[weapon][enemyWeapon]
  end

  return 0
end


-- Whether the defender got hit
function gotHit (attacker, attWeapon, defender, defWeapon)
  -- Hit Chance
  --   acc = hit + skl * 2 + lck + triangle bonus * 10
  --   avo = (attack speed * 2) + lck
  local acc = attWeapon.hit + 2*attacker.skl + attacker.lck + triangleBonus(attWeapon, defWeapon)*10
  local avo = (defender.spd - math.max(0, defWeapon.wt - defender.str))*2 + defender.lck
  local hitChance = math.max(0, math.min(100, acc - avo))
  local randomMean = (random() + random())/2

  return randomMean <= hitChance
end


-- Whether the attack was critical
function isCritical (attacker, attWeapon, defender, defWeapon)
  -- Critical chance
  --   critical rate = crt + (skl / 2)
  --   dodge = lck
  local criticalRate = attWeapon.crt + (attacker.skl/2)
  local dodge = defender.lck
  local criticalChance = math.max(0, math.min(100, criticalRate - dodge))

  return random() <= criticalChance
end


-- Attack power
function attackPower (attacker, attWeapon, defender, defWeapon, isPhysical)
  local effBonus = attWeapon.eff and attWeapon.eff == defender.trait and 2 or 1

  -- Weapon power
  local weaponPower = (attWeapon.mt + triangleBonus(attWeapon, defWeapon))*effBonus

  -- Attacker power
  local attackerPower = isPhysical and attacker.str or attacker.mag

  return attackerPower + weaponPower
end


-- Damage calculator function
function damage (attacker, attWeapon, defender, defWeapon)
  if not gotHit(attacker, attWeapon, defender, defWeapon) then
    return 0
  end

  local critical = isCritical(attacker, attWeapon, defender, defWeapon)
  local physicalWeapons = { 'sword', 'axe', 'lance', 'bow' }
  local isPhysical = tableContains(physicalWeapons, attWeapon.kind)
  local criticalBonus = critical and 3 or 1
  local defense = isPhysical and defender.def or defender.res
  local attack = attackPower(attacker, attWeapon, defender, defWeapon, isPhysical)
  
  print('attack: ' .. attack .. '\tdefense: ' .. defense)

  return (attack - defense)*criticalBonus
end


function attackSpeed (character, weapon)
  return character.spd - math.max(0, weapon.wt - character.str)
end


function SIMULATOR.run(scenario_input)
  -- Set seed
  math.randomseed(scenario_input.seed)

  -- Set variables
  local characters = copyTable(scenario_input.units)
  local weapons = copyTable(scenario_input.weapons)
  local fights = copyTable(scenario_input.fights)

  -- For each fight
  for i,fight in pairs(fights) do
    print('** ROUND ' .. i .. '**************************')
    print(fight[1] .. ':\t' .. characters[fight[1]].hp .. '\t\t' .. fight[2] .. ':\t' .. characters[fight[2]].hp)

    local first = characters[fight[1]]
    local second = characters[fight[2]]

    -- Attack
    local attack = first.hp > 0 and second.hp > 0 and damage(first, weapons[first.weapon], second, weapons[second.weapon]) or 0
    characters[fight[2]].hp = second.hp - attack > 0 and second.hp - attack or 0

    print('[ ATTACK ]')
    print(fight[1] .. ':\t' .. characters[fight[1]].hp .. '\t\t' .. fight[2] .. ':\t' .. characters[fight[2]].hp)

    -- Counter-attack
    local counterAttack = first.hp > 0 and second.hp > 0 and damage(second, weapons[second.weapon], first, weapons[first.weapon]) or 0
    characters[fight[1]].hp = first.hp - counterAttack > 0 and first.hp - counterAttack or 0

    print('[ COUNTER-ATTACK ]')
    print(fight[1] .. ':\t' .. characters[fight[1]].hp .. '\t\t' .. fight[2] .. ':\t' .. characters[fight[2]].hp)

    -- Double attack
    local firstAttackSpeed = attackSpeed(first, weapons[first.weapon])
    local secondAttackSpeed = attackSpeed(second, weapons[second.weapon])

    if attack > 0 and firstAttackSpeed > secondAttackSpeed + 3 then
      characters[fight[2]].hp = characters[fight[2]].hp - attack > 0 and characters[fight[2]].hp - attack or 0

      print('[ DOUBLE ATTACK ]')
      print(fight[1] .. ':\t' .. characters[fight[1]].hp .. '\t\t' .. fight[2] .. ':\t' .. characters[fight[2]].hp)
    elseif counterAttack > 0 and secondAttackSpeed > firstAttackSpeed + 3 then
      characters[fight[1]].hp = characters[fight[1]].hp - counterAttack and characters[fight[1]].hp - counterAttack or 0

      print('[ DOUBLE COUNTER-ATTACK ]')
      print(fight[1] .. ':\t' .. characters[fight[1]].hp .. '\t\t' .. fight[2] .. ':\t' .. characters[fight[2]].hp)
    end
    print()
  end

  -- Return hp's
  local hps = {}

  for k,v in pairs(characters) do
    hps[k] = { hp = v.hp }
  end

  return hps
end

return SIMULATOR
