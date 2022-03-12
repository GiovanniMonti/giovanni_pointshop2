GPS.ClItems = {}
-- LocalPlayer():GetNWInt("GPS2_Points")

function GPS.OpenMenu()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()/2,ScrH()/2)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton( false )

    function frame:Paint(w,h)
        draw.RoundedBox(2, 0, 0, w, h, Color(35, 35, 35, 240))
    end

    frame.closeBtn = vgui.Create( "DImageButton", frame )
	frame.closeBtn:SetText( "" )
	frame.closeBtn.DoClick = function ( button ) frame:Remove() end
    frame.closeBtn:SetImage("gps_cross_icon.png")
    frame.closeBtn:SizeToContents()
    frame.closeBtn:SetSize( frame.closeBtn:GetWide()*0.8, frame.closeBtn:GetTall()*0.8 )
    frame.closeBtn:SetPos( frame:GetWide() - frame.closeBtn:GetWide()*1.1, frame:GetTall()*0.01 )
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