GPS.ClItems = {}
GPS.WepCategories = {}
GPS.ItemsByCateogry = {}
GPS.ItemsByName = {}
local GPSPlyData = {}

GPS.Config = {
    ["LabelColor"] = Color(255, 255, 255),
    ["LabelColorH"] = Color(151, 151, 151),
    ["LabelColorS"] = Color(51, 146, 255),
    ["LabelColorSH"] = Color(88, 145, 209),
    ["BackgroundColor"] = Color(37,37,37,245),
    ["LineColor"] = Color(197, 197, 197),
    ["ButtonColor"] = Color(25, 93, 130),
    ["SelWepColor"] = Color(227, 34, 34),
    ["SelWepColoH"] = Color(212, 59, 59),
    ["DeleteColor"] = Color( 216,12,12),
    ["CloseBtnColor"] = Color(255, 255, 255),
    ["ButtonBackground"] = Color(41,40,40,252),
    ["blurmat"] = Material( "pp/blurscreen" )
}

---[[ testing blur, why do the examples suck so much?? 
-- completed 
local function drawPanelBlur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen( 0, 0 )

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( GPS.Config.blurmat )

    GPS.Config.blurmat:SetFloat( "$blur", layers * density )
    GPS.Config.blurmat:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
end
--]]

--[[
local button_drawfunc = function(self,w,h)
    --self:DrawOutlinedRect()
    draw.RoundedBox(4,0,0,w,h, GPS.Config.ButtonBackground )
end--]]

function GPS:OpenMenu()
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
            surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.11, self:GetWide() * 0.2 , self:GetTall() * 0.98)
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
        drawPanelBlur(self,4,10,255)

        draw.RoundedBox(4, 0, 0, w, h, GPS.Config.BackgroundColor)
        surface.SetDrawColor( GPS.Config.LineColor )

        surface.DrawLine(self:GetWide() * .02 , self:GetTall() * .115, self:GetWide() * .98 , self:GetTall() * .115)
        surface.DrawLine(self:GetWide() * .2 , self:GetTall() * .04, self:GetWide()*.2 , self:GetTall() * .115)
        draw.SimpleText("Points : " .. LocalPlayer():GetNWInt("GPS2_Points"), "GPS::MenuFont", self:GetWide()*.025 , self:GetTall()*.05, GPS.Config.LabelColor)
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
    frame.closeBtn:SetColor( GPS.Config.CloseBtnColor )
    frame.closeBtn:SizeToContents()
    frame.closeBtn:SetSize( frame.closeBtn:GetWide()*0.4, frame.closeBtn:GetTall()*0.4 )
    frame.closeBtn:SetPos( frame:GetWide() - frame.closeBtn:GetWide()*1.4, frame:GetTall()*0.02 )
    
    frame.tabSelect = {}

    frame.tabSelect[1] = vgui.Create("DLabel", frame)
    frame.tabSelect[1]:SetFont("GPS::DermaLarge")
    frame.tabSelect[1]:SetText("Shop")
    frame.tabSelect[1]:SizeToContents()
    frame.tabSelect[1]:SetPos(frame:GetWide()*0.26 - frame.tabSelect[1]:GetWide()/2 ,frame:GetTall()*0.05)
    frame.tabSelect[1]:SetMouseInputEnabled(true)
    --frame.tabSelect[1].Paint = button_drawfunc
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
    frame.tabSelect[2]:SetFont("GPS::DermaLarge")
    frame.tabSelect[2]:SetText("Loadout")
    frame.tabSelect[2]:SizeToContents()
    frame.tabSelect[2]:SetPos(frame:GetWide()*0.40 - frame.tabSelect[2]:GetWide()/2,frame:GetTall()*0.05)
    frame.tabSelect[2]:SetMouseInputEnabled(true)
    --frame.tabSelect[2].Paint = button_drawfunc
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
        frame.tabSelect[3]:SetFont("GPS::DermaLarge")
        frame.tabSelect[3]:SetText("Admin")
        frame.tabSelect[3]:SizeToContents()
        frame.tabSelect[3]:SetPos(frame:GetWide()*0.55 - frame.tabSelect[3]:GetWide()/2,frame:GetTall()*0.05)
        frame.tabSelect[3]:SetMouseInputEnabled(true)
        --frame.tabSelect[3].Paint = button_drawfunc
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
        if not self.nameEntry:GetValue() 
        or string.Trim(self.nameEntry:GetValue()) == '' 
        or not self.groupSelect:GetOptionData( self.groupSelect:GetSelectedID() ) 
        or not self.categoryEntry:GetValue() 
        then return end

        print("GPS2 : FETCHING NEW WEAPON INFO ...")
        local temptable = {}
        temptable.Class = self.nameEntry:GetValue()
        temptable.Print = self.printEntry:GetValue() or temptable.Class
        temptable.Price = self.priceEntry:GetValue() or 0
        temptable.Category = self.categoryEntry:GetValue()
        temptable.Model = self.modelEntry:GetValue() or ''
        temptable.Group = self.groupSelect:GetOptionData( self.groupSelect:GetSelectedID() )
        temptable.Teams = self.teamSelect.temptable
        if self.wepSelect:IsVisible() then 
            temptable.id = self.wepSelect:GetOptionData( self.wepSelect:GetSelectedID() )
        end
        PrintTable(temptable)
        print("GPS2 : WEAPON INFO FETCHED")

        if frame.adminPanel.teamSelect then frame.adminPanel.teamSelect.temptable = {} end
        frame.adminPanel.nameEntry:SetText('')
        frame.adminPanel.printEntry:SetText('')
        frame.adminPanel.priceEntry:SetText('')
        frame.adminPanel.categoryEntry:SetText('')
        frame.adminPanel.modelEntry:SetText('')
        frame.adminPanel.groupSelect:SetValue( "Pick a group" )
        frame.adminPanel.teamSelect.temptable = nil
        print("GPS2 : SENDING NEW WEAPON INFO TO SERVER ...")
        if self.wepSelect:IsVisible() then
            GPS.ClientShopReq(GPS.NET_ENUM.EDIT, temptable)
        else
            GPS.ClientShopReq(GPS.NET_ENUM.ADD , temptable)
        end
        print("GPS2 : SENT NEW WEAPON INFO TO SERVER")
    end

    function frame.adminPanel:DeleteItem()
        if not self.wepSelect:IsVisible() then 
            return
        end
        local item = self.wepSelect:GetOptionData( self.wepSelect:GetSelectedID() )
        GPS.ClientShopReq(GPS.NET_ENUM.EDIT, { ['id'] = item })
        timer.Simple(0, function() GPS.ClientShopReq( GPS.NET_ENUM.WEPTBL ) end)
    end

    local leftMar, spacer, topMar = frame:GetWide()*.02, frame:GetWide()*.014, frame:GetTall()*.22
    local panelWide, panelTall = frame:GetWide() - leftMar*2, frame:GetTall()*.08
    
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
        if frame.adminPanel.teamSelect then frame.adminPanel.teamSelect.temptable = {} end
        frame.adminPanel.printEntry:SetText('')
        frame.adminPanel.priceEntry:SetText('')
        frame.adminPanel.categoryEntry:SetText('')
        frame.adminPanel.modelEntry:SetText('')
        frame.adminPanel.groupSelect:SetValue( "Pick a group" )
       
        for _,tbl in pairs(weapons.GetList()) do
            if tbl.ClassName == frame.adminPanel.nameEntry:GetValue() then
                frame.adminPanel.modelEntry:SetText(tbl.WorldModel or '')
                frame.adminPanel.printEntry:SetText(tbl.PrintName or '')
                return
            end
        end
        
    end

    frame.adminPanel.wepSelect = vgui.Create("DComboBox", frame)
    frame.adminPanel.wepSelect:SetPos(leftMar, topMar )
    frame.adminPanel.wepSelect:SetSize( panelWide, panelTall)
    frame.adminPanel.wepSelect:SetFont("GPS::MenuFont")
    frame.adminPanel.wepSelect:Hide()

    local wepsel_oldclear = frame.adminPanel.wepSelect.Clear
    frame.adminPanel.wepSelect.Clear = function(self)
        wepsel_oldclear(self)
        frame.adminPanel.nameEntry:SetValue('')
        if frame.adminPanel.teamSelect then frame.adminPanel.teamSelect.temptable = {} end
        frame.adminPanel.printEntry:SetText('')
        frame.adminPanel.priceEntry:SetText('')
        frame.adminPanel.categoryEntry:SetText('')
        frame.adminPanel.modelEntry:SetText('')
        frame.adminPanel.groupSelect:SetValue( "Pick a group" )
        frame.adminPanel.teamSelect.temptable = nil
    end

    frame.adminPanel.wepSelect.OnSelect = function(self,ind,val,dat)
        frame.adminPanel.nameEntry:SetValue(val)
        if frame.adminPanel.teamSelect then frame.adminPanel.teamSelect.temptable = {} end
        frame.adminPanel.printEntry:SetText('')
        frame.adminPanel.priceEntry:SetText('')
        frame.adminPanel.categoryEntry:SetText('')
        frame.adminPanel.modelEntry:SetText('')
        frame.adminPanel.groupSelect:SetValue( "Pick a group" )

        frame.adminPanel.groupSelect:ChooseOptionID(GPS.ClItems[dat].Group)
        frame.adminPanel.priceEntry:SetValue( GPS.ClItems[dat].Price )
        frame.adminPanel.printEntry:SetValue( GPS.ClItems[dat].PrintName )
        frame.adminPanel.categoryEntry:SetValue( GPS.ClItems[dat].Category )
        frame.adminPanel.modelEntry:SetValue( GPS.ClItems[dat].Model )
        frame.adminPanel.teamSelect.temptable = GPS.ClItems[dat].Teams
        frame.adminPanel.deleteButton:Show()
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
    
    frame.adminPanel.priceEntry = vgui.Create("DTextEntry", frame)
    frame.adminPanel.priceEntry:SetPos(leftMar,topMar + (panelTall + spacer)*2)
    frame.adminPanel.priceEntry:SetSize( panelWide, panelTall)
    frame.adminPanel.priceEntry:SetFont("GPS::MenuFont")
    frame.adminPanel.priceEntry:SetPlaceholderText("Weapon price here")
    frame.adminPanel.priceEntry:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.priceEntry:SetUpdateOnType( true )
    frame.adminPanel.priceEntry:SetPaintBackground(false)
    frame.adminPanel.priceEntry.PaintOver = function(self, w,h)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.priceEntry.OnValueChange = function(self,val)
        val = tostring(val)
        local strlen = string.len(val or '')
        if strlen < 1 then return end

        if not tonumber(val[strlen]) then self:SetText(string.sub(val,0,strlen-1)) return end

        if not tonumber(val) or tonumber(val) < 0 then self:SetText('') return end

        -- max nett-able value
        if tonumber(val) > 4294967295 then self:SetText('4294967294') return end
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

    frame.adminPanel.groupSelect = vgui.Create("DComboBox", frame)
    frame.adminPanel.groupSelect:SetPos(leftMar,topMar + (panelTall + spacer)*5)
    frame.adminPanel.groupSelect:SetSize( frame:GetWide()*.2, panelTall)
    frame.adminPanel.groupSelect:SetSortItems(false)
    frame.adminPanel.groupSelect:SetFont("GPS::MenuFont")
    frame.adminPanel.groupSelect:SetValue( "Pick a group" )
    frame.adminPanel.groupSelect:AddChoice( "Primaries",1 )
    frame.adminPanel.groupSelect:AddChoice( "Secondaries",2 )
    frame.adminPanel.groupSelect:AddChoice( "Misc.",3 )

    frame.adminPanel.teamSelect = vgui.Create("DButton", frame)
    frame.adminPanel.teamSelect:SetPos(leftMar, topMar + (panelTall + spacer)*6)
    frame.adminPanel.teamSelect:SetSize(frame:GetWide()*.2,panelTall)
    frame.adminPanel.teamSelect:SetFont("GPS::MenuFont")
    frame.adminPanel.teamSelect:SetText("Manage Teams")
    frame.adminPanel.teamSelect:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.teamSelect:SetPaintBackground(false)
    frame.adminPanel.teamSelect.temptable = nil
    frame.adminPanel.teamSelect.Paint = function (self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, GPS.Config.ButtonColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.teamSelect.DoClick = function(self) 
        if not frame.adminPanel.nameEntry:GetValue() or frame.adminPanel.nameEntry:GetValue() == '' then return end
        
        local allSelected = false
        local curWep = GPS.ItemsByName[ frame.adminPanel.nameEntry:GetValue() ]

        if (GPS.ClItems[ curWep ] and not GPS.ClItems[ curWep ].Teams) and not self.temptable then
            allSelected = true
            self.temptable = {}
            for k,_ in pairs( team.GetAllTeams() ) do
                self.temptable[k] = true 
            end
        end


        local TeamsMenu = DermaMenu()
        --PrintTable(self.temptable)
        for k,_ in pairs( team.GetAllTeams() ) do
            
           
            --print(k,self.temptable[ k ])

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
    frame.adminPanel.submitButton:SetSize(frame:GetWide()*.25, panelTall)
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
        timer.Simple(0, function() GPS.ClientShopReq( GPS.NET_ENUM.WEPTBL ) end)
    end

    frame.adminPanel.editButton = vgui.Create("DButton",frame)
    frame.adminPanel.editButton:SetSize(frame:GetWide()*.25, panelTall)
    frame.adminPanel.editButton:SetPos(frame:GetWide() - leftMar - frame.adminPanel.submitButton:GetWide(), topMar + (panelTall + spacer)*5)
    frame.adminPanel.editButton:SetFont("GPS::MenuFont")
    frame.adminPanel.editButton:SetText("Edit Existing item")
    frame.adminPanel.editButton:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.editButton.Paint = function (self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, GPS.Config.ButtonColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.editButton.DoClick = function()
        if self.editing then
            frame.adminPanel.wepSelect:Hide()
            frame.adminPanel.nameEntry:Show()
            frame.adminPanel.wepSelect:Clear()
            frame.adminPanel.deleteButton:Hide()
            
        else
            frame.adminPanel.nameEntry:Hide()
            frame.adminPanel.wepSelect:SetValue("Select Item to edit")
            for id,tbl in pairs(GPS.ClItems) do
                frame.adminPanel.wepSelect:AddChoice(tbl.ClassName,id)
            end
            frame.adminPanel.wepSelect:Show()
            
        end
        self.editing = not self.editing
    end
    
    frame.adminPanel.deleteButton = vgui.Create("DButton",frame)
    frame.adminPanel.deleteButton:SetSize(frame:GetWide()*.25, panelTall)
    frame.adminPanel.deleteButton:SetPos(frame:GetWide() - leftMar - frame.adminPanel.submitButton:GetWide()*2.05, topMar + (panelTall + spacer)*6)
    frame.adminPanel.deleteButton:SetFont("GPS::MenuFont")
    frame.adminPanel.deleteButton:SetText("Delete item")
    frame.adminPanel.deleteButton:SetTextColor( GPS.Config.LabelColor )
    frame.adminPanel.deleteButton.Paint = function (self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, GPS.Config.DeleteColor)
        surface.SetDrawColor( GPS.Config.LineColor )
        self:DrawOutlinedRect()
    end
    frame.adminPanel.deleteButton.DoClick = function()
        frame.adminPanel:DeleteItem()

        frame.adminPanel.teamSelect.temptable = nil
        frame.adminPanel.wepSelect:Hide()
        frame.adminPanel.wepSelect:Clear()
        frame.adminPanel.nameEntry:Show()
        frame.adminPanel.nameEntry:SetText('')
        frame.adminPanel.printEntry:SetText('')
        frame.adminPanel.priceEntry:SetText('')
        frame.adminPanel.categoryEntry:SetText('')
        frame.adminPanel.modelEntry:SetText('')
        frame.adminPanel.groupSelect:SetValue( "Pick a group" )
        
    end

    function frame.adminPanel:Hide()
        self.nameEntry:Hide()
        self.printEntry:Hide()
        self.priceEntry:Hide()
        self.categoryEntry:Hide()
        self.modelEntry:Hide()
        self.groupSelect:Hide()
        self.teamSelect:Hide()
        self.submitButton:Hide()
        self.editButton:Hide()
        self.wepSelect:Hide()
        self.deleteButton:Hide()
    end

    function frame.adminPanel:Show()
        self.nameEntry:Show()
        self.printEntry:Show()
        self.priceEntry:Show()
        self.categoryEntry:Show()
        self.modelEntry:Show()
        self.groupSelect:Show()
        self.teamSelect:Show()
        self.submitButton:Show()
        self.editButton:Show()
        if self.editButton.editing then 
            self.wepSelect:Show()
            self.deleteButton:Show()
        end
    end

    frame.adminPanel:Hide()

    --* LOADOUT CODE STARTS

    frame.groupLabels = {}
    frame.groupLabels[1] = vgui.Create("DLabel", frame)
    frame.groupLabels[2] = vgui.Create("DLabel", frame)
    frame.groupLabels[3] = vgui.Create("DLabel", frame)
    frame.groupLabels[1]:SetFont("GPS::DermaLarge")
    frame.groupLabels[2]:SetFont("GPS::DermaLarge")
    frame.groupLabels[3]:SetFont("GPS::DermaLarge")
    frame.groupLabels[1]:SetText("Primaries")
    frame.groupLabels[2]:SetText("Secondaries")
    frame.groupLabels[3]:SetText("Misc.")
    frame.groupLabels[1]:SizeToContents()
    frame.groupLabels[2]:SizeToContents()
    frame.groupLabels[3]:SizeToContents()
    frame.groupLabels[1]:SetPos(frame:GetWide()/6- frame.groupLabels[1]:GetWide()/2,frame:GetTall()*.13)
    frame.groupLabels[2]:SetPos(frame:GetWide()*.5-frame.groupLabels[2]:GetWide()/2,frame:GetTall()*.13)
    frame.groupLabels[3]:SetPos(frame:GetWide()*(5/6)-frame.groupLabels[3]:GetWide()/2,frame:GetTall()*.13)
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
    frame.loadoutSelect[1]:SetPos(frame:GetWide()*0.04,frame:GetTall()*0.18)
    frame.loadoutSelect[1]:Hide()
    frame.loadoutSelect[1].VBar.Paint = function(self,w,h) end
    frame.loadoutSelect[1].VBar:SetHideButtons( true )
    frame.loadoutSelect[1].VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox( 4, 0, 0, w, h, GPS.Config.LineColor )
    end

    frame.loadoutSelect[2] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[2]:SetSize(frame:GetWide()/3.5,frame:GetTall()*0.68)
    frame.loadoutSelect[2]:SetPos(frame:GetWide()*0.5 - frame.loadoutSelect[2]:GetWide()/2 ,frame:GetTall()*0.18)
    frame.loadoutSelect[2]:Hide()
    frame.loadoutSelect[2].VBar.Paint = function(self,w,h) end
    frame.loadoutSelect[2].VBar:SetHideButtons( true )
    frame.loadoutSelect[2].VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox( 4, 0, 0, w, h, GPS.Config.LineColor )
    end

    frame.loadoutSelect[3] = vgui.Create("DScrollPanel", frame)
    frame.loadoutSelect[3]:SetSize(frame:GetWide()/3.5,frame:GetTall()*0.68)
    frame.loadoutSelect[3]:SetPos(frame:GetWide()*0.67,frame:GetTall()*0.18)
    frame.loadoutSelect[3]:Hide()
    frame.loadoutSelect[3].VBar.Paint = function(self,w,h) end
    frame.loadoutSelect[3].VBar:SetHideButtons( true )
    frame.loadoutSelect[3].VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox( 4, 0, 0, w, h, GPS.Config.LineColor )
    end

    function frame.loadoutSelect:Update()
        frame.loadoutSelect[1]:Clear()
        frame.loadoutSelect[2]:Clear()
        frame.loadoutSelect[3]:Clear()
        for id,tbl in pairs(GPS.ClItems) do
            if (not GPSPlyData.isdonator and not tbl.Owned) or (GPSPlyData.isadmin and not tbl.Visible) then continue end 
            local curItem = self[tbl.Group]:Add("DPanel")
            curItem:SetSize( self[tbl.Group]:GetWide()*0.95, self[tbl.Group]:GetTall()*0.2)
            curItem:Dock( TOP )
            curItem:DockMargin(0,curItem:GetTall()*.1,0,0)

            if GPS:IsSelected(id) then
                self[tbl.Group]:ScrollToChild(curItem)
            end

            function curItem:Paint()
                surface.SetDrawColor( GPS.Config.LineColor )
                self:DrawOutlinedRect()
            end

            curItem.nameLabel = vgui.Create("DLabel", curItem)
            curItem.nameLabel:SetFont("GPS::DermaLarge")
            curItem.nameLabel:SetText(tbl.PrintName)
            curItem.nameLabel:SizeToContents()
            curItem.nameLabel:SetPos(curItem:GetTall(),curItem:GetTall()*0.1)

            curItem.selectBtn = vgui.Create("DLabel", curItem)
            curItem.selectBtn:SetFont("GPS::DermaLarge")
            curItem.selectBtn:SetMouseInputEnabled(true)
            curItem.selectBtn:SetText("Sample")
            curItem.selectBtn:SizeToContents()
            curItem.selectBtn:SetPos(curItem:GetTall() , curItem:GetTall()*.99 - curItem.selectBtn:GetTall() )
            function curItem:SelectThis()
                local par = self:GetParent()
                local oldItem = par.selected
                if par.selected == self then par.selected = nil; self.selectBtn:Update() return end
                if oldItem and oldItem:IsValid() then oldItem.selected = false; oldItem.selectBtn:Update() end
                self.selected = true
                par.selected = self
                self.selectBtn:Update()
            end
            function curItem.selectBtn:Update()
                if GPS:IsSelected(id) then
                    self:SetText( "Deselect" )
                    self:SizeToContents()
                    self:SetTextColor(GPS.Config.SelWepColor)
                else
                    self:SetText( "Select" )
                    self:SizeToContents()
                    self:SetTextColor(GPS.Config.LabelColor)
                end
            end
            function curItem.selectBtn:DoClick()
                GPS.ClientShopReq(GPS.NET_ENUM.SELECT, {id})
                timer.Simple(0.3, function() curItem:SelectThis() end)
            end
            function curItem.selectBtn:OnCursorEntered()
                if self:GetText() == 'Select' then self:SetTextColor(GPS.Config.LabelColorH)
                else self:SetTextColor(GPS.Config.SelWepColorH) end
            end
            function curItem.selectBtn:OnCursorExited()
                --self:Update() -- update after a click, should resolve visual bugs. GPS.Config.SelWepColor
                if self:GetText() == 'Select' then self:SetTextColor(GPS.Config.LabelColor)
                else self:SetTextColor(GPS.Config.SelWepColor) end
            end
            curItem.modelPanel = vgui.Create("DModelPanel", curItem)
            curItem.modelPanel:SetModel( tbl.Model)
            curItem.modelPanel:SetSize(curItem:GetTall()*0.9,curItem:GetTall()*0.9)
            local min,max = curItem.modelPanel.Entity:GetRenderBounds();
			curItem.modelPanel:SetCamPos( min:Distance( max ) * Vector( .55, .55, .25 ) )
			curItem.modelPanel:SetLookAt( ( min + max ) / 2 )
			curItem.modelPanel.LayoutEntity = function() end

            if GPS:IsSelected(id) and not curItem:GetParent().selected then curItem.selected = true; curItem:GetParent().selected = curItem end
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
    frame.itemShop:SetPos(frame:GetWide()*0.225,frame:GetTall()*0.12)
    frame.itemShop:SetSize(frame:GetWide()*0.72,frame:GetTall()*0.86)
    frame.itemShop.VBar.Paint = function(self,w,h) end
    frame.itemShop.VBar:SetHideButtons( true )
    frame.itemShop.VBar.btnGrip.Paint = function(self,w,h)
        draw.RoundedBox( 4, 0, 0, w, h, GPS.Config.LineColor )
    end

    function frame.itemShop:Update()
        self:Clear()
        if table.IsEmpty( GPS.ItemsByCateogry ) then return end
        for id,_ in pairs(GPS.ItemsByCateogry[frame.catSelect.GetSelected():GetText()]) do

            if (GPSPlyData.isadmin and not GPS.ClItems[id].Visible) then continue end

            local curItem = self:Add("DPanel")
            curItem:Dock( TOP )
            curItem:SetSize(self:GetWide()*0.85, self:GetTall()*0.3)
            curItem:DockMargin(0,curItem:GetTall()*.1,0,0)


            function curItem:Paint()
                surface.SetDrawColor(92, 92, 92, 255 )
                surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0.65, self:GetWide() , self:GetTall() * 0.65)
                surface.DrawLine(self:GetWide() * 0.2 , self:GetTall() * 0, self:GetWide() * 0.2 , self:GetTall() )
                surface.DrawLine(self:GetWide() * 0.58 , self:GetTall() * 0.65, self:GetWide() * 0.58 , self:GetTall() )
                self:DrawOutlinedRect()
            end

            curItem.nameLabel = vgui.Create("DLabel", curItem)
            curItem.nameLabel:SetFont("GPS::DermaLarge")
            curItem.nameLabel:SetText(GPS.ClItems[id].PrintName)
            curItem.nameLabel:SizeToContents()
            curItem.nameLabel:Dock(TOP)
            curItem.nameLabel:DockMargin(self:GetWide()*0.22, self:GetTall()*0.065, 0, 0)

            curItem.priceLabel = vgui.Create("DLabel", curItem)
            curItem.priceLabel:SetFont("GPS::DermaLarge")
            curItem.priceLabel:SetText( "Price : " .. tostring(GPS.ClItems[id].Price) )
            curItem.priceLabel:SetSize(curItem:GetWide()*0.4,curItem:GetTall()*0.33)
            curItem.priceLabel:SetPos(curItem:GetWide()*0.26 , curItem:GetTall()*0.7 )

            curItem.transactionButton = vgui.Create("DLabel", curItem)
            curItem.transactionButton:SetFont("GPS::DermaLarge")
            curItem.transactionButton:SetSize(curItem:GetWide()*0.4, curItem:GetTall()*0.33)
            curItem.transactionButton:SetPos(curItem:GetWide()*0.7 , curItem:GetTall()*0.7 )
            curItem.transactionButton:SetMouseInputEnabled(true)
            function curItem.transactionButton:Update() 
                if ( GPS.ClItems[id] and GPS.ClItems[id].Owned) then
                    self:SetText( "Sell" )
                else
                    self:SetText( "Buy" )
                end
            end
            function curItem.transactionButton:DoClick()
                if self.clicked then
                    if GPS.ClItems[id].Owned then
                        GPS.ClientShopReq(GPS.NET_ENUM.SELL, {id})
                    else
                        GPS.ClientShopReq(GPS.NET_ENUM.BUY, {id})
                    end
                    GPS.ClientShopReq( GPS.NET_ENUM.WEPTBL )
                    timer.Simple(0.15, function() frame.itemShop:Update() end)
                    self.clicked = false

                else
                    self:SetText("Confirm?")
                    self.clicked = true
                end
            end

            function curItem.transactionButton:DoDoubleClick()
                self.clicked = false
                if GPS.ClItems[id].Owned then
                    GPS.ClientShopReq(GPS.NET_ENUM.SELL, {id})
                else
                    GPS.ClientShopReq(GPS.NET_ENUM.BUY, {id})
                end
                GPS.ClientShopReq( GPS.NET_ENUM.WEPTBL )
                timer.Simple(0.15, function() frame.itemShop:Update() end)
            end
            

            function curItem.transactionButton:OnCursorEntered()
                self:SetTextColor(GPS.Config.LabelColorH)
            end
            function curItem.transactionButton:OnCursorExited()
                self:Update() -- update after a click, should resolve visual bugs.
                self:SetTextColor(GPS.Config.LabelColor)
                self.clicked = false
            end

            curItem.transactionButton:Update()

            curItem.modelPanel = vgui.Create("DModelPanel", curItem)
            curItem.modelPanel:SetModel( GPS.ClItems[id].Model)
            curItem.modelPanel:SetSize(curItem:GetTall()*0.9,curItem:GetTall()*0.9)
            local min,max = curItem.modelPanel.Entity:GetRenderBounds();
			curItem.modelPanel:SetCamPos( min:Distance( max ) * Vector( .55, .55, .25 ) )
			curItem.modelPanel:SetLookAt( ( min + max ) / 2 )
			curItem.modelPanel.LayoutEntity = function() end
        end
    end
    frame.catSelect = vgui.Create("DScrollPanel", frame )
    frame.catSelect:SetPos(frame:GetWide()*0.01,frame:GetTall()*0.12)
    frame.catSelect:SetSize(frame:GetWide()*0.18,frame:GetTall()*0.88)
    function frame.catSelect.GetSelected() return frame.catSelect.selected end
    function frame.catSelect:Update()
        for k, category in ipairs(GPS.WepCategories) do
            -- check if cat is not visible at all
            local skip = true
            for id,_ in pairs(GPS.ItemsByCateogry[category]) do
                if GPS.ClItems[id].Visible then
                    skip = false
                end
            end
            if skip then continue end

            local catButton = self:Add("DLabel")
            catButton:SetText( tostring(category) )
            catButton:Dock( TOP )
            catButton:SetFont("GPS::DermaLarge")
            catButton:SizeToContents()
            catButton:DockMargin(ScrW()*0.01, catButton:GetTall()*.3, 0, ScrH()/216)
            catButton:SetMouseInputEnabled( true )
            catButton.selected = false
            --catButton.Paint = button_drawfunc
            function catButton:SelectThis()
                if frame.catSelect.selected == self then return end
                frame.catSelect.selected.selected = false
                frame.catSelect.selected:ToggleColor()
                frame.catSelect.selected = self
                self.selected = true
                frame.itemShop:Update()
            end
            function catButton:OnCursorEntered()
                if not self.selected then
                self:SetTextColor(GPS.Config.LabelColorSH)
                else
                    self:SetTextColor(GPS.Config.LabelColorH)
                end
            end
            function catButton:OnCursorExited()
                if not self.selected then
                self:SetTextColor(GPS.Config.LabelColor)
                else
                    self:SetTextColor(GPS.Config.LabelColorS)
                end
            end
            function catButton:ToggleColor()
                if not self.selected then
                    self:SetTextColor(GPS.Config.LabelColor)
                else
                    self:SetTextColor(GPS.Config.LabelColorS)
                end
            end
            function catButton:OnDepressed()
                if not self.selected then self:SelectThis() end
                self:ToggleColor()
            end
            if not frame.catSelect.selected then 
                frame.catSelect.selected = catButton
                catButton.selected = true
                catButton:ToggleColor()
            end
        end
    end

    frame.catSelect:Update()
    frame.itemShop:Update()
    frame:ChangeToTab(0)
    frame.tabSelect:UpdateColors()
end

-------------------* net code below

GPS.NET_ENUM = {
    ["WEPTBL"] = 0,
    ["SELECT"] = 1,
    ["BUY"] = 2,
    ["SELL"] = 3,
    ["ADD"] = 4,
    ["EDIT"] = 5,
}

GPS.SEL_NW = {
    [1] = "GPS::SPRIM",
    [2] = "GPS::SSEC",
    [3] = "GPS::SMISC"
}

function GPS:IsSelected(id)
    if not self.ClItems[id] then return end
    return self.SEL_NW[self.ClItems[id].Group] and LocalPlayer():GetNWInt(self.SEL_NW[self.ClItems[id].Group],false) == id
end

function GPS.ClientShopReq(requestType, args)
    --[[
        0 : request wep table update; {}
        1 : select item; {itemID}
        2 : buy item; {itemID}
        3 : sell item; {itemID}
        4 : add item;
        5 : edit item;
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
    elseif requestType == 4 or requestType == 5 then
        -- edit/add items
        if not args.id and requestType == 5 then return end -- dont fuck up
        if not args.Class and requestType == 4 then return end

        net.WriteString(args.Class or 'GPS__DELETE')
        net.WriteString(args.Print or '')
        net.WriteUInt(args.Price or 0, 32)
        net.WriteString(args.Category or '')
        net.WriteString(args.Model or '')
        net.WriteUInt(args.Group or 0, 2)
        local teamCount = 0
        if args.Teams then
            teamCount = table.Count(args.Teams )
        end
        net.WriteUInt(teamCount, 8)
        if teamCount > 0 then 
            for cteam,_ in pairs(args.Teams) do
                net.WriteUInt(cteam, 16)
            end
        end
        if requestType == 5 then net.WriteUInt(args.id, 8) end

    end
    net.SendToServer()
end

net.Receive("GPS2_SendToClient",function(len)
    table.Empty( GPS.WepCategories )
    table.Empty( GPS.ClItems )
    table.Empty( GPS.ItemsByCateogry )
    table.Empty( GPS.ItemsByName )
    --print(len) debugging
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
        GPSPlyData.isadmin = net.ReadBool()
        if GPSPlyData.isadmin then GPS.ClItems[id].Visible = net.ReadBool() end-- just for admin gui, not used in real checks.

        if not table.HasValue(GPS.WepCategories, GPS.ClItems[id].Category) then
            table.insert(GPS.WepCategories, GPS.ClItems[id].Category)
            GPS.ItemsByCateogry[ GPS.ClItems[id].Category ] = {}
        end

        if GPS.ClItems[id].Model == '' then
            GPS.ClItems[id].Model = "models/props_interiors/pot02a.mdl"
        end

        local nTeams = net.ReadUInt(8)
        if nTeams < 1 then goto cont end

        GPS.ClItems[id].Teams = {}

        for j = 1, nTeams do
            GPS.ClItems[id].Teams[net.ReadUInt(16)] = true
        end
        ::cont::
        GPS.ItemsByName[GPS.ClItems[id].ClassName] = id
        GPS.ItemsByCateogry[GPS.ClItems[id].Category][id] = true
    end
end)

net.Receive("GPS2_OpenMenu", function()
    GPSPlyData.isadmin = net.ReadBool()
    GPSPlyData.isdonator = net.ReadBool()
    GPS:OpenMenu()
end)

net.Receive("GPS2_LegacyNotifySv", function()
    local text = net.ReadString()
    local gtype = net.ReadInt(4)
    local lentime = net.ReadInt(8)
    print(text)
    notification.AddLegacy( text, gtype, lentime )
    surface.PlaySound( "buttons/button15.wav" )
end)