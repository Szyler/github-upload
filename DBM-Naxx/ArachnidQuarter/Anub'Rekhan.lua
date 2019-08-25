local mod	= DBM:NewMod("Anub'Rekhan", "DBM-Naxx", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2943 $"):sub(12, -3))
mod:SetCreatureID(15956)

mod:RegisterCombat("combat")

mod:EnableModel()

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_START",
	"PLAYER_ALIVE"
)
-----Locust Swarm-----
local prewarnLocustInitial	= mod:NewAnnounce("Locust Swarm Initial CD Now", 2, 28785)
local prewarnLocust			= mod:NewAnnounce("Locust Swarm Soon", 2, 28785)
local warnLocust			= mod:NewAnnounce("Locust Swarm", 3, 28785)
local timerLocust			= mod:NewTimer(90, "Next Locust Swarm", 28785)
local timerLocustInitial	= mod:NewTimer(90, "Locust Swarm Initial CD", 28785)
local timerLocustRemaining	= mod:NewTimer(15, "Locust Swarm: Time Remaining", 28785)
local specWarnLocust		= mod:NewSpecialWarning("Locust Swarm", nil, "Special warning for Locust Swarm cast")
local soundLocust			= mod:SoundRunAway(28785)
-----Dark Gaze-----
local specWarnDarkGaze		= mod:NewSpecialWarning("Dark Gaze", nil, "Special warning for Dark Gaze on you")
local soundDarkGaze			= mod:SoundAlarmLong(1003011)
-----IMPALE------
local specWarnImpale		= mod:NewSpecialWarning("Impale", nil, "Special warning for Impale on you")
local soundImpale			= mod:SoundAirHorn(28783)
-----Misc-----
local berserkTimer			= mod:NewBerserkTimer(600)
local target			 	= UnitName(15956 .. "target")

-----Boss Functions-----
function mod:OnCombatStart(delay)
	berserkTimer:Start()
	mod:getBestKill()
	timer = 90
	timerLocustInitial:Show(timer)
	prewarnLocustInitial:Schedule(timer)
end

function mod:locustRepeat()
	timer = 90
	timerLocust:Show(timer)
	prewarnLocust:Schedule(timer-5)
	warnLocust:Schedule(timer)
	soundLocust:Schedule(timer)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(1003011) then 
		if args:IsPlayer() then
			specWarnDarkGaze:Show(10);
			soundDarkGaze:Play();
			SendChatMessage(L.YellDarkGaze, "YELL")
		end
	end	
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(28785) then
		mod:locustRepeat()
		specWarnLocust:Show(18)
		timerLocustRemaining:Show(18)
	elseif args:IsSpellID(28783) then
		if target then 
			specWarnImpale:Show(5)
			soundImpale:Play()
		end
	end
end

-----TBM GLOBAL FUNCTIONS-----
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