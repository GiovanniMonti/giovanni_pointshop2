GPS.Items = GPS.Items or {}
GPS.ItemIDs = GPS.ItemsIDs or {}
GPS.Config = GPS.Config or {}
GPS.Config.AdminRanks = {
    ["superadmin"] = true,
    --["admin"] = true,
}

GPS.Config.DonatorRanks = {
    ["VIP"] = true,
    ["VIPAdmin"] = true,
    ["VIPGamemaster"] = true,
    ["Donator"] = true,
}

-- Do NOT edit below this line if you don't know what you're doing.

-- decided to add NWStrings at the start so they dont get in the way later, seems better.
util.AddNetworkString("GPS2_OpenMenu")
util.AddNetworkString("GPS2_SendToClient")
util.AddNetworkString("GPS2_ClientShopReq")

function GPS.Config.CustomAdminCheck(ply)
    if GPS.Config.AdminRanks[ ply:GetUserGroup() ] then 
        return true
    end
    return false
end

function GPS.Config.IsDonator(ply)
    if GPS.Config.AdminRanks[ ply:GetUserGroup() ] then 
        return true
    end
    return false
end


function GPS.SaveItemList()
    if #GPS.Items > 0 then
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
function GPS.AddWeapon( classname, printname, price, model, category, group, teamsTbl )
    if not classname or not weapons.GetStored(classname) or not printname or string.Trim(printname) == "" then return false end

    price = price or 0
    model = model or ''
    if group < 1 or group > 3 then group = 1 end
    local id = # GPS.Items + 1
    GPS.Items[id] = {
        ["ClassName"] = classname,
        ["PrintName"] = printname,
        ["Price"] = price,
        ["Model"] = model,
        ["Category"] = category,
        ["Group"] = group,
        ["Teams"] = teamsTbl -- {} : none; true : all; teamIDs : whitelist behaviour
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
-- send only what you need
function GPS.VisibleItems(ply)
    if not ply then return false end
    if GPS.Config.CustomAdminCheck(ply) then return GPS.Items end
    local visibleItems = {}
    for id, tbl in pairs(GPS.Items) do
        if not tbl.Teams or tbl.Teams[ply:Team()] then
            visibleItems[id] = tbl
        end
    end
    return visibleItems
end

function GPS.SendWepsToClient(ply)
    local VisibleItems = GPS.VisibleItems(ply)
    net.Start("GPS2_SendToClient",false)
        net.WriteUInt( table.Count( VisibleItems ), 8)
        for id,tbl in pairs( VisibleItems ) do
            net.WriteUInt(id, 8)
            net.WriteString(tbl.ClassName)
            net.WriteString(tbl.PrintName)
            net.WriteUInt(tbl.Price, 32)
            net.WriteString(tbl.Category)
            net.WriteUInt(tbl.Group, 2)
            net.WriteString(tbl.Model)
            net.WriteBool(GPS.HasItem(ply,id))
            local nTeams = 0
            if not tbl.teams then 
                nTeams = 0 
            else
                nTeams = table.Count(tbl.Teams)
            end
            net.WriteUInt(nTeams, 8)
            if nTeams < 1 then continue end
            for team,_ in pairs(tbl.Teams) do
                net.WriteUInt(team, 8)
            end
        end
    net.Send(ply)
end

hook.Add("ShowSpare1", "GPS2_OpenMenuCommand", function(ply)
    GPS.SendWepsToClient(ply)
    net.Start("GPS2_OpenMenu", true)
    net.WriteBool(GPS.Config.CustomAdminCheck(ply))
    net.WriteBool(GPS.Config.IsDonator(ply))
    net.Send(ply)
end)

net.Receive("GPS2_ClientShopReq", function(ply)

    local requestType = net.ReadUInt(4)

    if requestType == 0 then 
        -- update wep table
        GPS.SendWepsToClient(ply)

    elseif requestType == 1 then
        -- requesting tokencount be sent
        GPS.SendPointsToClient(ply)

    elseif requestType == 2 then
        -- select an item

    elseif requestType == 3 then
        -- buy an item

    elseif requestType == 4 then
        -- sell an item

    elseif requestType == 5 then
        -- edit/add an item

    end

end)