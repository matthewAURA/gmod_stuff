if SERVER then
	AddCSLuaFile()
	resource.AddWorkshop("652046425")
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitJuggernautSuit", function()
	if (GAMEMODE_NAME == "terrortown") then
		local detectiveCanUse = CreateConVar("ttt_juggernautsuit_det", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Detective be able to use the Juggernaut Suit.")
		local traitorCanUse = CreateConVar("ttt_juggernautsuit_tr", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Traitor be able to use the Juggernaut Suit.")

		EQUIP_JUGGERNAUT_SUIT = 128

		local juggernautSuit = {
			id = EQUIP_JUGGERNAUT_SUIT,
			loadout = false,
			type = "item_passive",
			material = "vgui/ttt/icon_juggernaut_suit",
			name = "Juggernaut Suit",
			desc = "Reduces explosion damage by 80%,\nbut you get a maximum of 50 damage,\nit further reduces fire damage by 65%\nand your movement speed by 25%."
		}

		if (detectiveCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_DETECTIVE], juggernautSuit)
		end
		if (traitorCanUse:GetBool()) then
			table.insert(EquipmentItems[ROLE_TRAITOR], juggernautSuit)
		end

		if SERVER then
			hook.Add("EntityTakeDamage", "TTTJuggernautSuit", function(ent, dmginfo)
				if (IsValid(ent) and ent:IsPlayer() and ent:HasEquipmentItem(EQUIP_JUGGERNAUT_SUIT)) then
					if (dmginfo:IsExplosionDamage()) then
						dmginfo:ScaleDamage(0.20)
						if (dmginfo:GetDamage() > 50) then
							dmginfo:SetDamage(50)
						end
					elseif (dmginfo:IsDamageType(DMG_BURN)) then
						dmginfo:ScaleDamage(0.35)
					end
				end
			end)

			hook.Add("TTTPlayerSpeed", "TTTJuggernautSuit", function(ply)
				if (IsValid(ply) and ply:HasEquipmentItem(EQUIP_JUGGERNAUT_SUIT)) then
					return 0.75 -- 25% decrease
				end
			end)

			local model = Model("models/player/zaratusa/juggernaut_suit/juggernaut_suit.mdl")
			hook.Add("TTTOrderedEquipment", "TTTJuggernautSuit", function(ply, equipment, isItem)
				if (equipment == EQUIP_JUGGERNAUT_SUIT) then
					ply:SetModel(model)
				end
			end)
		else
			local material = Material("vgui/ttt/perks/juggernaut_suit_hud.png")
			hook.Add("HUDPaint", "TTTJuggernautSuit", function()
				if (LocalPlayer():HasEquipmentItem(EQUIP_JUGGERNAUT_SUIT)) then
					surface.SetMaterial(material)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.DrawTexturedRect(20, ScrH() / 2 - 80, 64, 64)
				end
			end)
		end
	end
end)
