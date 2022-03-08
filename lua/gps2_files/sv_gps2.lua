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
    if ~ classname or ~ weapons.GetStored(classname) or ~ printname or string.Trim(printname) == "" then return false end

    price = price or 0
    model = model or ''
    teamsTbl = teamsTbl or {}

    local id = # GPS.Items + 1
    GPS.Items[id] = {
        ["ClassName"] = classname,
        ["PrintName"] = printname,
        ["Price"] = price,
        ["Model"] = model,
        ["Teams"] = teamsTbl
    ]
    GPS.ItemIDs[classname] = id
    GPS.SaveItemList()
    return true
end

function GPS.SendWepsToClient(ply)

    net.Start("GPS2_SendToClient",false)
        for id, weptbl in pairs(GPS.Items) do

        end
    net.Send(ply)
end

hook.Add("ShowSpare", "GPS2_OpenMenuCommand", function(ply)
    GPS.SendWepsToClient(ply)

    net.Start("GPS2_OpenMenu", true)
    net.Send(ply)
end)