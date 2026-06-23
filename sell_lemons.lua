--- madee by peliy11 on dihcord
-- sell lemons script
-- https://docs.nebulasoftworks.xyz/luna/configuration/windows 
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local plr         = game:GetService("Players").LocalPlayer
local RunService  = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

getgenv().farming       = false
getgenv().autorebirth   = false
getgenv().rebirthTarget = 1e6
getgenv().farmsettings  = {
    purchase = false,
    upgrade  = false,
    collect  = false,
    fruit    = false,
}
getgenv().antiafk = true

local tycoon
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:find("Tycoon") and v:FindFirstChild("Owner") and v:FindFirstChild("Owner").Value == plr then
        tycoon = v
        break
    end
end

local PurchasesFold = tycoon.Purchases

--- moneys
local suffixes = {
    K   = 1e3,  M   = 1e6,  B   = 1e9,  T   = 1e12,
    Qd  = 1e15, Qn  = 1e18, Sx  = 1e21, Sxd = 1e21,
    Sp  = 1e24, Oc  = 1e27, No  = 1e30, Dc  = 1e33,
}

local function decodeValue(str)
    if not str then return nil end
    local clean = tostring(str):gsub("[\226\128\128-\226\128\143]", "")
    local numStr, suffix = clean:match("%$?([%d%,%.]+)(%a*)")
    if not numStr then return nil end
    local num = tonumber((numStr:gsub(",", "")))
    if not num then return nil end
    if suffix == "" then return num end
    local multiplier = suffixes[suffix]
    if not multiplier then
        suffix = suffix:sub(1,1):upper() .. suffix:sub(2):lower()
        multiplier = suffixes[suffix]
    end
    return multiplier and (num * multiplier) or num
end

-- rebirths currently borken work on later
local function getPendingInvestors()
    local best = 0
    local function scan(obj, depth)
        if depth > 8 then return end
        for _, v in pairs(obj:GetChildren()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local txt = ""
                pcall(function() txt = v.Text end)
                local clean = txt:gsub(",", ""):match("([%d]+)")
                if clean then
                    local n = tonumber(clean)
                    if n and n > best and n < 1e13 then
                        best = n
                    end
                end
            end
            scan(v, depth + 1)
        end
    end
    scan(plr.PlayerGui, 0)
    return best
end

local rebirthCount = 0

local function doRebirth()
    local ok, result = pcall(function()
        return tycoon.Remotes.Rebirth:InvokeServer()
    end)
    if ok then
        rebirthCount += 1
        print("[Apollo] Rebirth #" .. rebirthCount .. " — server returned: " .. tostring(result))
    else
        warn("[Apollo] Rebirth failed: " .. tostring(result))
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if not getgenv().autorebirth then continue end
        local pending = getPendingInvestors()
        if pending >= getgenv().rebirthTarget then
            print("[Apollo] Rebirthing — pending: " .. pending .. " / target: " .. getgenv().rebirthTarget)
            doRebirth()
            task.wait(4)
        end
    end
end)

--- accept phone and no afk kick
tycoon.Remotes.PhoneOffer.OnClientEvent:Connect(function()
    if not getgenv().farming then return end
    tycoon.Remotes.PhoneOffer:FireServer("Accept")
end)

plr.Idled:Connect(function()
    if not getgenv().antiafk then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

--- auto farm stuff
local function startAutofarmLoop()
    local stands = tycoon.Values.Income.Streams

    task.spawn(function()
        while getgenv().farming do
            if not getgenv().farmsettings.collect then task.wait(1) continue end
            for _, v in pairs(stands:GetChildren()) do
                tycoon.Remotes.WakeIncomeStream:InvokeServer(v.Name)
            end
            task.wait()
        end
    end)

    while getgenv().farming do
        pcall(function()
            if not getgenv().farmsettings.purchase then return end
            for _, fold in pairs(PurchasesFold:GetChildren()) do
                if fold:FindFirstChild("Buttons") then
                    for _, nFold in pairs(fold.Buttons:GetChildren()) do
                        if nFold:IsA("Folder") then
                            for _, btn in pairs(nFold:GetChildren()) do
                                if btn:GetAttribute("Shown") and btn:GetAttribute("Enabled") and not btn:GetAttribute("Purchased") then
                                    local price      = decodeValue(btn.Button.Gui.Price.Text)
                                    local curbalance = decodeValue(plr.leaderstats.Cash.Value)
                                    if price and curbalance and price <= curbalance then
                                        firetouchinterest(plr.Character.Head, btn.Button, true)
                                        task.wait()
                                        firetouchinterest(plr.Character.Head, btn.Button, false)
                                    end
                                end
                            end
                        elseif nFold:IsA("Model") then
                            if nFold:GetAttribute("Shown") and nFold:GetAttribute("Enabled") and not nFold:GetAttribute("Purchased") then
                                local price      = decodeValue(nFold.Button.Gui.Price.Text)
                                local curbalance = decodeValue(plr.leaderstats.Cash.Value)
                                if price and curbalance and price <= curbalance then
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

        pcall(function()
            if not getgenv().farmsettings.upgrade then return end
            for _, fold in pairs(PurchasesFold:GetChildren()) do
                if fold:FindFirstChild(fold.Name) then
                    if not fold:FindFirstChild(fold.Name):GetAttribute("Enabled") then continue end
                    fold:FindFirstChild(fold.Name):FindFirstChild(fold.Name).Upgrade:InvokeServer(1)
                end
            end
        end)

        pcall(function()
            if not getgenv().farmsettings.cashdrop then return end
            for _, v in pairs(workspace.CashDrops:GetChildren()) do
                firetouchinterest(plr.Character.Head, v, true)
                task.wait()
                firetouchinterest(plr.Character.Head, v, false)
            end
        end)
        
        pcall(function()
            if not getgenv().farmsettings.fruit then return end
            for _, v in pairs(tycoon.Constant.Trees:GetChildren()) do
                for _, lemon in pairs(v:GetChildren()) do
                    if lemon.Name ~= "Fruit" then continue end
                    if not lemon:FindFirstChild("ClickPart") then continue end
                    fireclickdetector(lemon.ClickPart.ClickDetector)
                    task.wait()
                end
            end
        end)

        task.wait(1)
    end
end

-- luna ui
local Window = Luna:CreateWindow({
    Name            = "Apollo Program",
    Subtitle        = "https://discord.gg/U8X5U24u34",
    LogoID          = "71992521463355",
    LoadingEnabled  = true,
    LoadingTitle    = "Apollo Program Loading",
    LoadingSubtitle = "by ChefaoBR",
    ConfigSettings  = { RootFolder = nil, ConfigFolder = "AP Hub" },
    KeySystem       = false,
    KeySettings     = {
        Title        = "Apollo key system",
        Subtitle     = "Key System",
        Note         = "",
        SaveInRoot   = false,
        SaveKey      = false,
        Key          = { "1234" },
        SecondAction = { Enabled = true, Type = "Link", Parameter = "" }
    }
})

Window:CreateHomeTab({
    SupportedExecutors = { "Volt", "Delta", "Xeno", "Velocity" },
    DiscordInvite      = "U8X5U24u34",
    Icon               = 1,
})

local Tab = Window:CreateTab({
    Name        = "Auto Farm",
    Icon        = "sports_esports",
    ImageSource = "Material",
    ShowTitle   = true,
})

--ato farm tab
Tab:CreateToggle({
    Name         = "Auto Farm",
    Description  = "Auto matically run everythng",
    CurrentValue = false,
    Callback     = function(Value)
        getgenv().farming = Value
        if Value then task.spawn(startAutofarmLoop) end
    end,
}, "EnableAutoFarm")

Tab:CreateLabel({ Text = "Farm Settings", Style = 1 })

Tab:CreateToggle({
    Name         = "Auto Purchase",
    Description  = "Auto buys the pad things",
    CurrentValue = false,
    Callback     = function(Value) getgenv().farmsettings.purchase = Value end,
}, "AutoPurchase")

Tab:CreateToggle({
    Name         = "Auto Collect",
    Description  = "Presses collect button",
    CurrentValue = false,
    Callback     = function(Value) getgenv().farmsettings.collect = Value end,
}, "AutoCollect")

Tab:CreateToggle({
    Name         = "Auto Upgrade",
    Description  = "Auto clicks the upgrade button",
    CurrentValue = false,
    Callback     = function(Value) getgenv().farmsettings.upgrade = Value end,
}, "AutoUpgrade")

Tab:CreateToggle({
    Name         = "Auto Cash Drop",
    Description  = "Auto collects cash bags (may be broken)",
    CurrentValue = false,
    Callback     = function(Value) getgenv().farmsettings.cashdrop = Value end,
}, "AutoCashDrop")

Tab:CreateToggle({
    Name         = "Auto Fruit",
    Description  = "Clicks lemon tees",
    CurrentValue = false,
    Callback     = function(Value) getgenv().farmsettings.fruit = Value end,
}, "AutoFruit")

-- rebirht Tab
local RebirthTab = Window:CreateTab({
    Name        = "Auto Rebirth",
    Icon        = "autorenew",
    ImageSource = "Material",
    ShowTitle   = true,
})

RebirthTab:CreateToggle({
    Name         = "Auto Rebirth",
    Description  = "Rebirths are broken rn dont use it please",
    CurrentValue = false,
    Callback     = function(Value)
        getgenv().autorebirth = Value
    end,
}, "AutoRebirth")

RebirthTab:CreateLabel({ Text = "Investor Threshold", Style = 1 })

local thresholdOptions = {
    "100K", "250K", "500K",
    "1M",   "2.5M", "5M",   "10M",
    "25M",  "50M",  "100M",
    "250M", "500M",
    "1B",   "2.5B", "5B",   "10B",
}

local thresholdValues = {
    ["100K"] = 1e5,  ["250K"] = 2.5e5, ["500K"] = 5e5,
    ["1M"]   = 1e6,  ["2.5M"] = 2.5e6, ["5M"]   = 5e6,   ["10M"]  = 1e7,
    ["25M"]  = 2.5e7,["50M"]  = 5e7,   ["100M"] = 1e8,
    ["250M"] = 2.5e8,["500M"] = 5e8,
    ["1B"]   = 1e9,  ["2.5B"] = 2.5e9, ["5B"]   = 5e9,   ["10B"]  = 1e10,
}

RebirthTab:CreateDropdown({
    Name            = "Rebirth At (Investors)",
    Description     = "Auto Rebirth fires when pending investor count hits this threshold",
    Options         = thresholdOptions,
    CurrentOption   = { "1M" },
    MultipleOptions = false,
    Callback        = function(selected)
        local key = type(selected) == "table" and selected[1] or selected
        getgenv().rebirthTarget = thresholdValues[key] or 1e6
        print("[Apollo] Threshold -> " .. tostring(getgenv().rebirthTarget))
    end,
}, "RebirthThreshold")

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

print("loaded correctly")
