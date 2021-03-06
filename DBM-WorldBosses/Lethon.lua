local mod	= DBM:NewMod("Lethon", "DBM-WorldBosses")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4181 $"):sub(12, -3))
mod:SetCreatureID(14888)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"UNIT_HEALTH",
	"PLAYER_ALIVE"
)

function mod:OnCombatEnd(wipe)
	self:Stop();
end

function mod:PLAYER_ALIVE()
	if UnitIsDeadOrGhost("PLAYER") and self.Options.ResetOnRelease then
		self:Stop();
	end
end



local prewarnSpirit				= mod:NewAnnounce("Draw Spirit Soon", 3, 24811)
local warnSpirit				= mod:NewSpellAnnounce(24811, 2)

local lethonHealth = 100

local spiritCount
local prespiritCount

local soundSpirit		= mod:SoundInfoLong(24811)

function mod:preSpirit()
	prewarnSpirit:Show()
end

function mod:alertSpirit()
	warnSpirit:Show()
	self:ScheduleMethod(0, "alarmSound")
end

function mod:alarmSound()
	soundSpirit:Play()
end


function mod:OnCombatStart()
	spiritCount = 0
	prespiritCount = 0
	self:ScheduleMethod(0, "getBestKill")
	aspamOne = 1
	self:ScheduleMethod(1, "antiSpamone")
end

---------- NIGHTMARE DRAKES SHARED ----------
local warnBreath				= mod:NewSpellAnnounce(24818, 3)
local aspamOne
function mod:antiSpamone()
	if aspamOne == 2 then
		warnBreath:Show()
		aspamOne = 1
	end
	self:ScheduleMethod(1, "antiSpamone")
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(24818) then
		aspamOne = 2
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:UNIT_HEALTH(uId)
	if self:GetUnitCreatureId(uId) == 14888 then
		lethonHealth = UnitHealth(uId) / UnitHealthMax(uId) * 100
	end
	self:ScheduleMethod(0, "checkSpirit")
end

function mod:checkSpirit()
	if lethonHealth <= 80 and prespiritCount == 0 then
		prespiritCount = 1
		self:ScheduleMethod(0, "preSpirit")
	elseif lethonHealth <= 75 and spiritCount == 0 then
		spiritCount = 1
		self:ScheduleMethod(0, "alertSpirit")
	elseif lethonHealth <= 55 and prespiritCount == 1 then
		prespiritCount = 2
		self:ScheduleMethod(0, "preSpirit")	
	elseif lethonHealth <= 50 and spiritCount == 1 then
		spiritCount = 2 
		self:ScheduleMethod(0, "alertSpirit")
	elseif lethonHealth <= 30 and prespiritCount == 2 then
		prespiritCount = 3 
		self:ScheduleMethod(0, "preSpirit")
	elseif lethonHealth <= 25 and spiritCount == 2 then 
		spiritCount = 3
		self:ScheduleMethod(0, "alertSpirit")
	end
end
---------- NIGHTMARE DRAKES SHARED ----------

---------- SPEED KILL FUNCTION ----------
local timerSpeedKill		= mod:NewTimer(0, "Fastest Kill", 48266)function mod:getBestKill()	local bestkillTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicBestTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.bestTime
	timerSpeedKill:Show(bestkillTime)
end
---------- SPEED KILL FUNCTION ----------