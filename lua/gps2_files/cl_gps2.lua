GPS.ClItems = {}
GPS.WepCategories = {}
GPS.ItemsByCateogry = {}
--* LocalPlayer():GetNWInt("GPS2_Points")

GPS.Config = {
    -- GPS.Config.LabelColor
    ["LabelColor"] = Color(255, 255, 255),
    ["LabelColorH"] = Color(61, 123, 224),
    ["LabelColorS"] = Color(39, 94, 184),
    ["LabelColorSH"] = Color(108, 130, 166),
    ["BackgroundColor"] = Color(45, 45, 45, 240),
    ["LineColor"] = Color(105, 105, 105),

}

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
    frame.CurTab = 0

    function frame:AdditionalPaint(w,h)
        if self.CurTab == 0 then surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.2, self:GetWide() * 0.2 , self:GetTall() * 0.9) end
    end
    function frame:Paint(w,h)
        draw.RoundedBox(2, 0, 0, w, h, GPS.Config.BackgroundColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        surface.DrawLine(self:GetWide() * 0.02 , self:GetTall() * 0.18, self:GetWide() * 0.98 , self:GetTall() * 0.18)
        self:AdditionalPaint(w,h)
    end

    function frame:ChangeToTab(newTab)
        --[[
            tab 0 = shop
            tab 1 = wep select
            tab 2 = admin
        --]]
        if not newTab or not ( newTab >=0 and newTab <=2 ) then return end
        if self.CurTab == 0 then
            self.itemShop:Hide()
            self.catSelect:Hide()
        elseif self.CurTab == 1 then
            self.loadoutSelect:Hide()
        else 
            -- hide admin
        end

        if newTab == 0 then
            self.itemShop:Show()
            self.catSelect:Show()
        elseif newTab == 1 then
            self.loadoutSelect:Show()
        else 
            -- show admin
        end
        self.CurTab = newTab
    end

    frame.closeBtn = vgui.Create( "DImageButton", frame )
	frame.closeBtn:SetText( "" )
	frame.closeBtn.DoClick = function ( button ) frame:Remove() end
    frame.closeBtn:SetImage("cross_icon.png")
    frame.closeBtn:SizeToContents()
    frame.closeBtn:SetSize( frame.closeBtn:GetWide()*0.4, frame.closeBtn:GetTall()*0.4 )
    frame.closeBtn:SetPos( frame:GetWide() - frame.closeBtn:GetWide()*1.1, frame:GetTall()*0.01 )

    
    frame.tabSelect = {}

    frame.tabSelect[1] = vgui.Create("DLabel", frame)
    frame.tabSelect[1]:SetFont("DermaLarge")
    frame.tabSelect[1]:SetText("Shop")
    frame.tabSelect[1]:SizeToContents()
    frame.tabSelect[1]:SetPos(frame:GetWide()*0.25 - frame.tabSelect[1]:GetWide()/2 ,frame:GetTall()*0.12)
    frame.tabSelect[1]:SetMouseInputEnabled(true)
    frame.tabSelect[1].DoClick = function()
        frame:ChangeToTab(0)
        frame.tabSelect:UpdateColors()
    end
    frame.tabSelect[1].OnCursorEntered = function(self)
        if frame.CurTab == 0 then
            self:SetTextColor(GPS.Config.LabelColorSH)
        else
            self:SetTextColor(GPS.Config.LabelColorH)
        end
    end
    frame.tabSelect[1].OnCursorExited = function(self)
        if frame.CurTab == 0 then
            self:SetTextColor(GPS.Config.LabelColorS)
        else
            self:SetTextColor(GPS.Config.LabelColor)
        end
    end
    frame.tabSelect[2] = vgui.Create("DLabel", frame)
    frame.tabSelect[2]:SetFont("DermaLarge")
    frame.tabSelect[2]:SetText("Loadout")
    frame.tabSelect[2]:SizeToContents()
    frame.tabSelect[2]:SetPos(frame:GetWide()*0.40 - frame.tabSelect[2]:GetWide()/2,frame:GetTall()*0.12)
    frame.tabSelect[2]:SetMouseInputEnabled(true)
    frame.tabSelect[2].DoClick = function()
        frame:ChangeToTab(1)
        frame.tabSelect:UpdateColors()
    end
    frame.tabSelect[2].OnCursorEntered = function(self)
        if frame.CurTab == 1 then
            self:SetTextColor(GPS.Config.LabelColorSH)
        else
            self:SetTextColor(GPS.Config.LabelColorH)
        end
    end
    frame.tabSelect[2].OnCursorExited = function(self)
        if frame.CurTab == 1 then
            self:SetTextColor(GPS.Config.LabelColorS)
        else
            self:SetTextColor(GPS.Config.LabelColor)
        end
    end
    
    frame.tabSelect[3] = vgui.Create("DLabel", frame)
    frame.tabSelect[3]:SetFont("DermaLarge")
    frame.tabSelect[3]:SetText("Admin")
    frame.tabSelect[3]:SizeToContents()
    frame.tabSelect[3]:SetPos(frame:GetWide()*0.55 - frame.tabSelect[3]:GetWide()/2,frame:GetTall()*0.12)
    frame.tabSelect[3]:SetMouseInputEnabled(true)
    frame.tabSelect[3].DoClick = function()
        frame:ChangeToTab(2)
        frame.tabSelect:UpdateColors()
    end
    frame.tabSelect[3].OnCursorEntered = function(self)
        if frame.CurTab == 2 then
            self:SetTextColor(GPS.Config.LabelColorSH)
        else
            self:SetTextColor(GPS.Config.LabelColorH)
        end
    end
    frame.tabSelect[3].OnCursorExited = function(self)
        if frame.CurTab == 2 then
            self:SetTextColor(GPS.Config.LabelColorS)
        else
            self:SetTextColor(GPS.Config.LabelColor)
        end
    end
    function frame.tabSelect:UpdateColors()
        local curtab = frame.CurTab + 1
        self[curtab]:SetTextColor(GPS.Config.LabelColorS)
        if curtab == 1 then
            self[2]:SetTextColor(GPS.Config.LabelColor)
            self[3]:SetTextColor(GPS.Config.LabelColor)
        elseif curtab == 2 then
            self[1]:SetTextColor(GPS.Config.LabelColor)
            self[3]:SetTextColor(GPS.Config.LabelColor)
        else
            self[1]:SetTextColor(GPS.Config.LabelColor)
            self[2]:SetTextColor(GPS.Config.LabelColor)
        end
    end

    frame.loadoutSelect = {} --TODO make the 3 cats individually in here
    frame.loadoutSelect[1] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[1]:SetPos(0,0)
    --todo actually make this and the other 2

    function frame.loadoutSelect:Show()
        self[1]:Show()
        self[2]:Show()
        self[3]:Show()
    end
    function frame.loadoutSelect:Hide()
        self[1]:Hide()
        self[2]:Hide()
        self[3]:Hide()
    end

    frame.itemShop = vgui.Create("DScrollPanel", frame) 
    frame.itemShop:SetPos(frame:GetWide()*0.225,frame:GetTall()*0.22)
    frame.itemShop:SetSize(frame:GetWide()*0.62,frame:GetTall()*0.76)
    function frame.itemShop:Update()
        for id,tbl in pairs(GPS.ItemsByCateogry[frame.catSelect.GetSelected():GetText()]) do
            local curItem = self:Add("DPanel")
            curItem:Dock( TOP )
            curItem:SetSize(self:GetWide()*0.85, self:GetTall()*0.3)

            function curItem:Paint()
                surface.SetDrawColor(92, 92, 92, 255 )
                surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.65, self:GetWide() , self:GetTall() * 0.65)
                surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0, self:GetWide() * 0.2 , self:GetTall() )
                surface.DrawLine(self:GetWide() * 0.58 , self:GetTall() * 0.65, self:GetWide() * 0.58 , self:GetTall() )
                self:DrawOutlinedRect()
            end

            curItem.nameLabel = vgui.Create("DLabel", curItem)
            curItem.nameLabel:SetFont("DermaLarge")
            curItem.nameLabel:SetText(tbl.PrintName)
            curItem.nameLabel:SizeToContents()
            curItem.nameLabel:Dock(TOP)
            curItem.nameLabel:DockMargin(self:GetWide()*0.22, self:GetTall()*0.065, 0, 0)

            curItem.priceLabel = vgui.Create("DLabel", curItem)
            curItem.priceLabel:SetFont("DermaLarge")
            curItem.priceLabel:SetText( "Price : " .. tostring(tbl.Price) )
            curItem.priceLabel:SetSize(curItem:GetWide()*0.4,curItem:GetTall()*0.33)
            curItem.priceLabel:SetPos(curItem:GetWide()*0.26 , curItem:GetTall()*0.7 )

            curItem.transactionButton = vgui.Create("DLabel", curItem)
            curItem.transactionButton:SetFont("DermaLarge")
            curItem.transactionButton:SetSize(curItem:GetWide()*0.4, curItem:GetTall()*0.33)
            curItem.transactionButton:SetPos(curItem:GetWide()*0.7 , curItem:GetTall()*0.7 )
            curItem.transactionButton:SetMouseInputEnabled(true)
            function curItem.transactionButton:Update() 
                if (tbl.Owned) then
                    self:SetText( "Sell" )
                else
                    self:SetText( "Buy" )
                end
            end
            function curItem.transactionButton:DoClick()
                if tbl.Owned then
                    GPS.ClientShopReq(GPS.NET_ENUM.SELL, {id})
                else
                    GPS.ClientShopReq(GPS.NET_ENUM.BUY, {id})
                end
            end

            function curItem.transactionButton:OnCursorEntered()
                self:SetTextColor(GPS.Config.LabelColorH)
            end
            function curItem.transactionButton:OnCursorExited()
                self:Update() -- update after a click, should resolve visual bugs.
                self:SetTextColor(GPS.Config.LabelColor)
            end

            curItem.transactionButton:Update()

            curItem.modelPanel = vgui.Create("DModelPanel", curItem)
            curItem.modelPanel:SetModel( tbl.Model)
            curItem.modelPanel:SetSize(curItem:GetTall()*0.9,curItem:GetTall()*0.9)
            local min,max = curItem.modelPanel.Entity:GetRenderBounds();
			curItem.modelPanel:SetCamPos( min:Distance( max ) * Vector( .55, .55, .25 ) )
			curItem.modelPanel:SetLookAt( ( min + max ) / 2 )
			curItem.modelPanel.LayoutEntity = function() end
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
            catLabel:SetFont("DermaLarge")
            catLabel:SizeToContents()
            catLabel:DockMargin(ScrW()*0.02, 0, 0, ScrH()/216)
            catLabel:SetMouseInputEnabled( true )
            catLabel.selected = false
            function catLabel:SelectThis()
                if frame.catSelect.selected == self then return end
                frame.catSelect.selected.selected = false
                frame.catSelect.selected = self
                self.selected = true
                frame.itemShop:Update()
            end
            function catLabel:OnCursorEntered()
                if not self.selected then
                self:SetTextColor(GPS.Config.LabelColorSH)
                else
                    self:SetTextColor(GPS.Config.LabelColorH)
                end
            end
            function catLabel:OnCursorExited()
                if not self.selected then
                self:SetTextColor(GPS.Config.LabelColor)
                else
                    self:SetTextColor(GPS.Config.LabelColorS)
                end
            end
            function catLabel:ToggleColor()
                if not self.selected then
                    self:SetTextColor(GPS.Config.LabelColor)
                else
                    self:SetTextColor(GPS.Config.LabelColorS)
                end
            end
            function catLabel:OnDepressed()
                if not self.selected then self:SelectThis() end
                self:ToggleColor()
            end
            if not frame.catSelect.selected then 
                frame.catSelect.selected = catLabel
                catLabel.selected = true
                catLabel:ToggleColor()
            end
        end
    end
    frame.catSelect:Update()
    frame.itemShop:Update()
    frame:ChangeToTab(0)
    frame.tabSelect:UpdateColors()
    -- always default to shop
end

------------------- net code below

GPS.NET_ENUM = {
    ["WEPTBL"] = 0,
    ["SELECT"] = 1,
    ["BUY"] = 2,
    ["SELL"] = 3,
    ["EDIT"] = 4,
    ["ADD"] = 4,
}

function GPS.ClientShopReq(requestType, args)
    --[[
        0 : request wep table update; {}
        1 : select item; {itemID}
        2 : buy item; {itemID}
        3 : sell item; {itemID}
        4 : add/edit item;
    --]]
    net.Start("GPS2_ClientShopReq")
    net.WriteUInt(requestType, 4)

    if requestType == 0 then
        
    elseif requestType == 1 then
        net.WriteUInt(args[1], 8)
    elseif requestType == 2 then
        -- buy an item
        net.WriteUInt(args[1], 8)
    elseif requestType == 3 then
        -- sell an item
        net.WriteUInt(args[1], 8)
    elseif requestType == 4 then
        -- TODO edit/add items
    end
    net.SendToServer()
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

        if GPS.ClItems[id].Model == '' then
            GPS.ClItems[id].Model = "models/props_interiors/pot02a.mdl"
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