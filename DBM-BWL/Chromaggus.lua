local mod	= DBM:NewMod("Chromaggus", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 188 $"):sub(12, -3))
mod:SetCreatureID(14020)
mod:RegisterCombat("combat")
mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"PLAYER_ALIVE"
)

local warnBronze				= mod:NewSpellAnnounce(23170, 2)
local warnEnrage				= mod:NewSpellAnnounce(23128)
local timerEnrage				= mod:NewBuffActiveTimer(8, 23128)

local prewarnFirstBreath		= mod:NewAnnounce("First Breath Soon, can be anything", 3)
local prewarnIncinerate			= mod:NewAnnounce("Incinerate Soon, get to middle", 3, 23309)
local prewarnFrost				= mod:NewAnnounce("Frost Burn Soon, find safespot", 3, 23189)
local prewarnIgnite				= mod:NewAnnounce("Ignite Flesh Soon, IceB/DivShield", 3, 23316)
local prewarnCorrosive			= mod:NewAnnounce("Corrosive Acid Soon, deterrence", 3, 23313)
local prewarnTime				= mod:NewAnnounce("Time Lapse Soon, get to middle", 3, 23312)

local warnIncinerate			= mod:NewSpellAnnounce(23309, 2)
local warnFrost					= mod:NewSpellAnnounce(23189, 2)
local warnIgnite				= mod:NewSpellAnnounce(23316, 2)
local warnCorrosive				= mod:NewSpellAnnounce(23313, 2)
local warnTime					= mod:NewSpellAnnounce(23312, 2)

local timerFirst				= mod:NewTimer(20, "First Breath")
local timerIncinerate			= mod:NewCDTimer(20, 23309)
local timerFrost				= mod:NewCDTimer(20, 23189)
local timerIgnite				= mod:NewCDTimer(20, 23316)
local timerCorrosive			= mod:NewCDTimer(20, 23313)
local timerTime					= mod:NewCDTimer(20, 23312)

local berserkTimer				= mod:NewBerserkTimer(270)
local soundBronze				= mod:SoundAirHorn(23170)
local isFirstCast
local bronzeNoSpam

-----BOSS FUNCTIONS-----
function mod:preFirst()
	prewarnFirstBreath:Show()
end

function mod:preIncinerate()
	prewarnIncinerate:Show()
end

function mod:preFrost()
	prewarnFrost:Show()
end

function mod:preIgnite()
	prewarnIgnite:Show()
end

function mod:preCorrosive()
	prewarnCorrosive:Show()
end

function mod:preTime()
	prewarnTime:Show()
end

function mod:alertIncinerate()
	warnIncinerate:Show()
end

function mod:alertFrost()
	warnFrost:Show()
end

function mod:alertIgnite()
	warnIgnite:Show()
end

function mod:alertCorrosive()
	warnCorrosive:Show()
end

function mod:alertTime()
	warnTime:Show()
end

function mod:OnCombatStart(delay)
	self:ScheduleMethod(0, "getBestKill")
	isFirstCast = 1
	self:ScheduleMethod(0, "firstBreath")
	berserkTimer:Start()
	bronzeNoSpam = 1
	self:ScheduleMethod(0, "bronzeAntiSpam")
end

function mod:bronzeAntiSpam()
	local timer7 = 5
	bronzeNoSpam = 1
	self:ScheduleMethod(timer7, "bronzeAntiSpam")
end

function mod:firstBreath()
	local timer1 = 20
	timerFirst:Start(timer1)
	self:ScheduleMethod(timer1-5, "preFirst")
end

function mod:nextIncinerate()
	local timer2 = 20
	timerIncinerate:Show(timer2)
	self:ScheduleMethod(timer2-5, "preIncinerate")
	self:ScheduleMethod(timer2, "alertIncinerate")
	self:ScheduleMethod(timer2, "nextFrost")
end

function mod:nextFrost()
	local timer3 = 20
	timerFrost:Show(timer3)
	self:ScheduleMethod(timer3-5, "preFrost")
	self:ScheduleMethod(timer3, "alertFrost")
	self:ScheduleMethod(timer3, "nextIgnite")
end

function mod:nextIgnite()
	local timer4 = 20
	timerIgnite:Show(timer4)
	self:ScheduleMethod(timer4-5, "preIgnite")
	self:ScheduleMethod(timer4, "alertIgnite")
	self:ScheduleMethod(timer4, "nextCorrosive")
end

function mod:nextCorrosive()
	local timer5 = 20
	timerCorrosive:Show(timer5)
	self:ScheduleMethod(timer5-5, "preCorrosive")
	self:ScheduleMethod(timer5, "alertCorrosive")
	self:ScheduleMethod(timer5, "nextTime")
end

function mod:nextTime()
	local timer6 = 20
	timerTime:Show(timer6)
	self:ScheduleMethod(timer6-5, "preTime")
	self:ScheduleMethod(timer6, "alertTime")
	self:ScheduleMethod(timer6, "nextIncinerate")
end

function mod:SPELL_CAST_SUCCESS(args)
	if isFirstCast == 1 then	
		if args:IsSpellID(23309) then --INCINERATE
			self:ScheduleMethod(0, "alertIncinerate")
			self:ScheduleMethod(0, "nextFrost")
			isFirstCast = 2
		elseif args:IsSpellID(23189) then -- FROST BURN
			self:ScheduleMethod(0, "alertFrost")
			self:ScheduleMethod(0, "nextIgnite")
			isFirstCast = 2
		elseif args:IsSpellID(23316) then -- Ignite flesh
			self:ScheduleMethod(0, "alertIgnite")
			self:ScheduleMethod(0, "nextCorrosive")
			isFirstCast = 2
		elseif args:IsSpellID(23313) then --CORROSIVE ACID
			self:ScheduleMethod(0, "alertCorrosive")
			self:ScheduleMethod(0, "nextTime")
			isFirstCast = 2
		elseif args:IsSpellID(23312) then --TIME LAPSE
			self:ScheduleMethod(0, "alertTime")
			self:ScheduleMethod(0, "nextIncinerate")
			isFirstCast = 2
		end
	elseif isFirstCast == 2 then end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(23170) then
		self:ScheduleMethod(0, "bronzeCheck")
	elseif args:IsSpellID(23128) then
		warnEnrage:Show()
		timerEnrage:Start()
	end
end

function mod:bronzeCheck()
	if bronzeNoSpam == 1 then 
		bronzeNoSpam = 2 
		warnBronze:Show()
		soundBronze:Play()
	elseif bronzeNoSpam == 2 then
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(23128) then
		timerEnrage:Cancel()
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