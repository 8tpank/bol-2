
 --[[
  Update Note

  v 1.04
   Fix TargetSelector
  
  v 1.03
   Add Corki Htichance in Menu

  v 1.02
   Add Tristana
   Add Anti Gapcloser
   Add Anti Spell

  v 1.01
   Add Kog'Maw

 ]]

 local version = 1.05
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/jineyne/bol/master/Your ADC Series.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Your ADC Series.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Your ADC Series:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/jineyne/bol/master/version/Your ADC Series.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local champions = {
	["Graves"]		= true,
	--["Kalista"]		= true,
	--["Lucian"]		= true,
	--["MissFortune"]	= true,
	--["Vayne"]		= true,
	--["Sivir"]		= true,
	--["Ashe"]		= true,
	["Urgot"]		= true,
	["Ezreal"]		= true,
	["Jinx"]		= true,
	--["Kalista"]		= true,
	--["Caitlyn"]		= true,
	["KogMaw"]		= true,
	["Corki"]		= true,
	["Tristana"]	= true,
	--["Twitch"]		= true,
}

for k, _ in pairs(champions) do
    local className = k:gsub("%s+", "")
    class(className)
    champions[k] = _G[className]
end

if not champions[myHero.charName] then return end

local SCRIPT_LIBS = {
	["SourceLib"] = "https://raw.github.com/LegendBot/Scripts/master/Common/SourceLib.lua",
	["VPrediction"] = "https://raw.github.com/LegendBot/Scripts/master/Common/VPrediction.lua",
	["DivinePred"] = "http://divinetek.rocks/divineprediction/DivinePred.lua"
}
function Initiate()
	for LIBRARY, LIBRARY_URL in pairs(SCRIPT_LIBS) do
		if FileExist(LIB_PATH..LIBRARY..".lua") then
			require(LIBRARY)
		else
			DOWNLOADING_LIBS = true
			if LIBRARY == "DivinePred" then
				AutoupdaterMsg("Missing Library! Downloading "..LIBRARY..". If the library doesn't download, please download it manually.")
				DownloadFile("http://divinetek.rocks/divineprediction/DivinePred.lua", LIB_PATH.."DivinePred.lua",function() AutoupdaterMsg("Successfully downloaded "..LIBRARY) end)
				DownloadFile("http://divinetek.rocks/divineprediction/DivinePred.luac", LIB_PATH.."DivinePred.luac",function() AutoupdaterMsg("Successfully downloaded "..LIBRARY) end)
			else
				AutoupdaterMsg("Missing Library! Downloading "..LIBRARY..". If the library doesn't download, please download it manually.")
				DownloadFile(LIBRARY_URL,LIB_PATH..LIBRARY..".lua",function() AutoupdaterMsg("Successfully downloaded "..LIBRARY) end)
			end
		end
	end	
	if DOWNLOADING_LIBS then return true end
end
if Initiate() then return end


local champ = champions[myHero.charName]
local HPred, SxO, STS, DP = nil, nil, nil, nil
local ts
local Config = nil
local player = myHero
local enemyHeroes = GetEnemyHeroes()
local EnemyMinions = minionManager(MINION_ENEMY, 1500, player, MINION_SORT_MAXHEALTH_DEC)
local JungleMinions = minionManager(MINION_JUNGLE, 1500, player, MINION_SORT_MAXHEALTH_DEC)
local champLoaded = false
local MMALoad, RebornLoad, SxOLoad, RevampedLoaded = false, false, false, false

local MyminBBox = GetDistance(myHero.minBBox)/2
local AARange = myHero.range+MyminBBox

-- jinx

local JinxQ = 0
local Kalistastack = {}

local cansleingspell = {
	["Tristana"] = { spell = _R, spellRange = "645"},
}


local gapcloserspell = {
	--        ['Ahri']        = {true, spell = _R,},
        ['Aatrox']      = {true, spell = _Q,},
        ['Akali']       = {true, spell = _R,}, -- Targeted ability
        ['Alistar']     = {true, spell = _W,}, -- Targeted ability
        ['Diana']       = {true, spell = _R,}, -- Targeted ability
        ['Gragas']      = {true, spell = _E,},
        ['Graves']      = {true, spell = _E,},
        --['Hecarim']     = {true, spell = _R,},
        ['Irelia']      = {true, spell = _Q,}, -- Targeted ability
        --['JarvanIV']    = {true, spell = 'jarvanAddition',}, -- Skillshot/Targeted ability
        ['Jax']         = {true, spell = _Q,}, -- Targeted ability
        --['Jayce']       = {true, spell = 'JayceToTheSkies',}, -- Targeted ability
        ['Khazix']      = {true, spell = _E,},
        ['Leblanc']     = {true, spell = _W,},
        --['LeeSin']      = {true, spell = 'blindmonkqtwo',},
        ['Leona']       = {true, spell = _E,},
        --['Malphite']    = {true, spell = _R,},
        ['Maokai']      = {true, spell = _W,}, -- Targeted ability
        ['MonkeyKing']  = {true, spell = _E,}, -- Targeted ability
        ['Pantheon']    = {true, spell = _W,}, -- Targeted ability
        ['Poppy']       = {true, spell = _E,}, -- Targeted ability
        --['Quinn']       = {true, spell = _E,}, -- Targeted ability
        ['Renekton']    = {true, spell = _E,},
        ['Sejuani']     = {true, spell = _Q,},
        ['Shen']        = {true, spell = _E,},
        ['Tristana']    = {true, spell = _W,},
		['Thresh']		= {true, spell = _Q},
        --['Tryndamere']  = {true, spell = 'Slash',,
        ['XinZhao']     = {true, spell = _E,}, -- Targeted ability
}

local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"},
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
    { charName = "Warwick", spellName = "InfiniteDuress"}
}
local ToInterrupt = {}


 if VIP_USER then
 	AdvancedCallback:bind('OnApplyBuff', function(s, u, b) OnApplyBuff(s, u, b) end)
	AdvancedCallback:bind('OnRemoveBuff', function(u, b) OnRemoveBuff(u, b) end)
	AdvancedCallback:bind('OnUpdateBuff', function(u, b) OnUpdateBuff(u, b) end)
end

function OnLoad()
	champ = champ()
	self = champ

	if not champ then AutoupdaterMsg("There was an error while loading " .. player.charName .. ", please report the shown error to Yours, thanks!") return else champLoaded = true end

	AutoupdaterMsg(player.charName.." Load")
	OnOrbLoad()
	VP = VPrediction()
	STS = SimpleTS()

	LoadMenu()

	for i = 1, heroManager.iCount do
        local hero = heroManager:GetHero(i)
		for _, champ in pairs(InterruptList) do
			if hero.charName == champ.charName then
				table.insert(ToInterrupt, champ.spellName)
			end
        end
    end

	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true
	else
		TwistedTreeline = false
	end
	setting()

end

function setting()

	JungleMobs = {}
	JungleFocusMobs = {}

	if not TwistedTreeline then
		JungleMobNames = {
			["SRU_MurkwolfMini2.1.3"]	= true,
			["SRU_MurkwolfMini2.1.2"]	= true,
			["SRU_MurkwolfMini8.1.3"]	= true,
			["SRU_MurkwolfMini8.1.2"]	= true,
			["SRU_BlueMini1.1.2"]		= true,
			["SRU_BlueMini7.1.2"]		= true,
			["SRU_BlueMini21.1.3"]		= true,
			["SRU_BlueMini27.1.3"]		= true,
			["SRU_RedMini10.1.2"]		= true,
			["SRU_RedMini10.1.3"]		= true,
			["SRU_RedMini4.1.2"]		= true,
			["SRU_RedMini4.1.3"]		= true,
			["SRU_KrugMini11.1.1"]		= true,
			["SRU_KrugMini5.1.1"]		= true,
			["SRU_RazorbeakMini9.1.2"]	= true,
			["SRU_RazorbeakMini9.1.3"]	= true,
			["SRU_RazorbeakMini9.1.4"]	= true,
			["SRU_RazorbeakMini3.1.2"]	= true,
			["SRU_RazorbeakMini3.1.3"]	= true,
			["SRU_RazorbeakMini3.1.4"]	= true
		}

		FocusJungleNames = {
			["SRU_Blue1.1.1"]			= true,
			["SRU_Blue7.1.1"]			= true,
			["SRU_Murkwolf2.1.1"]		= true,
			["SRU_Murkwolf8.1.1"]		= true,
			["SRU_Gromp13.1.1"]			= true,
			["SRU_Gromp14.1.1"]			= true,
			["Sru_Crab16.1.1"]			= true,
			["Sru_Crab15.1.1"]			= true,
			["SRU_Red10.1.1"]			= true,
			["SRU_Red4.1.1"]			= true,
			["SRU_Krug11.1.2"]			= true,
			["SRU_Krug5.1.2"]			= true,
			["SRU_Razorbeak9.1.1"]		= true,
			["SRU_Razorbeak3.1.1"]		= true,
			["SRU_Dragon6.1.1"]			= true,
			["SRU_Baron12.1.1"]			= true
		}
	else
		FocusJungleNames = {
			["TT_NWraith1.1.1"]			= true,
			["TT_NGolem2.1.1"]			= true,
			["TT_NWolf3.1.1"]			= true,
			["TT_NWraith4.1.1"]			= true,
			["TT_NGolem5.1.1"]			= true,
			["TT_NWolf6.1.1"]			= true,
			["TT_Spiderboss8.1.1"]		= true
		}
		JungleMobNames = {
			["TT_NWraith21.1.2"]		= true,
			["TT_NWraith21.1.3"]		= true,
			["TT_NGolem22.1.2"]			= true,
			["TT_NWolf23.1.2"]			= true,
			["TT_NWolf23.1.3"]			= true,
			["TT_NWraith24.1.2"]		= true,
			["TT_NWraith24.1.3"]		= true,
			["TT_NGolem25.1.1"]			= true,
			["TT_NWolf26.1.2"]			= true,
			["TT_NWolf26.1.3"]			= true
		}
	end

	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			if FocusJungleNames[object.name] then
				JungleFocusMobs[#JungleFocusMobs+1] = object
			elseif JungleMobNames[object.name] then
				JungleMobs[#JungleMobs+1] = object
			end
		end
	end
end

function OnRemoveBuff(u, b)
	if player.charName == "Kalista" and  b.name == "kalistaexpungemarker" and u.type == player.type  then
		Kalistastack[u.charName].stack = 0
	end
	if player.charName == "Jinx" and b.name == "jinxqramp" then
		JinxQ = 0
	end
	if player.charName == "Jinx" and buff.name == 'JinxQ' then
		isFishBones = false
	end
end

function OnUpdateBuff(u, b, s)
	if player.charName == "Kalista" and  s ~= nil and b.name == "kalistaexpungemarker" and u.type == player.type then
		Kalistastack[u.charName].stack = s
		print(u.charName.." : "..s)
	end
	if player.charName == "Jinx" and b.name == "jinxqramp" then
		JinxQ = s
	end
end

function OnApplyBuff(s, u, b)
	if player.charName == "Kalista" and  b.name == "kalistaexpungemarker" and u.type == player.type  then
		if Kalistastack[u.charName] == nil then
			Kalistastack[u.charName] = {stack = 1}
		end
	end
	if player.charName == "Jinx" and b.name == "jinxqramp" then
		JinxQ = 1
	end
	if player.charName == "Jinx" and buff.name == 'JinxQ' then
		isFishBones = true
	end
end

function OnTick()
	if not champLoaded then return end

	OnSpellcheck()
	if champ.OnTick then
        champ:OnTick()
    end




	if champ.OnCombo and Config.combo.active then
        champ:OnCombo()
    elseif champ.OnHarass and Config.harass.active then
        champ:OnHarass()
	elseif champ.LineClear and Config.lc.active then
		champ:LineClear()
	elseif champ.OnFarm and Config.fm.active then
		champ:OnFarm()
    end
end

function OnDraw()
	if champ.OnDraw then
		champ.OnDraw()
	end
end

function OnOrbLoad()
	if _G.MMA_LOADED then
		AutoupdaterMsg("MMA LOAD")
		MMALoad = true
	elseif _G.AutoCarry then
		if _G.AutoCarry.Helper then
			AutoupdaterMsg("SIDA AUTO CARRY: REBORN LOAD")
			RebornLoad = true
		else
			AutoupdaterMsg("SIDA AUTO CARRY: REVAMPED LOAD")
			RevampedLoaded = true
		end
	elseif _G.Reborn_Loaded then
		DelayAction(OnOrbLoad, 1)
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		AutoupdaterMsg("SxOrbWalk Load")
		require 'SxOrbWalk'
		SxO = SxOrbWalk()
		SxOLoad = true
	end
end

local function OrbTarget(rance)
	local T
	if MMALoad then T = _G.MMA_Target end
	if RebornLoad then T = _G.AutoCarry.Crosshair.Attack_Crosshair.target end
	if RevampedLoaded then T = _G.AutoCarry.Orbwalker.target end
	if SxOLoad then T = SxO:GetTarget() end
	if T == nil then 
		T = STS:GetTarget(rance)
		return T
	end
	if T and T.type == player.type and ValidTarget(T, rance) then
		return T
	end
end

function LoadMenu()
	Config = MenuWrapper("[Your Series] " .. player.charName, "unique" .. player.charName:gsub("%s+", ""))

		if SxOLoad then
			Config:SetOrbwalker(SxO)
		end
		
		Config:SetTargetSelector(STS)
		Config = Config:GetHandle()

		if champ.OnCombo then
			Config:addSubMenu("Combo", "combo")
				Config.combo:addParam("active", "Combo Active", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		end

		if champ.OnHarass then
			Config:addSubMenu("Harass", "harass")
				Config.harass:addParam("active", "Harass Active", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		end

		if champ.LineClear then
			Config:addSubMenu("Line Clear", "lc")
				Config.lc:addParam("active", "Line Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
		end

		if champ.OnDraw then
			Config:addSubMenu("Draw", "draw")
		end

		if champ.OnFarm then
			Config:addSubMenu("farming","fm")
				Config.fm:addParam("active", "Farming", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
		end



		if champ.ApplyMenu then champ:ApplyMenu() end


end

function buffcheck(target)
	if player.charName == "Urgot" then
		return TargetHaveBuff("urgotcorrosivedebuff", target)
	end
end

function OnSpellcheck()
	if player:CanUseSpell(_Q) == READY then
		Qready = true
	else
		Qready = false
	end

	if player:CanUseSpell(_W) == READY then
		Wready = true
	else
		Wready = false
	end

	if player:CanUseSpell(_E) == READY then
		Eready = true
	else
		Eready = false
	end

	if player:CanUseSpell(_R) == READY then
		Rready = true
	else
		Rready = false
	end
end


--[[function OnProcessSpell(unit, spell)
	if #ToInterrupt > 0 then
		for _, ability in pairs(ToInterrupt) do
			if spell.name == ability and unit.team ~= player.team and GetDistance(unit) < cansleingspell[player.charName].spellrange then
				if cansleingspell[player.charName] ~= nil then
					CastSpell(cansleingspell[player.charName].spell, unit)
				end
			end
		end
	end
	if unit.type == player.type and unit.team ~= player.team and spell then
		if gapcloserspell[unit.charName] ~= nil then
			for i=1, #gapcloserspell[unit.charName] do
				if spell.name == unit:GetSpellData(gapcloserspell[unit.charName].spell).name then
					if cansleingspell[player.charName] ~= nil then
						local t = tostring(math.ceil(GetDistance(Vector(spell.endPos), player)))
						local a = cansleingspell[player.charName].spellRange
						if t < a then
							CastSpell(cansleingspell[player.charName].spell, unit)
						end
					end
				end
			end
		end
	end
end]]

function GetJungleMob(rance)
	for _, Mob in pairs(JungleFocusMobs) do
		if ValidTarget(Mob, rance) then return Mob end
	end
	for _, Mob in pairs(JungleMobs) do
		if ValidTarget(Mob, rance) then return Mob end
	end
end

function GetBestLineFarmPosition(range, width, objects)
	local BestPos
	local BestHit = 0
	for i, object in ipairs(objects) do
		local EndPos = Vector(player.visionPos) + range * (Vector(object) - Vector(player.visionPos)):normalized()
		local hit = CountObjectsOnLineSegment(player.visionPos, EndPos, width, objects)
		if hit > BestHit then
			BestHit = hit
			BestPos = Vector(object)
			if BestHit == #objects then
			   break
			end
		 end
	end
	return BestPos, BestHit
end


---------------------------------------------------------
------------------------Graves
---------------------------------------------------------

function Graves:__init()
	local Qrance = 900
	local Wrance = 1100
	local Erance = 425
	local Rrance = 600
end

 function Graves:OnCombo()
	local Target = OrbTarget(1100)
	if Target ~= nil then
		if Config.combo.useq then
			local CastPosition, HitChance, Hit = VP:GetConeAOECastPosition(Target, 0.25, 25 * math.pi/180, 900, 2000, player)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if Config.combo.usew then
			local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(Target, 0.25, 250, 1100, 1650, player)
			if TargetHitChance >= 2 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		end
	end
 end

 function Graves:OnHarass()
	local Target = OrbTarget(1100)
	if Target ~= nil then
		if Config.harass.useq and player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
			local CastPosition, HitChance, Hit = VP:GetConeAOECastPosition(Target, 0.25, 25 * math.pi/180, 900, 2000, player)
			if HitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
 end

function Graves:OnTick()
	local i, t
	for i, t in pairs(enemyHeroes) do
		if ValidTarget(t) and Config.ks.user and GetDistance(t, player) < 1000 and getDmg("R", t, player) > t.health then
			local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(t, 0.25, 100, 1100, 2100, player)
			if MainTargetHitChance >= 2 then
				CastSpell(_R, AOECastPosition.x, AOECastPosition.z)
			end
		end
	end
 end

 function Graves:OnDraw()
	if Config.draw.drawq then
		DrawCircle(player.x, player.y, player.z, 900, TARGB(Config.draw.drawqcolor))
	end
	if Config.draw.drawr then
		DrawCircle(player.x, player.y, player.z, 1000, TARGB(Config.draw.drawrcolor))
	end
	if Config.draw.draww then
		DrawCircle(player.x, player.y, player.z, 1100, TARGB(Config.draw.drawwcolor))
	end
 end

 function Graves:LineClear()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 900 and Config.lc.useq and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local bestpos, besthit = GetBestLineFarmPosition(900, 1000, JungleMinions.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
	end
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 900 and Config.lc.useq and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local bestpos, besthit = GetBestLineFarmPosition(900, 1000, EnemyMinions.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
	end
end

 function Graves:ApplyMenu()
		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)

		Config.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.lc:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawqcolor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawwcolor", "Draw W Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawrcolor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
 end

---------------------------------------------------------
------------------------Corki
---------------------------------------------------------

function Corki:__init()

 end

 function Corki:OnCombo()
	local Target = OrbTarget(1300)
	if Target ~= nil then
		if GetDistance(Target, player) < 825 and Qready and Config.combo.useq then
			local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(Target, 0.5, 450, 825, 1125, player)
			if TargetHitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if GetDistance(Target, player) < 600 and Eready and Config.combo.usee then
			CastSpell(_E, Target)
		end
		if GetDistance(Target, player) < 1225 and Rready and Config.combo.user then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 75, 1225, 2000, player, true)
			if HitChance >= Config.combo.rhitchance then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
 end

 function Corki:OnHarass()
	local Target = OrbTarget(1300)
	if Target ~= nil then
		if GetDistance(Target, player) < 825 and Qready and Config.harass.useq and player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
			local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(Target, 0.5, 450, 825, 1125, player)
			if TargetHitChance >= 2 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if GetDistance(Target, player) < 1225 and Rready and Config.harass.user and player.mana > (player.maxMana*(Config.harass.perr*0.01)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 75, 1225, 2000, player, true)
			if HitChance >= Config.combo.rhitchance then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
 end

function Corki:OnTick()
end

 function Corki:LineClear()
	JungleMinions:update()
	for i, minion in pairs(JungleMinions.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 900 and Config.lc.useq and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local bestpos, besthit = GetBestLineFarmPosition(825, 450, JungleMinions.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
		if minion ~= nil and not minion.dead and GetDistance(minion) < 1125 and Config.lc.user and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.25, 75, 1225, 2000, player, true)
			if HitChance >= 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
	EnemyMinions:update()
	for i, minion in pairs(EnemyMinions.objects) do
		if minion ~= nil and not minion.dead and GetDistance(minion) < 900 and Config.lc.useq and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local bestpos, besthit = GetBestLineFarmPosition(825, 450, EnemyMinions.objects)
			if bestpos ~= nil then
				CastSpell(_Q, bestpos.x, bestpos.z)
			end
		end
		if minion ~= nil and not minion.dead and GetDistance(minion) < 1125 and Config.lc.user and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.25, 75, 1225, 2000, player, true)
			if HitChance >= 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end

 function Corki:OnDraw()
	if Config.draw.drawq then
		DrawCircle(player.x, player.y, player.z, 825, TARGB(Config.draw.drawqcolor))
	end
	if Config.draw.drawr then
		DrawCircle(player.x, player.y, player.z, 1250, TARGB(Config.draw.drawrcolor))
	end
 end

 function Corki:ApplyMenu()
		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("rhitchance", "R Hit Chance", SCRIPT_PARAM_SLICE, 1, 1, 2, 0)

		Config.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Config.harass:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perr", "Until % R", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.lc:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawqcolor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawrcolor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)

 end

 ---------------------------------------------------------
------------------------Urgot
---------------------------------------------------------

function Urgot:__init()
 end

 function Urgot:OnCombo()
	local Target = OrbTarget(1200)
		if Config.combo.usee and Eready then
			local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(Target, 0.8, 200, 900)
			if HitChance >= 2 and GetDistance(CastPosition) < 900 then
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end
		end

		if Target ~= nil then
			if Config.combo.useq and Qready and GetDistance(Target) < 1200 then
				if Config.combo.usew and Wready and GetDistance(Target, player) < 1200 then
					CastSpell(_W)
				end
				if buffcheck(Target) then
					local CastPosition, HitChance, Position = VP:GetCircularCastPosition(Target, 0.5, 75, 1200)
					if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 1200 and Target.dead == false then
							CastSpell(_Q, CastPosition.x, CastPosition.z)
					end
				else
					local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.5, 75, 1100, 1500, player, true)
					if HitChance >= 2 and GetDistance(CastPosition) < 1100 then
						CastSpell(_Q, CastPosition.x, CastPosition.z)
					end
				end
			end
		end
 end

 function Urgot:OnHarass()
	if player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
		local Target = OrbTarget(1200)
		if Config.harass.usee and Eready and Target ~= nil then
			local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(Target, 0.8, 200, 900)
			if HitChance >= 2 and GetDistance(CastPosition) < 900 then
				CastSpell(_E, CastPosition.x, CastPosition.z)
			end
		end

		if Target ~= nil and Config.harass.useq then
			if buffcheck(Target) then
				local CastPosition, HitChance, Position = VP:GetCircularCastPosition(Target, 0.5, 75, 1200)
				if CastPosition and HitChance >= 2 and GetDistance(CastPosition) < 1200 and Target.dead == false then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			else
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.5, 75, 1100, 1500, player, true)
				if HitChance >= 2 and GetDistance(CastPosition) < 1100 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
 end

 function Urgot:OnTick()
 end

function Urgot:LineClear()

	if Config.lc.active and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
		JungleMinions:update()
		for i, minion in ipairs(JungleMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= 1200 and Qready and Config.lc.useq then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.5, 75, 1200, 1500, player, true)
				if HitChance >= 2 and GetDistance(CastPosition) < 1200 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		EnemyMinions:update()
		for i, minion in ipairs(EnemyMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= 1200 and Qready and Config.lc.useq then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.5, 75, 1200, 1500, player, true)
				if HitChance >= 2 and GetDistance(CastPosition) < 1200 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function Urgot:OnFarm()
	EnemyMinions:update()
	for i, minion in ipairs(EnemyMinions.objects) do
		if ValidTarget(minion) and GetDistance(minion) <= 1200 and Qready and getDmg("Q", minion, player) > minion.health and Config.fm.useq then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.5, 75, 1200, 1500, player, true)
			if HitChance >= 2 and GetDistance(CastPosition) < 1200 and player.mana > (player.maxMana*(Config.fm.perq*0.01)) then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

 function Urgot:OnDraw()
	if Config.draw.drawq then
		DrawCircle(player.x, player.y, player.z, 1100, TARGB(Config.draw.drawqcolor))
	end
	if Config.draw.drawe then
		DrawCircle(player.x, player.y, player.z, 900, TARGB(Config.draw.drawecolor))
	end
 end

 function Urgot:ApplyMenu()
		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

		Config.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Harass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawqcolor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawecolor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

		Config.lc:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.fm:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.fm:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
 end

---------------------------------------------------------
------------------------Jinx
---------------------------------------------------------
--[[
function Jinx:__init()

end

function Jinx:OnCombo()
	local Target = OrbTarget(1200)
end

function Jinx:OnHarass()
end

function Jinx:OnTick()
end

function Jinx:Qchange(unit)
	if unit ~= nil and not unit.dead then
		local PredictedPos, HitChance = CombinedPos(Target, 0.25, math.huge, myHero, false)
		if PredictedPos ~= nil and HitChance ~= nil then
			if
			end
		end
	end
end

function Jinx:ApplyMenu()

		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

		Config.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Harass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawwcolor", "Draw W Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawecolor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

		Config.lc:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.ks:addParam("maxr", "Max Range", SCRIPT_PARAM_SLICE, 1000, 1000, 5000, 0)

end

-------------------]]--------------------------------------
------------------------Ezreal
---------------------------------------------------------

function Ezreal:__init()
end

function Ezreal:OnCombo()
	local Target = OrbTarget(1200)
	if Target ~= nil then
		if Config.combo.useq and Qready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 50, 1150, 2025, player, true)
			if HitChance >= Config.combo.qhitchance and GetDistance(CastPosition) < 1200 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if Config.combo.usew and Wready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 50, 1150, 2025, player, true)
			if HitChance >= Config.combo.whitchance and GetDistance(CastPosition) < 1200 then
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function Ezreal:OnHarass()
	local Target = OrbTarget(1200)
	if Target ~= nil then
		if Config.harass.useq and Qready and player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 50, 1150, 2025, player, true)
			if HitChance >= Config.combo.qhitchance and GetDistance(CastPosition) < 1200 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end


function Ezreal:LineClear()
	if Config.lc.active and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
		JungleMinions:update()
		for i, minion in ipairs(JungleMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= 1150 and Qready and Config.lc.useq then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.25, 50, 1150, 2025, player, true)
				if HitChance >= 2 and GetDistance(CastPosition) < 1150 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
		EnemyMinions:update()
		for i, minion in ipairs(EnemyMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= 1150 and Qready and Config.lc.useq then
				local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.25, 50, 1150, 2025, player, true)
				if HitChance >= 2 and GetDistance(CastPosition) < 1150 then
					CastSpell(_Q, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function Ezreal:OnDraw()
	if Config.draw.drawq then
		DrawCircle(player.x, player.y, player.z, 1150, TARGB(Config.draw.drawqcolor))
	end
	if Config.draw.draww then
		DrawCircle(player.x, player.y, player.z, 1000, TARGB(Config.draw.drawqcolor))
	end
end

function Ezreal:OnTick()
	local i, t
	for i, t in pairs(enemyHeroes) do
		if ValidTarget(t) and Config.ks.useq and GetDistance(t, player) < 1150 and getDmg("Q", t, player) > t.health then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(t, 0.25, 50, 1150, 2025, player, true)
			if HitChance >= 2 and GetDistance(CastPosition) < 1150 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if ValidTarget(t) and Config.ks.useq and GetDistance(t, player) <= Config.ks.maxr and getDmg("R", t, player) > t.health and GetDistance(t, player) >= Config.ks.minr then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(t, 0.98, 120, Config.ks.perr, 2000, player, true)
			if HitChance >= 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function Ezreal:OnFarm()
	EnemyMinions:update()
	for i, minion in ipairs(EnemyMinions.objects) do
		if ValidTarget(minion) and GetDistance(minion) <= 1150 and Qready and getDmg("Q", minion, player) > minion.health and Config.fm.useq then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(minion, 0.25, 50, 1150, 2025, player, true)
			if HitChance >= Config.combo.qhitchance and GetDistance(CastPosition) < 1150 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function Ezreal:ApplyMenu()
		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("qhitchance", "Q Hit Chance", SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
		Config.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("whitchance", "W Hit Chance", SCRIPT_PARAM_SLICE, 1, 1, 2, 0)

		Config.harass:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Harass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawqcolor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("draww", "Draw W", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawwcolor", "Draw W Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

		Config.lc:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % Q", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.ks:addParam("maxr", "Max Range", SCRIPT_PARAM_SLICE, 1000, 1000, 5000, 0)
		Config.ks:addParam("minr", "Min Range", SCRIPT_PARAM_SLICE, 500, 100, 1000, 0)

		Config.fm:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
end

function KogMaw:__init()
end

function KogMaw:OnCombo()
	local Target = OrbTarget(1600)
	if Target ~= nil then
		if Config.combo.useq and GetDistance(Target) < 975 and Qready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.5, 70, 975, 1200, player, true)
			if HitChance >= 2 and GetDistance(CastPosition) < 975 then
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
		if Config.combo.usew and Wready and GetDistance(Target) <= 1000 then
			CastSpell(_W)
		end
		if Config.combo.usee and GetDistance(Target) < 1200 and Eready then
			local CastPos, HitChance, NTargets = VP:GetLineAOECastPosition(Target, 0.5, 120, 1200, 1200, player)
			if HitChance >= 2 then
				CastSpell(_E, CastPos.x, CastPos.z)
			end
		end
		local Rrance = champ.GetRrance()
		if Config.combo.user and GetDistance(Target) < Rrance and Rrance then
			local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(Target, 1.1, 225, Rrance, math.huge, player)
			if TargetHitChance >= 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function KogMaw:OnHarass()
	local Target = OrbTarget(1600)
	local Rrance = champ.GetRrance()
	if Target ~= nil then
		if player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
			if Config.harass.usee and GetDistance(Target) < 1200 and Eready then
				local CastPos, HitChance, NTargets = VP:GetLineAOECastPosition(Target, 0.5, 120, 1200, 1200, player)
				if HitChance >= 2 then
					CastSpell(_E, CastPos.x, CastPos.z)
				end
			end
			if Config.harass.user and GetDistance(Target) < Rrance and Rrance then
				local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(Target, 1.1, 225, Rrance, math.huge, player)
				if TargetHitChance >= 2 then
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
		end
	end
end

function KogMaw:OnTick()
	local i, t
	local Rrance = champ.GetRrance()
	for i, t in pairs(enemyHeroes) do
		if ValidTarget(t) and Config.ks.user and getDmg("R", t, player) > t.health then
			local CastPosition, TargetHitChance, Targets = VP:GetCircularAOECastPosition(t, 1.1, 225, Rrance, math.huge, player)
			if TargetHitChance >= 2 then
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end

function KogMaw:OnDraw()
	if Config.draw.drawq then DrawCircle(player.x, player.y, player.z, 975, TARGB(Config.draw.drawqcolor)) end
	if Config.draw.drawe then DrawCircle(player.x, player.y, player.z, 1200, TARGB(Config.draw.drawecolor)) end
	if Config.draw.drawr then DrawCircle(player.x, player.y, player.z, champ.GetRrance(), TARGB(Config.draw.drawrcolor)) end
end

function KogMaw:GetRrance()
	local Rrance = 0
	if player:GetSpellData(_R).level == 1 then Rrance = 1100
	elseif player:GetSpellData(_R).level == 2 then Rrance = 1375
	elseif player:GetSpellData(_R).level == 3 then Rrance = 1650
	end
	return Rrance
end

function KogMaw:LineClear()
	if Config.lc.active and player.mana > (player.maxMana*(Config.lc.perq*0.01)) then
		local Rrance = champ.GetRrance()
		JungleMinions:update()
		for i, minion in ipairs(JungleMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= Rrance and Rready and Config.lc.user then
				local bestpos, besthit = GetBestLineFarmPosition(Rrance, 225, JungleMinions.objects)
				if bestpos ~= nil then
					CastSpell(_R, bestpos.x, bestpos.z)
				end
			end
		end
		EnemyMinions:update()
		for i, minion in ipairs(EnemyMinions.objects) do
			if ValidTarget(minion) and GetDistance(minion) <= Rrance and Rready and Config.lc.user then
				local bestpos, besthit = GetBestLineFarmPosition(Rrance, 225, EnemyMinions.objects)
				if bestpos ~= nil then
					CastSpell(_R, bestpos.x, bestpos.z)
				end
			end
		end
	end
end

function KogMaw:ApplyMenu()
		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usew", "Use W", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)

		Config.harass:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Harass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawq", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawqcolor", "Draw Q Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawecolor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawrcolor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

		Config.lc:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
		Config.lc:addParam("perq", "Until % R", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)

end

function Tristana:__init()
end

function Tristana:OnCombo()
	local Target = OrbTarget(1000)
	if Target ~= nil then
		if Config.combo.useq and GetDistance(Target) > 600 and Qready then
			CastSpell(_Q)
		end
		if Config.combo.usee and GetDistance(Target) > 600 and Eready then
			CastSpell(_E, Target)
		end
	end
end

function Tristana:OnHarass()
	local Target = OrbTarget(player.range)
	if player.mana > (player.maxMana*(Config.harass.perq*0.01)) then
		if Config.harass.usee and GetDistance(Target) > 600 then
			CastSpell(_E, Target)
		end
	end
end

function Tristana:OnTick()
	local i, t
	for i, t in pairs(enemyHeroes) do
		if ValidTarget(t) and Config.ks.user and getDmg("R", t, player) > t.health and GetDistance(t) > 645 then
			CastSpell(_R, t)
		end
	end
end

function Tristana:OnDraw()
	if Config.draw.drawe then DrawCircle(player.x, player.y, player.z, 600, TARGB(Config.draw.drawecolor)) end
	if Config.draw.drawr then DrawCircle(player.x, player.y, player.z, 645, TARGB(Config.draw.drawrcolor)) end
end

function Tristana:ApplyMenu()

		Config.combo:addParam("useq", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Config.combo:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)

		Config.harass:addParam("usee", "Use E", SCRIPT_PARAM_ONOFF, true)
		Config.harass:addParam("perq", "Until % Harass", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

		Config.draw:addParam("drawe", "Draw E", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawecolor", "Draw E Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
		Config.draw:addParam("drawr", "Draw R", SCRIPT_PARAM_ONOFF, true)
		Config.draw:addParam("drawrcolor", "Draw R Color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})

	Config:addSubMenu("KillSteal", "ks")
		Config.ks:addParam("user", "Use R", SCRIPT_PARAM_ONOFF, true)
end

--[[
function Kalista:__init()
end

function Kalista:OnCombo()
end

function Kalista:OnHarass()
end

function Kalista:OnDraw()
end

function Kalista:OnTick()
	for i , j in ipairs(GetEnemyHeroes()) do
		if not Kalistastack[j.charName].stack == nil or not Kalistastack[j.charName].stack-1 < 0 then
			if GetDistance(j) < 400 then
			if j.health <= (getDmg("E", j, myHero)*(Kalistastack[j.charName].stack-1)) then
				CastSpell(_E)
			end
			end
		end
	end
end

function Kalista:ApplyMenu()
end
]]
--[[function Karthus:__init()
end

function Karthus:OnCombo()
end

function Karthus:OnHarass()
end

function Karthus:OnTick()
end

function Karthus:ApplyMenu()
end]]
