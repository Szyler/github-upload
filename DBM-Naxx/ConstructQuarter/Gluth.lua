local mod	= DBM:NewMod("Gluth", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2869 $"):sub(12, -3))
mod:SetCreatureID(15932)
mod:RegisterCombat("combat")
mod:EnableModel()
mod:RegisterEvents(
	"SPELL_DAMAGE",
	"PLAYER_ALIVE"
)

-----DECIMATE-----
local warnDecimateSoon	= mod:NewSoonAnnounce(54426, 2)
local warnDecimateNow	= mod:NewSpellAnnounce(54426, 3)
local timerDecimate		= mod:NewCDTimer(104, 54426)
-----MISC-----
local enrageTimer		= mod:NewBerserkTimer(480)

-----BOSS FUNCTIONS-----
function mod:OnCombatStart(delay)
	self:ScheduleMethod(0, "getBestKill")
	enrageTimer:Start(480 - delay)
	timerDecimate:Start(110 - delay)
	warnDecimateSoon:Schedule(100 - delay)
end

local decimateSpam = 0
function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(28375) and (GetTime() - decimateSpam) > 20 then
		decimateSpam = GetTime()
		warnDecimateNow:Show()
		timerDecimate:Start()
		warnDecimateSoon:Schedule(96)
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