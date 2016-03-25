if SERVER then
	AddCSLuaFile()
end

-- prevent the script is beeing loaded before or in another gamemode than TTT
hook.Add("PostGamemodeLoaded", "TTTInitRoleCounter", function() if (GAMEMODE_NAME == "terrortown") then
	if SERVER then
		util.AddNetworkString("TTT_RoleCount_Start")
		util.AddNetworkString("TTT_RoleCount_Say")
		util.AddNetworkString("TTT_RoleCount_Wait")
		util.AddNetworkString("TTT_RoleCount_Wait_Spam")
		util.AddNetworkString("TTT_RoleCount_Spectate")
		util.AddNetworkString("TTT_RoleCount_Leave")

		local ChatCommands = {
			"!roles",
			"/roles",
			"roles"
		}

		local plyInRound = {} -- the players that were active at round start

		local spamProtection = {}
		local waitTime = 20 -- time before one of the chat commands can be used again

		local function WriteRoleDistribution()
			local roles = {}
			roles[ROLE_INNOCENT] = 0
			roles[ROLE_DETECTIVE] = 0
			roles[ROLE_TRAITOR] = 0

			local role
			for _, ply in pairs(plyInRound) do
				role = ply:GetRole()
				roles[role] = roles[role] + 1
			end

			net.WriteUInt(roles[ROLE_INNOCENT], 6)
			net.WriteUInt(roles[ROLE_DETECTIVE], 6)
			net.WriteUInt(roles[ROLE_TRAITOR], 6)
		end

		hook.Add("TTTBeginRound", "TTT_RoleCount_Start", function()
			spamProtection = {}
			plyInRound = {}
			local spectators = 0

			for _, ply in pairs(player.GetAll()) do
				if (!ply:IsSpec()) then
					plyInRound[ply:EntIndex()] = ply
				else
					spectators = spectators + 1
				end
			end

			net.Start("TTT_RoleCount_Start")
				WriteRoleDistribution()
				net.WriteUInt(spectators, 6)
			net.Broadcast()
		end)

		hook.Add("PlayerSay", "TTT_RoleCount_Say", function(ply, text)
			if (table.HasValue(ChatCommands, string.lower(text))) then
				if (GetRoundState() == ROUND_ACTIVE) then
					local index = ply:EntIndex()
					local CurTime = CurTime()
					if (spamProtection[index] == nil or spamProtection[index] <= CurTime) then
						spamProtection[index] = CurTime + waitTime

						net.Start("TTT_RoleCount_Say")
							WriteRoleDistribution()
					else
						net.Start("TTT_RoleCount_Wait_Spam")
					end
				else
					net.Start("TTT_RoleCount_Wait")
				end
				net.Send(ply)

				return ""
			end
		end)

		local nextCheck = 0
		hook.Add("Think", "TTT_CheckForceSpectator", function()
			if (nextCheck <= CurTime() and GetRoundState() == ROUND_ACTIVE) then
				nextCheck = CurTime() + 2 -- only check all 2 seconds
				for _, ply in pairs(player.GetAll()) do
					if (ply:GetForceSpec()) then
						local index = ply:EntIndex()
						if (plyInRound[index] != nil) then
							plyInRound[index] = nil

							net.Start("TTT_RoleCount_Spectate")
								net.WriteUInt(ply:GetRole(), 3)
							net.Broadcast()
						end
					end
				end
			end
		end)

		hook.Add("PlayerDisconnected", "TTT_RoleCount_Leave", function(ply)
			if (GetRoundState() == ROUND_ACTIVE) then
				local index = ply:EntIndex()
				if (plyInRound[index] != nil) then
					plyInRound[index] = nil

					net.Start("TTT_RoleCount_Leave")
						net.WriteUInt(ply:GetRole(), 3)
						net.WriteBool(ply:Alive())
					net.Broadcast()
				end
			end
		end)
	else
		local ROLE_SPECTATOR = 3
		-- save colors and strings for easy access
		local roles = {
			[ROLE_INNOCENT] = {string = " innocent", color = Color(0, 255, 0, 255)},
			[ROLE_DETECTIVE] = {string = " detective", color = Color(0, 0, 255, 255)},
			[ROLE_TRAITOR] = {string = " traitor", color = Color(255, 0, 0, 255)},
			[ROLE_SPECTATOR] = {color = Color(255, 255, 0, 255)}
		}

		net.Receive("TTT_RoleCount_Start", function()
			local innocents = net.ReadUInt(6)
			local detectives = net.ReadUInt(6)
			local traitors = net.ReadUInt(6)
			local spectators = net.ReadUInt(6)

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
					roles[ROLE_SPECTATOR].color, "1 player",
					color_white, " is spectating the Trouble in this Terrorist Town."
				)
			end
		end)

		net.Receive("TTT_RoleCount_Say", function()
			local innocents = net.ReadUInt(6)
			local detectives = net.ReadUInt(6)
			local traitors = net.ReadUInt(6)

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

		net.Receive("TTT_RoleCount_Wait_Spam", function()
			chat.AddText(color_white, "Please wait a few seconds before you request the role distribution again.")
		end)

		net.Receive("TTT_RoleCount_Wait", function()
			chat.AddText(color_white, "Please wait until the round has started.")
		end)

		local function PrintToChat(role, alive, endtext)
			local starttext = "A"
			if (role == ROLE_INNOCENT) then
				starttext = starttext.."n"
			end

			if (alive != nil) then
				if (alive) then
					endtext = endtext .. "he was still alive."
				else
					endtext = endtext .. "he was already dead."
				end
			end

			chat.AddText(
				color_white, starttext,
				roles[role].color, roles[role].string,
				color_white, endtext
			)
		end

		net.Receive("TTT_RoleCount_Spectate", function()
			PrintToChat(net.ReadUInt(3), nil, " has switched to the spectators.")
		end)

		net.Receive("TTT_RoleCount_Leave", function()
			PrintToChat(net.ReadUInt(3), net.ReadBool(), " has left the server, ")
		end)
	end
end end)
