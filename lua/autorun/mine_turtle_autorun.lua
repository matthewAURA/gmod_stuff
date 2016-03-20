if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("TTT_MineTurtleWarning")

	-- config file
	local cfg = {
		MaxTurtles = 5,
		BoughtTurtles = 2
	}

	hook.Add("Initialize", "TTT_MineTurtleConfigSetup", function()
		if not file.Exists("ttt_weapons", "DATA") then
			file.CreateDir("ttt_weapons")
		end
		if not file.Exists("ttt_weapons/mine_turtle", "DATA") then
			file.CreateDir("ttt_weapons/mine_turtle")
		end
		if not file.Exists("ttt_weapons/mine_turtle/config.txt", "DATA") then
			file.Write("ttt_weapons/mine_turtle/config.txt", util.TableToJSON(cfg))
		end
	end)
else
	net.Receive("TTT_MineTurtleWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBool()

		if armed then
			local pos = net.ReadVector()
			RADAR.bombs[idx] = {pos=pos, nick="Mine Turtle"}
		else
			RADAR.bombs[idx] = nil
		end

		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
end
