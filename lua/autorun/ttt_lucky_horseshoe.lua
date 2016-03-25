if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("650523807")
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitLuckyHorseshoe", function()
	if (GAMEMODE_NAME == "terrortown") then
		local detectiveCanUse = CreateConVar("ttt_luckyhorseshoe_det", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Detective be able to use the Lucky Horseshoe.")
		local traitorCanUse = CreateConVar("ttt_luckyhorseshoe_tr", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Traitor be able to use the Lucky Horseshoe.")

		EQUIP_LUCKY_HORSESHOE = 64

		local luckyHorseshoe = {
			id = EQUIP_LUCKY_HORSESHOE,
			loadout = false,
			type = "item_passive",
			material = "vgui/ttt/icon_lucky_horseshoe",
			name = "Lucky Horseshoe",
			desc = "Negates all fall damage."
		}

		if (detectiveCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_DETECTIVE], luckyHorseshoe)
		end
		if (traitorCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_TRAITOR], luckyHorseshoe)
		end

		if SERVER then
			hook.Add("EntityTakeDamage", "TTTLuckyHorseshoe", function(ent, dmginfo)
				if (IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() and ent:HasEquipmentItem(EQUIP_LUCKY_HORSESHOE)) then
					return true -- block all damage
				end
			end)
		else
			local material = Material("vgui/ttt/perks/lucky_horseshoe_hud.png")
			hook.Add("HUDPaint", "TTTLuckyHorseshoe", function()
				if (LocalPlayer():HasEquipmentItem(EQUIP_LUCKY_HORSESHOE)) then
					surface.SetMaterial(material)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(20, ScrH() / 2, 64, 64)
				end
			end)
		end
	end
end)
