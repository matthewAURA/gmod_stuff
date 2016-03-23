if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("650523807")
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitLuckyHorseshoe", function() if (GAMEMODE_NAME == "terrortown") then
	EQUIP_LUCKY_HORSESHOE = 64

	local luckyHorseshoe = {
		id = EQUIP_LUCKY_HORSESHOE,
		loadout = false,
		type = "item_passive",
		material = "vgui/ttt/icon_lucky_horseshoe",
		name = "Lucky Horseshoe",
		desc = "Negates all fall damage."
	}

	table.insert(EquipmentItems[ROLE_DETECTIVE], luckyHorseshoe)
	table.insert(EquipmentItems[ROLE_TRAITOR], luckyHorseshoe)

	if SERVER then
		hook.Add("EntityTakeDamage", "TTTLuckyHorseshoe", function(ent, dmginfo)
			if (IsValid(ent) and ent:IsPlayer() and dmginfo:IsFallDamage() and ent:HasEquipmentItem(EQUIP_LUCKY_HORSESHOE)) then
				return true -- block all damage
			end
		end)
	end
end end)
