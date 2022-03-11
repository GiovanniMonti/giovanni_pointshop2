GPS.ClItems = {}
-- LocalPlayer():GetNWInt("GPS2_Points")
net.Receive("GPS2_SendToClient",function()
    local nItems = net.ReadUInt(8)
    for i = 1, nItems do
        local id = net.ReadUInt(8)
        GPS.ClItems[id].ClassName = net.ReadString()
        GPS.ClItems[id].PrintName = net.ReadString()
        GPS.ClItems[id].Price = net.ReadUInt(32)
        GPS.ClItems[id].Model = net.ReadString()
        local nTeams = net.ReadUInt(8)
        GPS.ClItems[id].Teams = {}
        for j = 1, nTeams do
            GPS.ClItems[id].Teams[net.ReadUInt(8)] = true
        end
    end
end)
local GPSPlyData = {}
net.Receive("GPS2_OpenMenu", function()
    GPSPlyData.isadmin = net.ReadBool()
    GPSPlyData.isdonator = net.ReadBool()

end)