GPS = GPS or {}
GPS.Items = GPS.Items or {}
GPS.ItemIDs = GPS.ItemsIDs or {}
-- decided to add NWStrings at the start so they dont get in the way later, seems better.
util.AddNetworkString("GPS2_OpenMenu")
util.AddNetworkString("GPS2_SendToClient")

function GPS.SaveItemList()
    if #GPS.Items >0 then
        file.Write("gps2.json",util.TableToJSON(GPS.Items))
    end
end

function GPS.LoadItemList()
    if file.Exists("gps2.json","DATA") then
        GPS.Items = util.JSONToTable(file.Read("gps2.json","DATA"))
    else 
        GPS.SaveItemList()
    end
end

-- function to add weapons to the shop, model should be that of the weapon
-- returns false if weapon adding fails.
function GPS.AddWeapon( classname, printname, price, model, teamsTbl )
    if not classname or not weapons.GetStored(classname) or not printname or string.Trim(printname) == "" then return false end

    price = price or 0
    model = model or ''

    local id = # GPS.Items + 1
    GPS.Items[id] = {
        ["ClassName"] = classname,
        ["PrintName"] = printname,
        ["Price"] = price,
        ["Model"] = model,
        ["Teams"] = teamsTbl -- {} : none; nil : all; teamIDs : whitelist behaviour
    }
    GPS.ItemIDs[classname] = id
    GPS.SaveItemList()
    GPS.AddToDB(id)
    return true
end

function GPS.RemoveWeapon(item)
    GPS.RemoveFromDB(item)
    GPS.ItemIDs[GPS.Items[item].ClassName] = nil
    table.remove(GPS.Items,item)
end

function GPS.CanUnlock(ply, item)
    if not item or not player or not GPS.Items[item] then return false end
    if GPS.HasItem(ply, item) then return false end
    if GPS.Items[item].Teams and not GPS.Items[item].Teams[ply:Team()] then return false end
    if GPS.Items[item].Price > ply:GetPoints(ply) then return false end
    return true
end

function GPS.SendWepsToClient(ply)
    net.Start("GPS2_SendToClient",false)
        net.WriteInt(#GPS.Items, 8)
        for id, #GPS.Items do
            local tbl = GPS.Items[id]
            net.WriteString(tbl.ClassName)
            net.WriteString(tbl.PrintName)
            net.WriteUInt(tbl.Price, 32)
            net.WriteString(tbl.Model)
            net.WriteUInt(table.Count(tbl.Teams), 8)
            for team,_ in pairs(tbl.Teams) do
                net.WriteUInt(team, 8)
            end
        end
    net.Send(ply)
end

hook.Add("ShowSpare", "GPS2_OpenMenuCommand", function(ply)
    GPS.SendWepsToClient(ply)

    net.Start("GPS2_OpenMenu", true)
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "GPS2_PlayerInitialSpawn", function(ply)

end)