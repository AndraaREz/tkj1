-- waypoints.lua
-- Full Featured Waypoint System with Misc Features
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/waypoints.lua"))()

local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local STORAGE_FILE = "waypoints_data.json"

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    self.player = Players.LocalPlayer
    self.waypoints = {}
    self.isMinimized = false
    
    -- Misc Features State
    self.flyEnabled = false
    self.flySpeed = 50
    self.antiAFKEnabled = false
    self.infJumpEnabled = false
    self.originalSpeed = 16
    self.originalJump = 50
    
    -- Connections
    self.connections = {}
    
    self:Initialize()
    return self
end

function WaypointSystem:Initialize()
    self:LoadWaypoints()
    self:CreateGUI()
    self:SetupDragging()
    self:LoadWaypointsToGUI()
    self:SetupCharacterConnection()
    print("✅ Waypoint System loaded!")
    print("📂 Loaded " .. self:CountWaypoints() .. " saved waypoints")
end

function WaypointSystem:SetupCharacterConnection()
    self.player.CharacterAdded:Connect(function(char)
        wait(0.5)
        self:GetOriginalValues()
        if self.flyEnabled then
            task.wait(1)
            self:EnableFly()
        end
    end)
    self:GetOriginalValues()
end

function WaypointSystem:GetOriginalValues()
    local char = self.player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            self.originalSpeed = hum.WalkSpeed
            self.originalJump = hum.JumpPower
        end
    end
end

function WaypointSystem:CountWaypoints()
    local count = 0
    for _ in pairs(self.waypoints) do count = count + 1 end
    return count
end

function WaypointSystem:SaveToFile()
    pcall(function()
        local data = {}
        for name, pos in pairs(self.waypoints) do
            data[name] = {X = pos.X, Y = pos.Y, Z = pos.Z}
        end
        writefile(STORAGE_FILE, HttpService:JSONEncode(data))
    end)
end

function WaypointSystem:LoadWaypoints()
    pcall(function()
        if isfile(STORAGE_FILE) then
            local data = HttpService:JSONDecode(readfile(STORAGE_FILE))
            for name, pos in pairs(data) do
                self.waypoints[name] = Vector3.new(pos.X, pos.Y, pos.Z)
            end
        end
    end)
end

function WaypointSystem:LoadWaypointsToGUI()
    for name, _ in pairs(self.waypoints) do
        self:CreateWaypointItem(name)
    end
end

function WaypointSystem:CreateGUI()
    if self.player.PlayerGui:FindFirstChild("WaypointGUI") then
        self.player.PlayerGui.WaypointGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "WaypointGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui = gui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 450)
    main.Position = UDim2.new(1, -320, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    self.main = main
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    
    self:CreateHeader(main)
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.content = content
    
    self:CreateTabButtons(content)
    self:CreateWaypointsTab(content)
    self:CreateMiscTab(content)
    
    self:SwitchTab("Waypoints")
    
    gui.Parent = self.player.PlayerGui
end

function WaypointSystem:CreateHeader(parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(35, 100, 180)
    header.BorderSizePixel = 0
    header.Parent = parent
    self.header = header
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = Color3.fromRGB(35, 100, 180)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Hub System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    minBtn.BackgroundColor3 = Color3.fromRGB(220, 170, 50)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = header
    self.minBtn = minBtn
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
    
    minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
    closeBtn.MouseButton1Click:Connect(function() self:CloseGUI() end)
end

function WaypointSystem:CreateTabButtons(parent)
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabButtons"
    tabFrame.Size = UDim2.new(1, -20, 0, 35)
    tabFrame.Position = UDim2.new(0, 10, 0, 5)
    tabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = parent
    
    Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 8)
    
    local waypointsBtn = Instance.new("TextButton")
    waypointsBtn.Name = "WaypointsBtn"
    waypointsBtn.Size = UDim2.new(0.5, -5, 1, -10)
    waypointsBtn.Position = UDim2.new(0, 5, 0, 5)
    waypointsBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    waypointsBtn.Text = "📍 Waypoints"
    waypointsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    waypointsBtn.TextSize = 13
    waypointsBtn.Font = Enum.Font.GothamBold
    waypointsBtn.Parent = tabFrame
    self.waypointsBtn = waypointsBtn
    
    Instance.new("UICorner", waypointsBtn).CornerRadius = UDim.new(0, 6)
    
    local miscBtn = Instance.new("TextButton")
    miscBtn.Name = "MiscBtn"
    miscBtn.Size = UDim2.new(0.5, -5, 1, -10)
    miscBtn.Position = UDim2.new(0.5, 0, 0, 5)
    miscBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    miscBtn.Text = "⚙️ Misc"
    miscBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    miscBtn.TextSize = 13
    miscBtn.Font = Enum.Font.GothamBold
    miscBtn.Parent = tabFrame
    self.miscBtn = miscBtn
    
    Instance.new("UICorner", miscBtn).CornerRadius = UDim.new(0, 6)
    
    waypointsBtn.MouseButton1Click:Connect(function() self:SwitchTab("Waypoints") end)
    miscBtn.MouseButton1Click:Connect(function() self:SwitchTab("Misc") end)
end

function WaypointSystem:CreateWaypointsTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "WaypointsTab"
    tab.Size = UDim2.new(1, 0, 1, -45)
    tab.Position = UDim2.new(0, 0, 0, 45)
    tab.BackgroundTransparency = 1
    tab.Visible = true
    tab.Parent = parent
    self.waypointsTab = tab
    
    self:CreateInputSection(tab)
    self:CreateWaypointsList(tab)
    self:CreateFooter(tab)
end

function WaypointSystem:CreateMiscTab(parent)
    local tab = Instance.new("Frame")
    tab.Name = "MiscTab"
    tab.Size = UDim2.new(1, 0, 1, -45)
    tab.Position = UDim2.new(0, 0, 0, 45)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.Parent = parent
    self.miscTab = tab
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -10)
    scroll.Position = UDim2.new(0, 10, 0, 5)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = tab
    
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)
    
    self:CreateFlySection(scroll)
    self:CreateSpeedSection(scroll)
    self:CreateJumpSection(scroll)
    self:CreateInfJumpSection(scroll)
    self:CreateAntiAFKSection(scroll)
end

function WaypointSystem:CreateFlySection(parent)
    local section = self:CreateSection(parent, "✈️ Fly (Anti-Detect)")
    
    local toggle = self:CreateToggle(section, "Enable Fly", function(enabled)
        if enabled then
            self:EnableFly()
        else
            self:DisableFly()
        end
    end)
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -16, 0, 20)
    speedLabel.Position = UDim2.new(0, 8, 0, 45)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Fly Speed: 50"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 11
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = section
    self.flySpeedLabel = speedLabel
    
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, -16, 0, 30)
    speedBox.Position = UDim2.new(0, 8, 0, 68)
    speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedBox.PlaceholderText = "1-100"
    speedBox.Text = "50"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.TextSize = 12
    speedBox.Font = Enum.Font.Gotham
    speedBox.Parent = section
    
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", speedBox).PaddingLeft = UDim.new(0, 8)
    
    speedBox.FocusLost:Connect(function()
        local value = tonumber(speedBox.Text)
        if value and value >= 1 and value <= 100 then
            self.flySpeed = value
            speedLabel.Text = "Fly Speed: " .. value
            if self.flyEnabled then
                self:UpdateFlySpeed()
            end
        else
            speedBox.Text = tostring(self.flySpeed)
        end
    end)
    
    section.Size = UDim2.new(1, -16, 0, 108)
end

function WaypointSystem:CreateSpeedSection(parent)
    local section = self:CreateSection(parent, "🏃 Walk Speed")
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -16, 0, 20)
    speedLabel.Position = UDim2.new(0, 8, 0, 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: 16"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 11
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = section
    self.speedLabel = speedLabel
    
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, -16, 0, 30)
    speedBox.Position = UDim2.new(0, 8, 0, 33)
    speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedBox.PlaceholderText = "1-100"
    speedBox.Text = "16"
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.TextSize = 12
    speedBox.Font = Enum.Font.Gotham
    speedBox.Parent = section
    
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", speedBox).PaddingLeft = UDim.new(0, 8)
    
    speedBox.FocusLost:Connect(function()
        local value = tonumber(speedBox.Text)
        if value and value >= 1 and value <= 100 then
            self:SetSpeed(value)
            speedLabel.Text = "Speed: " .. value
        else
            speedBox.Text = "16"
        end
    end)
    
    section.Size = UDim2.new(1, -16, 0, 73)
end

function WaypointSystem:CreateJumpSection(parent)
    local section = self:CreateSection(parent, "🦘 Jump Power")
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1, -16, 0, 20)
    jumpLabel.Position = UDim2.new(0, 8, 0, 10)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump: 50"
    jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    jumpLabel.TextSize = 11
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = section
    self.jumpLabel = jumpLabel
    
    local jumpBox = Instance.new("TextBox")
    jumpBox.Size = UDim2.new(1, -16, 0, 30)
    jumpBox.Position = UDim2.new(0, 8, 0, 33)
    jumpBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    jumpBox.PlaceholderText = "1-150"
    jumpBox.Text = "50"
    jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpBox.TextSize = 12
    jumpBox.Font = Enum.Font.Gotham
    jumpBox.Parent = section
    
    Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", jumpBox).PaddingLeft = UDim.new(0, 8)
    
    jumpBox.FocusLost:Connect(function()
        local value = tonumber(jumpBox.Text)
        if value and value >= 1 and value <= 150 then
            self:SetJumpPower(value)
            jumpLabel.Text = "Jump: " .. value
        else
            jumpBox.Text = "50"
        end
    end)
    
    section.Size = UDim2.new(1, -16, 0, 73)
end

function WaypointSystem:CreateInfJumpSection(parent)
    local section = self:CreateSection(parent, "♾️ Infinite Jump")
    
    self:CreateToggle(section, "Enable Infinite Jump", function(enabled)
        self:SetInfiniteJump(enabled)
    end)
    
    section.Size = UDim2.new(1, -16, 0, 45)
end

function WaypointSystem:CreateAntiAFKSection(parent)
    local section = self:CreateSection(parent, "💤 Anti-AFK")
    
    self:CreateToggle(section, "Enable Anti-AFK", function(enabled)
        self:SetAntiAFK(enabled)
    end)
    
    section.Size = UDim2.new(1, -16, 0, 45)
end

function WaypointSystem:CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -16, 0, 100)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 8)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 25)
    titleLabel.Position = UDim2.new(0, 8, 0, -12)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 6)
    
    return section
end

function WaypointSystem:CreateToggle(parent, text, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -16, 0, 30)
    toggle.Position = UDim2.new(0, 8, 0, 10)
    toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 35, 0, 20)
    button.Position = UDim2.new(1, -40, 0.5, -10)
    button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    button.Text = "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.Parent = toggle
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
    
    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        button.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
    
    return toggle
end

function WaypointSystem:SwitchTab(tabName)
    if tabName == "Waypoints" then
        self.waypointsTab.Visible = true
        self.miscTab.Visible = false
        self.waypointsBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
        self.waypointsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.miscBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        self.miscBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        self.waypointsTab.Visible = false
        self.miscTab.Visible = true
        self.waypointsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        self.waypointsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        self.miscBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
        self.miscBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Fly System (Anti-Detect)
function WaypointSystem:EnableFly()
    self.flyEnabled = true
    local char = self.player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e9
    bg.Parent = hrp
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    self.flyBodyGyro = bg
    self.flyBodyVelocity = bv
    
    self.connections.fly = RunService.Heartbeat:Connect(function()
        if not self.flyEnabled then return end
        
        local camera = workspace.CurrentCamera
        local direction = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + (camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - (camera.CFrame.LookVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - (camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + (camera.CFrame.RightVector)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        
        bv.Velocity = direction * self.flySpeed
        bg.CFrame = camera.CFrame
    end)
    
    self:Notify("✈️ Fly Enabled", Color3.fromRGB(50, 200, 50))
end

function WaypointSystem:DisableFly()
    self.flyEnabled = false
    
    if self.connections.fly then
        self.connections.fly:Disconnect()
        self.connections.fly = nil
    end
    
    if self.flyBodyGyro then
        self.flyBodyGyro:Destroy()
        self.flyBodyGyro = nil
    end
    
    if self.flyBodyVelocity then
        self.flyBodyVelocity:Destroy()
        self.flyBodyVelocity = nil
    end
    
    self:Notify("✈️ Fly Disabled", Color3.fromRGB(200, 50, 50))
end

function WaypointSystem:UpdateFlySpeed()
    -- Speed updated in realtime via Heartbeat
end

-- Speed System
function WaypointSystem:SetSpeed(speed)
    local char = self.player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed
        self:Notify("🏃 Speed: " .. speed, Color3.fromRGB(50, 200, 50))
    end
end

-- Jump Power System
function WaypointSystem:SetJumpPower(power)
    local char = self.player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = power
        self:Notify("🦘 Jump: " .. power, Color3.fromRGB(50, 200, 50))
    end
end

-- Infinite Jump System
function WaypointSystem:SetInfiniteJump(enabled)
    self.infJumpEnabled = enabled
    
    if enabled then
        if self.connections.infJump then
            self.connections.infJump:Disconnect()
        end
        
        self.connections.infJump = UserInputService.JumpRequest:Connect(function()
            if self.infJumpEnabled then
                local char = self.player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
        
        self:Notify("♾️ Infinite Jump ON", Color3.fromRGB(50, 200, 50))
    else
        if self.connections.infJump then
            self.connections.infJump:Disconnect()
            self.connections.infJump = nil
        end
        self:Notify("♾️ Infinite Jump OFF", Color3.fromRGB(200, 50, 50))
    end
end

-- Anti-AFK System
function WaypointSystem:SetAntiAFK(enabled)
    self.antiAFKEnabled = enabled
    
    if enabled then
        if self.connections.antiAFK then
            self.connections.antiAFK:Disconnect()
        end
        
        local vu = game:GetService("VirtualUser")
        self.connections.antiAFK = self.player.Idled:Connect(function()
            if self.antiAFKEnabled then
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end
        end)
        
        self:Notify("💤 Anti-AFK ON", Color3.fromRGB(50, 200, 50))
    else
        if self.connections.antiAFK then
            self.connections.antiAFK:Disconnect()
            self.connections.antiAFK = nil
        end
        self:Notify("💤 Anti-AFK OFF", Color3.fromRGB(200, 50, 50))
    end
end

-- Waypoints Tab Functions
function WaypointSystem:CreateInputSection(parent)
    local input = Instance.new("Frame")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 75)
    input.Position = UDim2.new(0, 10, 0, 10)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    input.BorderSizePixel = 0
    input.Parent = parent
    
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "NameBox"
    textBox.Size = UDim2.new(1, -16, 0, 28)
    textBox.Position = UDim2.new(0, 8, 0, 8)
    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    textBox.PlaceholderText = "Waypoint name..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
    textBox.TextSize = 13
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = input
    self.textBox = textBox
    
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
    local padding = Instance.new("UIPadding", textBox)
    padding.PaddingLeft = UDim.new(0, 8)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -16, 0, 32)
    saveBtn.Position = UDim2.new(0, 8, 0, 40)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 50)
    saveBtn.Text = "💾 Save Position"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 13
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.Parent = input
    
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    
    saveBtn.MouseButton1Click:Connect(function()
        self:SaveWaypoint()
    end)
end

function WaypointSystem:CreateWaypointsList(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "WaypointsList"
    scroll.Size = UDim2.new(1, -20, 1, -115)
    scroll.Position = UDim2.new(0, 10, 0, 90)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = parent
    self.scroll = scroll
    
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    self.layout = layout
    
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end

function WaypointSystem:CreateFooter(parent)
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, -20, 0, 20)
    footer.Position = UDim2.new(0, 10, 1, -25)
    footer.BackgroundTransparency = 1
    footer.Parent = parent
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0.5, 0, 1, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Saved: 0"
    countLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    countLabel.TextSize = 11
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Parent = footer
    self.countLabel = countLabel
    
    local storageLabel = Instance.new("TextLabel")
    storageLabel.Size = UDim2.new(0.5, 0, 1, 0)
    storageLabel.Position = UDim2.new(0.5, 0, 0, 0)
    storageLabel.BackgroundTransparency = 1
    storageLabel.Text = "💾 Persistent"
    storageLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
    storageLabel.TextSize = 11
    storageLabel.Font = Enum.Font.GothamBold
    storageLabel.TextXAlignment = Enum.TextXAlignment.Right
    storageLabel.Parent = footer
    
    self:UpdateFooter()
end

function WaypointSystem:UpdateFooter()
    if self.countLabel then
        self.countLabel.Text = "Saved: " .. self:CountWaypoints()
    end
end

function WaypointSystem:SaveWaypoint()
    local name = self.textBox.Text:match("^%s*(.-)%s*$")
    
    if name == "" then
        self:Notify("❌ Enter a name!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    if self.waypoints[name] then
        self:Notify("⚠️ Already exists!", Color3.fromRGB(220, 150, 50))
        return
    end
    
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then
        self:Notify("❌ Character not found!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    self.waypoints[name] = hrp.Position
    self:CreateWaypointItem(name)
    self:SaveToFile()
    self.textBox.Text = ""
    self:UpdateFooter()
    self:Notify("✅ Saved: " .. name, Color3.fromRGB(50, 160, 50))
end

function WaypointSystem:CreateWaypointItem(name)
    local item = Instance.new("Frame")
    item.Name = name
    item.Size = UDim2.new(1, -10, 0, 38)
    item.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    item.BorderSizePixel = 0
    item.Parent = self.scroll
    
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, -5, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "📌 " .. name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = item
    
    local goBtn = Instance.new("TextButton")
    goBtn.Size = UDim2.new(0, 55, 0, 28)
    goBtn.Position = UDim2.new(0.4, 5, 0.5, -14)
    goBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    goBtn.Text = "➜ Go"
    goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    goBtn.TextSize = 11
    goBtn.Font = Enum.Font.GothamBold
    goBtn.Parent = item
    
    Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 5)
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 55, 0, 28)
    delBtn.Position = UDim2.new(1, -63, 0.5, -14)
    delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    delBtn.Text = "🗑️ Del"
    delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delBtn.TextSize = 11
    delBtn.Font = Enum.Font.GothamBold
    delBtn.Parent = item
    
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 5)
    
    goBtn.MouseButton1Click:Connect(function()
        self:GoToWaypoint(name)
    end)
    
    delBtn.MouseButton1Click:Connect(function()
        self:DeleteWaypoint(name, item)
    end)
end

function WaypointSystem:GoToWaypoint(name)
    local pos = self.waypoints[name]
    if not pos then return end
    
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        self:Notify("✅ Teleported!", Color3.fromRGB(50, 160, 50))
    else
        self:Notify("❌ Character not found!", Color3.fromRGB(220, 50, 50))
    end
end

function WaypointSystem:DeleteWaypoint(name, item)
    self.waypoints[name] = nil
    item:Destroy()
    self:SaveToFile()
    self:UpdateFooter()
    self:Notify("🗑️ Deleted: " .. name, Color3.fromRGB(220, 150, 50))
end

function WaypointSystem:ToggleMinimize()
    self.isMinimized = not self.isMinimized
    
    local targetSize = self.isMinimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 450)
    local btnText = self.isMinimized and "□" or "−"
    
    self.content.Visible = not self.isMinimized
    self.minBtn.Text = btnText
    
    local tween = TweenService:Create(
        self.main,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = targetSize}
    )
    tween:Play()
end

function WaypointSystem:CloseGUI()
    -- Cleanup connections
    for _, conn in pairs(self.connections) do
        if conn then conn:Disconnect() end
    end
    
    self:DisableFly()
    
    local tween = TweenService:Create(
        self.main,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        self.gui:Destroy()
        self:Notify("👋 GUI Closed", Color3.fromRGB(100, 100, 110))
    end)
end

function WaypointSystem:Notify(text, color)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 0, 0, 35)
    notif.Position = UDim2.new(0.5, 0, 0, -50)
    notif.AnchorPoint = Vector2.new(0.5, 0.5)
    notif.BackgroundColor3 = color
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextSize = 13
    notif.Font = Enum.Font.GothamBold
    notif.TextTransparency = 1
    notif.BackgroundTransparency = 1
    
    local playerGui = self.player.PlayerGui
    local container = playerGui:FindFirstChild("WaypointGUI") or self.gui
    notif.Parent = container
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local tweenIn = TweenService:Create(
        notif,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 220, 0, 35),
            Position = UDim2.new(0.5, 0, 0, 50),
            BackgroundTransparency = 0,
            TextTransparency = 0
        }
    )
    tweenIn:Play()
    
    task.wait(1.5)
    
    local tweenOut = TweenService:Create(
        notif,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 0, 0, 35),
            BackgroundTransparency = 1,
            TextTransparency = 1
        }
    )
    tweenOut:Play()
    
    tweenOut.Completed:Connect(function()
        notif:Destroy()
    end)
end

function WaypointSystem:SetupDragging()
    local dragging, dragStart, startPos
    
    self.header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.main.Position
        end
    end)
    
    self.header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

return WaypointSystem.new()