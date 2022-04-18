-- always use item ID, not Name!

function GPS.SQLInit()
    if not sql.TableExists("GPS2") then
        local str = "CREATE TABLE IF NOT EXISTS GPS2 ( SID64 NVARCHAR , "
        if GPS.Items and table.Count(GPS.Items) > 0 then 
            for id, _ in pairs(GPS.Items) do
                str = str .. tostring( "w".. tostring(id) .. " BOOLEAN, " )
            end
        sql.Query( string.Left(str, #str-2) .. " );")
        end
    end
    if not sql.TableExists("GPS2_Money") then
        local str = "CREATE TABLE IF NOT EXISTS GPS2_Money ( SID64 NVARCHAR , Points INTEGER ) ;"
        sql.Query(str)
    end
end

function GPS.GetPoints(ply)
    if not ply or not ply:IsPlayer() then return false end
    local str = "SELECT Money FROM GPS2_Money WHERE SID4 = " .. SQLStr( ply:SteamID64() ) .. " ;"
    str = sql.QueryValue(str)
    return (not (str == 'NULL') or str)
end

function GPS.SetPoints(ply, points)
    if not ply or not isnumber(points) then return end
    local str = "UPDATE GPS2_Money SET Money = " .. SQLStr( points ) .. " WHERE SID64 = " .. SQLStr( ply:SteamID64() ) .." ;"
    str = sql.Query(str)
    ply:SetNWInt("GPS2_Points", GPS.GetPoints(ply) )
    return str
end

function GPS.AddToDB(item)
    if not item or not GPS.Items[item] or not weapons.GetStored( GPS.Items[item].ClassName ) then return false end
    local str =  "ALTER TABLE GPS2 ADD COLUMN w" .. SQLStr(item, true) .. " BOOLEAN ;"
    print('GPS2 Serverlog : added'  .. GPS.Items[item].ClassName .. " id : w" .. tostring(item) )
    return sql.Query(str)
end

function GPS.RemoveFromDB(item)
    if not item or not GPS.Items[item] or not weapons.GetStored( GPS.Items[item].ClassName ) then return false end
   
    local str =  "CREATE TABLE GPS_TEMP ( SID64 NVARCHAR , "
    local str2 = "SID64, "
    
    if GPS.Items and table.Count(GPS.Items) > 0 then 
        for id, _ in pairs(GPS.Items) do
            if id == item then continue end
                str = str .. tostring( "w".. tostring(id) .. " BOOLEAN, " )
                str2 = str2 .. tostring( "w".. tostring(id) .. " , " )
        end
        str = string.Left(str, #str-2) .. " );"
        str2 = string.Left(str2, #str2-2)
        
        sql.Query(str) -- creates the table GPS_Temp

        sql.Query('INSERT INTO GPS_TEMP ( ' .. str2 .. ' ) SELECT  ' .. str2 .. '  FROM GPS2 ;')
        sql.Query('DROP TABLE GPS2;')
        sql.Query('ALTER TABLE GPS_TEMP RENAME TO GPS2;')
      
    elseif GPS.Items and table.Count(GPS.Items) == 0 then
        GPS.ResetItemData()
    end
end

function GPS.ResetItemData()
    print('GPS2 Serverlog : DATABASE RESET STARTING')
    sql.Query('DROP TABLE GPS2')
    GPS.SQLInit()
    print('GPS2 Serverlog : DATABASE RESET COMPLETE')
end

function GPS.HasItem(ply, item)
    if not GPS.Items[item] then return false end
    local str = "SELECT " .. "w" .. SQLStr(item, true) .. " FROM GPS2 WHERE SID64 = '" .. ply:SteamID64() .. "' ;"
    local queryResult = sql.QueryValue(str)
    if queryResult == '0' or queryResult == 'NULL' then
        return false
    elseif queryResult == '1' then
        return true
    else
        return queryResult
    end
    -- false is returned if there is an error, nil if the query returned no data
    -- normally query result is a string.
end

function GPS.CanUnlock(ply, item)
    print("test 4")
    if not ply or not item or not GPS.Items[item] then return false end
    print("test 5")
    if GPS.HasItem(ply,item) then return false end
    print("test 6")
    if GPS.GetPoints(ply) < GPS.Items[item].Price then return false end
    print("test 7")
    if GPS.Items[item].Teams and not GPS.Items[item].Teams[ply:Team()] then return false end
    print("test 8")
    return true
end

function GPS.Unlock(ply, item)
    print("test 2 \n item : " , item, "\n items isreal : ", not not GPS.Items[item] )
    if not ply or GPS.Config.IsDonator(ply) or not item or not GPS.Items[item] or not GPS.CanUnlock(ply, item) then return false end
    print("test 3")
    local str = "UPDATE GPS2 SET w" .. SQLStr(item, true) .. " = 1 WHERE SID64 = '" .. ply:SteamID64() .. "' ;" 
    print('GPS2 Serverlog : ' .. ply:Name() .. " unlocked " .. GPS.Items[item].ClassName .. " id : w" .. tostring(item) )
    return sql.Query(str)
    -- return false if there is an error or you dont have permissions to unlock
    -- DOES NOT REMOVE COST!!!
end

function GPS.Lock(ply, item)
    if not ply or GPS.Config.IsDonator(ply) or not item or not GPS.Items[item] or not GPS.HasItem(ply, item) then return false end
    local str = "UPDATE GPS2 SET w" .. SQLStr(item, true) .. " = 0 WHERE SID64 = '" .. ply:SteamID64() .. "' ;" 
    print('GPS2 Serverlog : ' .. ply:Name() .. " locked " .. GPS.Items[item].ClassName .. " id : w" .. tostring(item) )
    return sql.Query(str)
    -- return false if there is an error or you dont have permissions to unlock
end

hook.Add("PlayerInitialSpawn", "GPS2_PlayerInitialSpawn", function(ply)
    if not GPS.GetPoints(ply) then
        local str = "INSERT INTO GPS2_Money ( SID64, Points ) VALUES ( " .. ply:SteamID64() .. " , " .. "0" .." ) ;"
        sql.Query(str)
    end
    local data = sql.Query("SELECT * FROM GPS2 WHERE SID64 = " .. sql.SQLStr( ply:SteamID64() ) .. " ;")
    if not data then 
        sql.Query( "INSERT INTO GPS2 ( SID64 ) VALUES( " .. sql.SQLStr( ply:SteamID64() ) .. " );" )
    end
end)