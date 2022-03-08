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


function GPS.AddToDB(item)

end

function GPS.RemoveFromDB(item)

end

function GPS.HasItem(ply, item)
    if not GPS.Items[item] then return false end
    local str = "SELECT " .. "w" .. SQLStr(item) .. " FROM GPS2 WHERE SID64 = '" .. ply:SteamID64() .. "' ;"
    return sql.Query(str)
    -- false is returned if there is an error, nil if the query returned no data. - from gmod wiki
end

function GPS.Unlock(ply, item)

end

function GPS.Lock(ply, item)

end