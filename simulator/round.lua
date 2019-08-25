
local ROUND = {}

-- Load module
local ATTACK = require "attack"

-- Calculate the weapon's triangle bonus
local function triangleBonus(weapon, enemyWeapon)
  local weaponTable = {
    sword = { axe = 1, lance = -1 },
    axe = { sword = -1, lance = 1 },
    lance = { sword = 1, axe = -1 },
    wind = { thunder = 1, fire = -1 },
    thunder = { wind = -1, fire = 1 },
    fire = { wind = 1, thunder = -1 }
  }

  return weaponTable[weapon] and weaponTable[weapon][enemyWeapon]
    and weaponTable[weapon][enemyWeapon]
    or 0
end

-- Prepare initial values
local function init(first, second)
  first.triangleBonus = triangleBonus(first.weapon, second.weapon)
  second.triangleBonus = triangleBonus(second.weapon, first.weapon)
  first.effortBonus = first.weapon.eff and first.weapon.eff == second.trait and 2 or 1
  second.effortBonus = second.weapon.eff and second.weapon.eff == first.trait and 2 or 1

  return first, second
end

-- Run an attack
local function runAttack(attacker, defender)
  local attack = attacker.hp > 0 and defender.hp > 0
    and ATTACK.damage(attacker, defender)
    or 0

  defender.hp = defender.hp - attack > 0 and defender.hp - attack or 0

  return attack, defender
end

-- Run double attack
local function doubleAttack(attacker, defender, attack, counterAttack)
  if attack > 0 and attacker.attackSpeed > defender.attackSpeed + 3 then
    defender.hp = defender.hp - attack > 0 and defender.hp - attack or 0
  elseif counterAttack > 0 and defender.attackSpeed > attacker.attackSpeed + 3 then
    attacker.hp = attacker.hp - counterAttack and attacker.hp - counterAttack or 0
  end

  return attacker, defender
end

-- Run a battle round
function ROUND.start(first, second)
  -- Prepare values
  local attacker, defender = init(first, second)
  local attack, counterAttack

  -- Attack
  attack, defender = runAttack(attacker, defender)

  -- Counter-attack
  counterAttack, attacker = runAttack(defender, attacker)

  -- Double attack
  return doubleAttack(attacker, defender, attack, counterAttack)
end

return ROUND
