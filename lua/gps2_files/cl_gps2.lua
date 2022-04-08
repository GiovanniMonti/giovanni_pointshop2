GPS.ClItems = {}
GPS.WepCategories = {}
GPS.ItemsByCateogry = {}
GPS.ItemsByName = {}
local GPSPlyData = {} -- visual checks
--* LocalPlayer():GetNWInt("GPS2_Points")

GPS.Config = {
    -- GPS.Config.LineColor
    ["LabelColor"] = Color(255, 255, 255),
    ["LabelColorH"] = Color(61, 123, 224),
    ["LabelColorS"] = Color(39, 94, 184),
    ["LabelColorSH"] = Color(108, 130, 166),
    ["BackgroundColor"] = Color(45, 45, 45, 240),
    ["LineColor"] = Color(105, 105, 105),
    ["ButtonColor"] = Color(25, 93, 130),
}

function GPS:OpenMenu()
    -- todo add points counter text
    -- todo make admin menu
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()/2,ScrH()/2)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton( false )
    frame.CurTab = 0

    function frame:AdditionalPaint(w,h)
        if self.CurTab == 0 then 
            surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.2, self:GetWide() * 0.2 , self:GetTall() * 0.9)
            return 
        end
        if self.CurTab == 1 then
            surface.SetDrawColor(GPS.Config.LineColor)
            local x1,x2 = self:GetWide()*.34, self:GetWide()*.656
            surface.DrawLine(x1, self:GetTall()*.2, x1, self:GetTall()*.99)
            surface.DrawLine(x2, self:GetTall()*.2, x2, self:GetTall()*.99)
        end
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
            frame.adminPanel:Hide()
        end

        if newTab == 0 then
            self.itemShop:Show()
            self.catSelect:Show()
        elseif newTab == 1 then
            self.loadoutSelect:Show()
        else 
            if not GPSPlyData.isadmin then return end
            frame.adminPanel:Show()
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
    if GPSPlyData.isadmin then
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
    end
    function frame.tabSelect:UpdateColors()
        local curtab = frame.CurTab + 1
        self[curtab]:SetTextColor(GPS.Config.LabelColorS)
        if curtab == 1 then
            self[2]:SetTextColor(GPS.Config.LabelColor)
            if GPSPlyData.isadmin then self[3]:SetTextColor(GPS.Config.LabelColor) end
        elseif curtab == 2 then
            self[1]:SetTextColor(GPS.Config.LabelColor)
            if GPSPlyData.isadmin then self[3]:SetTextColor(GPS.Config.LabelColor) end
        else
            self[1]:SetTextColor(GPS.Config.LabelColor)
            self[2]:SetTextColor(GPS.Config.LabelColor)
        end
    end

    --* ADMIN PANEL CODE STARTS

    frame.adminPanel = {}

    function frame.adminPanel:SendData()
        if not self.nameEntry:GetValue() or string.Trim(self.nameEntry:GetValue()) == '' then return end
        local temptable = {}
        temptable.Class = self.nameEntry:GetValue()
        temptable.Print = self.printEntry:GetValue() or temptable.Class
        temptable.Price = self.priceEntry:GetValue()
        temptable.Category = self.categoryEntry:GetValue()
        temptable.Model = self.modelEntry:GetValue()
        temptable.Group = self.groupSelect:GetOptionData()
        temptable.Teams = self.teamSelect.temptable
        PrintTable(temptable)
    end
    local leftMar, spacer, topMar = frame:GetWide()*.02, frame:GetWide()*.014, frame:GetTall()*.22
    local panelWide, panelTall = frame:GetWide() - leftMar*2, frame:GetTall()*.08
    --[[
    frame.adminPanel.addText = vgui.Create("DLabel", frame)
    frame.adminPanel.addText:SetText("Add New")
    frame.adminPanel.addText:SetFont("GPS::MenuFont")
    frame.adminPanel.addText:SizeToContents()
    frame.adminPanel.addText:SetPos(frame:GetWide()*.08 ,frame:GetTall()*.2)
    ]]
    frame.adminPanel.nameEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.nameEntry:SetPos(leftMar, topMar )
    frame.adminPanel.nameEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.nameEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.nameEntry:SetPlaceholderText("Weapon classname here")
    frame.adminPanel.nameEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.nameEntry:SetPaintBackground(false)
    frame.adminPanel.nameEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.nameEntry.OnEnter = function(self,value)
        frame.adminPanel.printEntry:Clear()
        frame.adminPanel.priceEntry:Clear()
        frame.adminPanel.categoryEntry:Clear()
        frame.adminPanel.modelEntry:Clear()
        if frame.adminPanel.groupSelect:GetSelected() then frame.adminPanel.groupSelect:SetValue( "Pick a group" ) end

        if GPS.ItemsByName[value] then
            frame.adminPanel.selected = GPS.ItemsByName[value]
        else
            for n,tbl in pairs(weapons.GetList()) do
                if tbl.ClassName == frame.adminPanel.nameEntry:GetValue() then
                    frame.adminPanel.modelEntry:SetText(tbl.WorldModel or '')
                    frame.adminPanel.printEntry:SetText(tbl.PrintName or '')
                    break
                end
            end
        end
    end

    frame.adminPanel.printEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.printEntry:SetPos(leftMar,topMar + (panelTall + spacer))
    frame.adminPanel.printEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.printEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.printEntry:SetPlaceholderText("Weapon printname here")
    frame.adminPanel.printEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.printEntry:SetPaintBackground(false)
    frame.adminPanel.printEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.printEntry.OnGetFocus = function(self)
        if frame.adminPanel.selected then 
            self:SetValue( GPS.ClItems[frame.adminPanel.selected].PrintName )
        end
    end
    
    frame.adminPanel.priceEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.priceEntry:SetPos(leftMar,topMar + (panelTall + spacer)*2)
    frame.adminPanel.priceEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.priceEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.priceEntry:SetPlaceholderText("Weapon price here")
    frame.adminPanel.priceEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.priceEntry:SetPaintBackground(false)
    frame.adminPanel.priceEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.priceEntry.OnGetFocus = function(self)
        if frame.adminPanel.selected then 
            self:SetValue( GPS.ClItems[frame.adminPanel.selected].Price )
        end
    end

    frame.adminPanel.categoryEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.categoryEntry:SetPos(leftMar,topMar + (panelTall + spacer)*3)
    frame.adminPanel.categoryEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.categoryEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.categoryEntry:SetPlaceholderText("Weapon category here")
    frame.adminPanel.categoryEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.categoryEntry:SetPaintBackground(false)
    frame.adminPanel.categoryEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.categoryEntry.OnGetFocus = function(self)
        if frame.adminPanel.selected then 
            self:SetValue( GPS.ClItems[frame.adminPanel.selected].Category )
        end
    end

    frame.adminPanel.modelEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.modelEntry:SetPos(leftMar,topMar + (panelTall + spacer)*4)
    frame.adminPanel.modelEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.modelEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.modelEntry:SetPlaceholderText("Weapon model here")
    frame.adminPanel.modelEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.modelEntry:SetPaintBackground(false)
    frame.adminPanel.modelEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.modelEntry.OnGetFocus = function(self)
        if frame.adminPanel.selected then 
            self:SetValue( GPS.ClItems[frame.adminPanel.selected].Model )
        end
    end

    frame.adminPanel.groupSelect = vgui.Create("DComboBox", frame)
    frame.adminPanel.groupSelect:SetPos(leftMar,topMar + (panelTall + spacer)*5)
    frame.adminPanel.groupSelect:SetSize( panelWide/2, panelTall)
    frame.adminPanel.groupSelect:SetSortItems(false)
    frame.adminPanel.groupSelect:SetFont("GPS::MenuFont")
    frame.adminPanel.groupSelect:SetValue( "Pick a group" )
    frame.adminPanel.groupSelect:AddChoice( "Primaries",1 )
    frame.adminPanel.groupSelect:AddChoice( "Secondaries",2 )
    frame.adminPanel.groupSelect:AddChoice( "Misc.",3 )
    frame.adminPanel.groupSelect.OnMenuOpened = function( self, pnl )
        if frame.adminPanel.selected then
            self:ChooseOptionID(GPS.ClItems[frame.adminPanel.selected].Group)
        end
    end

    frame.adminPanel.teamSelect = vgui.Create("DButton", frame)
    frame.adminPanel.teamSelect:SetPos(leftMar, topMar + (panelTall + spacer)*6)
    frame.adminPanel.teamSelect:SetSize(frame:GetWide()*.2,frame:GetTall()*.06)
    frame.adminPanel.teamSelect:SetFont("GPS::MenuFont")
    frame.adminPanel.teamSelect:SetText("Manage Teams")
    frame.adminPanel.teamSelect:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.teamSelect:SetPaintBackground(false)
    frame.adminPanel.teamSelect.Paint = function (self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, GPS.Config.ButtonColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.teamSelect.DoClick = function(self) 
        if not frame.adminPanel.nameEntry:GetValue() or frame.adminPanel.nameEntry:GetValue() == '' then return end
    local allSelected
        if frame.adminPanel.selected then 
            self.temptable = GPS.ClItems[frame.adminPanel.selected].Teams
            if not self.temptable then 
                allSelected = true
            end
        else
            self.temptable = self.temptable or {}
        end

        local TeamsMenu = DermaMenu()
        for k,_ in pairs( team.GetAllTeams() ) do
            if allSelected then self.temptable[ k ] = true end
            local option = TeamsMenu:AddOption(team.GetName(k), function()
                if self.temptable[ k ] then self.temptable[ k ] = nil
                else self.temptable[ k ] = true end
            end)
            if self.temptable[ k ] then
                option:SetIcon("icon16/tick.png")
            end
        end
        TeamsMenu:Open()
    end

    frame.adminPanel.submitButton = vgui.Create("DButton",frame)
    frame.adminPanel.submitButton:SetSize(frame:GetWide()*.25, frame:GetTall()*.06)
    frame.adminPanel.submitButton:SetPos(frame:GetWide() - leftMar - frame.adminPanel.submitButton:GetWide(), topMar + (panelTall + spacer)*6)
    frame.adminPanel.submitButton:SetFont("GPS::MenuFont")
    frame.adminPanel.submitButton:SetText("Submit item changes")
    frame.adminPanel.submitButton:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.submitButton.Paint = function (self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, GPS.Config.ButtonColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.submitButton.DoClick = function()
        frame.adminPanel:SendData()
    end

    function frame.adminPanel:Hide()
        --self.addText:Hide()
        self.nameEntry:Hide()
        self.printEntry:Hide()
        self.priceEntry:Hide()
        self.categoryEntry:Hide()
        self.modelEntry:Hide()
        self.groupSelect:Hide()
        self.teamSelect:Hide()
        self.submitButton:Hide()
    end

    function frame.adminPanel:Show()
        --self.addText:Show()
        self.nameEntry:Show()
        self.printEntry:Show()
        self.priceEntry:Show()
        self.categoryEntry:Show()
        self.modelEntry:Show()
        self.groupSelect:Show()
        self.teamSelect:Show()
        self.submitButton:Show()
    end

    frame.adminPanel:Hide()

    --* LOADOUT CODE STARTS

    frame.groupLabels = {}
    --ugly AF but it works
    frame.groupLabels[1] = vgui.Create("DLabel", frame)
    frame.groupLabels[2] = vgui.Create("DLabel", frame)
    frame.groupLabels[3] = vgui.Create("DLabel", frame)
    frame.groupLabels[1]:SetFont("DermaLarge")
    frame.groupLabels[2]:SetFont("DermaLarge")
    frame.groupLabels[3]:SetFont("DermaLarge")
    frame.groupLabels[1]:SetText("Primaries")
    frame.groupLabels[2]:SetText("Secondaries")
    frame.groupLabels[3]:SetText("Misc.")
    frame.groupLabels[1]:SizeToContents()
    frame.groupLabels[2]:SizeToContents()
    frame.groupLabels[3]:SizeToContents()
    frame.groupLabels[1]:SetPos(frame:GetWide()/6- frame.groupLabels[1]:GetWide()/2,frame:GetTall()*.2)
    frame.groupLabels[2]:SetPos(frame:GetWide()*.5-frame.groupLabels[2]:GetWide()/2,frame:GetTall()*.2)
    frame.groupLabels[3]:SetPos(frame:GetWide()*(5/6)-frame.groupLabels[3]:GetWide()/2,frame:GetTall()*.2)
    function frame.groupLabels:Show()
        self[1]:Show()
        self[2]:Show()
        self[3]:Show()
    end
    function frame.groupLabels:Hide()
        self[1]:Hide()
        self[2]:Hide()
        self[3]:Hide()
    end
    frame.groupLabels:Hide()

    frame.loadoutSelect = {}
    frame.loadoutSelect[1] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[1]:SetSize(frame:GetWide()/3.5,frame:GetTall()*0.68)
    frame.loadoutSelect[1]:SetPos(frame:GetWide()*0.04,frame:GetTall()*0.3)
    frame.loadoutSelect[1]:Hide()
    --[[
    frame.loadoutSelect[1].Paint = function(self)
        self:DrawOutlinedRect()
    end --]]
    frame.loadoutSelect[2] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[2]:SetSize(frame:GetWide()/3.5,frame:GetTall()*0.68)
    frame.loadoutSelect[2]:SetPos(frame:GetWide()*0.5 - frame.loadoutSelect[2]:GetWide()/2 ,frame:GetTall()*0.3)
    frame.loadoutSelect[2]:Hide()
    --[[
    frame.loadoutSelect[2].Paint = function(self)
        self:DrawOutlinedRect()
    end --]]
    frame.loadoutSelect[3] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[3]:SetSize(frame:GetWide()/3.5,frame:GetTall()*0.68)
    frame.loadoutSelect[3]:SetPos(frame:GetWide()*0.67,frame:GetTall()*0.3)
    frame.loadoutSelect[3]:Hide()
    --[[
    frame.loadoutSelect[3].Paint = function(self)
        self:DrawOutlinedRect()
    end --]]

    function frame.loadoutSelect:Update()
        -- TODO complete this
        frame.loadoutSelect[1]:Clear()
        frame.loadoutSelect[2]:Clear()
        frame.loadoutSelect[3]:Clear()
        for id,tbl in pairs(GPS.ClItems) do
            local curItem = self[tbl.Group]:Add("DPanel")
            curItem:Dock( TOP )
            curItem:SetSize( self[tbl.Group]:GetWide()*0.95,  self[tbl.Group]:GetTall()*0.2)

            function curItem:Paint()
                surface.SetDrawColor( GPS.Config.LineColor )
                self:DrawOutlinedRect()
            end

            curItem.nameLabel = vgui.Create("DLabel", curItem)
            curItem.nameLabel:SetFont("DermaLarge")
            curItem.nameLabel:SetText(tbl.PrintName)
            curItem.nameLabel:SizeToContents()
            curItem.nameLabel:SetPos(curItem:GetWide()*0.5,curItem:GetTall()*0.1)

            curItem.selectBtn = vgui.Create("DLabel", curItem)
            curItem.selectBtn:SetFont("DermaLarge")
            curItem.selectBtn:SetMouseInputEnabled(true)
            curItem.selectBtn:SetText("Sample")
            curItem.selectBtn:SizeToContents()
            curItem.selectBtn:SetPos(curItem:GetWide()*0.5 , curItem:GetTall()*.99 - curItem.selectBtn:GetTall() )
            function curItem.selectBtn:Update()
                if GPS:IsSelected(id) then
                    self:SetText( "Deselect" )
                else
                    self:SetText( "Select" )
                end
            end
            function curItem.selectBtn:DoClick()
                GPS.ClientShopReq(GPS.NET_ENUM.SELECT, {id})
            end

            function curItem.selectBtn:OnCursorEntered()
                self:SetTextColor(GPS.Config.LabelColorH)
            end
            function curItem.selectBtn:OnCursorExited()
                self:Update() -- update after a click, should resolve visual bugs.
                self:SetTextColor(GPS.Config.LabelColor)
            end

            curItem.modelPanel = vgui.Create("DModelPanel", curItem)
            curItem.modelPanel:SetModel( tbl.Model)
            curItem.modelPanel:SetSize(curItem:GetTall()*0.9,curItem:GetTall()*0.9)
            local min,max = curItem.modelPanel.Entity:GetRenderBounds();
			curItem.modelPanel:SetCamPos( min:Distance( max ) * Vector( .55, .55, .25 ) )
			curItem.modelPanel:SetLookAt( ( min + max ) / 2 )
			curItem.modelPanel.LayoutEntity = function() end

            curItem.selectBtn:Update()

        end
    end

    function frame.loadoutSelect:Show()
        self[1]:Show()
        self[2]:Show()
        self[3]:Show()
        self:Update()
        frame.groupLabels:Show()
    end
    function frame.loadoutSelect:Hide()
        self[1]:Hide()
        self[2]:Hide()
        self[3]:Hide()
        frame.groupLabels:Hide()
    end

    --* SHOP CODE STARTS

    frame.itemShop = vgui.Create("DScrollPanel", frame) 
    frame.itemShop:SetPos(frame:GetWide()*0.225,frame:GetTall()*0.22)
    frame.itemShop:SetSize(frame:GetWide()*0.62,frame:GetTall()*0.76)
    function frame.itemShop:Update()
        if table.IsEmpty( GPS.ItemsByCateogry ) then return end
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
    frame:ChangeToTab(2) --todo set back to 0
    frame.tabSelect:UpdateColors()
    -- always default to shop
end

-------------------* net code below

GPS.NET_ENUM = {
    ["WEPTBL"] = 0,
    ["SELECT"] = 1,
    ["BUY"] = 2,
    ["SELL"] = 3,
    ["EDIT"] = 4,
    ["ADD"] = 4,
}

GPS.SEL_NW = {
    [1] = "GPS::SPRIM",
    [2] = "GPS::SSEC",
    [3] = "GPS::SMISC"
}

function GPS:IsSelected(id)
    if not self.ClItems[id] then return end
    if self.SEL_NW[self.ClItems[id].Group] and LocalPlayer():GetNWInt(self.SEL_NW[self.ClItems[id].Group],-1) == self.ClItems[id] then return true end
    return false
end

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
        -- just needs req type
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
    table.Empty( GPS.ItemsByCateogry )
    table.Empty( GPS.ItemsByName )
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
        GPS.ItemsByName[GPS.ClItems[id].ClassName] = id
        GPS.ItemsByCateogry[GPS.ClItems[id].Category][id] = GPS.ClItems[id]
    end
end)
net.Receive("GPS2_OpenMenu", function()
    GPSPlyData.isadmin = net.ReadBool()
    GPSPlyData.isdonator = net.ReadBool()
    GPS:OpenMenu()
end)