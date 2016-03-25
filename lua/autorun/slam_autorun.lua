if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("TTT_SLAMWarning")

	-- config file
	local cfg = {
		MaxSlams = 5,
		BoughtSlams = 2
	}

	hook.Add("Initialize", "TTT_SLAMConfigSetup", function()
		if not file.Exists("ttt", "DATA") then
			file.CreateDir("ttt")
		end
		if not file.Exists("ttt/weapons", "DATA") then
			file.CreateDir("ttt/weapons")
		end
		if not file.Exists("ttt/weapons/slam", "DATA") then
			file.CreateDir("ttt/weapons/slam")
		end
		if not file.Exists("ttt/weapons/slam/config.txt", "DATA") then
			file.Write("ttt/weapons/slam/config.txt", util.TableToJSON(cfg))
		end
	end)
else
	net.Receive("TTT_SLAMWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBool()

		if armed then
			local pos = net.ReadVector()
			RADAR.bombs[idx] = {pos=pos, nick="SLAM"}
		else
			RADAR.bombs[idx] = nil
		end

		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
end
