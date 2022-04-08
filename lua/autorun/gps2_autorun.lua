GPS = GPS or {}

if SERVER then 
    include("gps2_files/sv_gps2_sql.lua")
    include("gps2_files/sv_gps2.lua")
    AddCSLuaFile("gps2_files/cl_gps2.lua")
    GPS.LoadItemList()
    GPS.SQLInit()
end

if CLIENT then
    surface.CreateFont("GPS::MenuFont", {
        font = "Tahoma", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = math.Clamp(ScrH() * (25/1080),8,255),
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    include("gps2_files/cl_gps2.lua")
end

print("----------------------\n  Giovanni's Pointshop\n    V 2.0 loaded    \n----------------------")