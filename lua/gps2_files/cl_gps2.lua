GPS.ClItems = {}
local playerGPS = {}

net.Receive("GPS2_SendToClient",function()
    local nItems = net.ReadUInt(8)
    for i, nItems do
        local id = net.ReadUInt(8)
        GPS.ClItems[id].ClassName = net.ReadString()
        GPS.ClItems[id].PrintName = net.ReadString()
        GPS.ClItems[id].Price = net.ReadUInt(32)
        GPS.ClItems[id].Model = net.ReadString()
        local nTeams = net.ReadUInt(8)
        GPS.ClItems[id].Teams = {}
        for j, nTeams do
            GPS.ClItems[id].Teams[net.ReadUInt(8)] = true
        end
    end
end)

net.Receive("GPS2_SendTokensToClient",function()
    playerGPS.Points = net.ReadUInt(32)
end)

net.Receive("GPS2_OpenMenu", function()
    playerGPS.IsAdmin = net.ReadBool()
    playerGPS.IsDonator = net.ReadBool()

end)