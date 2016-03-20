if SERVER then
	AddCSLuaFile()

	util.AddNetworkString("TTT_RoleCount_Start")
	util.AddNetworkString("TTT_RoleCount_Say")
	util.AddNetworkString("TTT_RoleCount_Wait")
	util.AddNetworkString("TTT_RoleCount_Leave")

	local ChatCommands = {
		"!roles",
		"/roles",
		"roles"
	}

	local roles = {}
	local SPECTATOR = 5
	local gameStarted, roundOver = false, false -- variables to avoid errors

	hook.Add("TTTBeginRound", "TTT_RoleCount_Start", function()
		roles[ROLE_INNOCENT] = 0
		roles[ROLE_DETECTIVE] = 0
		roles[ROLE_TRAITOR] = 0
		roles[SPECTATOR] = 0

		gameStarted = true
		roundOver = false

		local role
		for _, ply in pairs(player.GetAll()) do
			if (!ply:IsSpec()) then
				role = ply:GetRole()
				roles[role] = roles[role] + 1
			else
				roles[SPECTATOR] = roles[SPECTATOR] + 1
			end
		end

		net.Start("TTT_RoleCount_Start")
			net.WriteUInt(roles[ROLE_INNOCENT], 8)
			net.WriteUInt(roles[ROLE_DETECTIVE], 8)
			net.WriteUInt(roles[ROLE_TRAITOR], 8)
			net.WriteUInt(roles[SPECTATOR], 8)
		net.Broadcast()
	end)

	hook.Add("PlayerSay", "TTT_RoleCount_Say", function(ply, text)
		if (table.HasValue(ChatCommands, string.lower(text))) then
			if (gameStarted and !roundOver) then
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
		if (gameStarted) then
			local role = ply:GetRole()
			roles[role] = roles[role] - 1

			net.Start("TTT_RoleCount_Leave")
				net.WriteUInt(role, 4)
				net.WriteBool(ply:Alive())
			net.Broadcast()
		end
	end)

	hook.Add("TTTEndRound", "TTT_RoleCount", function()
		roundOver = true
	end)
else
	local ROLE_INNOCENT, ROLE_TRAITOR, ROLE_DETECTIVE = 0, 1, 2

	local COLOR_RED = Color(255, 0, 0)
	local COLOR_GREEN = Color(0, 255, 0)
	local COLOR_BLUE = Color(0, 0, 255)
	local COLOR_YELLOW = Color(255, 255, 0)
	local COLOR_DEFAULT = Color(255, 255, 255)

	-- save colors and strings for easy access
	local role_colors = {}
	local role_string = {}
	role_colors[ROLE_INNOCENT] = COLOR_GREEN
	role_string[ROLE_INNOCENT] = " innocent"
	role_colors[ROLE_DETECTIVE] = COLOR_BLUE
	role_string[ROLE_DETECTIVE] = " detective"
	role_colors[ROLE_TRAITOR] = COLOR_RED
	role_string[ROLE_TRAITOR] = " traitor"

	net.Receive("TTT_RoleCount_Start", function()
		local innocents = net.ReadUInt(8)
		local detectives = net.ReadUInt(8)
		local traitors = net.ReadUInt(8)
		local spectators = net.ReadUInt(8)

		chat.AddText(
			COLOR_DEFAULT, "There are ",
			role_colors[ROLE_INNOCENT], innocents..role_string[ROLE_INNOCENT].."(s)",
			COLOR_DEFAULT,", ",
			role_colors[ROLE_DETECTIVE], detectives..role_string[ROLE_DETECTIVE].."(s)",
			COLOR_DEFAULT, " and ",
			role_colors[ROLE_TRAITOR], traitors..role_string[ROLE_TRAITOR].."(s)",
			COLOR_DEFAULT, " this round!"
		)

		if (spectators != 1) then
			chat.AddText(
				COLOR_YELLOW, spectators.." players",
				COLOR_DEFAULT, " are spectating the Trouble in this Terrorist Town."
			)
		else
			chat.AddText(
				COLOR_YELLOW, "1 player",
				COLOR_DEFAULT, " is spectating the Trouble in this Terrorist Town."
			)
		end
	end)

	net.Receive("TTT_RoleCount_Say", function()
		local innocents = net.ReadUInt(8)
		local detectives = net.ReadUInt(8)
		local traitors = net.ReadUInt(8)

		chat.AddText(
			COLOR_DEFAULT, "There are currently ",
			role_colors[ROLE_INNOCENT], innocents..role_string[ROLE_INNOCENT].."(s)",
			COLOR_DEFAULT,", ",
			role_colors[ROLE_DETECTIVE], detectives..role_string[ROLE_DETECTIVE].."(s)",
			COLOR_DEFAULT, " and ",
			role_colors[ROLE_TRAITOR], traitors..role_string[ROLE_TRAITOR].."(s)",
			COLOR_DEFAULT, " this round!"
		)
	end)

	net.Receive("TTT_RoleCount_Wait", function()
		chat.AddText(COLOR_DEFAULT, "Please wait until the round has started.")
	end)

	net.Receive("TTT_RoleCount_Leave", function()
		local role = net.ReadUInt(4)
		local alive = net.ReadBool()

		local endtext = " has left the server, "
		if (alive) then
			endtext = endtext.."he was still alive."
		elseif (role == ROLE_INNOCENT) then -- special case for dead innocents, could also be a spectator already
			endtext = " or a spectator"..endtext.."however he was dead already."
		else
			endtext = endtext.."he was dead already."
		end

		chat.AddText(
			COLOR_DEFAULT, "A",
			role_colors[role], role_string[role],
			COLOR_DEFAULT, endtext
		)
	end)
end
