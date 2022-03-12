GPS.ClItems = {}
GPS.WepCategories = {}
-- LocalPlayer():GetNWInt("GPS2_Points")

function GPS:OpenMenu()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()/2,ScrH()/2)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton( false )

    function frame:Paint(w,h)
        draw.RoundedBox(2, 0, 0, w, h, Color(45, 45, 45, 240))
        surface.SetDrawColor( 105, 105, 105 )
        surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.1, self:GetWide() * 0.2 , self:GetTall() * 0.9)
    end

    frame.closeBtn = vgui.Create( "DImageButton", frame )
	frame.closeBtn:SetText( "" )
	frame.closeBtn.DoClick = function ( button ) frame:Remove() end
    frame.closeBtn:SetImage("gps_cross_icon.png")
    frame.closeBtn:SizeToContents()
    frame.closeBtn:SetSize( frame.closeBtn:GetWide()*0.8, frame.closeBtn:GetTall()*0.8 )
    frame.closeBtn:SetPos( frame:GetWide() - frame.closeBtn:GetWide()*1.1, frame:GetTall()*0.01 )

    frame.catSelect = vgui.Create("DScrollPanel", frame )
    frame.catSelect:SetPos(frame:GetWide()*0.01,frame:GetTall()*0.1)
    frame.catSelect:SetSize(frame:GetWide()*0.18,frame:GetTall()*0.9)
    function frame.catSelect:Update()
        for k, category in ipairs(GPS.WepCategories) do
            local catLabel = self:Add("DLabel")
            catLabel:SetText( tostring(category) )
            catLabel:Dock( TOP )
            catLabel:DockMargin(0, 0, 0, ScrH()/216)
            catLabel.selected = false
            function catLabel:ToggleColor()
                if self.selected then
                    self:SetTextColor(Color(255, 255, 255))
                else
                    self:SetTextColor(Color(39, 94, 184))
                end
            end
            function catLabel:OnDepressed()
                self.selected = not self.selected
                self:ToggleColor()
                -- change shown items here
            end
        end
    end

    frame.itemShop = vgui.Create("DScrollPanel", frame)




    frame.catSelect:Update()
end


net.Receive("GPS2_SendToClient",function()
    table.Empty( GPS.WepCategories )
    table.Empty( GPS.ClItems )
    local nItems = net.ReadUInt(8)
    for i = 1, nItems do
        local id = net.ReadUInt(8)
        GPS.ClItems[id] = {}
        GPS.ClItems[id].ClassName = net.ReadString()
        GPS.ClItems[id].PrintName = net.ReadString()
        GPS.ClItems[id].Price = net.ReadUInt(32)
        GPS.ClItems[id].Category = net.ReadString()
        GPS.ClItems[id].Group = net.ReadUInt(2)
        GPS.ClItems[id].Model = net.ReadString()
        GPS.ClItems[id].Owned = net.ReadBool() -- just for gui, not used in real checks.

        if not table.HasValue(GPS.WepCategories, GPS.ClItems[id].Category) then
            table.insert(GPS.WepCategories, GPS.ClItems[id].Category)
        end

        local nTeams = net.ReadUInt(8)
        GPS.ClItems[id].Teams = {}
        if nTeams < 1 then continue end
        for j = 1, nTeams do
            GPS.ClItems[id].Teams[net.ReadUInt(8)] = true
        end
    end
end)

local GPSPlyData = {}
net.Receive("GPS2_OpenMenu", function()
    GPSPlyData.isadmin = net.ReadBool()
    GPSPlyData.isdonator = net.ReadBool()
    GPS:OpenMenu()
end)