if GetConVarString("gamemode") == "terrortown" and SERVER then
	
  -- Commands
  map_stats_enabled = "map_stats_enabled"
  map_stats_min_players = "map_stats_min_players"
  map_stats_print_command = "map_stats_print"
  
  --SQL
  map_stats_table_name = "ttt_map_stats"
  
  
	if not ConVarExists(map_stats_enabled) then CreateConVar(map_stats_enabled, "1") end
	if not ConVarExists(map_stats_min_players) then CreateConVar(map_stats_min_players, "6") end
	
	concommand.Add(map_stats_print_command,function() 
      print_stats(print,"*")
    end)
	
     function print_stats(printer,map)
		data = sql.Query("SELECT * FROM " .. map_stats_table_name ..  " WHERE map_name = '" .. map .. "'")
        if(data == false) then
			error(sql.LastError())
		elseif (data == nil) then
            print("No records")
        else 
			for id, row in pairs( data ) do
				local totalGames = row["games_played"]
                printer("	"..row["map_name"])
                printer("Total Games:     "..totalGames)
                printer("Innocent Wins:   "..row["innocent_wins"]) 
                printer("Terrorist Wins:  "..row["terrorist_wins"]) 
                printer("")
            end
        end
	end 
  
  
    function create_tables()
      query = "CREATE TABLE IF NOT EXISTS " .. map_stats_table_name .. " (map_name TEXT NOT NULL PRIMARY KEY, games_played, innocent_wins, terrorist_wins)"
        result = sql.Query(query)
        if (result == false) then
          error(sql.LastError())
      end
    end
  
   function delete_tables()
      query = "DROP TABLE " .. map_stats_table_name
        result = sql.Query(query)
        if (result == false) then
          error(sql.LastError())
      end
    end
	 
	 
  
  -- map is of type string
	function new_map( map )
		result = sql.Query( "INSERT INTO " .. map_stats_table_name .. " (`map_name`, `games_played`, `innocent_wins`, `terrorist_wins`) VALUES ('".. map .."', '0', '0', '0')" )
	end
 
	function map_exists( map )
		result = sql.Query("SELECT map_name FROM " .. map_stats_table_name .." WHERE map_name = '".. map .."'")
		if(result == nil) then
			new_map( map )
		elseif(result == false) then
            error(sql.LastError())
        end
	end
	 
	function init_map_stats()
		create_tables()
        map_exists(game.GetMap())
	end
	 
	
	hook.Add( "InitPostEntity", "InitPostEntity", init_map_stats )
	 
	hook.Add("TTTEndRound","map_stats", function(result)
    -- If enabled and we have more than the minimum number of players for stats tracking
		if ((GetConVar(map_stats_enabled)):GetBool()) and table.Count(player.GetAll()) >= (GetConVarNumber(map_stats_min_players)) then 
      if (result == WIN_TRAITOR) then
          sql.Query("UPDATE " .. map_stats_table_name .. " SET terrorist_wins = terrorist_wins+1, games_played = games_played+1 WHERE map_name = '".. game.GetMap() .."'")
      elseif (result == WIN_INNOCENT) then
          sql.Query("UPDATE " .. map_stats_table_name .. " SET innocent_wins = innocent_wins+1, games_played = games_played+1 WHERE map_name = '".. game.GetMap() .."'")
      elseif (result == WIN_TIMELIMIT) then
          sql.Query("UPDATE " .. map_stats_table_name .. " SET innocent_wins = innocent_wins+1, games_played = games_played+1 WHERE map_name = '".. game.GetMap() .."'")
      end      
		else
			print("Statistics Not Saved");
		end

	end) 
  
    hook.Add( "PlayerSay", "stats", function( ply, text, team )
      if ( string.sub( text, 1, 6 ) == "!stats" ) then -- if the first four characters of the string are /all
        for k, ply in pairs( player.GetAll() ) do
	     print_stats(function(message)
          PrintMessage(HUD_PRINTTALK,message)      
        end,game.GetMap())
        end
        return
      end
    end )
  
end
