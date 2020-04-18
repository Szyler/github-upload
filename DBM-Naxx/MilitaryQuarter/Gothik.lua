local mod	= DBM:NewMod("Gothik", "DBM-Naxx", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2248 $"):sub(12, -3))
mod:SetCreatureID(16060)
mod:RegisterCombat("combat")
mod:RegisterEvents(
	"SPELL_AURA_APPLIED", --This should allow the addon to process this Event using the scripting from Kel'Thuzad for Harvest Soul.
	"SPELL_AURA_APPLIED_DOSE", --This should allow the addon to process this Event using the scripting from Kel'Thuzad for Harvest Soul.
	"UNIT_DIED",
	"PLAYER_ALIVE" 
)

-----ADD DEATHS-----
local warnRiderDown				= mod:NewAnnounce("Unrelenting Rider Killed", 2, 36461, nil, "Show a warning when an Unrelenting Rider is killed")
local warnKnightDown			= mod:NewAnnounce("Unrelenting Death Knight Killed", 2, 36461, nil, "Show a warning when an Unrelenting Rider is killed")
-----HARVEST SOUL-----
local warnHarvestSoon			= mod:NewSoonAnnounce(28679, 3)
local warnHarvest				= mod:NewSpellAnnounce(28679, 2)
local timerHarvest				= mod:NewNextTimer(15, 28679)
local soundTeleport				= mod:SoundInfoLong(46573, "Play the 'Long Info' sound effect when Heigan teleports to the platform")
-----COMBAT START----
local timerCombatStart			= mod:NewTimer(25, "Combat Starts", 2457, nil, "Show timer for the start of combat")
local warnCombatStartSoon		= mod:NewAnnounce("Combat Starts Soon", 2, 2457, nil, "Show pre-warning for the end of the Safety Dance")
local warnCombatStart			= mod:NewAnnounce("Combat Starts Now", 3, 2457, nil, "Show warning for the end of the Safety Dance")
-----GOTHIK ARRIVES----
local timerGothik				= mod:NewTimer(45, "Gothik Arrives", 46573, nil, "Show timer for the arrival of Gothik")
local warnGothikSoon			= mod:NewAnnounce("Gothik Arrives Soon", 2, 46573, nil, "Show pre-warning for the arrival of Gothik")
local warnGothik 				= mod:NewAnnounce("Gothik Arrives Now", 3, 46573, nil, "Show warning for the arrival of Gothik")
local soundGothik				= mod:SoundInfoLong(46573, "Play the 'Long Info' sound effect for the arrival of Gothik")

-----BOSS FUNCTIONS-----
function mod:OnCombatStart(delay)
	self:ScheduleMethod(0, "getBestKill")
	self:ScheduleMethod(60, "HarvestSoul")
	-----HARVEST SOUL-----
	harvestSoulIntiialTimer = 60
	warnHarvestSoon:Schedule(harvestSoulIntiialTimer-5)
	warnHarvest:Schedule(harvestSoulIntiialTimer)
	timerHarvest:Start(harvestSoulIntiialTimer)
	-----COMBAT START----
	combatStartTimer = 25 
	timerCombatStart:Start(combatStartTimer)
	warnCombatStartSoon:Schedule(combatStartTimer-5)
	warnCombatStart:Schedule(combatStartTimer)
	-----GOTHIK ARRIVES----
	gothikTimer = 45
	timerGothik:Start(gothikTimer)
	warnGothikSoon:Schedule(gothikTimer-5)
	warnGothik:Schedule(gothikTimer)
	soundGothik:Schedule(gothikTimer)

end

function mod:HarvestSoul()
	timer = 15
	timerHarvest:Start(timer)
	warnHarvestSoon:Schedule(timer-3, 15)
	warnHarvest:Schedule(timer)
	soundTeleport:Schedule(timer-3)
	self:ScheduleMethod(timer, "HarvestSoul")
end


function mod:UNIT_DIED(args)
	if bit.band(args.destGUID:sub(0, 5), 0x00F) == 3 then
		local guid = tonumber(args.destGUID:sub(9, 12), 16)
		if guid == 16126 then -- Unrelenting Rider
			warnRiderDown:Show()
		elseif guid == 16125 then -- Unrelenting Death Knight
			warnKnightDown:Show()
		end
	end
end

-----SBM GLOBAL FUNCTIONS-----
function mod:OnCombatEnd(wipe)
	self:Stop();
end

function mod:PLAYER_ALIVE()
	if UnitIsDeadOrGhost("PLAYER") and self.Options.ResetOnRelease then
		self:Stop();
	end
end

local timerSpeedKill		= mod:NewTimer(0, "Fastest Kill", 48266)
function mod:getBestKill()
	local bestkillTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicBestTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.bestTime
	timerSpeedKill:Show(bestkillTime)
end
-----SBM GLOBAL FUNCTIONS-----