-- waypoints_v2.lua
-- Compact Waypoint + Misc system (LocalScript)
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/waypoints_v2.lua"))()

local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

-- Constants
local LOCAL_PLAYER = Players.LocalPlayer
local STORAGE_FILE = "waypoints_data.json"

-- Safety/defaults
local DEFAULT_GUI_SIZE = UDim2.new(0, 240, 0, 280)
local MINIMIZED_SIZE = UDim2.new(0, 240, 0, 35)

-- Helper - clamp
local function clamp(val, a, b) if val < a then return a end if val > b then return b end return val end

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    self.player = LOCAL_PLAYER
    self.waypoints = {}
    self.isMinimized = false
    self.miscState = {
        fly = false,
        antiAfk = false,
        infiniteJump = false,
        speedEnabled = false,
        jumpEnabled = false,
        loopEnabled = false
    }
    self.settings = {
        walkSpeed = 16,
        jumpPower = 50,
        flySpeed = 100,
        loopDelay = 2
    }
    self:Initialize()
    return self
end

function WaypointSystem:Initialize()
    self:LoadWaypoints()
    self:CreateGUI()
    self:SetupDragging()
    self:LoadWaypointsToGUI()
    self:UpdateFooter()
    self:BindMiscHandlers()
    print("✅ Waypoint System v2 loaded!")
    print("📂 Loaded " .. tostring(self:CountWaypoints()) .. " saved waypoints")
end

function WaypointSystem:CountWaypoints()
    local count = 0
    for _ in pairs(self.waypoints) do count = count + 1 end
    return count
end

-- Persistence
function WaypointSystem:SaveToFile()
    local success, err = pcall(function()
        local data = {}
        for name, pos in pairs(self.waypoints) do
            data[name] = { X = pos.X, Y = pos.Y, Z = pos.Z }
        end
        writefile(STORAGE_FILE, HttpService:JSONEncode(data))
    end)
    if not success then warn("Failed to save waypoints:", err) end
end

function WaypointSystem:LoadWaypoints()
    local success, err = pcall(function()
        if isfile and isfile(STORAGE_FILE) then
            local jsonData = readfile(STORAGE_FILE)
            local data = HttpService:JSONDecode(jsonData)
            for name, pos in pairs(data) do
                self.waypoints[name] = Vector3.new(pos.X, pos.Y, pos.Z)
            end
        end
    end)
    if not success then warn("No saved waypoints or failed to load:", err) end
end

function WaypointSystem:LoadWaypointsToGUI()
    if not self.scroll then return end
    -- clear existing items first
    for _, v in pairs(self.scroll:GetChildren()) do
        if v:IsA("Frame") and v.Name ~= "Template" then v:Destroy() end
    end
    for name, _ in pairs(self.waypoints) do
        self:CreateWaypointItem(name)
    end
    self:PopulateLoopDropdown()
end

-- GUI Creation
function WaypointSystem:CreateGUI()
    if self.player.PlayerGui:FindFirstChild("WaypointGUI_v2") then
        self.player.PlayerGui.WaypointGUI_v2:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WaypointGUI_v2"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = self.player.PlayerGui
    self.gui = gui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = DEFAULT_GUI_SIZE
    main.Position = UDim2.new(1, -260, 0.5, -140)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    self.main = main

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

    -- Header with Tab buttons
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(35, 100, 180)
    header.BorderSizePixel = 0
    header.Parent = main
    self.header = header
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📍 Waypoints"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Tab Buttons
    local tabWay = Instance.new("TextButton")
    tabWay.Name = "TabWay"
    tabWay.Size = UDim2.new(0, 80, 0, 26)
    tabWay.Position = UDim2.new(0.6, 6, 0.13, 0)
    tabWay.Text = "Waypoints"
    tabWay.Font = Enum.Font.GothamBold
    tabWay.TextSize = 12
    tabWay.Parent = header
    Instance.new("UICorner", tabWay).CornerRadius = UDim.new(0,6)
    local tabMisc = Instance.new("TextButton")
    tabMisc.Name = "TabMisc"
    tabMisc.Size = UDim2.new(0, 60, 0, 26)
    tabMisc.Position = UDim2.new(0.6, 92, 0.13, 0)
    tabMisc.Text = "Misc"
    tabMisc.Font = Enum.Font.GothamBold
    tabMisc.TextSize = 12
    tabMisc.Parent = header
    Instance.new("UICorner", tabMisc).CornerRadius = UDim.new(0,6)

    -- Minimize & Close
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -56, 0.5, -12)
    minBtn.BackgroundColor3 = Color3.fromRGB(220,170,50)
    minBtn.Text = "−"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = header
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,5)
    self.minBtn = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,5)
    self.closeBtn = closeBtn

    -- Content Frames (two tabs)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.content = content

    -- Waypoints Tab Frame
    local wayFrame = Instance.new("Frame")
    wayFrame.Name = "WayFrame"
    wayFrame.Size = UDim2.new(1, 0, 1, 0)
    wayFrame.BackgroundTransparency = 1
    wayFrame.Parent = content
    self.wayFrame = wayFrame

    -- Input section
    local input = Instance.new("Frame")
    input.Name = "Input"
    input.Size = UDim2.new(1, -16, 0, 70)
    input.Position = UDim2.new(0, 8, 0, 8)
    input.BackgroundColor3 = Color3.fromRGB(35,35,45)
    input.Parent = wayFrame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,6)

    local nameBox = Instance.new("TextBox")
    nameBox.Name = "NameBox"
    nameBox.Size = UDim2.new(1, -16, 0, 28)
    nameBox.Position = UDim2.new(0,8,0,8)
    nameBox.PlaceholderText = "Waypoint name..."
    nameBox.ClearTextOnFocus = false
    nameBox.BackgroundColor3 = Color3.fromRGB(45,45,55)
    nameBox.TextColor3 = Color3.fromRGB(255,255,255)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 13
    nameBox.Parent = input
    self.textBox = nameBox
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -16, 0, 28)
    saveBtn.Position = UDim2.new(0,8,0,40)
    saveBtn.Text = "💾 Save Position"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.Parent = input
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50,160,50)

    -- Waypoints list
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "WaypointsList"
    scroll.Size = UDim2.new(1, -16, 1, -130)
    scroll.Position = UDim2.new(0,8,0,86)
    scroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.Parent = wayFrame
    self.scroll = scroll
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0,6)

    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout.Padding = UDim.new(0,5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
    end)

    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, -16, 0, 30)
    footer.Position = UDim2.new(0,8,1,-36)
    footer.BackgroundTransparency = 1
    footer.Parent = wayFrame

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0.6,0,1,0)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Saved: 0"
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 11
    countLabel.TextColor3 = Color3.fromRGB(200,200,200)
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Parent = footer
    self.countLabel = countLabel

    local persistent = Instance.new("TextLabel")
    persistent.Size = UDim2.new(0.4,0,1,0)
    persistent.Position = UDim2.new(0.6,0,0,0)
    persistent.BackgroundTransparency = 1
    persistent.Text = "💾 Persistent"
    persistent.Font = Enum.Font.GothamBold
    persistent.TextSize = 11
    persistent.TextColor3 = Color3.fromRGB(100,220,100)
    persistent.TextXAlignment = Enum.TextXAlignment.Right
    persistent.Parent = footer

    -- Misc Tab Frame
    local miscFrame = Instance.new("Frame")
    miscFrame.Name = "MiscFrame"
    miscFrame.Size = UDim2.new(1,0,1,0)
    miscFrame.Position = UDim2.new(1,0,0,0) -- hidden by shifting
    miscFrame.BackgroundTransparency = 1
    miscFrame.Parent = content
    self.miscFrame = miscFrame

    -- Misc controls (stacked)
    local function createLabel(parent, y, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 0, 20)
        lbl.Position = UDim2.new(0,8,0,y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    createLabel(miscFrame, 8, "Movement Settings:")
    local speedBox = Instance.new("TextBox")
    speedBox.Name = "SpeedBox"
    speedBox.Size = UDim2.new(0.5, -10, 0, 26)
    speedBox.Position = UDim2.new(0,8,0,30)
    speedBox.PlaceholderText = "Speed (1-100)"
    speedBox.Text = tostring(self.settings.walkSpeed)
    speedBox.ClearTextOnFocus = false
    speedBox.Font = Enum.Font.Gotham
    speedBox.TextSize = 12
    speedBox.Parent = miscFrame
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

    local setSpeedBtn = Instance.new("TextButton")
    setSpeedBtn.Size = UDim2.new(0.45, -10, 0, 26)
    setSpeedBtn.Position = UDim2.new(0.5, 2, 0, 30)
    setSpeedBtn.Text = "Set Speed"
    setSpeedBtn.Font = Enum.Font.GothamBold
    setSpeedBtn.Parent = miscFrame
    Instance.new("UICorner", setSpeedBtn).CornerRadius = UDim.new(0,6)
    setSpeedBtn.BackgroundColor3 = Color3.fromRGB(50,160,50)

    createLabel(miscFrame, 66, "Jump Settings:")
    local jumpBox = Instance.new("TextBox")
    jumpBox.Name = "JumpBox"
    jumpBox.Size = UDim2.new(0.5, -10, 0, 26)
    jumpBox.Position = UDim2.new(0,8,0,88)
    jumpBox.PlaceholderText = "JumpPower (1-150)"
    jumpBox.Text = tostring(self.settings.jumpPower)
    jumpBox.ClearTextOnFocus = false
    jumpBox.Font = Enum.Font.Gotham
    jumpBox.TextSize = 12
    jumpBox.Parent = miscFrame
    Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0,6)

    local setJumpBtn = Instance.new("TextButton")
    setJumpBtn.Size = UDim2.new(0.45, -10, 0, 26)
    setJumpBtn.Position = UDim2.new(0.5, 2, 0, 88)
    setJumpBtn.Text = "Set Jump"
    setJumpBtn.Font = Enum.Font.GothamBold
    setJumpBtn.Parent = miscFrame
    Instance.new("UICorner", setJumpBtn).CornerRadius = UDim.new(0,6)
    setJumpBtn.BackgroundColor3 = Color3.fromRGB(50,160,50)

    -- Toggles (fly, infjump, antiafk)
    local flyToggle = Instance.new("TextButton")
    flyToggle.Name = "FlyToggle"
    flyToggle.Size = UDim2.new(0.48, -10, 0, 26)
    flyToggle.Position = UDim2.new(0,8,0,128)
    flyToggle.Text = "Fly: Off"
    flyToggle.Font = Enum.Font.GothamBold
    flyToggle.Parent = miscFrame
    Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0,6)
    flyToggle.BackgroundColor3 = Color3.fromRGB(70,70,130)

    local infJumpToggle = Instance.new("TextButton")
    infJumpToggle.Name = "InfJumpToggle"
    infJumpToggle.Size = UDim2.new(0.48, -10, 0, 26)
    infJumpToggle.Position = UDim2.new(0.5, 2, 0, 128)
    infJumpToggle.Text = "Infinite Jump: Off"
    infJumpToggle.Font = Enum.Font.GothamBold
    infJumpToggle.Parent = miscFrame
    Instance.new("UICorner", infJumpToggle).CornerRadius = UDim.new(0,6)
    infJumpToggle.BackgroundColor3 = Color3.fromRGB(120,80,80)

    local antiAfkToggle = Instance.new("TextButton")
    antiAfkToggle.Name = "AntiAfkToggle"
    antiAfkToggle.Size = UDim2.new(1, -16, 0, 26)
    antiAfkToggle.Position = UDim2.new(0,8,0,166)
    antiAfkToggle.Text = "Anti AFK: Off"
    antiAfkToggle.Font = Enum.Font.GothamBold
    antiAfkToggle.Parent = miscFrame
    Instance.new("UICorner", antiAfkToggle).CornerRadius = UDim.new(0,6)
    antiAfkToggle.BackgroundColor3 = Color3.fromRGB(90,90,90)

    -- Loop waypoint controls
    createLabel(miscFrame, 206, "Loop Waypoints:")
    local dropdown = Instance.new("TextBox")
    dropdown.Name = "LoopTarget"
    dropdown.Size = UDim2.new(1, -16, 0, 24)
    dropdown.Position = UDim2.new(0,8,0,228)
    dropdown.PlaceholderText = "Type waypoint name (or leave empty for all)"
    dropdown.ClearTextOnFocus = false
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 11
    dropdown.Parent = miscFrame
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0,6)

    local loopCountBox = Instance.new("TextBox")
    loopCountBox.Name = "LoopCount"
    loopCountBox.Size = UDim2.new(0.45, -10, 0, 26)
    loopCountBox.Position = UDim2.new(0,8,0,258)
    loopCountBox.PlaceholderText = "Loops (e.g. 3)"
    loopCountBox.Text = "1"
    loopCountBox.ClearTextOnFocus = false
    loopCountBox.Font = Enum.Font.Gotham
    loopCountBox.TextSize = 11
    loopCountBox.Parent = miscFrame
    Instance.new("UICorner", loopCountBox).CornerRadius = UDim.new(0,6)

    local loopDelayBox = Instance.new("TextBox")
    loopDelayBox.Name = "LoopDelay"
    loopDelayBox.Size = UDim2.new(0.45, -10, 0, 26)
    loopDelayBox.Position = UDim2.new(0.55, 2, 0, 258)
    loopDelayBox.PlaceholderText = "Delay (s)"
    loopDelayBox.Text = tostring(self.settings.loopDelay)
    loopDelayBox.ClearTextOnFocus = false
    loopDelayBox.Font = Enum.Font.Gotham
    loopDelayBox.TextSize = 11
    loopDelayBox.Parent = miscFrame
    Instance.new("UICorner", loopDelayBox).CornerRadius = UDim.new(0,6)

    local startLoopBtn = Instance.new("TextButton")
    startLoopBtn.Name = "StartLoop"
    startLoopBtn.Size = UDim2.new(1, -16, 0, 26)
    startLoopBtn.Position = UDim2.new(0,8,0,292)
    startLoopBtn.Text = "Start Loop"
    startLoopBtn.Font = Enum.Font.GothamBold
    startLoopBtn.Parent = miscFrame
    Instance.new("UICorner", startLoopBtn).CornerRadius = UDim.new(0,6)
    startLoopBtn.BackgroundColor3 = Color3.fromRGB(70,130,200)

    -- Wiring buttons
    saveBtn.MouseButton1Click:Connect(function() self:SaveWaypoint() end)
    setSpeedBtn.MouseButton1Click:Connect(function()
        local n = tonumber(speedBox.Text)
        if not n then self:NotifySmall("Invalid speed") return end
        n = clamp(n, 1, 100)
        self.settings.walkSpeed = n
        self:ApplyWalkSpeed()
        self:NotifySmall("WalkSpeed set to " .. tostring(n))
    end)
    setJumpBtn.MouseButton1Click:Connect(function()
        local n = tonumber(jumpBox.Text)
        if not n then self:NotifySmall("Invalid jump power") return end
        n = clamp(n, 1, 150)
        self.settings.jumpPower = n
        self:ApplyJumpPower()
        self:NotifySmall("JumpPower set to " .. tostring(n))
    end)

    flyToggle.MouseButton1Click:Connect(function()
        self.miscState.fly = not self.miscState.fly
        flyToggle.Text = "Fly: " .. (self.miscState.fly and "On" or "Off")
        if self.miscState.fly then
            self:EnableFly()
        else
            self:DisableFly()
        end
    end)

    infJumpToggle.MouseButton1Click:Connect(function()
        self.miscState.infiniteJump = not self.miscState.infiniteJump
        infJumpToggle.Text = "Infinite Jump: " .. (self.miscState.infiniteJump and "On" or "Off")
    end)

    antiAfkToggle.MouseButton1Click:Connect(function()
        self.miscState.antiAfk = not self.miscState.antiAfk
        antiAfkToggle.Text = "Anti AFK: " .. (self.miscState.antiAfk and "On" or "Off")
        if self.miscState.antiAfk then
            self:EnableAntiAfk()
        else
            self:DisableAntiAfk()
        end
    end)

    startLoopBtn.MouseButton1Click:Connect(function()
        local loops = tonumber(loopCountBox.Text) or 1
        local delay = tonumber(loopDelayBox.Text) or self.settings.loopDelay
        local target = dropdown.Text
        loops = math.max(1, math.floor(loops))
        delay = math.max(0.1, delay)
        self:StartLoopWaypoints(target, loops, delay)
    end)

    -- Tab switching
    tabWay.MouseButton1Click:Connect(function()
        self:SwitchToTab("Way")
    end)
    tabMisc.MouseButton1Click:Connect(function()
        self:SwitchToTab("Misc")
    end)

    -- Min / Close
    minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
    closeBtn.MouseButton1Click:Connect(function() self:CloseGUI() end)
end

-- Tab switch function
function WaypointSystem:SwitchToTab(which)
    if not self.content then return end
    if which == "Way" then
        self.wayFrame.Position = UDim2.new(0,0,0,0)
        self.miscFrame.Position = UDim2.new(1,0,0,0)
    else
        self.wayFrame.Position = UDim2.new(-1,0,0,0)
        self.miscFrame.Position = UDim2.new(0,0,0,0)
    end
end

-- Footer update
function WaypointSystem:UpdateFooter()
    if self.countLabel then
        self.countLabel.Text = "Saved: " .. tostring(self:CountWaypoints())
    end
end

-- Notifications (small)
function WaypointSystem:NotifySmall(text)
    -- short top-center small label
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 200, 0, 28)
    notif.Position = UDim2.new(0.5, 0, 0, -20)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BackgroundColor3 = Color3.fromRGB(40,40,50)
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextSize = 13
    notif.Font = Enum.Font.GothamBold
    notif.Parent = self.gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,6)
    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.25), {Position = UDim2.new(0.5,0,0,8), TextTransparency = 0, BackgroundTransparency = 0})
    tweenIn:Play()
    delay(1.4, function()
        local tweenOut = TweenService:Create(notif, TweenInfo.new(0.2), {Position = UDim2.new(0.5,0,0,-20), TextTransparency = 1, BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function() notif:Destroy() end)
    end)
end

-- Waypoint actions
function WaypointSystem:SaveWaypoint()
    local name = tostring(self.textBox.Text):match("^%s*(.-)%s*$")
    if name == "" then self:NotifySmall("Enter a name!") return end
    if self.waypoints[name] then self:NotifySmall("Name exists!") return end
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then self:NotifySmall("Character not found!") return end
    self.waypoints[name] = hrp.Position
    self:CreateWaypointItem(name)
    self:SaveToFile()
    self.textBox.Text = ""
    self:UpdateFooter()
    self:NotifySmall("Saved: " .. name)
    self:PopulateLoopDropdown()
end

function WaypointSystem:CreateWaypointItem(name)
    if not self.scroll then return end
    local item = Instance.new("Frame")
    item.Name = name
    item.Size = UDim2.new(1, -8, 0, 34)
    item.BackgroundColor3 = Color3.fromRGB(45,45,55)
    item.BorderSizePixel = 0
    item.Parent = self.scroll
    Instance.new("UICorner", item).CornerRadius = UDim.new(0,6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -6, 1, 0)
    label.Position = UDim2.new(0,6,0,0)
    label.BackgroundTransparency = 1
    label.Text = "📌 " .. name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = item

    local goBtn = Instance.new("TextButton")
    goBtn.Size = UDim2.new(0, 50, 0, 24)
    goBtn.Position = UDim2.new(0.5, 6, 0.5, -12)
    goBtn.Text = "➜ Go"
    goBtn.Font = Enum.Font.GothamBold
    goBtn.Parent = item
    Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,6)
    goBtn.BackgroundColor3 = Color3.fromRGB(50,120,200)

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 50, 0, 24)
    delBtn.Position = UDim2.new(1, -58, 0.5, -12)
    delBtn.Text = "🗑️"
    delBtn.Font = Enum.Font.GothamBold
    delBtn.Parent = item
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)
    delBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)

    goBtn.MouseButton1Click:Connect(function() self:GoToWaypoint(name) end)
    delBtn.MouseButton1Click:Connect(function()
        self:DeleteWaypoint(name, item)
    end)
end

function WaypointSystem:GoToWaypoint(name)
    local pos = self.waypoints[name]
    if not pos then self:NotifySmall("Waypoint not found!") return end
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        self:NotifySmall("Teleported to " .. name)
    else
        self:NotifySmall("Character not found!")
    end
end

function WaypointSystem:DeleteWaypoint(name, item)
    self.waypoints[name] = nil
    if item then item:Destroy() end
    self:SaveToFile()
    self:UpdateFooter()
    self:NotifySmall("Deleted: " .. name)
    self:PopulateLoopDropdown()
end

-- Loop waypoints
function WaypointSystem:PopulateLoopDropdown()
    -- no fancy dropdown — user types name or leave empty for all
    -- but we update placeholder to suggest a waypoint name
    if not self.miscFrame then return end
    local box = self.miscFrame:FindFirstChild("LoopTarget")
    if not box then return end
    -- show first waypoint as hint
    for k,_ in pairs(self.waypoints) do
        box.PlaceholderText = "e.g. " .. tostring(k)
        return
    end
    box.PlaceholderText = "Type waypoint name (or leave empty for all)"
end

function WaypointSystem:StartLoopWaypoints(targetName, loops, delaySec)
    if self._looping then
        self:NotifySmall("Already looping")
        return
    end
    -- Build ordered list
    local list = {}
    if targetName and targetName ~= "" then
        if not self.waypoints[targetName] then self:NotifySmall("Target not found") return end
        table.insert(list, targetName)
    else
        for name,_ in pairs(self.waypoints) do table.insert(list, name) end
        table.sort(list)
    end
    if #list == 0 then self:NotifySmall("No waypoints saved") return end

    self._looping = true
    self:NotifySmall("Loop started")
    spawn(function()
        for i = 1, loops do
            if not self._looping then break end
            for _, name in ipairs(list) do
                if not self._looping then break end
                self:GoToWaypoint(name)
                wait(delaySec)
            end
        end
        self._looping = false
        self:NotifySmall("Loop finished")
    end)
end

function WaypointSystem:StopLooping()
    self._looping = false
end

-- Dragging
function WaypointSystem:SetupDragging()
    local dragging, dragStart, startPos
    local header = self.header
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
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

-- Minimize / Close
function WaypointSystem:ToggleMinimize()
    self.isMinimized = not self.isMinimized
    local target = self.isMinimized and MINIMIZED_SIZE or DEFAULT_GUI_SIZE
    self.content.Visible = not self.isMinimized
    self.minBtn.Text = self.isMinimized and "□" or "−"
    local tween = TweenService:Create(self.main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = target})
    tween:Play()
end

function WaypointSystem:CloseGUI()
    local tween = TweenService:Create(self.main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Size = UDim2.new(0,0,0,0)})
    tween:Play()
    tween.Completed:Connect(function()
        if self.gui then self.gui:Destroy() end
        self:NotifySmall("GUI Closed")
    end)
end

-- Movement settings application
function WaypointSystem:ApplyWalkSpeed()
    local char = self.player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = self.settings.walkSpeed or 16
    end
end

function WaypointSystem:ApplyJumpPower()
    local char = self.player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- some games use JumpPower, some use JumpHeight — we set JumpPower
        pcall(function() humanoid.JumpPower = self.settings.jumpPower or 50 end)
    end
end

-- Bind when character added
function WaypointSystem:BindMiscHandlers()
    self.player.CharacterAdded:Connect(function(char)
        wait(0.5)
        self:ApplyWalkSpeed()
        self:ApplyJumpPower()
    end)
    -- apply now if char exist
    if self.player.Character then
        self:ApplyWalkSpeed()
        self:ApplyJumpPower()
    end

    -- infinite jump
    UserInputService.JumpRequest:Connect(function()
        if self.miscState.infiniteJump then
            local char = self.player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Anti AFK
function WaypointSystem:EnableAntiAfk()
    if self._antiAfkConn then return end
    self._antiAfkConn = self.player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    self:NotifySmall("Anti-AFK enabled")
end

function WaypointSystem:DisableAntiAfk()
    if self._antiAfkConn then
        self._antiAfkConn:Disconnect()
        self._antiAfkConn = nil
    end
    self:NotifySmall("Anti-AFK disabled")
end

-- Fly implementation (smooth fly using BodyVelocity & BodyGyro)
function WaypointSystem:EnableFly()
    if self._flyLoop then return end
    local char = self.player.Character
    if not char then self:NotifySmall("Character required for fly"); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then self:NotifySmall("Character invalid"); return end

    -- create controllers
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    self._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(4e5,4e5,4e5)
    bg.P = 2000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    self._flyBG = bg

    -- disable humanoid auto-physics a bit
    if hum then hum.PlatformStand = false end

    -- control via RenderStepped
    local speed =  (tonumber(self.settings.walkSpeed) and clamp(self.settings.walkSpeed,1,100)) or 50
    self._flyLoop = RunService.RenderStepped:Connect(function(dt)
        if not self._flyBV or not hrp then return end
        local moveVec = Vector3.new(0,0,0)
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Vector3.new(forward.X, 0, forward.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - Vector3.new(forward.X, 0, forward.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - Vector3.new(right.X, 0, right.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Vector3.new(right.X, 0, right.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec = moveVec + Vector3.new(0,-1,0) end

        local flySpeed = tonumber(self.settings.flySpeed) or clamp(self.settings.walkSpeed * 2, 10, 300)
        flySpeed = clamp(flySpeed, 10, 1000)

        local vel = (moveVec.Unit ~= moveVec.Unit and Vector3.new(0,0,0) or moveVec.Unit * flySpeed) * (moveVec.Magnitude > 0 and 1 or 0)
        -- smooth lerp
        self._flyBV.Velocity = hrp.CFrame:VectorToWorldSpace(Vector3.new(vel.X, vel.Y, vel.Z))
        self._flyBG.CFrame = workspace.CurrentCamera.CFrame
    end)

    self:NotifySmall("Fly enabled (use WASD + Space/Ctrl)")
end

function WaypointSystem:DisableFly()
    if self._flyLoop then
        self._flyLoop:Disconnect()
        self._flyLoop = nil
    end
    if self._flyBV then
        self._flyBV:Destroy()
        self._flyBV = nil
    end
    if self._flyBG then
        self._flyBG:Destroy()
        self._flyBG = nil
    end
    local char = self.player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    self:NotifySmall("Fly disabled")
end

-- Apply walk speed and jump when user toggles or char spawns
function WaypointSystem:EnableSpeed()
    self:ApplyWalkSpeed()
    self.miscState.speedEnabled = true
end
function WaypointSystem:DisableSpeed()
    self.miscState.speedEnabled = false
    -- optional: reset to default 16
    local humanoid = self.player.Character and self.player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = 16 end
end

-- Utility: when destroying script ensure toggles off
function WaypointSystem:DestroyAll()
    self:DisableFly()
    self:DisableAntiAfk()
    self:StopLooping()
    if self.gui then self.gui:Destroy() end
end

-- Final return
return WaypointSystem.new()
