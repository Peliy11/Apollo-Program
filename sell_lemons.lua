-- Load Luna UI and Icons
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- ==========================================
-- BACKEND CORE LOGIC & VARIABLES
-- ==========================================
local plr = game:GetService("Players").LocalPlayer

getgenv().farming = false
getgenv().farmsettings = {
    purchase = false,
    upgrade = false,
    collect = false,
    cashdrop = false,
    fruit = false
}
getgenv().antiafk = true

local tycoon
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:find("Tycoon") and v:FindFirstChild("Owner").Value == plr then
        tycoon = v
    end
end

local PurchasesFold = tycoon.Purchases

local suffixes = {
    K   = 1e3,
    M   = 1e6,
    B   = 1e9,
    T   = 1e12,
    Qd  = 1e15,
    Qn  = 1e18,
    Sx  = 1e21,
    Sxd = 1e21,
    Sp  = 1e24,
    Oc  = 1e27,
    No  = 1e30,
    Dc  = 1e33,
}

function decodeValue(str)
    local clean = str:gsub("[\226\128\128-\226\128\143]", "")
    local numStr, suffix = clean:match("%$([%d%,%.]+)(%a*)")
    if not numStr then return nil end

    local num = tonumber((numStr:gsub(",", "")))
    if not num then return nil end
    if suffix == "" then return num end

    local multiplier = suffixes[suffix]
    if not multiplier then
        suffix = suffix:sub(1,1):upper() .. suffix:sub(2):lower()
        multiplier = suffixes[suffix]
    end

    if multiplier then return num * multiplier end
    return num
end

-- Incoming phone deal auto-accept
tycoon.Remotes.PhoneOffer.OnClientEvent:Connect(function()
    if not getgenv().farming then return end
    tycoon.Remotes.PhoneOffer:FireServer("Accept")
end)

-- Anti AFK Implementation
plr.Idled:Connect(function()
    if not getgenv().antiafk then return end
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- The Loop Logic Function
local function startAutofarmLoop()
    local stands = tycoon.Values.Income.Streams
    
    -- Sub-task for collecting money (Parallel loop running when main farm is active)
    task.spawn(function()
        while getgenv().farming do
            if not getgenv().farmsettings.collect then task.wait(1) continue end
            for i, v in pairs(stands:GetChildren()) do
                tycoon.Remotes.WakeIncomeStream:InvokeServer(v.Name)
            end
            task.wait()
        end
    end)

    -- Main farming step actions
    while getgenv().farming do
        -- Step 2. Buy cool stuff
        pcall(function()
            if not getgenv().farmsettings.purchase then return end
            for _, fold in pairs(PurchasesFold:GetChildren()) do
                if fold:FindFirstChild("Buttons") then
                    for i, nFold in pairs(fold.Buttons:GetChildren()) do
                        if nFold:IsA("Folder") then
                            for _,btn in pairs(nFold:GetChildren()) do
                                if btn:GetAttribute("Shown") and btn:GetAttribute("Enabled") and not btn:GetAttribute("Purchased") then
                                    local price = decodeValue(btn.Button.Gui.Price.Text)
                                    local curbalance = decodeValue(plr.leaderstats.Cash.Value)

                                    if price <= curbalance then
                                        firetouchinterest(plr.Character.Head, btn.Button, true)
                                        task.wait()
                                        firetouchinterest(plr.Character.Head, btn.Button, false)
                                    end
                                end
                            end
                        elseif nFold:IsA("Model") then
                            if nFold:GetAttribute("Shown") and nFold:GetAttribute("Enabled") and not nFold:GetAttribute("Purchased") then
                                local price = decodeValue(nFold.Button.Gui.Price.Text)
                                local curbalance = decodeValue(plr.leaderstats.Cash.Value)

                                if price <= curbalance then
                                    firetouchinterest(plr.Character.Head, nFold.Button, true)
                                    task.wait()
                                    firetouchinterest(plr.Character.Head, nFold.Button, false)
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- Step 3. Upgrade everything
        pcall(function()
            if not getgenv().farmsettings.upgrade then return end
            for _, fold in pairs(PurchasesFold:GetChildren()) do
                if fold:FindFirstChild(fold.Name) then
                    if not fold:FindFirstChild(fold.Name):GetAttribute("Enabled") then continue end
                    fold:FindFirstChild(fold.Name):FindFirstChild(fold.Name).Upgrade:InvokeServer(1)
                end
            end
        end)

        -- Step 4. Cash drops
        pcall(function()
            if not getgenv().farmsettings.cashdrop then return end
            for i, v in pairs(workspace.CashDrops:GetChildren()) do
                firetouchinterest(plr.Character.Head, v, true)
                task.wait()
                firetouchinterest(plr.Character.Head, v, false)
            end
        end)

        -- Step 5. Collect fruit
        pcall(function()
            if not getgenv().farmsettings.fruit then return end
            for i, v in pairs(tycoon.Constant.Trees:GetChildren()) do
                for _, lemon in pairs(v:GetChildren()) do
                    if not (lemon.Name == "Fruit") then continue end
                    if not lemon:FindFirstChild("ClickPart") then continue end
                    fireclickdetector(lemon.ClickPart.ClickDetector)
                    task.wait()
                end
            end
        end)

        task.wait(1)
    end
end

-- ==========================================
-- LUNA UI INITIALIZATION
-- ==========================================
local Window = Luna:CreateWindow({
    Name = "Apollo Program", 
    Subtitle = "https://discord.gg/U8X5U24u34", 
    LogoID = "71992521463355", 
    LoadingEnabled = true, 
    LoadingTitle = "Apollo Program Loading", 
    LoadingSubtitle = "by ChefaoBR", 

    ConfigSettings = {
        RootFolder = nil, 
        ConfigFolder = "AP Hub" 
    },

    KeySystem = false, 
    KeySettings = {
        Title = "Apollo key system",
        Subtitle = "Key System",
        Note = "",
        SaveInRoot = false, 
        SaveKey = false, 
        Key = {"1234"},
        SecondAction = {
            Enabled = true,
            Type = "Link", 
            Parameter = ""
        }
    }
})

Window:CreateHomeTab({
    SupportedExecutors = {
    "Volt",
    "Delta",
    "Xeno",
    "Velocity",
},
    DiscordInvite = "U8X5U24u34", 
    Icon = 1
})

local Tab = Window:CreateTab({
    Name = "Auto Farm",
    Icon = "sports_esports",
    ImageSource = "Material",
    ShowTitle = true
})

-- Master Autofarm Toggle
Tab:CreateToggle({
    Name = "Auto Farm",
    Description = "Activate master automated framework",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farming = Value
        if Value then
            task.spawn(startAutofarmLoop)
        end
    end
}, "EnableAutoFarm")

local Label = Tab:CreateLabel({
    Text = "Settings",
    Style = 1 
})

-- Sub settings toggles mapped directly to farmsettings flags
Tab:CreateToggle({
    Name = "Auto Purchase",
    Description = "Automatically steps on unlocked building buttons",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farmsettings.purchase = Value
    end
}, "AutoPurchase")

Tab:CreateToggle({
    Name = "Auto Collect",
    Description = "Claims stand income instantly",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farmsettings.collect = Value
    end
}, "AutoCollect")

Tab:CreateToggle({
    Name = "Auto Upgrade",
    Description = "Invokes upgrade configurations",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farmsettings.upgrade = Value
    end
}, "AutoUpgrade")

Tab:CreateToggle({
    Name = "Auto Cash Drop",
    Description = "Teleports player head to map money pickups",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farmsettings.cashdrop = Value
    end
}, "AutoCashDrop")

Tab:CreateToggle({
    Name = "Auto Fruit",
    Description = "Clicks lemon/tree fruit drops",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().farmsettings.fruit = Value
    end
}, "AutoFruit")

-- Settings & Utilities Tab (replaces CalmLib Section 2)
local UtilityTab = Window:CreateTab({
    Name = "Utilities",
    Icon = "build",
    ImageSource = "Material",
    ShowTitle = true
})

UtilityTab:CreateToggle({
    Name = "Disable 3D Rendering",
    Description = "Lowers CPU/GPU overhead drastically",
    CurrentValue = false,
    Callback = function(Value)
        game:GetService("RunService"):Set3dRenderingEnabled(not Value)
    end
}, "DisableRendering")

UtilityTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents idle kicks from Roblox client servers",
    CurrentValue = true,
    Callback = function(Value)
        getgenv().antiafk = Value
    end
}, "AntiAFK")

-- Themes and Settings
local ThemeTab = Window:CreateTab({
    Name = "Theme Tab",
    Icon = "palette",
    ImageSource = "Material",
    ShowTitle = true
})
ThemeTab:BuildThemeSection()

local ConfigTab = Window:CreateTab({
    Name = "Config Tab",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})
ConfigTab:BuildConfigSection()
