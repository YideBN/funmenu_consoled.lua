surface.CreateFont("SpeedFontSize",{
	font    = "Verdana",
	size    = ScreenScale(15),
	weight  = 500,
	antialias = true,
	shadow = false
})
surface.CreateFont("SpeedFont",{
	font    = "Arial",
	size    = ScreenScale(22.5),
	weight  = 500,
	antialias = true,
	shadow = false
})
surface.CreateFont("SpeedFontSmall",{
	font    = "Arial",
	size    = ScreenScale(8),
	weight  = 500,
	antialias = true,
	shadow = false
})
local placeholder = "";
local food = {"buymilk","buybeer","buyshoe","buycoco","buydonut","buycoffee","buycookie","buyegg","buymelon","buyhotdog"}
local hl2weapons = {"crossbow","shotgun","ar2","rpg"}
local fply = LocalPlayer()
local ftime, ftimeend = 0,0
local returned = false
local xreturned = false
local press = false

local datafilename = "sfn_hud_settings.txt"
local function ReadDataList()
    if !file.Exists(datafilename, "DATA") then return end
    local json = file.Read(datafilename, "DATA")
    return util.JSONToTable(json) or {}
end

local DATATABLE = ReadDataList() or 
{
	CLRTable = {
		["Crosshair Color"]={clr=Color(255,255,255,255)},
		["Enemy ESP Color"]={clr=Color(255,255,255,255)},
		["Friend ESP Color"]={clr=Color(255,255,255,255)},
		["ViewModel Color"]={clr=Color(255,255,255,255)},
		["Other Color"]={clr=Color(255,255,255,255)}
	}, -- ptrclr
	entESPTable = {},
	friendsTable = {}
}

local function GetClearData()
	local retTable = table.Copy(DATATABLE)
	for k, v in pairs(retTable.CLRTable) do
        v.ptrclr = nil
    end
	for k, v in pairs(retTable.entESPTable) do
        v.ptrclr = nil
    end
	return retTable
end

local function WriteDataFile()
	file.Write(datafilename, util.TableToJSON(GetClearData(), true))
end

local entESPBTable = {"player", "worldspawn"}

--<<=====================================================================Hooks start here=====================================================================>>

local function RGBControl(rgb, tbl)
	for k,v in pairs(tbl) do
		if !v.rgb then
			tbl[k].ptrclr = tbl[k].clr
		else
			if !v.rgbrevert then
				tbl[k].ptrclr = Color(rgb.r, rgb.g, rgb.b, tbl[k].clr.a)
			else
				tbl[k].ptrclr = Color(255-rgb.r, 255-rgb.g, 255-rgb.b, tbl[k].clr.a)
			end
		end
	end
end
hook.Remove( "Think", "RGBRC")
hook.Add( "Think", "RGBRC", function() 
	local rgb=HSVToColor(CurTime()% 6*60,1,1)
	RGBControl(rgb, DATATABLE.CLRTable)
	RGBControl(rgb, DATATABLE.entESPTable)
end)


--<<===================================================================Functions start here===================================================================>>

local function RemoveENTESP(class)
	if DATATABLE.entESPTable[class] then
		DATATABLE.entESPTable[class] = nil
		chat.AddText(Color(0, 191.25, 255), "[✓]Entity \"".. class.. "\" has been removed from the entities list.")
		return true
	else
		chat.AddText(Color(0, 191.25, 255), "[!]Entity \"".. class.. "\" is not in the entities list.")
	end
	return false
end

local function EditENTESP(class, name, clr, argc, args, rgb, rgbrevert)
	if DATATABLE.entESPTable[class] then
		DATATABLE.entESPTable[class] = {
			name = name or "Unnamed", 
			clr = clr or Color(0,255,255,255),
			argc = argc or 0,
			args = args or {},
			rgb = rgb or false,
			rgbrevert = rgbrevert or false
		}
		chat.AddText(Color(0, 191.25, 255), "[✓]Entity \"".. class.. "\" has been updated in the entities list.")
		return true
	else
		chat.AddText(Color(0, 191.25, 255), "[!]Entity \"".. class.. "\" is not in the entities list.")
	end
	return false
end

local function AddENTESP(class, name, clr, argc, args, rgb, rgbrevert)
	if !DATATABLE.entESPTable[class] then
		if !table.HasValue(entESPBTable, class) then
			DATATABLE.entESPTable[class] = {
				name = name or "Unnamed", 
				clr = clr or Color(0,255,255,255),
				argc = argc or 0,
				args = args or {},
				rgb = rgb or false,
				rgbrevert = rgbrevert or false
			}
			chat.AddText(Color(0, 191.25, 255), "[✓]Entity \"".. class.. "\" has been added to the entities list.")
			return true
		else
			chat.AddText(Color(0, 191.25, 255), "[!]Entity \"".. class.. "\" is in the blocked entities list.")
		end
	else
		chat.AddText(Color(0, 191.25, 255), "[!]Entity \"".. class.. "\" is already in the entities list.")
	end
	return false
end

local function RemoveFriend(friend)
	if friend:IsPlayer() then
		if table.HasValue(DATATABLE.friendsTable, friend:SteamID64()) then
			table.RemoveByValue( DATATABLE.friendsTable, friend:SteamID64() )
			chat.AddText(Color(191.25, 0, 255), "[✓]Player \"".. friend:Nick().. "\" has been removed from the friends list.")
			return true
		else
			chat.AddText(Color(191.25, 0, 255), "[!]Player \"".. friend:Nick().. "\" is not in the friends list.")
		end
	end
	return false
end

local function AddFriend(friend)
	if !table.HasValue(DATATABLE.friendsTable, friend:SteamID64()) then
		table.insert( DATATABLE.friendsTable, friend:SteamID64() )
		chat.AddText(Color(191.25, 0, 255), "[✓]Player \"".. friend:Nick().. "\" has been added to the friends list.")
		return true
	else
		chat.AddText(Color(191.25, 0, 255), "[!]Player \"".. friend:Nick().. "\" is already in the friends list.")
	end
	return false
end

local handcuf_wep = "weapon_handcuffed"

local function FoodHeel( foodcount )
	for foodspawn = 1, foodcount do
		RunConsoleCommand("darkrp", food[foodspawn])
	end
	RunConsoleCommand("+use")
	timer.Simple(0.2, function() RunConsoleCommand("-use") end )
end

local function afkb()
	if CurTime() > ftime + GetConVar("funmenuCV_afkdelay"):GetInt() then
		ftime = CurTime()
		RunConsoleCommand("+jump")
		fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-1, fply:EyeAngles().r))
	end
	if CurTime() > ftimeend + GetConVar("funmenuCV_afkdelay"):GetInt() + 0.1 then
		ftimeend = CurTime()
		RunConsoleCommand("-jump")
		fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y+1, fply:EyeAngles().r))
	end
end

local function WeaponsCrateFarm( cmd )
	RunConsoleCommand("+use")
	if fply:Alive() then
		if ( press ) then
			cmd:RemoveKey( IN_USE )
			press = false
			else
			press = true
		end
	end
end
local function WeaponsCrateFarm2()
	for i = 1, #hl2weapons do
		if fply:HasWeapon("weapon_".. hl2weapons[i]) == true and returned == false then
			fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-180, fply:EyeAngles().r))
			returned = true
			RunConsoleCommand("use", "weapon_".. hl2weapons[i])
			RunConsoleCommand("darkrp", "dropweapon")
			RunConsoleCommand("+duck")
			RunConsoleCommand("+use")
			timer.Simple(1, function() RunConsoleCommand("-duck") RunConsoleCommand("-use") fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-180, fply:EyeAngles().r)) returned = false end )
		end
	end
end
local function spd_huddraw(mvd)
	if LocalPlayer():Health()>0 then
		local SpeedText = tostring(math.floor(LocalPlayer():GetVelocity():Length()))
		surface.SetDrawColor( 250, 238, 57, 128 )
		surface.SetFont("SpeedFontSize")
		local w, h = surface.GetTextSize("000")
		local ws, hs = surface.GetTextSize( "Speed 00")
		draw.RoundedBox( 10, ScrW()/2-ws/2, ScrH()-hs*2.4, ws*1.2, hs*1.75, Color( 0, 0, 0, 70 ) )
		draw.DrawText("SPEED ", "SpeedFontSmall", ScrW()/2-w/1.75, ScrH()-hs*1.5, Color( 245, 245, 0, 255),1)
		draw.DrawText(SpeedText, "SpeedFont", ScrW()/2+w, ScrH()-hs*2.3, Color( 225, 225, 0, 250),1)
	end
end 

local function vmchanger()
	if fply:Alive() then
		fply:GetViewModel(0):SetMaterial("models/props_combine/stasisfield_beam")
		fply:GetViewModel(0):SetColor(DATATABLE.CLRTable["ViewModel Color"].ptrclr)
		fply:GetHands():SetMaterial("models/props_combine/stasisfield_beam")
		fply:GetHands():SetColor(DATATABLE.CLRTable["ViewModel Color"].ptrclr)
	end
end

local function mplhealth()
	for _,v in ipairs(player.GetAll()) do
		if v:Alive() and v != fply then
			v:SetMaterial("models/debug/debugwhite")
			v:SetColor(Color(-v:Health() - v:Health()*1.5,v:Health() + v:Health()*1.5,0))
		end
	end
end

local function esp()
	for k,v in ipairs(player.GetAll()) do
		if v != fply then 
			pos = ( v:GetPos() + Vector(0,0,v:OBBMaxs().z+20) ):ToScreen()
			local clr = table.HasValue(DATATABLE.friendsTable, v:SteamID64()) and DATATABLE.CLRTable["Friend ESP Color"].ptrclr or DATATABLE.CLRTable["Enemy ESP Color"].ptrclr
			draw.DrawText( v:Name(), "ChatFont", pos.x, pos.y, clr, 1 )
			local weptext = pos.y + 12.5
			if v:Alive() then
				draw.DrawText(v:Health().. "%|"..v:Armor().. "%", "ChatFont", pos.x, weptext, clr, 1 )
				draw.DrawText(IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetPrintName() or "NULL", "ChatFont", pos.x, weptext+12.5, clr, 1 )
			else
				draw.DrawText("Dead", "ChatFont", pos.x, weptext, clr, 1 )
			end
		end
	end
end
local function espw()
	for k,v in ipairs(player.GetAll()) do
		if(v != fply) then
			local mins, maxs = v:GetCollisionBounds()
			render.DrawWireframeBox(v:GetPos(), Angle(0,0,0), mins, maxs, table.HasValue(DATATABLE.friendsTable, v:SteamID64()) and DATATABLE.CLRTable["Friend ESP Color"].ptrclr or DATATABLE.CLRTable["Enemy ESP Color"].ptrclr, false)
		end
	end
end

local function entESP()
    for class,_ in pairs(DATATABLE.entESPTable) do
        for _, ent in ipairs(ents.FindByClass(class)) do
			if IsValid(ent) and (!IsValid(ent:GetParent()) or !ent:GetParent():IsPlayer()) then
				pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
				local name = DATATABLE.entESPTable[class].name
				local yOffset = 0
				if name != "" then 
					draw.DrawText(name, "ChatFont", pos.x, pos.y, DATATABLE.entESPTable[class].ptrclr, 1 )
					yOffset = 15
				end
				for i=1,DATATABLE.entESPTable[class].argc do
				    local arg = CompileString("local ent = ...\n".. DATATABLE.entESPTable[class].args[i], "EntDynamic", GetConVar("funmenuCV_handleerror"):GetBool())
					if arg then
						local success, result = pcall(arg, ent)
						if success then
							draw.DrawText(tostring(result), "ChatFont", pos.x, pos.y+yOffset, DATATABLE.entESPTable[class].ptrclr, 1 )
							yOffset = yOffset + 15
						end
					end
				end
			end
        end
    end
end

local function entESPW()
    for class,_ in pairs(DATATABLE.entESPTable) do
        for _, ent in ipairs(ents.FindByClass(class)) do
			if IsValid(ent) and (!IsValid(ent:GetParent()) or !ent:GetParent():IsPlayer()) then
				local mins, maxs = ent:GetCollisionBounds()
				render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), mins, maxs, DATATABLE.entESPTable[class].ptrclr, false)
			end
        end
    end
end

local function aimbot(cmd)
	if cmd:KeyDown( IN_ATTACK ) then
		local closest = nil
		local closestDist = math.huge
		local closesthead = nil
		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply != fply and !table.HasValue(DATATABLE.friendsTable, ply:SteamID64()) and ply:Alive() then
				local dist = fply:GetPos():Distance(ply:GetPos())
				local targetheadpos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
				local trace = util.TraceLine({start = fply:GetShootPos(),endpos = targetheadpos,filter = {fply, ply},mask = MASK_SHOT})
				if !trace.Hit then
					if dist < closestDist then
						closestDist = dist
						closest = ply
						closesthead = targetheadpos
					end
				end
			end
		end
		if IsValid(closest) then
			cmd:SetViewAngles((closesthead - fply:GetShootPos()):Angle())
		end
	end
end

local function keypadlogger()
	for k,v in ipairs(ents.FindByClass("keypad")) do
		if IsValid(v) then
			if v:GetStatus() == v.Status_Granted then
				local pass = v:GetText()
				if pass=="****" or pass=="***" or pass=="**" or pass=="*" then continue end
				v.keypass = pass
			end
			if v.keypass then 
				pos = (v:GetPos()+v:OBBCenter()):ToScreen()
				draw.DrawText(v.keypass, "ChatFont", pos.x, pos.y, Color(255, 255, 0, 255), 1)
			end
		end
	end
end

local function handcufbypass( cmd )
	if fply:Alive() then
		if (cmd:KeyDown( IN_ATTACK ) == true) then
			if ( LocalPlayer():GetActiveWeapon():GetClass() == handcuf_wep ) then
				if ( press ) then
					cmd:RemoveKey( IN_ATTACK )
					press = false
				else
					press = true
				end
			end
		end
	end
end

local function TriggerBot(cmd)
	local Target = fply:GetEyeTrace().Entity
	if fply:Alive() and fply:GetActiveWeapon():IsValid() then
		if Target:IsPlayer() or Target:IsNPC() then
			if table.HasValue(DATATABLE.friendsTable, Target:SteamID64()) == false then
				if !Firing then
					cmd:AddKey( IN_ATTACK )
					Firing = true
				else
					cmd:RemoveKey( IN_ATTACK )
					Firing = false
				end
			end
		else
			cmd:RemoveKey( IN_ATTACK )
		end
	end
end

local function mysteryfarm( cmd )
	cmd:AddKey( IN_ATTACK )
	if fply:Alive() then
		if (cmd:KeyDown( IN_ATTACK ) == true) then
			if ( press ) then
				cmd:RemoveKey( IN_ATTACK )
				press = false
				else
				press = true
			end
		end
		for k,v in ipairs(ents.FindByClass("itemstore_box_huge")) do
			if fply:GetPos():Distance(v:GetPos()) < 220 then
				return false
			end
		end
		RunConsoleCommand("darkrp", "buymysterybox")
	end
end
local function donfarm( cmd )
	cmd:AddKey( IN_USE )
	if fply:Alive() then
		if (cmd:KeyDown( IN_USE ) == true) then
			if ( press ) then
				cmd:RemoveKey( IN_USE )
				press = false
				else
				press = true
			end
		end
	end
end
local function donfarm2()
	if fply:Alive() then
		local tr = util.GetPlayerTrace( fply )
		local trres = util.TraceLine( tr )
		local don = trres.Entity
		if don:GetClass() == "double_or_nothing" then
			if don:GetMultiplier() >= GetConVar("funmenuCV_DONMultiplier"):GetInt() and xreturned == false then
				xreturned = true
				fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y+20, fply:EyeAngles().r))
				timer.Simple(3, function()
					fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-20, fply:EyeAngles().r))
					xreturned = false
				end)
			end
		end
	end
end
local function banhop( cmd )
	if cmd:KeyDown( IN_JUMP ) then
		if ( !fply:OnGround() ) then
			cmd:RemoveKey(IN_JUMP)
		end
	end
end

local function warnm()
	for _,p in ipairs(player.GetAll()) do
		local look = util.GetPlayerTrace( p )
		local lookres = util.TraceLine( look )
		local printer = lookres.Entity
		if (printer:GetClass() == "mattsmoneyprinter" or printer:GetClass() == "money_printer") and printer:Getowning_ent() == fply and p != fply then
			draw.DrawText("Warning: " ..p:Name().. " looking to your money printer!", "ChatFont", ScrW()/2, ScrH()/2, Color(255, 255, 255, 127.5),1)
		end
	end
end


--<<======================================================================GUI start here======================================================================>>


local function settings()
	local friend
	local clr = "Crosshair Color"
	
	local DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetTitle( "Settings" )
	local width = 550
	local height = 380
	DermaFrame:SetPos( ScrW()/2 - width/2,ScrH()/2 - height/2 )
	DermaFrame:SetSize( width, height ) 
	DermaFrame:SetSizable(false)	
	DermaFrame:SetVisible( true )	
	DermaFrame:SetDraggable( false ) 
	DermaFrame:ShowCloseButton( true ) 
	DermaFrame:MakePopup(true)
	DermaFrame.Paint = function( _, w, h )
		draw.RoundedBox( 4,2,2,w , h,Color(0, 0, 0, 63,75))
	end
	DermaFrame.OnClose = function( _, w, h )
		WriteDataFile()
	end
	
	local checkboxbg = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxbg:SetPos( 10, 40 )
	checkboxbg:SetText( "Enable BG on menu open?" )
	checkboxbg:SetConVar( "funmenuCV_bg" )
	local DONMultiplierNumSlider = vgui.Create( "DNumSlider", DermaFrame )
	DONMultiplierNumSlider:SetPos( 10, 60 )				
	DONMultiplierNumSlider:SetSize( 300, 20 )			
	DONMultiplierNumSlider:SetText( "DON Multiplier" )	
	DONMultiplierNumSlider:SetMin( 1 )				 	
	DONMultiplierNumSlider:SetMax( 10 )				
	DONMultiplierNumSlider:SetDecimals( 0 )				
	DONMultiplierNumSlider:SetConVar( "funmenuCV_DONMultiplier" )
	local textclr = vgui.Create( "DLabel", DermaFrame )
	textclr:SetPos( 75, 80 )
	textclr:SetText( "Color Controller" )
	textclr:SizeToContents()

	local Mixerclr = vgui.Create("DColorMixer", DermaFrame)
	Mixerclr:SetPos( 10, 115 )				
	Mixerclr:SetPalette(true)  			
	Mixerclr:SetAlphaBar(true) 			
	Mixerclr:SetWangs(true) 				
	Mixerclr:SetColor(DATATABLE.CLRTable[clr].clr)
	Mixerclr.ValueChanged = function(_--[[panel]], val)
		DATATABLE.CLRTable[clr].clr = val
	end	
	
	local checkboxrgb = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxrgb:SetPos( 10, 355 )
	checkboxrgb:SetText( "RGB" )
	checkboxrgb:SetValue(DATATABLE.CLRTable[clr].rgb)
	checkboxrgb.OnChange = function(_--[[panel]], val)
		DATATABLE.CLRTable[clr].rgb = val
	end
	
	local checkboxrgbrevert = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxrgbrevert:SetPos( 100, 355 )
	checkboxrgbrevert:SetText( "RGB Revert" )
	checkboxrgbrevert:SetValue(DATATABLE.CLRTable[clr].rgbrevert)
	checkboxrgbrevert.OnChange = function(_--[[panel]], val)
		DATATABLE.CLRTable[clr].rgbrevert = val
	end
	
	
	local clrlist = vgui.Create( "DComboBox", DermaFrame )
	clrlist:SetPos( 10, 93 )
	clrlist:SetSize( 250, 20 )
	clrlist:SetValue( clr )
	for k,_ in pairs(DATATABLE.CLRTable) do
		clrlist:AddChoice(k)
	end
	clrlist.OnSelect = function( _--[[panel]],_,txt )
		clr = txt
		Mixerclr:SetColor(DATATABLE.CLRTable[txt].clr)
		checkboxrgb:SetValue(DATATABLE.CLRTable[txt].rgb)
		checkboxrgbrevert:SetValue(DATATABLE.CLRTable[txt].rgbrevert)
	end
	
	
	
	local PLRFRList = vgui.Create( "DListView", DermaFrame )
	PLRFRList:SetPos( 280,40 )
	PLRFRList:SetSize( 185,150 )
	PLRFRList:SetMultiSelect( false )
	PLRFRList:AddColumn( "Player" ):SetFixedWidth(145)
	PLRFRList:AddColumn( "Friend" ):SetFixedWidth(40)

	local function UpdatePLRFRList()
		for ln,_ in ipairs( PLRFRList:GetLines() ) do
			PLRFRList:RemoveLine(ln)
		end
		for _,v in ipairs(player.GetAll()) do
			if v != fply then
				PLRFRList:AddLine( v:Nick(), table.HasValue(DATATABLE.friendsTable, v:SteamID64()) and "✓" or "" )
			end
		end
	end
	UpdatePLRFRList()
	PLRFRList.OnRowSelected = function( lst, index, pnl ) friend = pnl:GetColumnText(1) end
	
	local UpdateFRlistButton = vgui.Create( "DButton", DermaFrame )
	UpdateFRlistButton:SetText( "Update" )
	UpdateFRlistButton:SetPos( 465, 40 )
	UpdateFRlistButton:SetSize( 80, 20 )
	UpdateFRlistButton.DoClick = function()
		UpdatePLRFRList()
	end
	local AddFRButton = vgui.Create( "DButton", DermaFrame )
	AddFRButton:SetText( "Add Friend" )
	AddFRButton:SetPos( 465, 62 )
	AddFRButton:SetSize( 80, 20 )
	AddFRButton.DoClick = function()
		for _,v in ipairs(player.GetAll()) do
			if v:Nick() == friend then
				AddFriend(v)
			end
		end
		UpdatePLRFRList()
	end
	local RemFRButton = vgui.Create( "DButton", DermaFrame )
	RemFRButton:SetText( "Remove Friend" )
	RemFRButton:SetPos( 465, 84 )
	RemFRButton:SetSize( 80, 20 )
	RemFRButton.DoClick = function()
		for _,v in ipairs(player.GetAll()) do
			if v:Nick() == friend then
				RemoveFriend(v)
			end
		end
		UpdatePLRFRList()
	end
	local textluarun = vgui.Create( "DLabel", DermaFrame )
	textluarun:SetPos( 280, 195 )
	textluarun:SetText( "Lua Run" )
	local LuaRunTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
	LuaRunTextEntry:SetPos( 320,195 )	
	LuaRunTextEntry:SetSize( 200,20 )
	LuaRunTextEntry:SetText("")	
	LuaRunTextEntry:SetMultiline( false )	
	LuaRunTextEntry:SetEditable( true )	
	LuaRunTextEntry:SetAllowNonAsciiCharacters( true )	
	LuaRunTextEntry:SetEnterAllowed( true )	
	LuaRunTextEntry.OnEnter = function(_,val)	
		local func = CompileString(val, "lua_cl_run_menuRUN")
		if func then
			func()
		end
	end
	local AFKBDelayNumSlider = vgui.Create( "DNumSlider", DermaFrame )
	AFKBDelayNumSlider:SetPos( 280, 220 )				
	AFKBDelayNumSlider:SetSize( 300, 20 )			
	AFKBDelayNumSlider:SetText( "AFK Bypass Delay" )	
	AFKBDelayNumSlider:SetMin( 1 )				 	
	AFKBDelayNumSlider:SetMax( 20 )				
	AFKBDelayNumSlider:SetDecimals( 0 )				
	AFKBDelayNumSlider:SetConVar( "funmenuCV_afkdelay" )
end

local function EntsList()
	local class = util.TraceLine(util.GetPlayerTrace(fply)).Entity:GetClass()
	local data = DATATABLE.entESPTable[class] or {}
	class = table.HasValue(entESPBTable, class) and "" or class
	
	local argc = 0
	local args = {}
	local curarg = 0
	local selent = ""

	local DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetTitle( "Entity List" )
	local width = 550
	local height = 330
	DermaFrame:SetPos( ScrW()/2 - width/2,ScrH()/2 - height/2 )
	DermaFrame:SetSize( 550, 330 ) 
	DermaFrame:SetSizable(false)	
	DermaFrame:SetVisible( true )	
	DermaFrame:SetDraggable( false ) 
	DermaFrame:ShowCloseButton( true ) 
	DermaFrame:MakePopup(true)
	DermaFrame.Paint = function( _, w, h )
		draw.RoundedBox( 4,2,2,w,h,Color(0, 0, 0, 63,75))
	end
	DermaFrame.OnClose = function( _, w, h )
		WriteDataFile()
	end
	
	local textclr = vgui.Create( "DLabel", DermaFrame )
	textclr:SetPos( 75, 25 )
	textclr:SetText( "Entity ESP Color" )
	textclr:SizeToContents()
	local Mixerclr = vgui.Create("DColorMixer", DermaFrame)
	Mixerclr:SetPos( 10, 40 )				
	Mixerclr:SetPalette(true)  			
	Mixerclr:SetAlphaBar(true) 			
	Mixerclr:SetWangs(true) 				
	Mixerclr:SetColor(Color(255,255,255,255))
	
	local checkboxrgb = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxrgb:SetPos( 215, 135 )
	checkboxrgb:SetText( "RGB" )
	checkboxrgb:SetValue(false)
	
	local checkboxrgbrevert = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxrgbrevert:SetPos( 215, 155 )
	checkboxrgbrevert:SetText( "  RGB\nRevert" )
	checkboxrgbrevert:SetValue(false)
	
	local textclass = vgui.Create( "DLabel", DermaFrame )
	textclass:SetPos( 10, 275 )
	textclass:SetText( "Class" )
	local ClassTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
	ClassTextEntry:SetPos( 40,275 )	
	ClassTextEntry:SetSize( 240,20 )
	ClassTextEntry:SetText(class)	
	ClassTextEntry:SetMultiline( false )	
	ClassTextEntry:SetEditable( true )	
	ClassTextEntry:SetAllowNonAsciiCharacters( true )	
	ClassTextEntry:SetEnterAllowed( false )
	ClassTextEntry.OnChange = function()
		class = ClassTextEntry:GetText()
	end
	local textname = vgui.Create( "DLabel", DermaFrame )
	textname:SetPos( 10, 300 )
	textname:SetText( "Name" )
	local NameTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
	NameTextEntry:SetPos( 40,300 )	
	NameTextEntry:SetSize( 240,20 )
	NameTextEntry:SetText("")	
	NameTextEntry:SetMultiline( false )	
	NameTextEntry:SetEditable( true )	
	NameTextEntry:SetAllowNonAsciiCharacters( true )	
	NameTextEntry:SetEnterAllowed( false )
	
	local ESPENTList = vgui.Create( "DListView", DermaFrame )
	ESPENTList:SetPos( 280,40 )
	ESPENTList:SetSize( 185,150 )
	ESPENTList:SetMultiSelect( false )
	ESPENTList:AddColumn( "Entity Class" )
	ESPENTList:AddColumn( "Name" )
	
	local function UpdateESPENTLIST()
		for ln,_ in ipairs( ESPENTList:GetLines() ) do
			ESPENTList:RemoveLine(ln)
		end
		for k,v in pairs(DATATABLE.entESPTable) do
			ESPENTList:AddLine( k, DATATABLE.entESPTable[k].name )
		end
	end
	UpdateESPENTLIST()
	
	local AddENTButton = vgui.Create( "DButton", DermaFrame )
	AddENTButton:SetText( "Add Entity" )
	AddENTButton:SetPos( 465, 40 )
	AddENTButton:SetSize( 80, 20 )
	AddENTButton.DoClick = function()
		local class = ClassTextEntry:GetText()
		local name = NameTextEntry:GetText()
		if class != "" then 
			AddENTESP(class, name, Mixerclr:GetColor(), argc, args, checkboxrgb:GetChecked(), checkboxrgbrevert:GetChecked())
			UpdateESPENTLIST()
		end
	end
	local EditENTButton = vgui.Create( "DButton", DermaFrame )
	EditENTButton:SetText( "Edit Entity" )
	EditENTButton:SetPos( 465, 62 )
	EditENTButton:SetSize( 80, 20 )
	EditENTButton.DoClick = function()
		local class = ClassTextEntry:GetText()
		local name = NameTextEntry:GetText()
		if class != "" then 
			EditENTESP(class, name, Mixerclr:GetColor(), argc, args, checkboxrgb:GetChecked(), checkboxrgbrevert:GetChecked())
			UpdateESPENTLIST()
		end
	end
	local RemENTButton = vgui.Create( "DButton", DermaFrame )
	RemENTButton:SetText( "Remove Entity" )
	RemENTButton:SetPos( 465, 84 )
	RemENTButton:SetSize( 80, 20 )
	RemENTButton.DoClick = function()
		if selent != "" then 
			RemoveENTESP(selent)
			UpdateESPENTLIST()
		end
	end
	
	local argclist = vgui.Create( "DComboBox", DermaFrame )
	-- function below \/
	argclist:SetPos( 280, 240 )
	argclist:SetSize( 50, 20 )
	argclist:SetValue( 0 )
	argclist:SetSortItems(false)
	local function argclistUpdate()
		argclist:Clear()
		for i=1,argc do
			argclist:AddChoice(i)
		end
	end
	argclistUpdate()
	
	local argcNumSlider = vgui.Create( "DNumSlider", DermaFrame )
	argcNumSlider:SetPos( 280, 195 )				
	argcNumSlider:SetSize( 300, 20 )			
	argcNumSlider:SetText( "Arguments Count" )	
	argcNumSlider:SetMin( 0 )				 	
	argcNumSlider:SetMax( 20 )				
	argcNumSlider:SetDecimals( 0 )
	argcNumSlider:SetValue(argc)
	argcNumSlider.OnValueChanged = function(_,val)
		argc = math.floor(val)
		argclistUpdate()
	end
	
	local textarg = vgui.Create( "DLabel", DermaFrame )
	textarg:SetPos( 280, 220 )
	textarg:SetText( "Argument" )
	local argTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
	argTextEntry:SetPos( 340,220 )	
	argTextEntry:SetSize( 200,100 )
	argTextEntry:SetText("")
	argTextEntry:SetMultiline( true )	
	argTextEntry:SetEditable( false )	
	argTextEntry:SetAllowNonAsciiCharacters( true )	
	argTextEntry:SetEnterAllowed( false )	
	argTextEntry.OnChange = function()
		args[curarg] = argTextEntry:GetText()
	end
	
	local checkboxerror = vgui.Create( "DCheckBoxLabel", DermaFrame )
	checkboxerror:SetPos( 280, 265 )
	checkboxerror:SetText( "Errors" )
	checkboxerror:SetConVar("funmenuCV_handleerror")
	
	argclist.OnSelect = function( _--[[panel]],i,_ )
		curarg = i
		argTextEntry:SetEditable( true )
		if args[i] then
			argTextEntry:SetText(args[i])
		else
			argTextEntry:SetText("")
		end
	end
	
	local function RefreshValues(ent)
		local data = DATATABLE.entESPTable[ent] or {}
		argc = data.argc or 0
		args = data.args or {}
		
		ClassTextEntry:SetText(table.HasValue(entESPBTable, ent) and "" or ent)
		NameTextEntry:SetText(data.name or "")
		Mixerclr:SetColor(data.clr or Color(255,255,255,255))
		argcNumSlider:SetValue(argc)
		
		checkboxrgb:SetValue(data.rgb or false)
		checkboxrgbrevert:SetValue(data.rgbrevert or false)
		
		argTextEntry:SetText("")
		argTextEntry:SetEditable( false )
	end
	
	ESPENTList.OnRowSelected = function( lst, index, pnl ) 
		selent = pnl:GetColumnText(1) 
		RefreshValues(selent)
	end
	RefreshValues(class)
end


--<<========================================================================FunMenuCon=========================================================================>>


local function FunMenuCon()
	-- By YideBN
	local trace = util.GetPlayerTrace( fply )
	local traceRes = util.TraceLine( trace )
	local mymenu = DermaMenu()
	local cheats, cheatsicon = mymenu:AddSubMenu( "Cheats" )
	cheatsicon:SetIcon( "Icon16/cake.png" ) 
	cheats:SetDeleteSelf( false )
	local espmenu, espicon = cheats:AddSubMenu( "ESP" )
		espicon:SetIcon( "Icon16/feed.png" ) 
		espmenu:AddOption( "ESP-ON", function() hook.Add( "HUDPaint", "ESP", esp ) hook.Add( "PostDrawTranslucentRenderables", "ESPWire", espw )end ):SetIcon( "Icon16/feed_add.png" )
		espmenu:AddOption( "ESP-OFF", function() hook.Remove( "HUDPaint", "ESP") hook.Remove( "PostDrawTranslucentRenderables", "ESPWire")end ):SetIcon( "Icon16/feed_delete.png" )
	local aim, aimicon = cheats:AddSubMenu( "Aimbot" )
		aimicon:SetIcon( "Icon16/map.png" ) 
		aim:AddOption( "Aimbot-ON", function() hook.Add("CreateMove","aim",aimbot )end ):SetIcon( "Icon16/map_add.png" )
		aim:AddOption( "Aimbot-OFF", function() hook.Remove("CreateMove","aim")end ):SetIcon( "Icon16/map_delete.png" )
	local trigger, triggericon = cheats:AddSubMenu( "Triggerbot" )
		triggericon:SetIcon( "Icon16/joystick.png" ) 
		trigger:AddOption( "Triggerbot-ON", function() hook.Add("CreateMove","trigger",TriggerBot )end ):SetIcon( "Icon16/joystick_add.png" )
		trigger:AddOption( "Triggerbot-OFF", function() hook.Remove("CreateMove","trigger") RunConsoleCommand( "-attack" ) end ):SetIcon( "Icon16/joystick_delete.png" )
	local entit, entiticon = cheats:AddSubMenu( "Entities ESP" )
		entiticon:SetIcon( "Icon16/book_addresses.png" ) 
		entit:AddOption( "Entities ESP-ON", function() hook.Add( "HUDPaint", "entESP", entESP ) hook.Add( "PostDrawTranslucentRenderables", "entESPW", entESPW )end ):SetIcon( "Icon16/book_open.png" )
		entit:AddOption( "Entities ESP-OFF", function() hook.Remove( "HUDPaint", "entESP") hook.Remove( "PostDrawTranslucentRenderables", "entESPW")end ):SetIcon( "Icon16/book.png" )
	local bhop, bhopicon = cheats:AddSubMenu( "BHOP" )
		bhopicon:SetIcon( "Icon16/keyboard.png" ) 
		bhop:AddOption( "BHOP-ON", function() hook.Add( "CreateMove", "banhop", banhop )end ):SetIcon( "Icon16/keyboard_add.png" )
		bhop:AddOption( "BHOP-OFF", function() hook.Remove( "CreateMove", "banhop")end ):SetIcon( "Icon16/keyboard_delete.png" )
	local friends, friendsicon = cheats:AddSubMenu( "Friends" )
		friendsicon:SetIcon( "Icon16/user.png" ) 
		friends:AddOption( "Add Friend", function() 
			local friend = traceRes.Entity
			if friend:IsPlayer() then
				if AddFriend(friend) then
					WriteDataFile()
				end
			end
		end ):SetIcon( "Icon16/user_add.png" )
		friends:AddOption( "Remove Friend", function()
			local friend = traceRes.Entity
			if friend:IsPlayer() then
				if RemoveFriend(friend) then
					WriteDataFile()
				end
			end
		end ):SetIcon( "Icon16/user_delete.png" )
		friends:AddOption( "Friend IDS List", function()
		chat.AddText(Color(191.25, 0, 255), "<============FriendsID list============>")
		for friend = 1,#DATATABLE.friendsTable do
			chat.AddText(Color(95.625, 0, 127.5), "	" ..DATATABLE.friendsTable[friend])
		end
		chat.AddText(Color(191.25, 0, 255), "<=================================>")
		end ):SetIcon( "Icon16/user_edit.png" )
	local afk, afkicon = cheats:AddSubMenu( "AFK Bypass" )
		afkicon:SetIcon( "Icon16/shield.png" ) 
		afk:AddOption( "AFKB-ON", function() hook.Add("Think","afkb",afkb) end ):SetIcon( "Icon16/shield_add.png" ) 
		afk:AddOption( "AFKB-OFF", function() hook.Remove("Think", "afkb") RunConsoleCommand("-jump") end ):SetIcon( "Icon16/shield_delete.png" ) 
	local keypadloggerop, keypadloggeropicon = cheats:AddSubMenu( "Keypad Logger" )
		keypadloggeropicon:SetIcon( "Icon16/key.png" ) 
		keypadloggerop:AddOption( "Keypad Logger-ON", function() hook.Add("HUDPaint", "keypadlogger", keypadlogger) end ):SetIcon( "Icon16/key_add.png" )
		keypadloggerop:AddOption( "Keypad Logger-OFF", function() hook.Remove("HUDPaint", "keypadlogger") end ):SetIcon( "Icon16/key_delete.png" )
	local debugmenu, debugmenuicon = mymenu:AddSubMenu( "Debug" )
	debugmenuicon:SetIcon( "Icon16/cog.png" )
	debugmenu:SetDeleteSelf( false )
	local crosshair, crosshairicon = debugmenu:AddSubMenu( "Crosshair" )
		crosshairicon:SetIcon( "Icon16/chart_line.png" ) 
		crosshair:AddOption( "Crosshair-ON", function() 
			hook.Add( "HUDPaint", "crosshaircustom", function()
				local x, y = ScrW() / 2 - 1, ScrH() / 2 
				surface.SetDrawColor(DATATABLE.CLRTable["Crosshair Color"].ptrclr)
				surface.DrawLine(x - 10, y, x - 5, y)
				surface.DrawLine(x, y + 5, x, y + 10)
				surface.DrawLine(x + 10, y, x + 5, y)
				surface.DrawLine(x, y - 5, x, y - 10)
				surface.DrawRect(x, y, 1, 1)
			end)
		end ):SetIcon( "Icon16/chart_line_add.png" )
		crosshair:AddOption( "Crosshair-OFF", function() 
			hook.Remove( "HUDPaint", "crosshaircustom" ) 
			hook.Remove( "HUDPaint", "FlodorCrosshair" )
		end ):SetIcon( "Icon16/chart_line_delete.png" )
	local handcuff, handcufficon = debugmenu:AddSubMenu( "Handcuff Break Bypass" )
		handcufficon:SetIcon( "Icon16/plugin_error.png" ) 
		handcuff:AddOption( "Handcuff Break Bypass-ON", function()	hook.Add( "CreateMove", "handcufbypass", handcufbypass ) end ):SetIcon( "Icon16/plugin.png" )
		handcuff:AddOption( "Handcuff Break Bypass-OFF", function()	hook.Remove( "CreateMove", "handcufbypass") end ):SetIcon( "Icon16/plugin_disabled.png" )
	local mystery, mysteryicon = debugmenu:AddSubMenu( "Mystery Box Farm" )
		mysteryicon:SetIcon( "Icon16/money.png" )
		mystery:AddOption( "Mystery Box Farm-ON", function()	hook.Add( "CreateMove", "mysteryfarm", mysteryfarm ) end ):SetIcon( "Icon16/money_add.png" )
		mystery:AddOption( "Mystery Box Farm-OFF", function()	hook.Remove( "CreateMove", "mysteryfarm") RunConsoleCommand("-attack") end ):SetIcon( "Icon16/money_delete.png" )
	local donf, donficon = debugmenu:AddSubMenu( "Double Or Nothing Farm" )
		donficon:SetIcon( "Icon16/money_dollar.png" ) 
		donf:AddOption( "DON Farm-ON", function()	hook.Add( "CreateMove", "donfarm", donfarm ) hook.Add( "Think", "donfarm2", donfarm2 ) end ):SetIcon( "Icon16/add.png" )
		donf:AddOption( "DON Farm-OFF", function()	hook.Remove( "CreateMove", "donfarm") RunConsoleCommand("-use") xreturned = false hook.Remove( "Think", "donfarm2") end ):SetIcon( "Icon16/delete.png" )
	local foodheel, foodheelicon = debugmenu:AddSubMenu( "Food Heal" )
		foodheelicon:SetIcon( "Icon16/award_star_gold_3.png" ) 
		foodheel:AddOption( "Food Heal-10%", function()	FoodHeel( 1 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-20%", function()	FoodHeel( 2 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-30%", function()	FoodHeel( 3 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-40%", function()	FoodHeel( 4 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-50%", function()	FoodHeel( 5 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-60%", function()	FoodHeel( 6 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-70%", function()	FoodHeel( 7 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-80%", function()	FoodHeel( 8 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-90%", function()	FoodHeel( 9 ) end ):SetIcon( "Icon16/award_star_add.png" )
		foodheel:AddOption( "Food Heal-100%", function() FoodHeel( 10 ) end ):SetIcon( "Icon16/award_star_add.png" )
	local gunboxban, gunboxbanicon = debugmenu:AddSubMenu( "Weapons Crate Farm" )
		gunboxbanicon:SetIcon( "Icon16/package.png" ) 
		gunboxban:AddOption( "Weapons Crate Farm-ON", function() hook.Add( "CreateMove", "WeaponsCrateFarm", WeaponsCrateFarm ) hook.Add( "Think", "WeaponsCrateFarm2", WeaponsCrateFarm2 ) end ):SetIcon( "Icon16/package_add.png" )
		gunboxban:AddOption( "Weapons Crate Farm-OFF", function() hook.Remove( "CreateMove", "WeaponsCrateFarm") RunConsoleCommand("-use") returned = false hook.Remove( "Think", "WeaponsCrateFarm2") end ):SetIcon( "Icon16/package_delete.png" )
	local fullb, fullbicon = debugmenu:AddSubMenu( "Fullbright" )
		fullbicon:SetIcon( "Icon16/lightbulb_add.png" ) 
		fullb:AddOption( "Fullbright-ON", function() 
			hook.Add ( "RenderScene", "Fulllight", function()
				render.SetLightingMode(1)
			end )
			hook.Add ( "PreDrawEffects", "Fulllightfix", function()
				render.SetLightingMode(0)
			end )
		end ):SetIcon( "Icon16/lightbulb.png" )
		fullb:AddOption( "Fullbright-OFF", function() 
			hook.Remove ( "RenderScene", "Fulllight") 
			hook.Remove ( "PreDrawEffects", "Fulllightfix")
		end ):SetIcon( "Icon16/lightbulb_off.png" )
	local warnmoney, warnmoneyicon = debugmenu:AddSubMenu( "Money Printer Warning Message" )
		warnmoneyicon:SetIcon( "Icon16/error.png" ) 
		warnmoney:AddOption( "MPWM-ON", function() hook.Add("HUDPaint","warnm",warnm) end ):SetIcon( "Icon16/error_add.png" ) 
		warnmoney:AddOption( "MPWM-OFF", function() hook.Remove("HUDPaint", "warnm") end ):SetIcon( "Icon16/error_delete.png" ) 
	local wepcolchanger, wepcolchangericon = debugmenu:AddSubMenu( "Weapon Recolor" )
		wepcolchangericon:SetIcon( "Icon16/rainbow.png" ) 
		wepcolchanger:AddOption( "RGBWC-ON", function() hook.Add("Think", "RGBWC",function() fply:SetWeaponColor(Vector(DATATABLE.CLRTable["Other Color"].ptrclr.r/255,DATATABLE.CLRTable["Other Color"].ptrclr.g/255,DATATABLE.CLRTable["Other Color"].ptrclr.b/255)) end) end ):SetIcon( "Icon16/add.png" ) 
		wepcolchanger:AddOption( "RGBWC-OFF", function() hook.Remove("Think", "RGBWC") fply:SetWeaponColor(Vector(fply:GetInfo( "cl_weaponcolor" ))) end ):SetIcon( "Icon16/delete.png" ) 
	local plrcolchanger, plrcolchangericon = debugmenu:AddSubMenu( "Player Recolor" )
		plrcolchangericon:SetIcon( "Icon16/user_red.png" ) 
		plrcolchanger:AddOption( "RGBPC-ON", function() hook.Add("Think", "RGBPC",function() fply:SetPlayerColor(Vector(DATATABLE.CLRTable["Other Color"].ptrclr.r/255,DATATABLE.CLRTable["Other Color"].ptrclr.g/255,DATATABLE.CLRTable["Other Color"].ptrclr.b/255)) end) end ):SetIcon( "Icon16/add.png" ) 
		plrcolchanger:AddOption( "RGBPC-OFF", function() hook.Remove("Think", "RGBPC") fply:SetPlayerColor(Vector(fply:GetInfo( "cl_playercolor" ))) end ):SetIcon( "Icon16/delete.png" ) 
	local viewmodelschanger, viewmodelschangericon = debugmenu:AddSubMenu( "View Model Changer" )
		viewmodelschangericon:SetIcon( "Icon16/pencil.png" ) 
		viewmodelschanger:AddOption( "VMC-ON", function() hook.Add("Think", "VModel",vmchanger) end ):SetIcon( "Icon16/pencil_add.png" ) 
		viewmodelschanger:AddOption( "VMC-OFF", function() 
			hook.Remove("Think", "VModel") 
			fply:GetViewModel(0):SetMaterial("")
			fply:GetViewModel(0):SetColor(Color( 255, 255, 255, 255 ))
			fply:GetHands():SetMaterial("")
			fply:GetHands():SetColor(Color( 255, 255, 255, 255 ))
			for _,v in ipairs(player.GetAll()) do
				if v:Alive() and v != fply then
					v:SetMaterial("")
					v:SetColor(Color(255,255,255))
				end
			end
		end ):SetIcon( "Icon16/pencil_delete.png" ) 
	local mplrheal, mplrhealicon = debugmenu:AddSubMenu( "Player Health Color Model" )
		mplrhealicon:SetIcon( "Icon16/ipod_cast.png" ) 
		mplrheal:AddOption( "PHCM-ON", function() hook.Add("Think", "PHCM",mplhealth) end ):SetIcon( "Icon16/ipod_cast_add.png" ) 
		mplrheal:AddOption( "PHCM-OFF", function() 
			hook.Remove("Think", "PHCM")
			for _,v in ipairs(player.GetAll()) do
				if v:Alive() and v != fply then
					v:SetMaterial("")
					v:SetColor(Color(255,255,255))
				end
			end
		end ):SetIcon( "Icon16/ipod_cast_delete.png" ) 
	local overlay, overlayicon = mymenu:AddSubMenu( "Overlay" )
	overlayicon:SetIcon( "Icon16/image.png" )
	overlay:SetDeleteSelf( false )
		overlay:AddOption( "Drug Overlay Remover", function()	hook.Remove("RenderScreenspaceEffects", "drugged") end ):SetIcon( "Icon16/transmit.png" )
		overlay:AddOption( "GDrugs Overlay Remover", function()	hook.Remove( "RenderScreenspaceEffects", "GD.RenderScreenspaceEffects") end ):SetIcon( "Icon16/transmit_add.png" )
		overlay:AddOption( "Sleep Overlay Remover", function()	hook.Remove("HUDPaintBackground", "BlackScreen") end ):SetIcon( "Icon16/transmit_blue.png" )
	local sv, svicon = mymenu:AddSubMenu( "Servers" )
	svicon:SetIcon( "Icon16/script.png" )
	sv:SetDeleteSelf( false )
	sv:AddOption( "Drop Weapon[DarkRP]", function() RunConsoleCommand("darkrp", "drop") end ):SetIcon( "Icon16/gun.png" )
	sv:AddOption( "Sleep[DarkRP]", function() RunConsoleCommand("darkrp", "sleep") end ):SetIcon( "Icon16/user.png" )
	sv:AddOption( "Allowed Props Bypass[DarkRP]", function() hook.Remove("SpawnMenuOpen", "blockmenutabs") end ):SetIcon( "Icon16/box.png" )
	sv:AddOption( "Set min. price for lab[DarkRP]", function() RunConsoleCommand("darkrp", "price", "0") end ):SetIcon( "Icon16/wand.png" )
	local info, infoicon = sv:AddSubMenu( "Information" )
		infoicon:SetIcon( "Icon16/drive_magnify.png" ) 
		info:AddOption( "Get classname entity", function() 
			local classent = traceRes.Entity
			if !classent:IsPlayer() and classent:GetClass() != "worldspawn" then
				chat.AddText(Color(255, 0, 255), "Classname: " ..classent:GetClass().. "")
				chat.AddText(Color(255, 0, 255), "Model: " ..classent:GetModel().. "")
				print(classent)
			end
		end ):SetIcon( "Icon16/report_picture.png" )
		info:AddOption( "HP of all players", function()
			chat.AddText(Color(0, 255, 0), "<=========Health of all players=========>")
			for k,v in ipairs(player.GetAll()) do
				chat.AddText(Color(0, 127, 0), "	", v:Nick().. " | ".. v:Health().. "%")
			end
			chat.AddText(Color(0, 255, 0), "<==============================>")
			end ):SetIcon( "Icon16/heart.png" )
		info:AddOption( "Armor of all players", function()
			chat.AddText(Color(0, 0, 255), "<=========Armor of all players=========>")
			for k,v in ipairs(player.GetAll()) do
				chat.AddText(Color(0, 0, 127), "	", v:Nick().. " | ".. v:Armor().. "%")
			end
			chat.AddText(Color(0, 0, 255), "<=============================>")
			end ):SetIcon( "Icon16/heart_add.png" )
		info:AddOption( "Balance of all players[DarkRP]", function()
			chat.AddText(Color(255, 0, 255), "<========Balance of all players========>")
			for k,v in ipairs(player.GetAll()) do
				chat.AddText(Color(255, 0, 127), "	", v:Nick().. " | ".. v:getDarkRPVar("money").. "$")
			end
			chat.AddText(Color(255, 0, 255), "<==============================>")
		end ):SetIcon( "Icon16/money.png" )
		info:AddOption( "All Info of players", function()
			chat.AddText(Color(127, 127, 255, 127), "<=========All Info of players=========>")
			chat.AddText(Color(63, 63, 127, 127), "	", "Name | Health | Moneys | Group | Armor")
			chat.AddText(Color(63, 63, 127, 127), "——————————————————————————")
			for k,v in ipairs(player.GetAll()) do
				chat.AddText(Color(63, 63, 127, 127), "	", v:Nick().. " | ".. v:Health().. "%".. " | " .. v:getDarkRPVar("money").. "$".. " | " ..v:GetUserGroup().. " | " .. v:Armor())
			end
			chat.AddText(Color(127, 127, 255, 127), "<==============================>")
		end ):SetIcon( "Icon16/vcard.png" )
		info:AddOption( "Not-User Group list", function()
			chat.AddText(Color(255, 255, 0), "<=========Not-User Group List=========>")
			for k,v in ipairs(player.GetAll()) do
				if( v:GetUserGroup() != "user" ) then
					chat.AddText(Color(0, 255, 0), "	", v:Nick().. " | ".. v:GetUserGroup())
				end
			end
			chat.AddText(Color(255, 255, 0), "<==============================>")
		end ):SetIcon( "Icon16/clock.png" )
		info:AddOption( "PC Info", function() 
			chat.AddText(Color(0, 127, 255), "<============PC Info============>")
			chat.AddText(Color(0, 255, 255), "	PC OS: ".. (system.IsLinux() and "Linux" or system.IsWindows() and "Windows" or system.IsOSX() and "OSX" or "NULL"))
			chat.AddText(Color(0, 255, 255), "	GMOD is windowed: ".. (system.IsWindowed() and "True" or "False"))
			chat.AddText(Color(0, 255, 255), "	PC Country: " ..system.GetCountry().. "")
			chat.AddText(Color(0, 255, 255), "	PC Battery Power: ".. (system.BatteryPower() > 100 and "Without a battery" or system.BatteryPower()))
			chat.AddText(Color(0, 127, 255), "<=============================>")
		end ):SetIcon( "Icon16/clock_red.png" )
		local spdmtr, spdmtricon = info:AddSubMenu( "Speed Meter" )
			spdmtricon:SetIcon( "Icon16/sport_soccer.png" ) 
			spdmtr:AddOption( "SPDMTR-ON", function() hook.Add( "HUDPaint", "spd_huddraw", spd_huddraw ) end ):SetIcon( "Icon16/add.png" ) 
			spdmtr:AddOption( "SPDMTR-OFF", function() hook.Remove("HUDPaint","spd_huddraw") end ):SetIcon( "Icon16/delete.png" )
	local test, testicon = mymenu:AddSubMenu( "Useless" )
		testicon:SetIcon( "Icon16/lock_go.png" )
		test:SetDeleteSelf( false )
		local entall, entallicon = test:AddSubMenu( "Classes of all" )
			entallicon:SetIcon( "Icon16/script.png" ) 
			entall:AddOption( "SCAE-ON", function() 
				hook.Add( "HUDPaint", "classallent", function()
					for _,v in ipairs(ents.GetAll()) do
						if v:GetClass() != "worldspawn" and v:GetClass() != "viewmodel" then
							pos = (v:GetPos()):ToScreen()
							draw.DrawText(v:GetClass(), "ChatFont", pos.x, pos.y, Color(255, 255, 255, 63.75), 1 )
						end
					end 
				end)
			end ):SetIcon( "Icon16/script_add.png" )
			entall:AddOption( "SCAE-OFF", function() hook.Remove( "HUDPaint", "classallent")end ):SetIcon( "Icon16/script_delete.png" )
	local person, personicon = test:AddSubMenu( "Person" )
		personicon:SetIcon( "Icon16/door.png" ) 
		person:AddOption( "Thirdperson", function() RunConsoleCommand("thirdperson") end ):SetIcon( "Icon16/door_in.png" )
		person:AddOption( "Firstperson", function() RunConsoleCommand("firstperson") end ):SetIcon( "Icon16/door_out.png" )
	mymenu:AddOption( "Settings", settings):SetIcon( "Icon16/page_white_gear.png" )
	mymenu:AddOption( "Entity List", EntsList):SetIcon( "Icon16/text_list_bullets.png" )
	mymenu:AddSpacer()
	mymenu:AddOption( "Close                 ", function() end ):SetIcon( "Icon16/cancel.png" )
	mymenu:Center()
	mymenu:MakePopup()
end
	
CreateClientConVar( "funmenuCV_bg", "1", true, false)

CreateClientConVar( "funmenuCV_DONMultiplier", "2", true, false)

CreateClientConVar( "funmenuCV_afkdelay", "3", true, false)

CreateClientConVar( "funmenuCV_handleerror", "1", true, false)

concommand.Add("funmenuCV_open", function() 
	FunMenuCon()
	if GetConVar("funmenuCV_bg"):GetBool() then
		hook.Add( "RenderScreenspaceEffects", "ScreenEFF", function() DrawMaterialOverlay( "Models/effects/comball_tape", 0.5 ) end)
	end
end )
hook.Remove("CloseDermaMenus", "ScreenEFFController")
hook.Add("CloseDermaMenus", "ScreenEFF2Controller", function() hook.Remove( "RenderScreenspaceEffects", "ScreenEFF") end)
print("Activated!(By YideBN)")