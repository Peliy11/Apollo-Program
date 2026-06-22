local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "Apollo Service"
Junkie.identifier = "1104877"
Junkie.provider = "Apollo Program"

-- Map your Roblox Place IDs to your Raw GitHub code links
local GamesDatabase = {
    [79268393072444] = "https://raw.githubusercontent.com/Peliy11/Apollo-Program/refs/heads/main/sell_lemons.lua", -- Real Lemon Tycoon ID
}

local currentPlaceId = game.PlaceId

-- Halt early if game is unsupported before spinning up the UI process
if not GamesDatabase[currentPlaceId] then
    game:GetService("Players").LocalPlayer:Kick("Apollo Hub: This game is currently not supported.")
    return
end

local result = (function()
    getgenv().UI_CLOSED = false
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")
    local Colors = {
        background = Color3.fromRGB(13, 17, 23),
        surface = Color3.fromRGB(22, 27, 34),
        surfaceLight = Color3.fromRGB(30, 36, 44),
        primary = Color3.fromRGB(88, 166, 255),
        primaryDark = Color3.fromRGB(58, 136, 225),
        primaryGlow = Color3.fromRGB(120, 180, 255),
        accent = Color3.fromRGB(136, 87, 224),
        success = Color3.fromRGB(47, 183, 117),
        successDark = Color3.fromRGB(37, 153, 97),
        successGlow = Color3.fromRGB(67, 203, 137),
        error = Color3.fromRGB(248, 81, 73),
        textPrimary = Color3.fromRGB(230, 237, 243),
        textSecondary = Color3.fromRGB(139, 148, 158),
        textMuted = Color3.fromRGB(110, 118, 129),
        border = Color3.fromRGB(48, 54, 61),
        borderLight = Color3.fromRGB(63, 71, 79),
        glass = Color3.fromRGB(255, 255, 255),
        neonBlue = Color3.fromRGB(0, 229, 255),
        neonPurple = Color3.fromRGB(187, 134, 252)
    }
    
    local function hasFileSystemSupport()
        local hasWritefile = pcall(function() return type(writefile) == "function" end)
        local hasReadfile = pcall(function() return type(readfile) == "function" end)
        local hasIsfile = pcall(function() return type(isfile) == "function" end)
        return hasWritefile and hasReadfile and hasIsfile
    end
    
    local fileSystemSupported = hasFileSystemSupport()
    
    local function saveVerifiedKey(key)
        if not fileSystemSupported then return false end
        local ok = pcall(function()
            writefile("verified_key.txt", key)
        end)
        return ok
    end
    
    local function loadVerifiedKey()
        if not fileSystemSupported then 
            return nil 
        end
        
        local ok, content = pcall(function()
            return readfile("verified_key.txt")
        end)
        
        if not ok or not content then 
            return nil 
        end
        return content
    end
    
    local function clearSavedKey()
        if not fileSystemSupported then return false end
        local ok = pcall(function() delfile("verified_key.txt") end)
        return ok
    end
    

    local function loadUIFactory()
        return function(Colors, Players, TweenService, UserInputService, Lighting)
        local IconAssets = {
            shield = 84528813312016,
            x = 73070135088117,
            key = 128426502701541,
            link = 73034596791310,
            check = 83827110621355
        }
        
        local function createIconImage(name, size, color)
            local id = IconAssets[name]
            if id then
                local img = Instance.new("ImageLabel")
                img.BackgroundTransparency = 1
                img.Size = UDim2.new(0, size or 18, 0, size or 18)
                img.Image = "rbxassetid://" .. tostring(id)
                img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
                img.ScaleType = Enum.ScaleType.Fit
                if img:IsA("ImageLabel") and img.ResampleMode ~= nil then
                    img.ResampleMode = Enum.ResamplerMode.Default
                end
                return img
            end

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0, size or 18, 0, size or 18)
            lbl.TextScaled = true
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
            lbl.Text = ({ shield = "🛡️", key = "🔑", link = "🔗", x = "✕", check = "✓" })[name] or "🔘"
            return lbl
        end
        return function(self)
            if self.gui then
                self.gui:Destroy()
            end
            
            self.gui = Instance.new("ScreenGui")
            self.gui.Name = "JunkieKeySystemUI"
            self.gui.ResetOnSpawn = false
            self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            self.gui.IgnoreGuiInset = true
            
            local backdrop = Instance.new("Frame")
            backdrop.Name = "Backdrop"
            backdrop.Size = UDim2.new(1, 0, 1, 0)
            backdrop.Position = UDim2.new(0, 0, 0, 0)
            backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            backdrop.BackgroundTransparency = 0.4
            backdrop.BorderSizePixel = 0
            backdrop.Parent = self.gui
            
            local blur = Instance.new("BlurEffect")
            blur.Size = 16
            blur.Name = "JunkieUIBlur"
            blur.Parent = Lighting
            
            local container = Instance.new("Frame")
            container.Name = "Container"
            
            local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
            local viewportSize = workspace.CurrentCamera.ViewportSize
            
            if isMobile then
                container.Size = UDim2.new(0.6, 0, 0, math.min(320, viewportSize.Y * 0.8))
                container.Position = UDim2.new(0.5, 0, 0.5, 0)
                container.AnchorPoint = Vector2.new(0.5, 0.5)
            else
                container.Size = UDim2.new(0, 580, 0, 320)
                container.Position = UDim2.new(0.5, 0, 0.5, 0)
                container.AnchorPoint = Vector2.new(0.5, 0.5)
            end
            
            container.BackgroundColor3 = Colors.surface
            container.BorderSizePixel = 0
            container.Parent = backdrop
            
            container:SetAttribute("IsMobile", isMobile)
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 14)
            containerCorner.Parent = container
            
            local containerStroke = Instance.new("UIStroke")
            containerStroke.Color = Colors.border
            containerStroke.Thickness = 1
            containerStroke.Transparency = 0.3
            containerStroke.Parent = container
            
            local shadow = Instance.new("Frame")
            shadow.Name = "Shadow"
            shadow.Size = UDim2.new(1, 40, 1, 40)
            shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
            shadow.AnchorPoint = Vector2.new(0.5, 0.5)
            shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            shadow.BackgroundTransparency = 0.7
            shadow.BorderSizePixel = 0
            shadow.ZIndex = 0
            shadow.Parent = backdrop
            
            local shadowCorner = Instance.new("UICorner")
            shadowCorner.CornerRadius = UDim.new(0, 18)
            shadowCorner.Parent = shadow
            
            local glowFrame = Instance.new("Frame")
            glowFrame.Name = "GlowEffect"
            glowFrame.Size = UDim2.new(1, 60, 1, 60)
            glowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            glowFrame.BackgroundColor3 = Colors.primary
            glowFrame.BackgroundTransparency = 0.95
            glowFrame.BorderSizePixel = 0
            glowFrame.ZIndex = -1
            glowFrame.Parent = backdrop
            
            local glowCorner = Instance.new("UICorner")
            glowCorner.CornerRadius = UDim.new(0, 30)
            glowCorner.Parent = glowFrame

            local glowTween = TweenService:Create(glowFrame,
                TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = 0.9, Size = UDim2.new(1, 80, 1, 80)}
            )
            glowTween:Play()
            
            local glassOverlay = Instance.new("Frame")
            glassOverlay.Name = "GlassOverlay"
            glassOverlay.Size = UDim2.new(1, 0, 1, 0)
            glassOverlay.Position = UDim2.new(0, 0, 0, 0)
            glassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            glassOverlay.BackgroundTransparency = 0.98
            glassOverlay.BorderSizePixel = 0
            glassOverlay.ZIndex = 1
            glassOverlay.Parent = container
            
            local glassCorner = Instance.new("UICorner")
            glassCorner.CornerRadius = UDim.new(0, 14)
            glassCorner.Parent = glassOverlay
            
            local glassGradient = Instance.new("UIGradient")
            glassGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
            }
            glassGradient.Rotation = 45
            glassGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.96),
                NumberSequenceKeypoint.new(0.5, 0.98),
                NumberSequenceKeypoint.new(1, 1)
            }
            glassGradient.Parent = glassOverlay
            
            local topBar = Instance.new("Frame")
            topBar.Name = "TopBar"
            topBar.Size = UDim2.new(1, 0, 0, 45)
            topBar.Position = UDim2.new(0, 0, 0, 0)
            topBar.BackgroundColor3 = Colors.background
            topBar.BorderSizePixel = 0
            topBar.ZIndex = 10
            topBar.Parent = container
            
            local topBarCorner = Instance.new("UICorner")
            topBarCorner.CornerRadius = UDim.new(0, 14)
            topBarCorner.Parent = topBar

            local topBarFix = Instance.new("Frame")
            topBarFix.Size = UDim2.new(1, 0, 0, 10)
            topBarFix.Position = UDim2.new(0, 0, 1, -10)
            topBarFix.BackgroundColor3 = Colors.background
            topBarFix.BorderSizePixel = 0
            topBarFix.Parent = topBar
            
            local brandLogo = Instance.new("Frame")
            brandLogo.Name = "BrandLogo"
            brandLogo.Size = UDim2.new(0, 200, 1, 0)
            brandLogo.Position = UDim2.new(0, 20, 0, 0)
            brandLogo.BackgroundTransparency = 1
            brandLogo.ZIndex = 11
            brandLogo.Parent = topBar

            local brandLogoIcon = createIconImage("shield", 20, Colors.primary)
            brandLogoIcon.AnchorPoint = Vector2.new(0, 0.5)
            brandLogoIcon.Position = UDim2.new(0, 0, 0.5, 0)
            brandLogoIcon.ZIndex = 11
            brandLogoIcon.Parent = brandLogo

            local brandLogoText = Instance.new("TextLabel")
            brandLogoText.BackgroundTransparency = 1
            brandLogoText.Size = UDim2.new(1, -30, 1, 0)
            brandLogoText.Position = UDim2.new(0, 28, 0, 0)
            brandLogoText.Text = "Junkie Key System"
            brandLogoText.TextColor3 = Colors.textPrimary
            brandLogoText.TextSize = 15
            brandLogoText.TextXAlignment = Enum.TextXAlignment.Left
            brandLogoText.Font = Enum.Font.GothamSemibold
            brandLogoText.ZIndex = 11
            brandLogoText.Parent = brandLogo
            
            local closeButton = Instance.new("TextButton")
            closeButton.Name = "CloseButton"
            closeButton.Size = UDim2.new(0, 30, 0, 30)
            closeButton.Position = UDim2.new(1, -40, 0.5, 0)
            closeButton.AnchorPoint = Vector2.new(0, 0.5)
            closeButton.BackgroundColor3 = Colors.error
            closeButton.BackgroundTransparency = 0.8
            closeButton.BorderSizePixel = 0
            closeButton.Text = ""
            closeButton.AutoButtonColor = false
            closeButton.ZIndex = 11
            closeButton.Parent = topBar
            
            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 8)
            closeCorner.Parent = closeButton

            local closeIcon = createIconImage("x", 16, Colors.textPrimary)
            closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            closeIcon.ZIndex = 12
            closeIcon.Parent = closeButton
            

            local contentArea = Instance.new("Frame")
            contentArea.Name = "ContentArea"
            contentArea.Size = UDim2.new(1, -40, 1, -65)
            contentArea.Position = UDim2.new(0, 20, 0, 55)
            contentArea.BackgroundTransparency = 1
            contentArea.Parent = container
            
            local titleSection = Instance.new("Frame")
            titleSection.Name = "TitleSection"
            titleSection.Size = UDim2.new(1, 0, 0, 85)
            titleSection.Position = UDim2.new(0, 0, 0, 5)
            titleSection.BackgroundTransparency = 1
            titleSection.Parent = contentArea
            

            local iconFrame = Instance.new("Frame")
            iconFrame.Name = "IconFrame"
            iconFrame.Size = UDim2.new(0, 52, 0, 52)
            iconFrame.Position = UDim2.new(0.5, -26, 0, 0)
            iconFrame.BackgroundColor3 = Colors.surfaceLight
            iconFrame.BorderSizePixel = 0
            iconFrame.Parent = titleSection
            
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 12)
            iconCorner.Parent = iconFrame
  
            local iconGradient = Instance.new("UIGradient")
            iconGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Colors.primary),
                ColorSequenceKeypoint.new(0.5, Colors.primaryGlow),
                ColorSequenceKeypoint.new(1, Colors.accent)
            }
            iconGradient.Rotation = 45
            iconGradient.Parent = iconFrame
            
            local iconStroke = Instance.new("UIStroke")
            iconStroke.Color = Colors.primary
            iconStroke.Thickness = 2
            iconStroke.Transparency = 0.5
            iconStroke.Parent = iconFrame
            
            local strokeGradient = Instance.new("UIGradient")
            strokeGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Colors.neonBlue),
                ColorSequenceKeypoint.new(0.5, Colors.primary),
                ColorSequenceKeypoint.new(1, Colors.neonPurple)
            }
            strokeGradient.Rotation = 0
            strokeGradient.Parent = iconStroke
            
        
            local strokeTween = TweenService:Create(strokeGradient,
                TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                {Rotation = 360}
            )
            strokeTween:Play()
            
            local mainIcon = createIconImage("shield", 26, Color3.fromRGB(255, 255, 255))
            mainIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            mainIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            mainIcon.Parent = iconFrame
        
            
            local titleText = Instance.new("TextLabel")
            titleText.Name = "TitleText"
            titleText.Size = UDim2.new(1, 0, 0, 24)
            titleText.Position = UDim2.new(0, 0, 0, 58)
            titleText.BackgroundTransparency = 1
            titleText.Text = self.title
            titleText.TextColor3 = Colors.textPrimary
            titleText.TextSize = 17
            titleText.TextXAlignment = Enum.TextXAlignment.Center
            titleText.Font = Enum.Font.GothamBold
            titleText.Parent = titleSection
            
            local subtitleText = Instance.new("TextLabel")
            subtitleText.Name = "SubtitleText"
            subtitleText.Size = UDim2.new(1, 0, 0, 18)
            subtitleText.Position = UDim2.new(0, 0, 0, 82)
            subtitleText.BackgroundTransparency = 1
            subtitleText.Text = self.subtitle
            subtitleText.TextColor3 = Colors.textSecondary
            subtitleText.TextSize = 13
            subtitleText.TextXAlignment = Enum.TextXAlignment.Center
            subtitleText.Font = Enum.Font.Gotham
            subtitleText.Parent = titleSection
            
            local inputSection = Instance.new("Frame")
            inputSection.Name = "InputSection"
            inputSection.Size = UDim2.new(1, 0, 0, 46)
            inputSection.Position = UDim2.new(0, 0, 0, 115)
            inputSection.BackgroundColor3 = Colors.surfaceLight
            inputSection.BorderSizePixel = 0
            inputSection.Parent = contentArea
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 10)
            inputCorner.Parent = inputSection
            
            local inputStroke = Instance.new("UIStroke")
            inputStroke.Color = Colors.border
            inputStroke.Thickness = 1
            inputStroke.Transparency = 0.5
            inputStroke.Parent = inputSection
            

            local keyIcon = createIconImage("key", 18, Colors.primary)
            keyIcon.AnchorPoint = Vector2.new(0, 0.5)
            keyIcon.Position = UDim2.new(0, 14, 0.5, 0)
            keyIcon.Parent = inputSection
            
            local keyInput = Instance.new("TextBox")
            keyInput.Name = "KeyInput"
            keyInput.Size = UDim2.new(1, -50, 1, 0)
            keyInput.Position = UDim2.new(0, 40, 0, 0)
            keyInput.BackgroundTransparency = 1
            keyInput.PlaceholderText = "Enter your verification key"
            keyInput.PlaceholderColor3 = Colors.textMuted
            keyInput.Text = ""
            keyInput.TextColor3 = Colors.textPrimary
            keyInput.TextSize = 14
            keyInput.TextXAlignment = Enum.TextXAlignment.Left
            keyInput.TextTruncate = Enum.TextTruncate.AtEnd
            keyInput.Font = Enum.Font.Gotham
            keyInput.ClearTextOnFocus = false
            keyInput.Parent = inputSection
            
            local buttonSection = Instance.new("Frame")
            buttonSection.Name = "ButtonSection"
            buttonSection.Size = UDim2.new(1, 0, 0, 40)
            buttonSection.Position = UDim2.new(0, 0, 0, 175)
            buttonSection.BackgroundTransparency = 1
            buttonSection.Parent = contentArea
            
            local getLinkButton = Instance.new("TextButton")
            getLinkButton.Name = "GetLinkButton"
            getLinkButton.Size = UDim2.new(0.48, 0, 1, 0)
            getLinkButton.Position = UDim2.new(0, 0, 0, 0)
            getLinkButton.BackgroundColor3 = Colors.primary
            getLinkButton.Text = ""  
            getLinkButton.Font = Enum.Font.GothamSemibold
            getLinkButton.TextSize = 14
            getLinkButton.BorderSizePixel = 0
            getLinkButton.AutoButtonColor = false
            getLinkButton.Parent = buttonSection

            local getLinkCorner = Instance.new("UICorner")
            getLinkCorner.CornerRadius = UDim.new(0, 10)
            getLinkCorner.Parent = getLinkButton

            local getLinkGradient = Instance.new("UIGradient")
            getLinkGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Colors.primary),
                ColorSequenceKeypoint.new(1, Colors.primaryDark)
            }
            getLinkGradient.Rotation = 90
            getLinkGradient.Parent = getLinkButton

            local getLinkGlow = Instance.new("UIStroke")
            getLinkGlow.Color = Colors.primaryGlow
            getLinkGlow.Thickness = 0
            getLinkGlow.Transparency = 0.8
            getLinkGlow.Parent = getLinkButton

            local getLinkIcon = createIconImage("link", 16, Color3.fromRGB(255, 255, 255))
            getLinkIcon.AnchorPoint = Vector2.new(0, 0.5)
            getLinkIcon.Position = UDim2.new(0, 12, 0.5, 0)
            getLinkIcon.Parent = getLinkButton

            local getLinkText = Instance.new("TextLabel")
            getLinkText.Name = "ButtonText"
            getLinkText.Size = UDim2.new(1, 0, 1, 0)  
            getLinkText.Position = UDim2.new(0, 0, 0, 0)
            getLinkText.BackgroundTransparency = 1
            getLinkText.Text = "Get Link"
            getLinkText.TextColor3 = Color3.fromRGB(255, 255, 255)  
            getLinkText.Font = Enum.Font.GothamSemibold
            getLinkText.TextSize = 14  
            getLinkText.TextXAlignment = Enum.TextXAlignment.Center  
            getLinkText.Parent = getLinkButton

            local verifyButton = Instance.new("TextButton")
            verifyButton.Name = "VerifyButton"
            verifyButton.Size = UDim2.new(0.48, 0, 1, 0)
            verifyButton.Position = UDim2.new(0.52, 0, 0, 0)
            verifyButton.BackgroundColor3 = Colors.success
            verifyButton.BorderSizePixel = 0
            verifyButton.Text = ""  
            verifyButton.TextSize = 14
            verifyButton.Font = Enum.Font.GothamSemibold
            verifyButton.AutoButtonColor = false
            verifyButton.Parent = buttonSection

            local verifyCorner = Instance.new("UICorner")
            verifyCorner.CornerRadius = UDim.new(0, 10)
            verifyCorner.Parent = verifyButton

            local verifyGradient = Instance.new("UIGradient")
            verifyGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Colors.success),
                ColorSequenceKeypoint.new(1, Colors.successDark)
            }
            verifyGradient.Rotation = 90
            verifyGradient.Parent = verifyButton

            local verifyGlow = Instance.new("UIStroke")
            verifyGlow.Color = Colors.successGlow
            verifyGlow.Thickness = 0
            verifyGlow.Transparency = 0.8
            verifyGlow.Parent = verifyButton

            local verifyIcon = createIconImage("check", 16, Color3.fromRGB(255, 255, 255))
            verifyIcon.AnchorPoint = Vector2.new(0, 0.5)
            verifyIcon.Position = UDim2.new(0, 12, 0.5, 0)
            verifyIcon.Parent = verifyButton

            local verifyText = Instance.new("TextLabel")
            verifyText.Name = "ButtonText"
            verifyText.Size = UDim2.new(1, 0, 1, 0)  
            verifyText.Position = UDim2.new(0, 0, 0, 0)
            verifyText.BackgroundTransparency = 1
            verifyText.Text = "Verify Key"
            verifyText.TextColor3 = Color3.fromRGB(255, 255, 255)  
            verifyText.Font = Enum.Font.GothamSemibold
            verifyText.TextSize = 14  
            verifyText.TextXAlignment = Enum.TextXAlignment.Center  
            verifyText.Parent = verifyButton
            
        
            local statusBar = Instance.new("Frame")
            statusBar.Name = "StatusBar"
            statusBar.Size = UDim2.new(1, -40, 0, 2)
            statusBar.Position = UDim2.new(0.5, 0, 1, -14)
            statusBar.AnchorPoint = Vector2.new(0.5, 0)
            statusBar.BackgroundColor3 = Colors.border
            statusBar.BorderSizePixel = 0
            statusBar.Parent = container

            local statusText = Instance.new("TextLabel")
            statusText.Name = "StatusText"
            statusText.BackgroundTransparency = 1
            statusText.Text = ""
            statusText.TextColor3 = Colors.textSecondary
            statusText.Font = Enum.Font.Gotham
            statusText.TextSize = 12
            statusText.TextXAlignment = Enum.TextXAlignment.Center
            statusText.Size = UDim2.new(1, -40, 0, 20)
            statusText.Position = UDim2.new(0.5, 0, 1, -38)
            statusText.AnchorPoint = Vector2.new(0.5, 0)
            statusText.Visible = false
            statusText.Parent = container
            

            self.elements = {
                backdrop = backdrop,
                container = container,
                iconFrame = iconFrame,
                brandLogo = brandLogo,
                title = titleText,
                subtitle = subtitleText,
                getLinkButton = getLinkButton,
                inputContainer = inputSection,
                inputFrame = inputSection,
                keyInput = keyInput,
                verifyButton = verifyButton,
                statusBar = statusBar,
                statusText = statusText,
                inputStroke = inputStroke,
                closeButton = closeButton,
                glassOverlay = glassOverlay,
                glowFrame = glowFrame
            }
            
            local function createAmbientParticle()
                local particle = Instance.new("Frame")
                particle.Name = "AmbientParticle"
                particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
                particle.Position = UDim2.new(math.random(), 0, 1, 0)
                particle.BackgroundColor3 = Colors.primaryGlow
                particle.BackgroundTransparency = 0.7
                particle.BorderSizePixel = 0
                particle.Parent = container
                
                local particleCorner = Instance.new("UICorner")
                particleCorner.CornerRadius = UDim.new(1, 0)
                particleCorner.Parent = particle
                
                local floatTween = TweenService:Create(particle,
                    TweenInfo.new(math.random(8, 12), Enum.EasingStyle.Linear),
                    {
                        Position = UDim2.new(particle.Position.X.Scale, 0, -0.1, 0),
                        BackgroundTransparency = 1
                    }
                )
                floatTween:Play()
                
                floatTween.Completed:Connect(function()
                    particle:Destroy()
                end)
            end
            
            task.spawn(function()
                while container and container.Parent do
                    createAmbientParticle()
                    task.wait(math.random(2, 4))
                end
            end)
            
            local getLinkStroke = getLinkButton:FindFirstChild("UIStroke")
            if getLinkStroke then
                getLinkStroke.Name = "GetLinkButtonGlow"
            end
            local verifyStroke = verifyButton:FindFirstChild("UIStroke")
            if verifyStroke then
                verifyStroke.Name = "VerifyButtonGlow"
            end

            local function setupAnimations()
                local elements = self.elements
                
                if elements.closeButton then
                    elements.closeButton.MouseEnter:Connect(function()
                        TweenService:Create(elements.closeButton, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2
                        }):Play()
                    end)
                    
                    elements.closeButton.MouseLeave:Connect(function()
                        TweenService:Create(elements.closeButton, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.8
                        }):Play()
                    end)
                end
                
                if elements.getLinkButton then
                    elements.getLinkButton.MouseEnter:Connect(function()
                        TweenService:Create(elements.getLinkButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Colors.primaryGlow,
                            Size = UDim2.new(0.48, 2, 1, 2),
                            Position = UDim2.new(0, -1, 0, -1)
                        }):Play()
                        
                        local glow = elements.getLinkButton:FindFirstChild("GetLinkButtonGlow")
                        if glow then
                            TweenService:Create(glow, TweenInfo.new(0.2), {
                                Thickness = 2,
                                Transparency = 0.3
                            }):Play()
                        end
                    end)
                    
                    elements.getLinkButton.MouseLeave:Connect(function()
                        TweenService:Create(elements.getLinkButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Colors.primary,
                            Size = UDim2.new(0.48, 0, 1, 0),
                            Position = UDim2.new(0, 0, 0, 0)
                        }):Play()
                        
                        local glow = elements.getLinkButton:FindFirstChild("GetLinkButtonGlow")
                        if glow then
                            TweenService:Create(glow, TweenInfo.new(0.2), {
                                Thickness = 0,
                                Transparency = 0.8
                            }):Play()
                        end
                    end)
                    
                    elements.getLinkButton.MouseButton1Down:Connect(function()
                        TweenService:Create(elements.getLinkButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                            Size = UDim2.new(0.47, 0, 0.95, 0),
                            Position = UDim2.new(0.005, 0, 0.025, 0)
                        }):Play()
                    end)
                    
                    elements.getLinkButton.MouseButton1Up:Connect(function()
                        TweenService:Create(elements.getLinkButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                            Size = UDim2.new(0.48, 0, 1, 0),
                            Position = UDim2.new(0, 0, 0, 0)
                        }):Play()
                    end)
                end
                
                if elements.verifyButton then
                    elements.verifyButton.MouseEnter:Connect(function()
                        TweenService:Create(elements.verifyButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Colors.successGlow,
                            Size = UDim2.new(0.48, 2, 1, 2),
                            Position = UDim2.new(0.52, -1, 0, -1)
                        }):Play()
                        
                        local glow = elements.verifyButton:FindFirstChild("VerifyButtonGlow")
                        if glow then
                            TweenService:Create(glow, TweenInfo.new(0.2), {
                                Thickness = 2,
                                Transparency = 0.3
                            }):Play()
                        end
                    end)
                    
                    elements.verifyButton.MouseLeave:Connect(function()
                        TweenService:Create(elements.verifyButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = Colors.success,
                            Size = UDim2.new(0.48, 0, 1, 0),
                            Position = UDim2.new(0.52, 0, 0, 0)
                        }):Play()
                        
                        local glow = elements.verifyButton:FindFirstChild("VerifyButtonGlow")
                        if glow then
                            TweenService:Create(glow, TweenInfo.new(0.2), {
                                Thickness = 0,
                                Transparency = 0.8
                            }):Play()
                        end
                    end)
                    
                    elements.verifyButton.MouseButton1Down:Connect(function()
                        TweenService:Create(elements.verifyButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                            Size = UDim2.new(0.47, 0, 0.95, 0),
                            Position = UDim2.new(0.525, 0, 0.025, 0)
                        }):Play()
                    end)
                    
                    elements.verifyButton.MouseButton1Up:Connect(function()
                        TweenService:Create(elements.verifyButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
                            Size = UDim2.new(0.48, 0, 1, 0),
                            Position = UDim2.new(0.52, 0, 0, 0)
                        }):Play()
                    end)
                end
            end
            setupAnimations()
        end
    end)()
end)()

-- Immediate Dynamic Loader targeting your assigned game database configuration profile
local gameScriptUrl = GamesDatabase[currentPlaceId]
local successLoad, scriptContent = pcall(game.HttpGet, game, gameScriptUrl)

if successLoad and scriptContent then
    local loadedFunction, err = loadstring(scriptContent)
    if loadedFunction then
        loadedFunction()
    else
        warn("Structure failure compilation target: " .. tostring(err))
    end
else
    warn("Failed to contact GitHub storage network engine.")
end
