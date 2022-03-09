if SERVER then 

    if GPS then print('You are using an addon which conflicts with GPS2, this may cause issues!') end
    include("gps2_files/sv_gps2_sql.lua")
    include("gps2_files/sv_gps2.lua")
    AddCSLuaFile("gps2_files/cl_gps2.lua")
    GPS.LoadItemList()
    GPS.SQLInit()
end

if CLIENT then
    include("gps2_files/cl_gps2.lua")
end

print("------------------\nGiovanni's Pointshop\n    V 2.0 loaded    \n------------------")