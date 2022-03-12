GPS.ClItems = {}
-- LocalPlayer():GetNWInt("GPS2_Points")

function GPS.OpenMenu()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()/3,ScrH()/2)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame.btnMaxim:SetVisible( false )
	frame.btnMinim:SetVisible( false )

    function frame:Paint(w,h)
        draw.RoundedBox(2, 0, 0, w, h, Color(35, 35, 35, 240))
    end

    --function frame.btnClose:Paint()

    --end
end


net.Receive("GPS2_SendToClient",function()
    local nItems = net.ReadUInt(8)
    for i = 1, nItems do
        local id = net.ReadUInt(8)
        GPS.ClItems[id].ClassName = net.ReadString()
        GPS.ClItems[id].PrintName = net.ReadString()
        GPS.ClItems[id].Price = net.ReadUInt(32)
        GPS.ClItems[id].Model = net.ReadString()
        GPS.ClItems[id].Owned = net.ReadBool() -- just for gui, not used in real checks.
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
    GPS.OpenMenu()
end)