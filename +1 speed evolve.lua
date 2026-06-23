-- made by peliy11 & AI collaborator
-- +1 evolve script game thing
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("RemoteEventService")

local SpeedRemote = SharedModules:WaitForChild("AddSpeedRemoteEvent")
local RebirthRemote = SharedModules:WaitForChild("RebirthRemoteEvent")
local EvolutionRemote = SharedModules:WaitForChild("EvolutionRemoteEvent")

getgenv().MasterAutoFarm = false
getgenv().AutoSpeed = false
getgenv().AutoEvolve = false
getgenv().AutoRebirth = false
getgenv().AutoWins = false 
getgenv().antiafk = true

local function startWinsLoop()
   local LocalPlayer = Players.LocalPlayer
   local WinPad = workspace:WaitForChild("Wins"):WaitForChild("14"):WaitForChild("Touch")
   
   while getgenv().MasterAutoFarm and getgenv().AutoWins do
      local Character = LocalPlayer.Character
      local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
      
      if RootPart and WinPad then
         firetouchinterest(RootPart, WinPad, 0)
         task.wait(0.01)
         firetouchinterest(RootPart, WinPad, 1)
      end
      
      task.wait(0.4)
   end
end

local function startSpeedLoop()
   while getgenv().MasterAutoFarm and getgenv().AutoSpeed do
      SpeedRemote:FireServer()
      task.wait(0.05)
   end
end

local function startEvolveLoop()
   while getgenv().MasterAutoFarm and getgenv().AutoEvolve do
      EvolutionRemote:FireServer({ Action = "Evolve" })
      task.wait(1)
   end
end

local function startRebirthLoop()
   while getgenv().MasterAutoFarm and getgenv().AutoRebirth do
      RebirthRemote:FireServer()
      task.wait(3)
   end
end

task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        if getgenv().antiafk then
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

local Window = Luna:CreateWindow({
    Name = "Apollo Program", 
    Subtitle = "https://discord.gg/U8X5U24u34", 
    LogoID = "82795327169782", 
    LoadingEnabled = true, 
    LoadingTitle = "Apollo Program Loading Engine", 
    LoadingSubtitle = "by Stryx", 
    ConfigSettings = { RootFolder = nil, ConfigFolder = "ApolloProgram" },
    KeySystem = false
})

Window:CreateHomeTab({
    SupportedExecutors = {"Volt", "Delta", "Xeno", "Velocity"},
    DiscordInvite = "U8X5U24u34", 
    Icon = 1
})

local Tab = Window:CreateTab({
    Name = "Auto Farm",
    Icon = "sports_esports",
    ImageSource = "Material",
    ShowTitle = true 
})

local Paragraph  = Tab:CreateParagraph ({
    Title = "Attention please",
    Text = "This script was only to test remote events and working with them some stuff may not work"
})

Tab:CreateSection("Auto Farm")

local Toggle = Tab:CreateToggle({
    Name = "Enable Auto Farm",
    Description = "Enables auto farm",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().MasterAutoFarm = Value
        if Value then
            if getgenv().AutoSpeed then task.spawn(startSpeedLoop) end
            if getgenv().AutoEvolve then task.spawn(startEvolveLoop) end
            if getgenv().AutoRebirth then task.spawn(startRebirthLoop) end
            if getgenv().AutoWins then task.spawn(startWinsLoop) end
        end
    end
}, "Toggle auto farm")

Tab:CreateToggle({
    Name = "Auto Gain Speed",
    Description = "Earn speed automatically",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoSpeed = Value
        if Value and getgenv().MasterAutoFarm then
            task.spawn(startSpeedLoop)
        end
    end
}, "Toggle auto speed")

Tab:CreateToggle({
    Name = "Auto Evolve",
    Description = "Evolve automatically",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoEvolve = Value
        if Value and getgenv().MasterAutoFarm then
            task.spawn(startEvolveLoop)
        end
    end
}, "Toggle auto evolve")

Tab:CreateToggle({
    Name = "Auto Rebirth",
    Description = "Rebirth automatically",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoRebirth = Value
        if Value and getgenv().MasterAutoFarm then
            task.spawn(startRebirthLoop)
        end
    end
}, "Toggle auto rebirth")

Tab:CreateToggle({
    Name = "Auto Claim Wins Pad",
    Description = "Instantly claims the final wins",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoWins = Value
        if Value and getgenv().MasterAutoFarm then
            task.spawn(startWinsLoop)
        end
    end
}, "Toggle auto wins")

local UtilityTab = Window:CreateTab({
    Name        = "Utilities",
    Icon        = "build",
    ImageSource = "Material",
    ShowTitle   = true,
})

UtilityTab:CreateToggle({
    Name         = "Disable 3D Rendering",
    Description  = "Lowers CPU/GPU overhead drastically",
    CurrentValue = false,
    Callback     = function(Value)
        RunService:Set3dRenderingEnabled(not Value)
    end,
}, "DisableRendering")

UtilityTab:CreateToggle({
    Name         = "Anti AFK",
    Description  = "Prevents idle kicks from Roblox client servers",
    CurrentValue = true,
    Callback     = function(Value)
        getgenv().antiafk = Value
    end,
}, "AntiAFK")

local ThemeTab = Window:CreateTab({
    Name        = "Theme Tab",
    Icon        = "palette",
    ImageSource = "Material",
    ShowTitle   = true,
})
ThemeTab:BuildThemeSection()

local ConfigTab = Window:CreateTab({
    Name        = "Config Tab",
    Icon        = "settings",
    ImageSource = "Material",
    ShowTitle   = true,
})
ConfigTab:BuildConfigSection()

print("Script Loaded Successfully")
