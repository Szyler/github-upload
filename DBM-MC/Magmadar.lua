local mod	= DBM:NewMod("Magmadar", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 132 $"):sub(12, -3))
mod:SetCreatureID(11982)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
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



local warnPanic		= mod:NewSpellAnnounce(19408)
local timerPanicCD	= mod:NewCDTimer(30, 19408)
local timerPanic	= mod:NewBuffActiveTimer(8, 19408)

function mod:OnCombatStart(delay)
	self:ScheduleMethod(0, "getBestKill")
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(19408) then
		warnPanic:Show()
		timerPanic:Start()
		timerPanicCD:Start()
	end
end

---------- SPEED KILL FUNCTION ----------
local timerSpeedKill		= mod:NewTimer(0, "Fastest Kill", 48266)function mod:getBestKill()	local bestkillTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicBestTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.bestTime
	timerSpeedKill:Show(bestkillTime)
end
---------- SPEED KILL FUNCTION ----------