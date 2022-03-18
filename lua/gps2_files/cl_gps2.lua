GPS.ClItems = {}
GPS.WepCategories = {}
GPS.ItemsByCateogry = {}
--* LocalPlayer():GetNWInt("GPS2_Points")

function GPS:OpenMenu()
    -- todo add points counter text
    -- todo make admin menu
    -- todo make selection menu
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
        surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.2, self:GetWide() * 0.2 , self:GetTall() * 0.9)
    end

    frame.closeBtn = vgui.Create( "DImageButton", frame )
	frame.closeBtn:SetText( "" )
	frame.closeBtn.DoClick = function ( button ) frame:Remove() end
    frame.closeBtn:SetImage("cross_icon.png")
    frame.closeBtn:SizeToContents()
    frame.closeBtn:SetSize( frame.closeBtn:GetWide()*0.4, frame.closeBtn:GetTall()*0.4 )
    frame.closeBtn:SetPos( frame:GetWide() - frame.closeBtn:GetWide()*1.1, frame:GetTall()*0.01 )

    frame.itemShop = vgui.Create("DScrollPanel", frame) 
    frame.itemShop:SetPos(frame:GetWide()*0.225,frame:GetTall()*0.22)
    frame.itemShop:SetSize(frame:GetWide()*0.62,frame:GetTall()*0.76)
    function frame.itemShop:Update()
        for id,tbl in pairs(GPS.ItemsByCateogry[frame.catSelect.GetSelected():GetText()]) do
            local curItem = self:Add("DPanel")
            curItem:Dock( TOP )
            
            curItem:SetSize(self:GetWide()*0.85, self:GetTall()*0.2)

            function curItem:Paint()
                surface.SetDrawColor(92, 92, 92, 255 )
                self:DrawOutlinedRect()
            end

            curItem.nameLabel = vgui.Create("DLabel", curItem)
            curItem.nameLabel:SetFont("DermaLarge")
            curItem.nameLabel:SetText(tbl.PrintName)
            curItem.nameLabel:SizeToContents()
            curItem.nameLabel:Dock(TOP)
            curItem.nameLabel:DockMargin(self:GetWide()*0.2, self:GetTall()*0.065, 0, 0)

            -- TODO modelpanel
            -- TODO add label item and buttons to curItem

        end
    end

    frame.catSelect = vgui.Create("DScrollPanel", frame )
    frame.catSelect:SetPos(frame:GetWide()*0.01,frame:GetTall()*0.22)
    frame.catSelect:SetSize(frame:GetWide()*0.18,frame:GetTall()*0.78)
    function frame.catSelect.GetSelected() return frame.catSelect.selected end
    function frame.catSelect:Update()
        for k, category in ipairs(GPS.WepCategories) do
            local catLabel = self:Add("DLabel")
            catLabel:SetText( tostring(category) )
            catLabel:Dock( TOP )
            catLabel:DockMargin(ScrW()/384, 0, 0, ScrH()/216)
            catLabel:SetFont("DermaLarge")
            catLabel:SizeToContents()
            catLabel:SetMouseInputEnabled( true )
            catLabel.selected = false
            if not frame.catSelect.selected then frame.catSelect.selected = catLabel end
            function catLabel:SelectThis()
                if frame.catSelect.selected == self then return end
                if not frame.catSelect.selected then frame.catSelect.selected = self end
                frame.catSelect.selected.selected = false
                frame.catSelect.selected = self
                self.selected = true
            end
            function catLabel:OnCursorEntered()
                if not self.selected then
                self:SetTextColor(Color(108, 130, 166))
                else
                    self:SetTextColor(Color(61, 123, 224))
                end
            end
            function catLabel:OnCursorExited()
                if not self.selected then
                self:SetTextColor(Color(255, 255, 255))
                else
                    self:SetTextColor(Color(39, 94, 184))
                end
            end
            function catLabel:ToggleColor()
                if not self.selected then
                    self:SetTextColor(Color(255, 255, 255))
                else
                    self:SetTextColor(Color(39, 94, 184))
                end
            end
            function catLabel:OnDepressed()
                self.selected = not self.selected
                if self.selected then self:SelectThis() end
                self:ToggleColor()
            end
        end
    end

    frame.catSelect:Update()
    frame.itemShop:Update()
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
            GPS.ItemsByCateogry[ GPS.ClItems[id].Category ] = {}
        end

        local nTeams = net.ReadUInt(8)
        GPS.ClItems[id].Teams = {}
        if nTeams < 1 then goto cont end
        for j = 1, nTeams do
            GPS.ClItems[id].Teams[net.ReadUInt(8)] = true
        end

        ::cont::

        GPS.ItemsByCateogry[GPS.ClItems[id].Category][id] = GPS.ClItems[id]
    end
end)

local GPSPlyData = {}
net.Receive("GPS2_OpenMenu", function()
    GPSPlyData.isadmin = net.ReadBool()
    GPSPlyData.isdonator = net.ReadBool()
    GPS:OpenMenu()
end)