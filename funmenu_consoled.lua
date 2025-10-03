if !friendsTable then
	friendsTable = {"YideBN"}
end
surface.CreateFont("SpeedFontSize",{
	font    = "Verdana",
	size    = ScreenScale(15),
	weight  = 500,
	antialias = true,
	shadow = false
})
surface.CreateFont("SpeedFont",{
	font    = "HalfLife2",
	size    = ScreenScale(22.5),
	weight  = 500,
	antialias = true,
	shadow = false
})
surface.CreateFont("SpeedFontSmall",{
	font    = "HalfLife2",
	size    = ScreenScale(8),
	weight  = 500,
	antialias = true,
	shadow = false
})
local placeholder = "";
local food = {"buymilk","buybeer","buyshoe","buycoco","buydonut","buycoffee","buycookie","buyegg","buymelon","buyhotdog"}
local hl2weapons = {"crossbow","shotgun","ar2","rpg"}
local returned = false
local killed = false
local xreturned = false
local netStart = net.Start
local netReceive = net.Receive
local runcmdcommand = RunConsoleCommand
if !crosshaircolor then
	crosshaircolor = Color(0, 255, 0 )
end
function FunMenuCon()
	-- By YideBN
	local clown = false
	local jump = false
	local mymenu = DermaMenu()
	local fply = LocalPlayer()
	local trace = util.GetPlayerTrace( fply )
	local traceRes = util.TraceLine( trace )
	--local looked = false
	--mymenu:AddSpacer() -- icon 1 is free

	local cheats, icon6 = mymenu:AddSubMenu( "Cheats" )
	icon6:SetIcon( "Icon16/cake.png" ) 
	cheats:SetDeleteSelf( false )
	local wh, iconcheatssub1 = cheats:AddSubMenu( "Wallhack" )
		iconcheatssub1:SetIcon( "Icon16/feed.png" ) 
		wh:AddOption( "Wallhack-ON", function() hook.Add( "HUDPaint", "Wh", wallban )end ):SetIcon( "Icon16/feed_add.png" )
		wh:AddOption( "Wallhack-OFF", function() hook.Remove( "HUDPaint", "Wh")end ):SetIcon( "Icon16/feed_delete.png" )
	local aim, iconcheatssub2 = cheats:AddSubMenu( "Aimbot" )
		iconcheatssub2:SetIcon( "Icon16/map.png" ) 
		aim:AddOption( "Aimbot-ON", function() hook.Add("Think","aim",aimban )end ):SetIcon( "Icon16/map_add.png" )
		aim:AddOption( "Aimbot-OFF", function() hook.Remove("Think","aim")end ):SetIcon( "Icon16/map_delete.png" )
	local trigger, iconcheatssub3 = cheats:AddSubMenu( "Triggerbot" )
		iconcheatssub3:SetIcon( "Icon16/joystick.png" ) 
		trigger:AddOption( "Triggerbot-ON", function() hook.Add("Think","trigger",TriggerBot )end ):SetIcon( "Icon16/joystick_add.png" )
		trigger:AddOption( "Triggerbot-OFF", function() hook.Remove("Think","trigger") RunConsoleCommand( "-attack" ) end ):SetIcon( "Icon16/joystick_delete.png" )
	local entit, iconcheatssub4 = cheats:AddSubMenu( "All ents" )
		iconcheatssub4:SetIcon( "Icon16/book_addresses.png" ) 
		entit:AddOption( "All ents-ON", function() hook.Add( "HUDPaint", "allents", allents )end ):SetIcon( "Icon16/book_open.png" )
		entit:AddOption( "All ents-OFF", function() hook.Remove( "HUDPaint", "allents")end ):SetIcon( "Icon16/book.png" )
	local bhop, iconcheatssub5 = cheats:AddSubMenu( "BHOP" )
		iconcheatssub5:SetIcon( "Icon16/keyboard.png" ) 
		bhop:AddOption( "BHOP-ON", function() hook.Add( "CreateMove", "banhop", banhop )end ):SetIcon( "Icon16/keyboard_add.png" )
		bhop:AddOption( "BHOP-OFF", function() hook.Remove( "CreateMove", "banhop")end ):SetIcon( "Icon16/keyboard_delete.png" )
	--[[local strafe, iconcheatssub6 = cheats:AddSubMenu( "Strafe" )
		iconcheatssub6:SetIcon( "Icon16/keyboard.png" ) 
		strafe:AddOption( "Strafe-ON", function() hook.Add( "CreateMove", "strafe", strafe )end ):SetIcon( "Icon16/keyboard_add.png" )
		strafe:AddOption( "Strafe-OFF", function() hook.Remove( "CreateMove", "strafe")end ):SetIcon( "Icon16/keyboard_delete.png" )]] -- icon slot 6 is free
	local friends, iconcheatssub7 = cheats:AddSubMenu( "Friends" )
		iconcheatssub7:SetIcon( "Icon16/user.png" ) 
		friends:AddOption( "Add Friend", function() 
			local friend = traceRes.Entity
			if friend:IsPlayer() then
				if table.HasValue(friendsTable, friend:Nick()) == false then
					table.insert( friendsTable, friend:Nick() )
					chat.AddText(Color(191.25, 0, 255), "[✓]Player ".. friend:Nick().. " has been added to the friends list.")
				else
					chat.AddText(Color(191.25, 0, 255), "[!]Player ".. friend:Nick().. " is already in the friends list.")
				end
			end
		end ):SetIcon( "Icon16/user_add.png" )
		friends:AddOption( "Remove Friend", function()
			local friend = traceRes.Entity
			if friend:IsPlayer() then
				if table.HasValue(friendsTable, friend:Nick()) == true then
					table.RemoveByValue( friendsTable, friend:Nick() )
					chat.AddText(Color(191.25, 0, 255), "[✓]Player ".. friend:Nick().. " has been removed from the friends list.")
				else
					chat.AddText(Color(191.25, 0, 255), "[!]Player ".. friend:Nick().. " is not in the friends list.")
				end
			end
		end ):SetIcon( "Icon16/user_delete.png" )
		friends:AddOption( "Friends List", function()
		chat.AddText(Color(191.25, 0, 255), "<=============Friends list=============>")
		for friend = 1,#friendsTable do
			if friendsTable[friend] != "YideBN" then
				chat.AddText(Color(95.625, 0, 127.5), "	" ..friendsTable[friend])
			end
		end
		chat.AddText(Color(191.25, 0, 255), "<=================================>")
		end ):SetIcon( "Icon16/user_edit.png" )
	local afk, iconcheatssub8 = cheats:AddSubMenu( "AFK Bypass" )
		iconcheatssub8:SetIcon( "Icon16/shield.png" ) 
		afk:AddOption( "AFKB-ON", function() hook.Add("Think","afkb",afkb) end ):SetIcon( "Icon16/shield_add.png" ) 
		afk:AddOption( "AFKB-OFF", function() hook.Remove("Think", "afkb") RunConsoleCommand("-jump") end ):SetIcon( "Icon16/shield_delete.png" ) 
	local debugmenu, icon2 = mymenu:AddSubMenu( "Debug" )
	icon2:SetIcon( "Icon16/cog.png" )
	debugmenu:SetDeleteSelf( false )
	local crosshair, icondebugsub1 = debugmenu:AddSubMenu( "Crosshair" )
		icondebugsub1:SetIcon( "Icon16/chart_line.png" ) 
		crosshair:AddOption( "Crosshair-ON", function() 
			hook.Add( "HUDPaint", "crosshaircustom", function()
				local x, y = ScrW() / 2 - 1, ScrH() / 2 
				surface.SetDrawColor(crosshaircolor)
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
	local crosshaircolorer, icondebugsub11 = debugmenu:AddSubMenu( "RGB Crosshair Color" )
		icondebugsub11:SetIcon( "Icon16/color_wheel.png" ) 
		crosshaircolorer:AddOption( "RGBCC-ON", function()	hook.Add( "Think", "rgbcc", function() local rgb=HSVToColor(CurTime()% 6*60,1,1) crosshaircolor = Color(rgb.r, rgb.g, rgb.b ) end) end ):SetIcon( "Icon16/add.png" )
		crosshaircolorer:AddOption( "RGBCC-OFF", function()	hook.Remove( "Think", "rgbcc") end ):SetIcon( "Icon16/delete.png" )
	local handcuff, icondebugsub2 = debugmenu:AddSubMenu( "Handcuff Break Bypass" )
		icondebugsub2:SetIcon( "Icon16/plugin_error.png" ) 
		handcuff:AddOption( "Handcuff Break Bypass-ON", function()	hook.Add( "CreateMove", "attackclown", attackclown ) end ):SetIcon( "Icon16/plugin.png" )
		handcuff:AddOption( "Handcuff Break Bypass-OFF", function()	hook.Remove( "CreateMove", "attackclown") end ):SetIcon( "Icon16/plugin_disabled.png" )
	local mystery, icondebugsub3 = debugmenu:AddSubMenu( "Mystery Box Farm" )
		icondebugsub3:SetIcon( "Icon16/money.png" )
		mystery:AddOption( "Mystery Box Farm-ON", function()	hook.Add( "CreateMove", "mysteryfarm", mysteryfarm ) end ):SetIcon( "Icon16/money_add.png" )
		mystery:AddOption( "Mystery Box Farm-OFF", function()	hook.Remove( "CreateMove", "mysteryfarm") RunConsoleCommand("-attack") end ):SetIcon( "Icon16/money_delete.png" )
	local mystery, icondebugsub3 = debugmenu:AddSubMenu( "Double Or Nothing Farm" )
		icondebugsub3:SetIcon( "Icon16/money_dollar.png" ) 
		mystery:AddOption( "DON Farm-ON", function()	hook.Add( "CreateMove", "donfarm", donfarm ) hook.Add( "Think", "donfarm2", donfarm2 ) end ):SetIcon( "Icon16/add.png" )
		mystery:AddOption( "DON Farm-OFF", function()	hook.Remove( "CreateMove", "donfarm") RunConsoleCommand("-use") xreturned = false hook.Remove( "Think", "donfarm2") end ):SetIcon( "Icon16/delete.png" )
	local foodheel, icondebugsub4 = debugmenu:AddSubMenu( "Food Heal" )
		icondebugsub4:SetIcon( "Icon16/award_star_gold_3.png" ) 
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
	local gunboxban, icondebugsub5 = debugmenu:AddSubMenu( "Weapons Crate Farm" )
		icondebugsub5:SetIcon( "Icon16/package.png" ) 
		gunboxban:AddOption( "Weapons Crate Farm-ON", function() hook.Add( "CreateMove", "WeaponsCrateFarm", WeaponsCrateFarm ) hook.Add( "Think", "WeaponsCrateFarm2", WeaponsCrateFarm2 ) end ):SetIcon( "Icon16/package_add.png" )
		gunboxban:AddOption( "Weapons Crate Farm-OFF", function() hook.Remove( "CreateMove", "WeaponsCrateFarm") RunConsoleCommand("-use") returned = false hook.Remove( "Think", "WeaponsCrateFarm2") end ):SetIcon( "Icon16/package_delete.png" )
	local medhud, icondebugsub6 = debugmenu:AddSubMenu( "Medic Hud" )
		icondebugsub6:SetIcon( "Icon16/heart.png" ) 
		medhud:AddOption( "Medic Hud-ON", function() hook.Add( "HUDPaint", "MedHud", medhudenable )end ):SetIcon( "Icon16/heart_add.png" )
		medhud:AddOption( "Medic Hud-OFF", function() hook.Remove( "HUDPaint", "MedHud")end ):SetIcon( "Icon16/heart_delete.png" )
	local fullb, icondebugsub7 = debugmenu:AddSubMenu( "Fullbright" )
		icondebugsub7:SetIcon( "Icon16/lightbulb_add.png" ) 
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
	local warnmoney, icondebugsub8 = debugmenu:AddSubMenu( "Money Printer Warning Message" )
		icondebugsub8:SetIcon( "Icon16/error.png" ) 
		warnmoney:AddOption( "MPWM-ON", function() hook.Add("HUDPaint","warnm",warnm) end ):SetIcon( "Icon16/error_add.png" ) 
		warnmoney:AddOption( "MPWM-OFF", function() hook.Remove("HUDPaint", "warnm") end ):SetIcon( "Icon16/error_delete.png" ) 
	local pandhmodelschanger, icondebugsub9 = debugmenu:AddSubMenu( "Player & Hands Models Changer" )
		icondebugsub9:SetIcon( "Icon16/emoticon_happy.png" ) 
		pandhmodelschanger:AddOption( "P&HMC-ON", function() hook.Add("Think", "PandHModel",pandhmchanger) end ):SetIcon( "Icon16/emoticon_smile.png" ) 
		pandhmodelschanger:AddOption( "P&HMC-OFF", function() hook.Remove("Think", "PandHModel") end ):SetIcon( "Icon16/emoticon_unhappy.png" ) 
	local wepcolchanger, icondebugsub13 = debugmenu:AddSubMenu( "Weapon Recolor(crosshair color)" )
		icondebugsub13:SetIcon( "Icon16/rainbow.png" ) 
		wepcolchanger:AddOption( "RGBWC-ON", function() hook.Add("Think", "RGBWC",function() fply:SetWeaponColor(Vector(crosshaircolor.r/255,crosshaircolor.g/255,crosshaircolor.b/255)) end) end ):SetIcon( "Icon16/add.png" ) 
		wepcolchanger:AddOption( "RGBWC-OFF", function() hook.Remove("Think", "RGBWC") fply:SetWeaponColor(Vector(fply:GetInfo( "cl_weaponcolor" ))) end ):SetIcon( "Icon16/delete.png" ) 
	local plrcolchanger, icondebugsub14 = debugmenu:AddSubMenu( "Player Recolor(crosshair color)" )
		icondebugsub14:SetIcon( "Icon16/user_red.png" ) 
		plrcolchanger:AddOption( "RGBPC-ON", function() hook.Add("Think", "RGBPC",function() fply:SetPlayerColor(Vector(crosshaircolor.r/255,crosshaircolor.g/255,crosshaircolor.b/255)) end) end ):SetIcon( "Icon16/add.png" ) 
		plrcolchanger:AddOption( "RGBPC-OFF", function() hook.Remove("Think", "RGBPC") fply:SetPlayerColor(Vector(fply:GetInfo( "cl_playercolor" ))) end ):SetIcon( "Icon16/delete.png" ) 
	local viewmodelschanger, icondebugsub10 = debugmenu:AddSubMenu( "View Model Changer" )
		icondebugsub10:SetIcon( "Icon16/pencil.png" ) 
		viewmodelschanger:AddOption( "VMC-ON", function() hook.Add("Think", "VModel",vmchanger) end ):SetIcon( "Icon16/pencil_add.png" ) 
		viewmodelschanger:AddOption( "VMC-OFF", function() 
			hook.Remove("Think", "VModel") 
			fply:GetViewModel(0):SetMaterial("")
			fply:GetViewModel(0):SetColor(Color( 255, 255, 255, 255 ))
			fply:GetHands():SetMaterial("")
			fply:GetHands():SetColor(Color( 255, 255, 255, 255 ))
			for _,v in pairs(player.GetAll()) do
				if v:Alive() and v != fply then
					v:SetMaterial("")
					v:SetColor(Color(255,255,255))
				end
			end
		end ):SetIcon( "Icon16/pencil_delete.png" ) 
	local mplrheal, icondebugsub12 = debugmenu:AddSubMenu( "Player Health Color Model" )
		icondebugsub12:SetIcon( "Icon16/ipod_cast.png" ) 
		mplrheal:AddOption( "PHCM-ON", function() hook.Add("Think", "PHCM",mplhealth) end ):SetIcon( "Icon16/ipod_cast_add.png" ) 
		mplrheal:AddOption( "PHCM-OFF", function() 
			hook.Remove("Think", "PHCM")
			for _,v in pairs(player.GetAll()) do
				if v:Alive() and v != fply then
					v:SetMaterial("")
					v:SetColor(Color(255,255,255))
				end
			end
		end ):SetIcon( "Icon16/ipod_cast_delete.png" ) 
	local overlay, icon5 = mymenu:AddSubMenu( "Overlay" )
	icon5:SetIcon( "Icon16/image.png" )
	overlay:SetDeleteSelf( false )
		overlay:AddOption( "Drug Overlay Remover", function()	hook.Remove("RenderScreenspaceEffects", "drugged") end ):SetIcon( "Icon16/transmit.png" )
		overlay:AddOption( "GDrugs Overlay Remover", function()	hook.Remove( "RenderScreenspaceEffects", "GD.RenderScreenspaceEffects") end ):SetIcon( "Icon16/transmit_add.png" )
		overlay:AddOption( "Sleep Overlay Remover", function()	hook.Remove("HUDPaintBackground", "BlackScreen") end ):SetIcon( "Icon16/transmit_blue.png" )
	local sv, icon3 = mymenu:AddSubMenu( "Servers" )
	icon3:SetIcon( "Icon16/script.png" )
	sv:SetDeleteSelf( false )
	sv:AddOption( "Undisguise[DarkRP]", function() RunConsoleCommand("undisguise") end ):SetIcon( "Icon16/tux.png" )
	sv:AddOption( "Admin menu[SAM]", function() RunConsoleCommand("sam", "menu") end ):SetIcon( "Icon16/script_code.png" )
	sv:AddOption( "Drop Weapon[DarkRP]", function() RunConsoleCommand("darkrp", "drop") end ):SetIcon( "Icon16/gun.png" )
	sv:AddOption( "Sleep[DarkRP]", function() RunConsoleCommand("darkrp", "sleep") end ):SetIcon( "Icon16/user.png" )
	sv:AddOption( "Allowed Props Bypass[DarkRP]", function() hook.Remove("SpawnMenuOpen", "blockmenutabs") end ):SetIcon( "Icon16/box.png" )
	sv:AddOption( "Set min. price for lab[DarkRP]", function() RunConsoleCommand("darkrp", "price", "0") end ):SetIcon( "Icon16/wand.png" )
	local sgbypass, icondebugsubSG = sv:AddSubMenu( "Screengrab Bypass(VAXOD)" )
		icondebugsubSG:SetIcon( "Icon16/page_white_camera.png" ) 
		sgbypass:AddOption( "SG Bypass-ON", function() 
			function net.Start(str) 
				if str != "VACS:StartScreen" then netStart(str) end
			end 
		end ):SetIcon( "Icon16/page_white_code.png" ) 
		sgbypass:AddOption( "SG Bypass-OFF", function() function net.Start(str) netStart(str) end end):SetIcon( "Icon16/page_white_code_red.png" )
	local info, icondebugsub5 = sv:AddSubMenu( "Information" )
		icondebugsub5:SetIcon( "Icon16/drive_magnify.png" ) 
		info:AddOption( "HP of all players", function()
			chat.AddText(Color(0, 255, 0), "<=========Health of all players=========>")
			for k,v in pairs(player.GetAll()) do
				chat.AddText(Color(0, 127, 0), "	", v:Nick().. " | ".. v:Health().. "%")
			end
			chat.AddText(Color(0, 255, 0), "<==============================>")
			end ):SetIcon( "Icon16/heart.png" )
		info:AddOption( "Armor of all players", function()
			chat.AddText(Color(0, 0, 255), "<=========Armor of all players=========>")
			for k,v in pairs(player.GetAll()) do
				chat.AddText(Color(0, 0, 127), "	", v:Nick().. " | ".. v:Armor().. "%")
			end
			chat.AddText(Color(0, 0, 255), "<=============================>")
			end ):SetIcon( "Icon16/heart_add.png" )
		info:AddOption( "Balance of all players[DarkRP]", function()
			chat.AddText(Color(255, 0, 255), "<========Balance of all players========>")
			for k,v in pairs(player.GetAll()) do
				chat.AddText(Color(255, 0, 127), "	", v:Nick().. " | ".. v:getDarkRPVar("money").. "$")
			end
			chat.AddText(Color(255, 0, 255), "<==============================>")
		end ):SetIcon( "Icon16/money.png" )
		info:AddOption( "All Info of players", function()
			chat.AddText(Color(127, 127, 255, 127), "<=========All Info of players=========>")
			chat.AddText(Color(63, 63, 127, 127), "	", "Name | Health | Moneys | Group | Armor")
			chat.AddText(Color(63, 63, 127, 127), "——————————————————————————")
			for k,v in pairs(player.GetAll()) do
				chat.AddText(Color(63, 63, 127, 127), "	", v:Nick().. " | ".. v:Health().. "%".. " | " .. v:getDarkRPVar("money").. "$".. " | " ..v:GetUserGroup().. " | " .. v:Armor())
			end
			chat.AddText(Color(127, 127, 255, 127), "<==============================>")
		end ):SetIcon( "Icon16/vcard.png" )
		info:AddOption( "Not-User Group list", function()
			chat.AddText(Color(255, 255, 0), "<=========Not-User Group List=========>")
			for k,v in pairs(player.GetAll()) do
				if( v:GetUserGroup() != "user" ) then
					chat.AddText(Color(0, 255, 0), "	", v:Nick().. " | ".. v:GetUserGroup())
				end
			end
			chat.AddText(Color(255, 255, 0), "<==============================>")
		end ):SetIcon( "Icon16/clock.png" )
		info:AddOption( "PC Info", function() 
		
		chat.AddText(Color(0, 127, 255), "<============PC Info============>")
		if system.IsLinux() == true then
			chat.AddText(Color(0, 255, 255), "	PC OS: Linux")
		end
		
		if system.IsWindows() == true then
			chat.AddText(Color(0, 255, 255), "	PC OS: Windows")
		end
		
		if system.IsOSX() == true then
			chat.AddText(Color(0, 255, 255), "	PC OS: OSX")
		end
		
		if system.IsWindowed() == true then
			chat.AddText(Color(0, 255, 255), "	GMOD is windowed: True")
		end
		
		if system.IsWindowed() == false then
			chat.AddText(Color(0, 255, 255), "	GMOD is windowed: False")
		end
	
		chat.AddText(Color(0, 255, 255), "	PC Country: " ..system.GetCountry().. "")
		if system.BatteryPower() > 100 then
			chat.AddText(Color(0, 255, 255), "	PC Battery Power: Without a battery")
		else
			chat.AddText(Color(0, 255, 255), "	PC Battery Power: " ..system.BatteryPower().. "")
		end
		
		chat.AddText(Color(0, 127, 255), "<=============================>")
		end ):SetIcon( "Icon16/clock_red.png" )
		local spdmtr, icondebugsub6 = info:AddSubMenu( "Speed Meter" )
			icondebugsub6:SetIcon( "Icon16/sport_soccer.png" ) 
			spdmtr:AddOption( "SPDMTR-ON", function() hook.Add( "HUDPaint", "spd_huddraw", spd_huddraw ) end ):SetIcon( "Icon16/add.png" ) 
			spdmtr:AddOption( "SPDMTR-OFF", function() hook.Remove("HUDPaint","spd_huddraw") end ):SetIcon( "Icon16/delete.png" ) 
	local test, icon4 = mymenu:AddSubMenu( "Testing" )
		icon4:SetIcon( "Icon16/clock_error.png" )
		test:SetDeleteSelf( false )
		local keypadloggerop, icontest1 = test:AddSubMenu( "Keypad Logger" )
			icontest1:SetIcon( "Icon16/key.png" ) 
			keypadloggerop:AddOption( "Keypad Logger-ON", function() hook.Add("HUDPaint", "kaban", keyban) end ):SetIcon( "Icon16/key_add.png" )
			keypadloggerop:AddOption( "Keypad Logger-OFF", function() hook.Remove("HUDPaint", "kaban") local key = "" end ):SetIcon( "Icon16/key_delete.png" )
		test:AddOption( "Entity List Add", entadd ):SetIcon( "Icon16/report_add.png" )
		test:AddOption( "Get classname entity", function() 
			local classent = traceRes.Entity
			if !classent:IsPlayer() and classent:GetClass() != "worldspawn" then
				chat.AddText(Color(255, 0, 255), "Classname: " ..classent:GetClass().. "")
				chat.AddText(Color(255, 0, 255), "Model: " ..classent:GetModel().. "")
				print(classent)
			end
		end ):SetIcon( "Icon16/report_picture.png" )
		local entall, icontest = test:AddSubMenu( "#show.classes.of.entities" )
			icontest:SetIcon( "Icon16/script.png" ) 
			entall:AddOption( "show.classes.of.entities.on", function() 
				hook.Add( "HUDPaint", "allent", function()
					for _,v in pairs(ents.GetAll()) do
						if v:GetClass() != "worldspawn" and v:GetClass() != "viewmodel" then
							pos = (v:GetPos()):ToScreen()
							draw.DrawText(v:GetClass(), "ChatFont", pos.x, pos.y, Color(255, 255, 255, 63.75), 1 )
						end
					end 
				end)
			end ):SetIcon( "Icon16/script_add.png" )
			entall:AddOption( "show.classes.of.entities.off", function() hook.Remove( "HUDPaint", "allent")end ):SetIcon( "Icon16/script_delete.png" )
		test:AddOption( "play.music.to.looking.entity", function() 
			local musent = traceRes.Entity
			if IsValid(musent) then
				musent:EmitSound("cook.ogg", 65)
			end
		end )
		test:AddOption( "stop.music.to.looking.entity", function() 
			local musent = traceRes.Entity
			if IsValid(musent) then
				musent:StopSound("cook.ogg")
			end
		end )
		local worldmusic, icontest4 = test:AddSubMenu( "Music" )
			icontest4:SetIcon( "Icon16/sound.png" ) 
			worldmusic:AddOption( "Music-ON", function() 
				g_station = nil
				sound.PlayURL(GetConVar("musicURL"):GetString(), "mono", function(station)
					if ( IsValid( station ) ) then
						station:Play()
						g_station = station
						chat.AddText(Color(0, 255, 0), "URL is valid.")
					else
						chat.AddText(Color(255, 255, 0), "Invalid URL!")
					end
				end )
			end ):SetIcon( "Icon16/sound_add.png" ) 
			worldmusic:AddOption( "Music-STOP", function() if g_station:IsValid() then g_station:Stop() end end ):SetIcon( "Icon16/sound_delete.png" ) 
		local deathmessage, icontest5 = test:AddSubMenu( "OnDeath message" )
			icontest5:SetIcon( "Icon16/ruby_link.png" ) 
			deathmessage:AddOption( "OnDeath message-ON", function() 
				hook.Add( "Think", "OnDeath", function()
					if fply:Alive() then
						killed = false
					else
						if killed == false then
							RunConsoleCommand("say", "/y Я сдох.")
							killed = true
						end
					end
				end )
			end ):SetIcon( "Icon16/ruby_add.png" ) 
			deathmessage:AddOption( "OnDeath message-OFF", function() hook.Remove( "Think", "OnDeath") killed = false end ):SetIcon( "Icon16/ruby_delete.png" )  
	--test:AddCVar( "Funny props", "r_colorstaticprops", "1", "0" ):SetIcon( "Icon16/flag_green.png" )  -- need sv_debugmenu 1
	local person, icontest7 = test:AddSubMenu( "Person" )
		icontest7:SetIcon( "Icon16/door.png" ) 
		person:AddOption( "Thirdperson", function() RunConsoleCommand("thirdperson") end ):SetIcon( "Icon16/door_in.png" ) -- need sv_debugmenu 1
		person:AddOption( "Firstperson", function() RunConsoleCommand("firstperson") end ):SetIcon( "Icon16/door_out.png" ) -- need sv_debugmenu 1
	mymenu:AddOption( "Settings", settings):SetIcon( "Icon16/page_white_gear.png" )
	mymenu:AddSpacer()
	mymenu:AddOption( "Close(And fix overlay)", function()	hook.Add( "RenderScreenspaceEffects", "Screen",BGoff) end ):SetIcon( "Icon16/cancel.png" )

--<<===================================================================Functions start here===================================================================>>

	function OpenMenuBG()
		DrawMaterialOverlay( "Models/effects/comball_sphere", 0.5 )
	end
	
	function BGoff()
		DrawMaterialOverlay( "", 0.1 )
	end
	
	mymenu:Center()
	mymenu:MakePopup()
	
	local clown_wep = "weapon_handcuffed"
	
	function FoodHeel( foodcount )
		for foodspawn = 1, foodcount do
			RunConsoleCommand("darkrp", food[foodspawn])
		end
		RunConsoleCommand("+use")
		timer.Simple(0.2, function() RunConsoleCommand("-use") end )
	end
	
	function afkb()
		if CurTime() > ftime + GetConVar("afkdelay"):GetInt() then
			ftime = CurTime()
			RunConsoleCommand("+jump")
			fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-1, fply:EyeAngles().r))
		end
		if CurTime() > ftimeend + GetConVar("afkdelay"):GetInt() + 0.1 then
			ftimeend = CurTime()
			RunConsoleCommand("-jump")
			fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y+1, fply:EyeAngles().r))
		end
	end
	
	function WeaponsCrateFarm( cmd )
		RunConsoleCommand("+use")
		if fply:Alive() then
			if ( clown ) then
				cmd:RemoveKey( IN_USE )
				clown = false
				else
				clown = true
			end
		end
	end
	function WeaponsCrateFarm2()
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
	function spd_huddraw(mvd)
		if LocalPlayer():Health()>0 then
			local SpeedText = tostring(math.floor(LocalPlayer():GetVelocity():Length()))
			surface.SetDrawColor( 250, 238, 57, 128 )
			surface.SetFont("SpeedFontSize")
			local w, h = surface.GetTextSize("000")
			local ws, hs = surface.GetTextSize( "Скорость 00")
			--draw.RoundedBox( 10, ws/5.1, ScrH()-hs*2.4, ws*1.2, hs*1.75, Color( 0, 0, 0, 63.75 ) )
			draw.RoundedBox( 10, ScrW()/2-ws/2, ScrH()-hs*2.4, ws*1.2, hs*1.75, Color( 0, 0, 0, 70 ) )
			--draw.DrawText("Speed: " ..SpeedText, "SpeedFont", ScrW()/2+w/2, ScrH()-hs*2, Color( 250, 238, 57, 255),1)
			--draw.DrawText(SpeedText, "HudNumbersGlow", ScrW()/2+w/2, ScrH()-hs*2, Color( 250, 238, 57, 255),1)
			draw.DrawText("СКОРОСТЬ ", "SpeedFontSmall", ScrW()/2-w/1.75, ScrH()-hs*1.5, Color( 245, 245, 0, 255),1)
			draw.DrawText(SpeedText, "SpeedFont", ScrW()/2+w, ScrH()-hs*2.3, Color( 225, 225, 0, 250),1)
		end
	end 
	function pandhmchanger()
		for _,v in pairs(ents.FindByClass("gmod_hands")) do
			if v:GetOwner() == fply then
				v:SetModel(GetConVar("HModel"):GetString())
			end
		end
		for _,v in pairs(player.GetAll()) do
			if file.Exists( fply:getDarkRPVar("job"), "GAME" ) == true and v != fply then
				v:SetModel( v:getDarkRPVar("job") )
			end
		end
	end
	
	function vmchanger()
		if fply:Alive() then
			fply:GetViewModel(0):SetMaterial("models/props_combine/stasisfield_beam")
			fply:GetViewModel(0):SetColor(crosshaircolor)
			fply:GetHands():SetMaterial("models/props_combine/stasisfield_beam")
			fply:GetHands():SetColor(crosshaircolor)
		end
	end
	
	function mplhealth()
		for _,v in pairs(player.GetAll()) do
			if v:Alive() and v != fply then
				v:SetMaterial("models/debug/debugwhite")
				v:SetColor(Color(-v:Health() - v:Health()*1.5,v:Health() + v:Health()*1.5,0))
			end
		end
	end
	
	function wallban()
		for k,v in pairs(player.GetAll()) do
			if(v != fply) then 
				pos = ( v:GetPos() + Vector( 0,0,80 ) ):ToScreen()
				local hp = ""
				local wep = ""
				local Name = ""
				if v == fply then 
					Name = "" 
					wep = ""
					hp = ""
				else 
					Name = v:Name()
					if v:Health() >= 1 then
						hp = v:Health()
						--wep = v:GetActiveWeapon():GetPrintName()
					end
				end
				draw.DrawText( Name, "ChatFont", pos.x, pos.y, Color(0, 255, 0, 73.5), 1 )
				local weptext = pos.y + 10
				if v:Health() > 0 then					
					draw.DrawText(hp.. "%", "ChatFont", pos.x, weptext, Color(0, 255, 0, 73.5), 1 )
					draw.DrawText(wep, "ChatFont", pos.x, weptext, Color(0, 255, 0, 73.5), 1 )
					else
					draw.DrawText("Dead", "ChatFont", pos.x, weptext, Color(0, 255, 0, 73.5), 1 )
				end
			end
		end
	end
	
	function allents()
		for _,v in pairs(ents.FindByClass("mattsmoneyprinter")) do
			pos = (v:GetPos()):ToScreen()
			draw.DrawText("Matt's printer:".. v:GetMoneyAmount().. "$", "ChatFont", pos.x, pos.y, Color(255, 255, 0, 127), 1 )
		end
		for _,d in pairs(ents.FindByClass("money_printer")) do
			pos = (d:GetPos()):ToScreen()
			draw.DrawText("DarkRP printer ", "ChatFont", pos.x, pos.y, Color(255, 255, 0, 127), 1 )
		end
		for _,c in pairs(ents.FindByClass("spawned_shipment")) do
			pos = (c:GetPos()):ToScreen()
			local content = c:Getcontents() or ""
			local wep = CustomShipments[content]
			draw.DrawText("Shipment:".. wep.name.. " " ..c:Getcount(), "ChatFont", pos.x, pos.y, Color(0, 255, 0, 127), 1 )
		end
		for _,s in pairs(ents.FindByClass("spawned_weapon")) do
			pos = (s:GetPos()):ToScreen()
			draw.DrawText("Weapon:".. s:GetWeaponClass(), "ChatFont", pos.x, pos.y, Color(255, 0, 0, 127), 1 )
		end
		for _,r in pairs(ents.FindByClass("prop_physic")) do
			pos = (r:GetPos()):ToScreen()
			draw.DrawText("Radio", "ChatFont", pos.x, pos.y, Color(255, 0, 255, 127), 1 )
		end
		for _,t in pairs(ents.FindByClass("nitrolab")) do
			pos = (t:GetPos()):ToScreen()
			draw.DrawText("NitroLab", "ChatFont", pos.x, pos.y, Color(255, 0, 127, 127), 1 )
		end
		for _,h in pairs(ents.FindByClass("spawned_money")) do
			pos = (h:GetPos()):ToScreen()
			draw.DrawText("Moneys:".. h:Getamount(), "ChatFont", pos.x, pos.y, Color(50, 255, 25, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("itemstore_box_huge")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Mystery box:".. f:Health() .."%", "ChatFont", pos.x, pos.y, Color(50, 255, 127, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("weapons_crate")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Weapons Crate", "ChatFont", pos.x, pos.y, Color(209, 114, 25, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass(placeholder)) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("placeholder", "ChatFont", pos.x, pos.y, Color(50, 255, 127, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("double_or_nothing")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("DON: ".. f:GetMultiplier(), "ChatFont", pos.x, pos.y, Color(50, 255, 127, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("itemstore_bank")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Bank", "ChatFont", pos.x, pos.y, Color(255, 255, 127, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("sprinter_rack")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("sPrinter Rack", "ChatFont", pos.x, pos.y, Color(127, 255, 127, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("sprinter_tier_1")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("sPrinter Tier 1: ".. f:GetMoney(), "ChatFont", pos.x, pos.y, Color(174, 174, 174, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("sprinter_tier_2")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("sPrinter Tier 2: ".. f:GetMoney(), "ChatFont", pos.x, pos.y, Color(0, 188, 178, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("sprinter_tier_3")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("sPrinter Tier 3: ".. f:GetMoney(), "ChatFont", pos.x, pos.y, Color(94, 188, 0, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("sprinter_tier_4")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("sPrinter Tier 4: ".. f:GetMoney(), "ChatFont", pos.x, pos.y, Color(188 ,188 ,0 , 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("zgo2_npc_export")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Exporter", "ChatFont", pos.x, pos.y, Color(188 ,188 ,188 , 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("rtb_npc")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Robber", "ChatFont", pos.x, pos.y, Color(188 ,0 ,188 , 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("rtb_case")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Money Case", "ChatFont", pos.x, pos.y, Color(0 ,188 ,0 , 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("bp_pill_market")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("Pill Market", "ChatFont", pos.x, pos.y, Color(0, 116, 188, 127), 1 )
		end
		for _,f in pairs(ents.FindByClass("yiditem_drugbuyer")) do
			pos = (f:GetPos()):ToScreen()
			draw.DrawText("YideBN's Drug Buyer", "ChatFont", pos.x, pos.y, Color(0, 0, 188, 127), 1 )
		end
	end

	function entadd()
		local entet = traceRes.Entity
		if !entet:IsPlayer() and entet:GetClass() != "worldspawn" then
			chat.AddText(Color(255, 0, 255), "Adding " ..entet:GetClass().. " to ENT list...")
			--file.Read("funmenu\Addedents.txt","DATA")
			--file.Write("funmenu\Addedents.txt","poop")
			chat.AddText(Color(255, 0, 255), "Complete!")
		end
	end

	function aimban()
		local aimtrace = util.GetPlayerTrace( fply )
		local aimtraceRes = util.TraceLine( aimtrace )
		if aimtraceRes.HitNonWorld then
			local aimtarget = aimtraceRes.Entity
			if aimtarget:IsPlayer() and table.HasValue(friendsTable, aimtarget:Nick()) == false then
				local targethead = aimtarget:LookupBone("ValveBiped.Bip01_Head1")
				local targetheadpos,targetheadang = aimtarget:GetBonePosition(targethead)
				fply:SetEyeAngles((targetheadpos - fply:GetShootPos()):Angle())
			end
		end
	end
	
	--[[function strafe()
		fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y-1, fply:EyeAngles().r))
		RunConsoleCommand("+moveright")
		timer.Simple(1, function() fply:SetEyeAngles(Angle(fply:EyeAngles().p, fply:EyeAngles().y+1, fply:EyeAngles().r)) RunConsoleCommand("-moveright") end)
	end]]
	
	function keyban()
		for k,v in ipairs(ents.FindByClass("keypad")) do
			if v:GetStatus() == v.Status_Granted then
				local pass = v:GetText()
				if pass=="****" or pass=="***" or pass=="**" or pass=="*" then continue end
				local key = {}
				key.one = pass
			end
			if key then 
				pos = (v:GetPos()):ToScreen()
				draw.DrawText(key, "ChatFont", pos.x, pos.y, Color(255, 255, 0, 255), 1)
			end
		end
	end
	
	function attackclown( cmd )
		if fply:Alive() then
			if (cmd:KeyDown( IN_ATTACK ) == true) then
				if ( LocalPlayer():GetActiveWeapon():GetClass() == clown_wep ) then
					if ( clown ) then
						cmd:RemoveKey( IN_ATTACK )
						clown = false
						else
						clown = true
					end
				end
			end
		end
	end
	if table.HasValue(friendsTable, "YideBN") == false then
		table.insert( friendsTable, "YideBN" )
	end
	function TriggerBot()
	    local Target = fply:GetEyeTrace().Entity
		if fply:Alive() and fply:GetActiveWeapon():IsValid() then
			if Target:IsPlayer() or Target:IsNPC() then
				if table.HasValue(friendsTable, Target:Nick()) == false then
					if !Firing then
						RunConsoleCommand( "+attack" )
						Firing = true
					else
						RunConsoleCommand( "-attack" ) 
						Firing = false
					end
				end
			else
				RunConsoleCommand( "-attack" ) 
			end
		end
	end
	
	function mysteryfarm( cmd )
		RunConsoleCommand("+attack")
		if fply:Alive() then
			if (cmd:KeyDown( IN_ATTACK ) == true) then
				if ( clown ) then
					cmd:RemoveKey( IN_ATTACK )
					clown = false
					else
					clown = true
				end
			end
			for k,v in pairs(ents.FindByClass("itemstore_box_huge")) do
				if fply:GetPos():Distance(v:GetPos()) < 220 then
					return false
				end
			end
			RunConsoleCommand("darkrp", "buymysterybox")
		end
	end
	function donfarm( cmd )
		RunConsoleCommand("+use")
		if fply:Alive() then
			if (cmd:KeyDown( IN_USE ) == true) then
				if ( clown ) then
					cmd:RemoveKey( IN_USE )
					clown = false
					else
					clown = true
				end
			end
		end
	end
	function donfarm2()
		if fply:Alive() then
			local tr = util.GetPlayerTrace( fply )
			local trres = util.TraceLine( tr )
			local don = trres.Entity
			if don:GetClass() == "double_or_nothing" then
				if don:GetMultiplier() >= GetConVar("Multiplier"):GetInt() and xreturned == false then
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
	function banhop( cmd )
		if cmd:KeyDown( IN_JUMP ) then
			if jump then 
				cmd:RemoveKey( IN_JUMP )
				jump = false
			else
				jump = true
			end
		else
			jump = false
		end
	end
	
	function warnm()
		for _,p in pairs(player.GetAll()) do
			local look = util.GetPlayerTrace( p )
			local lookres = util.TraceLine( look )
			local printer = lookres.Entity
			if (printer:GetClass() == "mattsmoneyprinter" or printer:GetClass() == "money_printer") and printer:Getowning_ent() == fply and p != fply then
				draw.DrawText("Warning: " ..p:Name().. " looking to your money printer!", "ChatFont", ScrW()/2, ScrH()/2, Color(255, 255, 255, 127.5),1)
			end
		end
	end
	
	function medhudenable()
		if fply:Alive() and fply:HasWeapon("pocket") == true and fply:GetActiveWeapon():GetClass() == "pocket" and fply:getDarkRPVar("job") == "Medic" then
			draw.DrawText("<=========Health of all players=========>", "ChatFont", 200, 10, Color(0, 255, 0, 255),1)
			uppingtext = 30
			for k,v in pairs(player.GetAll()) do
				if v:Alive() then
					draw.DrawText(v:Nick().. " | ".. v:Health().. "%", "ChatFont", 200, uppingtext, Color(0, 127, 0, 255),1)
					if v:Health() < 100 and v:Health() > 50 then
						draw.DrawText(v:Nick().. " | ".. v:Health().. "%", "ChatFont", 200, uppingtext, Color(127, 127, 0, 255),1)
					end
					if v:Health() <= 50 then
						draw.DrawText(v:Nick().. " | ".. v:Health().. "%", "ChatFont", 200, uppingtext, Color(127, 63.7, 0, 255),1)
					end
				else
					draw.DrawText(v:Nick().. " | DEAD", "ChatFont", 200, uppingtext, Color(127, 0, 0, 255),1)
				end
				uppingtext = uppingtext + 20
			end
			draw.DrawText("<===============================>", "ChatFont", 200, uppingtext, Color(0, 255, 0, 255),1)
		end
	end
	
	function settings()
		local fr;
		local DermaFrame = vgui.Create( "DFrame" )
		DermaFrame:SetTitle( "Settings" )
		DermaFrame:SetPos( ScrW()/2 - 275,ScrH()/2 - 200 )
		DermaFrame:SetSize( 550, 400 ) 
		DermaFrame:SetSizable(false)	
		DermaFrame:SetVisible( true )	
		DermaFrame:SetDraggable( false ) 
		DermaFrame:ShowCloseButton( true ) 
		DermaFrame:MakePopup(true)
		DermaFrame.Paint = function( s, w, h )
			draw.RoundedBox( 4,2,2,w , h,Color(0, 0, 0, 31.875))
		end
		
		local checkboxbg = vgui.Create( "DCheckBoxLabel", DermaFrame )
		checkboxbg:SetPos( 10, 40 )
		checkboxbg:SetText( "Enable BG on menu open?" )
		checkboxbg:SetConVar( "funmenuCV_bg" )
		local DONMultiplierNumSlider = vgui.Create( "DNumSlider", DermaFrame )
		DONMultiplierNumSlider:SetPos( 10, 85 )				
		DONMultiplierNumSlider:SetSize( 300, 20 )			
		DONMultiplierNumSlider:SetText( "DON Multiplier" )	
		DONMultiplierNumSlider:SetMin( 1 )				 	
		DONMultiplierNumSlider:SetMax( 10 )				
		DONMultiplierNumSlider:SetDecimals( 0 )				
		DONMultiplierNumSlider:SetConVar( "Multiplier" )
		local textcrosshaircolor = vgui.Create( "DLabel", DermaFrame )
		textcrosshaircolor:SetPos( 75, 132.5 )
		textcrosshaircolor:SetText( "Crosshair Color" )
		textcrosshaircolor:SizeToContents()
		local Mixercrosshaircolor = vgui.Create("DColorMixer", DermaFrame)
		Mixercrosshaircolor:SetPos( 10, 150 )				
		Mixercrosshaircolor:SetPalette(true)  			
		Mixercrosshaircolor:SetAlphaBar(false) 			
		Mixercrosshaircolor:SetWangs(true) 				
		Mixercrosshaircolor:SetColor(crosshaircolor)
		Mixercrosshaircolor.ValueChanged = function()
			crosshaircolor = Mixercrosshaircolor:GetColor()
		end
		local textmusicurl = vgui.Create( "DLabel", DermaFrame )
		textmusicurl:SetPos( 10, 60 )
		textmusicurl:SetText( "Music URL" )
		local MusicURLTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
		MusicURLTextEntry:SetPos( 60,60 )	
		MusicURLTextEntry:SetSize( 200,20 )
		MusicURLTextEntry:SetText("")	
		MusicURLTextEntry:SetMultiline( false )	
		MusicURLTextEntry:SetEditable( true )	
		MusicURLTextEntry:SetAllowNonAsciiCharacters( true )	
		MusicURLTextEntry:SetEnterAllowed( true )		
		MusicURLTextEntry:SetConVar( "musicURL" )
		local texthmodel = vgui.Create( "DLabel", DermaFrame )
		texthmodel:SetPos( 10, 110 )
		texthmodel:SetText( "Hands Model" )
		local HModelTextEntry = vgui.Create( "DTextEntry", DermaFrame )	
		HModelTextEntry:SetPos( 75,110 )	
		HModelTextEntry:SetSize( 200,20 )
		HModelTextEntry:SetText("")	
		HModelTextEntry:SetMultiline( false )	
		HModelTextEntry:SetEditable( true )	
		HModelTextEntry:SetAllowNonAsciiCharacters( true )	
		HModelTextEntry:SetEnterAllowed( true )		
		HModelTextEntry:SetConVar( "HModel" )
		local PLRFRList = vgui.Create( "DListView", DermaFrame )
		PLRFRList:SetPos( 280,40 )
		PLRFRList:SetSize( 185,150 )
		PLRFRList:SetMultiSelect( false )
		PLRFRList:AddColumn( "Player" )
		PLRFRList:AddColumn( "Friend?" )
		for _,v in pairs(player.GetAll()) do
			if v != fply then
				PLRFRList:AddLine( v:Nick(), table.HasValue(friendsTable, v:Nick()) )
			end
		end
		PLRFRList.OnRowSelected = function( lst, index, pnl ) fr = pnl:GetColumnText(1) end
		local UpdateFRlistButton = vgui.Create( "DButton", DermaFrame )
		UpdateFRlistButton:SetText( "Update" )
		UpdateFRlistButton:SetPos( 465, 40 )
		UpdateFRlistButton:SetSize( 80, 20 )
		UpdateFRlistButton.DoClick = function()
			for ln,_ in pairs( PLRFRList:GetLines() ) do
				PLRFRList:RemoveLine(ln)
			end
			for _,v in pairs(player.GetAll()) do
				if v != fply then
					PLRFRList:AddLine( v:Nick(), table.HasValue(friendsTable, v:Nick()) )
				end
			end
		end
		local AddFRButton = vgui.Create( "DButton", DermaFrame )
		AddFRButton:SetText( "Add Friend" )
		AddFRButton:SetPos( 465, 62 )
		AddFRButton:SetSize( 80, 20 )
		AddFRButton.DoClick = function()
			for _,v in pairs(player.GetAll()) do
				if v:Nick() == fr then
					if table.HasValue(friendsTable, v:Nick()) == false then
						table.insert( friendsTable, v:Nick() )
						chat.AddText(Color(191.25, 0, 255), "[✓]Player ".. v:Nick().. " has been added to the friends list.")
					else
						chat.AddText(Color(191.25, 0, 255), "[!]Player ".. v:Nick().. " is already in the friends list.")
					end
				end
			end
			for ln,_ in pairs( PLRFRList:GetLines() ) do
				PLRFRList:RemoveLine(ln)
			end
			for _,v in pairs(player.GetAll()) do
				if v != fply then
					PLRFRList:AddLine( v:Nick(), table.HasValue(friendsTable, v:Nick()) )
				end
			end
		end
		local RemFRButton = vgui.Create( "DButton", DermaFrame )
		RemFRButton:SetText( "Remove Friend" )
		RemFRButton:SetPos( 465, 84 )
		RemFRButton:SetSize( 80, 20 )
		RemFRButton.DoClick = function()
			for _,v in pairs(player.GetAll()) do
				if v:Nick() == fr then
					if table.HasValue(friendsTable, v:Nick()) == true then
						table.RemoveByValue( friendsTable, v:Nick() )
						chat.AddText(Color(191.25, 0, 255), "[✓]Player ".. v:Nick().. " has been removed from the friends list.")
					else
						chat.AddText(Color(191.25, 0, 255), "[!]Player ".. v:Nick().. " is not in the friends list.")
					end
				end
			end
			for ln,_ in pairs( PLRFRList:GetLines() ) do
				PLRFRList:RemoveLine(ln)
			end
			for _,v in pairs(player.GetAll()) do
				if v != fply then
					PLRFRList:AddLine( v:Nick(), table.HasValue(friendsTable, v:Nick()) )
				end
			end
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
		LuaRunTextEntry.OnEnter = function()	
			local func = CompileString(LuaRunTextEntry:GetValue(), "lua_cl_run_menuRUN")
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
		AFKBDelayNumSlider:SetConVar( "afkdelay" )
	end
end
	
CreateClientConVar( "funmenuCV_bg", "1", true, false)

CreateClientConVar( "musicURL", "", true, false)

CreateClientConVar( "HModel", "", true, false)

CreateClientConVar( "Multiplier", "2", true, false)

CreateClientConVar( "afkdelay", "3", true, false)

concommand.Add("funmenuCV_open", function() 
	FunMenuCon()
	if GetConVar("funmenuCV_bg"):GetBool() == true then
		hook.Add( "RenderScreenspaceEffects", "Screen", OpenMenuBG)
	end
end )

concommand.Add("bgoff", function() 
	hook.Add( "RenderScreenspaceEffects", "Screen",BGoff)
end )
print("Activated!(By YideBN)")
