if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("650523765")
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitHermesBoots", function() if (GAMEMODE_NAME == "terrortown") then
	EQUIP_HERMES_BOOTS = 32

	local hermesBoots = {
		id = EQUIP_HERMES_BOOTS,
		loadout = false,
		type = "item_passive",
		material = "vgui/ttt/icon_hermes_boots",
		name = "Hermes Boots",
		desc = "Increases your movement speed by 30%."
	}

	table.insert(EquipmentItems[ROLE_DETECTIVE], hermesBoots)
	table.insert(EquipmentItems[ROLE_TRAITOR], hermesBoots)

	if SERVER then
		hook.Add("TTTPlayerSpeed", "TTTHermesBoots", function(ply)
			if (IsValid(ply) and ply:HasEquipmentItem(EQUIP_HERMES_BOOTS)) then
				return 1.3 -- 30% increase
			end
		end)
	end
end end)
