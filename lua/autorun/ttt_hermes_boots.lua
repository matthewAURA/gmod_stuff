if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("650523765")
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitHermesBoots", function()
	if (GAMEMODE_NAME == "terrortown") then
		local detectiveCanUse = CreateConVar("ttt_hermesboots_det", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Detective be able to use the Hermes Boots.")
		local traitorCanUse = CreateConVar("ttt_hermesboots_tr", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Traitor be able to use the Hermes Boots.")

		EQUIP_HERMES_BOOTS = 32

		local hermesBoots = {
			id = EQUIP_HERMES_BOOTS,
			loadout = false,
			type = "item_passive",
			material = "vgui/ttt/icon_hermes_boots",
			name = "Hermes Boots",
			desc = "Increases your movement speed by 30%."
		}

		if (detectiveCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_DETECTIVE], hermesBoots)
		end
		if (traitorCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_TRAITOR], hermesBoots)
		end

		if SERVER then
			hook.Add("TTTPlayerSpeed", "TTTHermesBoots", function(ply)
				if (IsValid(ply) and ply:HasEquipmentItem(EQUIP_HERMES_BOOTS)) then
					return 1.3 -- 30% increase
				end
			end)
		else
			local material = Material("vgui/ttt/perks/hermes_boots_hud.png")
			hook.Add("HUDPaint", "TTTHermesBoots", function()
				if (LocalPlayer():HasEquipmentItem(EQUIP_HERMES_BOOTS)) then
					surface.SetMaterial(material)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(20, ScrH() / 2 + 80, 64, 64)
				end
			end)
		end
	end
end)
