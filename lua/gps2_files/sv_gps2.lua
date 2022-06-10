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

GPS.Config.RefundMultiplier = .75

-- Do NOT edit below this line if you don't know what you're doing.

function GPS.Config.CustomAdminCheck(ply)
    if not ply then return end
    if GPS.Config.AdminRanks[ ply:GetUserGroup() ] then 
        return true
    end
    return false
end

function GPS.Config.IsDonator(ply)
    if not ply then return end
    if GPS.Config.DonatorRanks[ ply:GetUserGroup() ] then 
        return true
    end
    return false
end
-- no more config below here, stop touching even if yo know what you're doing.

util.AddNetworkString("GPS2_OpenMenu")
util.AddNetworkString("GPS2_SendToClient")
util.AddNetworkString("GPS2_ClientShopReq")
util.AddNetworkString( "GPS2_LegacyNotifySv" )

GPS.SEL_NW = {
    [1] = "GPS::SPRIM",
    [2] = "GPS::SSEC",
    [3] = "GPS::SMISC"
}


GPS.NOTIFY = {
    ['GENERIC'] = 0,
    ['ERROR'] = 1,
    ['UNDO'] = 2,
    ['HINT'] = 3,
    ['CLEANUP'] = 4,
}
-- same as the client-only vanilla gmod ones.

function GPS.LegacyNotifyPlayer(ply, text, gtype, length)
    length = length or 2
    gtype = gtype or 0
    if !ply or !text then return end
    net.Start("GPS2_LegacyNotifySv")
        net.WriteString(text)
        net.WriteInt(gtype, 4)
        net.WriteInt(length,8) 
    if ply == "BROADCAST" then     
        net.Broadcast()
    else   
        net.Send(ply)
    end
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
function GPS.AddWeapon( classname, printname, price, model, category, group, teamsTbl, id )
    if not classname or not weapons.GetStored(classname) or not printname or string.Trim(printname) == "" then return false end

    price = price or 0
    model = model or ''
    if group < 1 or group > 3 then group = 1 end
    local id = id or # GPS.Items + 1
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

-- send only what you need
function GPS.VisibleItems(ply)
    if not ply then return false end
    --if GPS.Config.CustomAdminCheck(ply) then return GPS.Items end for debugging
    local visibleItems = {}
    for id, tbl in pairs(GPS.Items) do
        if ( not tbl.Teams ) or tbl.Teams[ply:Team()] then
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
    net.Start("GPS2_OpenMenu")
    net.WriteBool(GPS.Config.CustomAdminCheck(ply))
    net.WriteBool(GPS.Config.IsDonator(ply))
    net.Send(ply)
end)

net.Receive("GPS2_ClientShopReq", function(len,ply)
    local requestType = net.ReadUInt(4)
    if requestType == 0 then 
        --* update wep table
        GPS.SendWepsToClient(ply)
        print("GPS : " .. ply:Nick() .. " requesting wep table refresh")
        return

    elseif requestType == 1 then
        --* select an item
        local id = net.ReadUInt(8)
        print("GPS : " .. ply:Nick() .. " selecting wep id : " .. id)
        -- check if selectable
        if not GPS.Items[id] then print("GPS : Error selecting item! - doesnt exist") return end
        if not GPS.HasItem(ply, id) and not GPS.Config.IsDonator(ply) then print("GPS : Error selecting item! - Item not owned!") return end
        --give to player
        local curSel = ply:GetNWInt( GPS.SEL_NW[GPS.Items[id].Group] ) 
        if curSel ~= 0 then ply:StripWeapon(GPS.Items[curSel].ClassName) end
        if curSel == id then ply:SetNWInt( GPS.SEL_NW[GPS.Items[id].Group], 0 ) return end
        ply:SetNWInt( GPS.SEL_NW[GPS.Items[id].Group], id )
        ply:Give(GPS.Items[id].ClassName)
        return

    elseif requestType == 2 then
        --*buy an item
        local id = net.ReadUInt(8)
        print("GPS : " .. ply:Nick() .. " buying wep id : " .. id)
        if not GPS.GetPoints(ply) or GPS.GetPoints(ply) < GPS.Items[id].Price then 
            GPS.LegacyNotifyPlayer(ply, "You do not have the funds to buy this item!",  GPS.NOTIFY.ERROR)
        end
        if GPS.Unlock(ply,id) then GPS.SetPoints(ply, GPS.GetPoints(ply) - GPS.Items[id].Price ) end

    elseif requestType == 3 then
        --* sell an item
        local id = net.ReadUInt(8)
        print("GPS : " .. ply:Nick() .. " selling wep id : " .. id)
        if GPS.Lock(ply,id) then GPS.SetPoints(ply, GPS.GetPoints(ply) + (GPS.Items[id].Price * GPS.Config.RefundMultiplier) ) end

        if ply:GetNWInt( GPS.SEL_NW[ GPS.Items[id].Group ], 0 ) == id then
            ply:StripWeapon( GPS.Items[id].ClassName )
        end

    elseif requestType == 4 then
        --* add an item

        if not GPS.Config.CustomAdminCheck(ply) then return end

        local tbl = {}
        tbl.Teams = {}
        tbl.ClassName = net.ReadString()
        tbl.PrintName = net.ReadString()
        tbl.Price = net.ReadUInt(32) or 0
        tbl.Category = net.ReadString()
        tbl.Model = net.ReadString()
        tbl.Group = net.ReadUInt(2)
        local teamNum = net.ReadUInt(8) or 0
        if teamNum > 0 then
            for i = 1, teamNum do
                tbl.Teams[net.ReadUInt(8)] = true
            end
        end

        print("GPS : " .. ply:Nick() .. " adding new weapon : ")
        PrintTable(tbl)
        if not tbl.ClassName then
            print("GPS : Classname missing, ABORT!")
            return
        elseif not tbl.PrintName then 
            print("GPS : Printname missing, ABORT!")
            return
        elseif not tbl.Category then 
            print("GPS : Category missing, ABORT!")
            return
        elseif not tbl.Group then 
            print("GPS : Group missing, ABORT!")
            return
        end

        GPS.AddWeapon(tbl.ClassName, tbl.PrintName,  tbl.Price, tbl.Model, tbl.Category, tbl.Group,  tbl.teams)
        print("GPS : " .. ply:Nick() .. " added new weapon succesfully!")

    elseif requestType == 5 then

        --* edit an item

        if not GPS.Config.CustomAdminCheck(ply) then return end

        local tbl = {}
        tbl.Teams = {}
        tbl.ClassName = net.ReadString()
        tbl.PrintName = net.ReadString()
        tbl.Price = net.ReadUInt(32) or 0
        tbl.Category = net.ReadString()
        tbl.Model = net.ReadString()
        tbl.Group = net.ReadUInt(2)
        local teamNum = net.ReadUInt(8) or 0
        if teamNum > 0 then
            for i = 1, teamNum do
                tbl.Teams[net.ReadUInt(8)] = true
            end
        end
        tbl.id = net.ReadUInt(8)
        print("GPS : " .. ply:Nick() .. " adding new / editing weapon : ")
        PrintTable(tbl)
        if GPS.Items[id] and GPS.Items[id].ClassName == tbl.ClassName then
            print("GPS : ID and Classname do not match, ABORT!")
        elseif not tbl.ClassName or string.Trim(tbl.ClassName) == '' then
            print("GPS : Classname missing, ABORT!")
            return
        elseif not tbl.PrintName or string.Trim(tbl.PrintName) == '' then 
            print("GPS : Printname missing, ABORT!")
            return
        elseif not tbl.Category or string.Trim(tbl.Category) == ''then 
            print("GPS : Category missing, ABORT!")
            return
        elseif not tbl.Group or not ( tbl.Group == 1 or tbl.Group == 2 or tbl.Group == 3 ) then 
            print("GPS : Group missing, ABORT!")
            return
        end

        GPS.AddWeapon(tbl.ClassName, tbl.PrintName,  tbl.Price, tbl.Model, tbl.Category, tbl.Group,  tbl.Teams, tbl.id)
        print("GPS : " .. ply:Nick() .. " edited new weapon succesfully!")

    end
end)