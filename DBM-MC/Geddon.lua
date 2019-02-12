local mod	= DBM:NewMod("Geddon", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 132 $"):sub(12, -3))
mod:SetCreatureID(12056)
mod:SetUsedIcons(8)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
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



local warnInferno		= mod:NewSpellAnnounce(19695)
local warnIgnite		= mod:NewSpellAnnounce(19659)
local warnBomb			= mod:NewTargetAnnounce(20475)
local warnArmageddon	= mod:NewSpellAnnounce(20478)

local timerInferno		= mod:NewCastTimer(8, 19695)
local timerBomb			= mod:NewTargetTimer(8, 20475)
local timerIgnite		= mod:NewBuffActiveTimer(300, 19659)
local timerArmageddon	= mod:NewCastTimer(8, 20478)

local specWarnBomb		= mod:NewSpecialWarningYou(20475)

mod:AddBoolOption("SetIconOnBombTarget", true)

function mod:OnCombatStart(delay)
	self:ScheduleMethod(0, "getBestKill")
	DBM:AddMsg("This boss has not yet been re-scripted in OBM. In order to assist with scripting, please record your attempts and send the footage to Sky17#0017 on Discord.")
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(20475) then
		timerBomb:Start(args.destName)
		warnBomb:Show(args.destName)
		if self.Options.SetIconOnBombTarget then
			self:SetIcon(args.destName, 8, 8)
		end
		if args:IsPlayer() then
			specWarnBomb:Show()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(19695) then
		warnInferno:Show()
		timerInferno:Start()
	elseif args:IsSpellID(19659) then
		warnIgnite:Show()
		timerIgnite:Start()
	elseif args:IsSpellID(20478) then
		warnArmageddon:Show()
		timerArmageddon:Start()
	end
end

---------- SPEED KILL FUNCTION ----------
local timerSpeedKill		= mod:NewTimer(5, "Fastest Kill")
function mod:getBestKill()
	local bestkillTime = (mod:IsDifficulty("heroic5", "heroic25") and mod.stats.heroicBestTime) or mod:IsDifficulty("normal5", "heroic10") and mod.stats.bestTime
	timerSpeedKill:Show(bestkillTime)
end
---------- SPEED KILL FUNCTION ----------