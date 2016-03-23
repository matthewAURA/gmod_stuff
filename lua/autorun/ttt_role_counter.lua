if SERVER then
	AddCSLuaFile()
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitRoleCounter", function() if (GAMEMODE_NAME == "terrortown") then
	local ROLE_SPECTATOR = 3

	if SERVER then
		util.AddNetworkString("TTT_RoleCount_Start")
		util.AddNetworkString("TTT_RoleCount_Say")
		util.AddNetworkString("TTT_RoleCount_Wait")
		util.AddNetworkString("TTT_RoleCount_Leave")

		local ChatCommands = {
			"!roles",
			"/roles",
			"roles"
		}

		local roles = {} -- keep track of the current role distribution

		hook.Add("TTTBeginRound", "TTT_RoleCount_Start", function()
			roles[ROLE_INNOCENT] = 0
			roles[ROLE_DETECTIVE] = 0
			roles[ROLE_TRAITOR] = 0
			roles[ROLE_SPECTATOR] = 0

			roundOver = false

			local role
			for _, ply in pairs(player.GetAll()) do
				if (!ply:IsSpec()) then
					role = ply:GetRole()
					roles[role] = roles[role] + 1
				else
					roles[ROLE_SPECTATOR] = roles[ROLE_SPECTATOR] + 1
				end
			end

			net.Start("TTT_RoleCount_Start")
				net.WriteUInt(roles[ROLE_INNOCENT], 8)
				net.WriteUInt(roles[ROLE_DETECTIVE], 8)
				net.WriteUInt(roles[ROLE_TRAITOR], 8)
				net.WriteUInt(roles[ROLE_SPECTATOR], 8)
			net.Broadcast()
		end)

		hook.Add("PlayerSay", "TTT_RoleCount_Say", function(ply, text)
			if (table.HasValue(ChatCommands, string.lower(text))) then
				if (GetRoundState() == ROUND_ACTIVE) then
					net.Start("TTT_RoleCount_Say")
						net.WriteUInt(roles[ROLE_INNOCENT], 8)
						net.WriteUInt(roles[ROLE_DETECTIVE], 8)
						net.WriteUInt(roles[ROLE_TRAITOR], 8)
					net.Send(ply)
				else
					net.Start("TTT_RoleCount_Wait")
					net.Send(ply)
				end

				return ""
			end
		end)

		hook.Add("PlayerDisconnected", "TTT_RoleCount_Leave", function(ply)
			if (GetRoundState() == ROUND_ACTIVE) then
				local role = ply:GetRole()
				roles[role] = roles[role] - 1

				net.Start("TTT_RoleCount_Leave")
					net.WriteUInt(role, 4)
					net.WriteBool(ply:Alive())
				net.Broadcast()
			end
		end)
	else
		-- save colors and strings for easy access
		local roles = {
			[ROLE_INNOCENT] = {string = " innocent", color = Color(0, 255, 0, 255)},
			[ROLE_DETECTIVE] = {string = " detective", color = Color(0, 0, 255, 255)},
			[ROLE_TRAITOR] = {string = " traitor", color = Color(255, 0, 0, 255)},
			[ROLE_SPECTATOR] = {color = Color(255, 255, 0, 255)}
		}

		net.Receive("TTT_RoleCount_Start", function()
			local innocents = net.ReadUInt(8)
			local detectives = net.ReadUInt(8)
			local traitors = net.ReadUInt(8)
			local spectators = net.ReadUInt(8)

			chat.AddText(
				color_white, "There are ",
				roles[ROLE_INNOCENT].color, innocents .. roles[ROLE_INNOCENT].string .. "(s)",
				color_white,", ",
				roles[ROLE_DETECTIVE].color, detectives .. roles[ROLE_DETECTIVE].string .. "(s)",
				color_white, " and ",
				roles[ROLE_TRAITOR].color, traitors .. roles[ROLE_TRAITOR].string .. "(s)",
				color_white, " this round!"
			)

			if (spectators != 1) then
				chat.AddText(
					roles[ROLE_SPECTATOR].color, spectators .. " players",
					color_white, " are spectating the Trouble in this Terrorist Town."
				)
			else
				chat.AddText(
					COLOR_YELLOW, "1 player",
					color_white, " is spectating the Trouble in this Terrorist Town."
				)
			end
		end)

		net.Receive("TTT_RoleCount_Say", function()
			local innocents = net.ReadUInt(8)
			local detectives = net.ReadUInt(8)
			local traitors = net.ReadUInt(8)

			chat.AddText(
				color_white, "There are currently ",
				roles[ROLE_INNOCENT].color, innocents .. roles[ROLE_INNOCENT].string .. "(s)",
				color_white,", ",
				roles[ROLE_DETECTIVE].color, detectives .. roles[ROLE_DETECTIVE].string .. "(s)",
				color_white, " and ",
				roles[ROLE_TRAITOR].color, traitors .. roles[ROLE_TRAITOR].string .."(s)",
				color_white, " this round!"
			)
		end)

		net.Receive("TTT_RoleCount_Wait", function()
			chat.AddText(color_white, "Please wait until the round has started.")
		end)

		net.Receive("TTT_RoleCount_Leave", function()
			local role = net.ReadUInt(4)
			local alive = net.ReadBool()

			local starttext = "A"
			if (role == ROLE_INNOCENT) then
				starttext = starttext.."n"
			end

			local endtext = " has left the server, "
			if (alive) then
				-- special case for a living innocent, which could also be a spectator already
				if (role == ROLE_INNOCENT) then
					endtext = " or a spectator" .. endtext .. "however "
				end
				endtext = endtext .. "he was still alive."
			else
				endtext = endtext .. "he was already dead."
			end

			chat.AddText(
				color_white, starttext,
				roles[role].color, roles[role].string,
				color_white, endtext
			)
		end)
	end
end end)
