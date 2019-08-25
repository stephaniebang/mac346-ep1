
local ATTACK = {}

-- Get random integer from 1 to 100
local function random ()
  return math.random(100)
end

-- Whether the defender got hit
local function gotHit (attacker, defender)
  local acc = attacker.weapon.hit + 2*attacker.skl + attacker.lck + attacker.triangleBonus*10
  local avo = (defender.spd - math.max(0, defender.weapon.wt - defender.str))*2 + defender.lck
  local hitChance = math.max(0, math.min(100, acc - avo))
  local randomMean = (random() + random())/2

  return randomMean <= hitChance
end

-- Whether the attack was critical
local function isCritical (attacker, defender)
  local criticalRate = attacker.weapon.crt + (attacker.skl/2)
  local dodge = defender.lck
  local criticalChance = math.max(0, math.min(100, criticalRate - dodge))

  return random() <= criticalChance
end

-- Calculate attack power
local function attackPower (attacker)
  local weaponPower = (attacker.weapon.mt + attacker.triangleBonus)*attacker.effortBonus
  local attackerPower = attacker.weapon.physical and attacker.str or attacker.mag

  return attackerPower + weaponPower
end

-- Calculate attack damage
function ATTACK.damage (attacker, defender)
  if not gotHit(attacker, defender) then
    return 0
  end

  local critical = isCritical(attacker, defender)
  local criticalBonus = critical and 3 or 1
  local defense = attacker.weapon.physical and defender.def or defender.res
  local attack = attackPower(attacker, defender)

  return (attack - defense)*criticalBonus
end

return ATTACK
