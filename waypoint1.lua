-- waypoints_v2_1.lua
-- Compact Waypoint + Misc system (LocalScript)
-- Loadable via: loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/waypoints_v2_1.lua"))()

-- =========================
--  CONFIG & SERVICES
-- =========================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LOCAL_PLAYER = Players.LocalPlayer
local STORAGE_FILE = "waypoints_data.json"

-- GUI sizing
local DEFAULT_SIZE = UDim2.new(0, 340, 0, 380) -- slightly larger
local MINIMIZED_SIZE = UDim2.new(0, 340, 0, 40)

-- clamp helper
local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end

-- safe pcall wrappers for file ops
local function safeWriteFile(name, content)
    if writefile then
        local ok, err = pcall(writefile, name, content)
        if not ok then warn("writefile failed:", err) end
    else
        warn("writefile not available in this environment")
    end
end
local function safeReadFile(name)
    if isfile and isfile(name) and readfile then
        local ok, data = pcall(readfile, name)
        if ok then return data end
    end
    return nil
end

-- =========================
--  WAYPOINT SYSTEM OBJECT
-- =========================
local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    self.player = LOCAL_PLAYER
    self.waypoints = {} -- name -> Vector3
    self.ui = {}
    self.isMinimized = false
    self.misc = {
        fly = false,
        antiAfk = false,
        infiniteJump = false,
        looping = false
    }
    self.settings = {
        walkSpeed = 16,
        jumpPower = 50,
        flySpeed = 120,
        loopDelay = 2
    }
    self:_loadWaypoints()
    self:_createGUI()
    self:_populateWaypointsList()
    self:_bindCharacterSettings()
    return self
end

-- =========================
--  PERSISTENCE
-- =========================
function WaypointSystem:_saveWaypointsToFile()
    local data = {}
    for name, pos in pairs(self.waypoints) do
        data[name] = {X = pos.X, Y = pos.Y, Z = pos.Z}
    end
    local json = HttpService:JSONEncode(data)
    safeWriteFile(STORAGE_FILE, json)
end

function WaypointSystem:_loadWaypoints()
    local json = safeReadFile(STORAGE_FILE)
    if json then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
        if ok and type(data) == "table" then
            for name, p in pairs(data) do
                if type(p) == "table" and p.X and p.Y and p.Z then
                    self.waypoints[tostring(name)] = Vector3.new(tonumber(p.X) or 0, tonumber(p.Y) or 0, tonumber(p.Z) or 0)
                end
            end
        end
    end
end

-- =========================
--  UTILITIES
-- =========================
function WaypointSystem:_notify(text)
    -- small top notification
    local gui = self.ui.gui
    if not gui then return end
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 260, 0, 30)
    notif.Position = UDim2.new(0.5, 0, 0, 6)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BackgroundColor3 = Color3.fromRGB(34, 40, 52)
    notif.BorderSizePixel = 0
    notif.Text = " " .. tostring(text)
    notif.TextColor3 = Color3.fromRGB(240,240,240)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 13
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,6)
    local tween1 = TweenService:Create(notif, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0, 46), BackgroundTransparency = 0})
    tween1:Play()
    delay(1.4, function()
        local tween2 = TweenService:Create(notif, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, 0, 0, 6), BackgroundTransparency = 1, TextTransparency = 1})
        tween2:Play()
        tween2.Completed:Connect(function() notif:Destroy() end)
    end)
end

function WaypointSystem:_countWaypoints()
    local c = 0
    for _ in pairs(self.waypoints) do c = c + 1 end
    return c
end

-- =========================
--  GUI CREATION
-- =========================
function WaypointSystem:_createGUI()
    -- cleanup existing if present
    if self.player and self.player.PlayerGui:FindFirstChild("WaypointGUI_v2_1") then
        self.player.PlayerGui.WaypointGUI_v2_1:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WaypointGUI_v2_1"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = self.player.PlayerGui
    self.ui.gui = gui

    -- Main frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = DEFAULT_SIZE
    main.Position = UDim2.new(1, -360, 0.45, -190)
    main.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)
    self.ui.main = main

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Color3.fromRGB(29, 89, 166)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)
    self.ui.header = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, -8, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📍 Waypoints"
    title.TextColor3 = Color3.fromRGB(250,250,250)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Close & Minimize
    local btnClose = Instance.new("TextButton")
    btnClose.Name = "Close"
    btnClose.Size = UDim2.new(0, 34, 0, 30)
    btnClose.Position = UDim2.new(1, -40, 0.5, -15)
    btnClose.BackgroundColor3 = Color3.fromRGB(209,62,62)
    btnClose.Text = "✕"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 16
    btnClose.Parent = header
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)
    self.ui.closeBtn = btnClose

    local btnMin = Instance.new("TextButton")
    btnMin.Name = "Minimize"
    btnMin.Size = UDim2.new(0, 34, 0, 30)
    btnMin.Position = UDim2.new(1, -80, 0.5, -15)
    btnMin.BackgroundColor3 = Color3.fromRGB(222,168,53)
    btnMin.Text = "−"
    btnMin.Font = Enum.Font.GothamBold
    btnMin.TextSize = 16
    btnMin.Parent = header
    Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)
    self.ui.minBtn = btnMin

    -- Tabbar (below header content area)
    local tabbar = Instance.new("Frame")
    tabbar.Name = "Tabbar"
    tabbar.Size = UDim2.new(1, -24, 0, 46)
    tabbar.Position = UDim2.new(0, 12, 0, 52)
    tabbar.BackgroundTransparency = 1
    tabbar.Parent = main
    self.ui.tabbar = tabbar

    -- Tab Buttons centered
    local wayBtn = Instance.new("TextButton")
    wayBtn.Name = "WayBtn"
    wayBtn.Size = UDim2.new(0, 140, 0, 34)
    wayBtn.Position = UDim2.new(0.5, -150, 0, 6)
    wayBtn.BackgroundColor3 = Color3.fromRGB(36, 44, 60)
    wayBtn.Text = "📍 Waypoints"
    wayBtn.Font = Enum.Font.GothamBold
    wayBtn.TextSize = 13
    wayBtn.Parent = tabbar
    Instance.new("UICorner", wayBtn).CornerRadius = UDim.new(0,8)
    self.ui.wayBtn = wayBtn

    local miscBtn = Instance.new("TextButton")
    miscBtn.Name = "MiscBtn"
    miscBtn.Size = UDim2.new(0, 120, 0, 34)
    miscBtn.Position = UDim2.new(0.5, -8, 0, 6)
    miscBtn.BackgroundColor3 = Color3.fromRGB(36, 44, 60)
    miscBtn.Text = "⚙️ Misc"
    miscBtn.Font = Enum.Font.GothamBold
    miscBtn.TextSize = 13
    miscBtn.Parent = tabbar
    Instance.new("UICorner", miscBtn).CornerRadius = UDim.new(0,8)
    self.ui.miscBtn = miscBtn

    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -24, 1, -110)
    content.Position = UDim2.new(0, 12, 0, 104)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.ui.content = content

    -- Waypoints Panel (left)
    local wayPanel = Instance.new("Frame")
    wayPanel.Name = "WayPanel"
    wayPanel.Size = UDim2.new(1, 0, 1, 0)
    wayPanel.BackgroundTransparency = 1
    wayPanel.Parent = content
    self.ui.wayPanel = wayPanel

    -- Input box + Save
    local inputBox = Instance.new("Frame")
    inputBox.Size = UDim2.new(1, 0, 0, 70)
    inputBox.Position = UDim2.new(0, 0, 0, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 35, 44)
    inputBox.Parent = wayPanel
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,8)

    local nameBox = Instance.new("TextBox")
    nameBox.Name = "NameBox"
    nameBox.Size = UDim2.new(0.65, -12, 0, 30)
    nameBox.Position = UDim2.new(0, 8, 0, 12)
    nameBox.PlaceholderText = "Waypoint name..."
    nameBox.ClearTextOnFocus = false
    nameBox.Text = ""
    nameBox.BackgroundColor3 = Color3.fromRGB(40,45,54)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 13
    nameBox.TextColor3 = Color3.fromRGB(240,240,240)
    nameBox.Parent = inputBox
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)
    self.ui.nameBox = nameBox

    local saveBtn = Instance.new("TextButton")
    saveBtn.Name = "SaveBtn"
    saveBtn.Size = UDim2.new(0.33, -12, 0, 30)
    saveBtn.Position = UDim2.new(0.66, 8, 0, 12)
    saveBtn.Text = "💾 Save Position"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 13
    saveBtn.Parent = inputBox
    saveBtn.BackgroundColor3 = Color3.fromRGB(60,150,90)
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)
    self.ui.saveBtn = saveBtn

    -- Waypoints list (scrolling)
    local wayScroll = Instance.new("ScrollingFrame")
    wayScroll.Name = "WayScroll"
    wayScroll.Size = UDim2.new(1, 0, 1, -78)
    wayScroll.Position = UDim2.new(0, 0, 0, 78)
    wayScroll.BackgroundColor3 = Color3.fromRGB(28,33,40)
    wayScroll.BorderSizePixel = 0
    wayScroll.ScrollBarThickness = 8
    wayScroll.Parent = wayPanel
    Instance.new("UICorner", wayScroll).CornerRadius = UDim.new(0,8)
    self.ui.wayScroll = wayScroll

    local wayLayout = Instance.new("UIListLayout")
    wayLayout.Parent = wayScroll
    wayLayout.SortOrder = Enum.SortOrder.LayoutOrder
    wayLayout.Padding = UDim.new(0,8)
    wayLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        wayScroll.CanvasSize = UDim2.new(0, 0, 0, wayLayout.AbsoluteContentSize.Y + 10)
    end)
    self.ui.wayLayout = wayLayout

    -- Misc Panel (overlaid, initially hidden)
    local miscPanel = Instance.new("Frame")
    miscPanel.Name = "MiscPanel"
    miscPanel.Size = UDim2.new(1, 0, 1, 0)
    miscPanel.Position = UDim2.new(1, 0, 0, 0) -- off-screen to the right
    miscPanel.BackgroundTransparency = 1
    miscPanel.Parent = content
    self.ui.miscPanel = miscPanel

    -- Misc scroll frame
    local miscScroll = Instance.new("ScrollingFrame")
    miscScroll.Name = "MiscScroll"
    miscScroll.Size = UDim2.new(1, 0, 1, 0)
    miscScroll.Position = UDim2.new(0, 0, 0, 0)
    miscScroll.BackgroundColor3 = Color3.fromRGB(28,33,40)
    miscScroll.BorderSizePixel = 0
    miscScroll.ScrollBarThickness = 8
    miscScroll.Parent = miscPanel
    Instance.new("UICorner", miscScroll).CornerRadius = UDim.new(0,8)
    self.ui.miscScroll = miscScroll

    local miscLayout = Instance.new("UIListLayout")
    miscLayout.Parent = miscScroll
    miscLayout.SortOrder = Enum.SortOrder.LayoutOrder
    miscLayout.Padding = UDim.new(0,10)
    miscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        miscScroll.CanvasSize = UDim2.new(0, 0, 0, miscLayout.AbsoluteContentSize.Y + 14)
    end)
    self.ui.miscLayout = miscLayout

    -- build misc controls (as frames for spacing)
    local function addSection(title)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -12, 0, 72)
        frame.Position = UDim2.new(0, 6, 0, 6)
        frame.BackgroundTransparency = 1
        frame.Parent = miscScroll

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextColor3 = Color3.fromRGB(230,230,230)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        return frame
    end

    -- Movement section
    local s1 = addSection("Movement Settings")
    s1.Size = UDim2.new(1, -12, 0, 86)
    s1.Parent = miscScroll
    do
        local speedBox = Instance.new("TextBox")
        speedBox.Name = "SpeedBox"
        speedBox.Size = UDim2.new(0.55, -8, 0, 28)
        speedBox.Position = UDim2.new(0, 0, 0, 22)
        speedBox.PlaceholderText = "Walk Speed (1-100)"
        speedBox.Text = tostring(self.settings.walkSpeed)
        speedBox.ClearTextOnFocus = false
        speedBox.BackgroundColor3 = Color3.fromRGB(36,41,50)
        speedBox.Font = Enum.Font.Gotham
        speedBox.TextSize = 13
        speedBox.Parent = s1
        Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)
        self.ui.speedBox = speedBox

        local applySpeed = Instance.new("TextButton")
        applySpeed.Size = UDim2.new(0.43, 0, 0, 28)
        applySpeed.Position = UDim2.new(0.57, 8, 0, 22)
        applySpeed.Text = "Set Speed"
        applySpeed.Font = Enum.Font.GothamBold
        applySpeed.TextSize = 13
        applySpeed.Parent = s1
        applySpeed.BackgroundColor3 = Color3.fromRGB(60,150,90)
        Instance.new("UICorner", applySpeed).CornerRadius = UDim.new(0,6)
        self.ui.applySpeed = applySpeed

        local jumpBox = Instance.new("TextBox")
        jumpBox.Name = "JumpBox"
        jumpBox.Size = UDim2.new(0.55, -8, 0, 28)
        jumpBox.Position = UDim2.new(0, 0, 0, 52)
        jumpBox.PlaceholderText = "JumpPower (1-150)"
        jumpBox.Text = tostring(self.settings.jumpPower)
        jumpBox.ClearTextOnFocus = false
        jumpBox.BackgroundColor3 = Color3.fromRGB(36,41,50)
        jumpBox.Font = Enum.Font.Gotham
        jumpBox.TextSize = 13
        jumpBox.Parent = s1
        Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0,6)
        self.ui.jumpBox = jumpBox

        local applyJump = Instance.new("TextButton")
        applyJump.Size = UDim2.new(0.43, 0, 0, 28)
        applyJump.Position = UDim2.new(0.57, 8, 0, 52)
        applyJump.Text = "Set Jump"
        applyJump.Font = Enum.Font.GothamBold
        applyJump.TextSize = 13
        applyJump.Parent = s1
        applyJump.BackgroundColor3 = Color3.fromRGB(60,150,90)
        Instance.new("UICorner", applyJump).CornerRadius = UDim.new(0,6)
        self.ui.applyJump = applyJump
    end

    -- Toggles section
    local s2 = addSection("Toggles")
    s2.Size = UDim2.new(1, -12, 0, 140)
    s2.Parent = miscScroll
    do
        local flyBtn = Instance.new("TextButton")
        flyBtn.Name = "FlyBtn"
        flyBtn.Size = UDim2.new(1, 0, 0, 32)
        flyBtn.Position = UDim2.new(0, 0, 0, 22)
        flyBtn.Text = "Fly: Off"
        flyBtn.Font = Enum.Font.GothamBold
        flyBtn.TextSize = 13
        flyBtn.Parent = s2
        flyBtn.BackgroundColor3 = Color3.fromRGB(60,70,110)
        Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,6)
        self.ui.flyBtn = flyBtn

        local infBtn = Instance.new("TextButton")
        infBtn.Name = "InfBtn"
        infBtn.Size = UDim2.new(1, 0, 0, 32)
        infBtn.Position = UDim2.new(0, 0, 0, 62)
        infBtn.Text = "Infinite Jump: Off"
        infBtn.Font = Enum.Font.GothamBold
        infBtn.TextSize = 13
        infBtn.Parent = s2
        infBtn.BackgroundColor3 = Color3.fromRGB(95,60,60)
        Instance.new("UICorner", infBtn).CornerRadius = UDim.new(0,6)
        self.ui.infBtn = infBtn

        local afkBtn = Instance.new("TextButton")
        afkBtn.Name = "AfkBtn"
        afkBtn.Size = UDim2.new(1, 0, 0, 32)
        afkBtn.Position = UDim2.new(0, 0, 0, 102)
        afkBtn.Text = "Anti AFK: Off"
        afkBtn.Font = Enum.Font.GothamBold
        afkBtn.TextSize = 13
        afkBtn.Parent = s2
        afkBtn.BackgroundColor3 = Color3.fromRGB(95,95,95)
        Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0,6)
        self.ui.afkBtn = afkBtn
    end

    -- Loop section
    local s3 = addSection("Loop Waypoints")
    s3.Size = UDim2.new(1, -12, 0, 160)
    s3.Parent = miscScroll
    do
        -- dropdown (non-editable)
        local dd = Instance.new("TextButton")
        dd.Name = "LoopTarget"
        dd.Size = UDim2.new(1, 0, 0, 30)
        dd.Position = UDim2.new(0, 0, 0, 22)
        dd.Text = "Target: All"
        dd.Font = Enum.Font.Gotham
        dd.TextSize = 12
        dd.TextXAlignment = Enum.TextXAlignment.Left
        dd.Parent = s3
        dd.BackgroundColor3 = Color3.fromRGB(36,41,50)
        Instance.new("UICorner", dd).CornerRadius = UDim.new(0,6)
        self.ui.loopTargetBtn = dd

        -- dropdown list (hidden) - inside miscScroll so it scrolls if large
        local ddList = Instance.new("Frame")
        ddList.Name = "LoopList"
        ddList.Size = UDim2.new(1, 0, 0, 0)
        ddList.Position = UDim2.new(0, 0, 0, 54)
        ddList.ClipsDescendants = true
        ddList.BackgroundTransparency = 1
        ddList.Parent = s3
        self.ui.loopList = ddList

        local ddCanvas = Instance.new("ScrollingFrame")
        ddCanvas.Size = UDim2.new(1, 0, 0, 0)
        ddCanvas.Position = UDim2.new(0,0,0,0)
        ddCanvas.BackgroundTransparency = 1
        ddCanvas.ScrollBarThickness = 8
        ddCanvas.Parent = ddList
        Instance.new("UICorner", ddCanvas).CornerRadius = UDim.new(0,6)
        local ddLayout = Instance.new("UIListLayout")
        ddLayout.Parent = ddCanvas
        ddLayout.Padding = UDim.new(0,4)
        ddCanvas:GetPropertyChangedSignal("CanvasPosition"):Connect(function() end)
        self.ui.loopCanvas = ddCanvas
        self.ui.loopLayout = ddLayout

        -- Count & Delay
        local lc = Instance.new("TextBox")
        lc.Name = "LoopCount"
        lc.Size = UDim2.new(0.48, -6, 0, 28)
        lc.Position = UDim2.new(0, 0, 0, 72)
        lc.PlaceholderText = "Loops (e.g. 3)"
        lc.Text = "1"
        lc.ClearTextOnFocus = false
        lc.BackgroundColor3 = Color3.fromRGB(36,41,50)
        lc.Font = Enum.Font.Gotham
        lc.TextSize = 12
        lc.Parent = s3
        Instance.new("UICorner", lc).CornerRadius = UDim.new(0,6)
        self.ui.loopCount = lc

        local delayBox = Instance.new("TextBox")
        delayBox.Name = "LoopDelay"
        delayBox.Size = UDim2.new(0.48, -6, 0, 28)
        delayBox.Position = UDim2.new(0.52, 6, 0, 72)
        delayBox.PlaceholderText = "Delay (s)"
        delayBox.Text = tostring(self.settings.loopDelay)
        delayBox.ClearTextOnFocus = false
        delayBox.BackgroundColor3 = Color3.fromRGB(36,41,50)
        delayBox.Font = Enum.Font.Gotham
        delayBox.TextSize = 12
        delayBox.Parent = s3
        Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0,6)
        self.ui.loopDelay = delayBox

        local startBtn = Instance.new("TextButton")
        startBtn.Name = "StartLoop"
        startBtn.Size = UDim2.new(1, 0, 0, 34)
        startBtn.Position = UDim2.new(0, 0, 0, 108)
        startBtn.Text = "Start Loop"
        startBtn.Font = Enum.Font.GothamBold
        startBtn.TextSize = 13
        startBtn.Parent = s3
        startBtn.BackgroundColor3 = Color3.fromRGB(70,120,190)
        Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)
        self.ui.startLoopBtn = startBtn
    end

    -- footer saved count
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 26)
    footer.Position = UDim2.new(0, 0, 1, -28)
    footer.BackgroundTransparency = 1
    footer.Parent = main

    local savedLabel = Instance.new("TextLabel")
    savedLabel.Size = UDim2.new(1, -16, 1, 0)
    savedLabel.Position = UDim2.new(0, 8, 0, 0)
    savedLabel.BackgroundTransparency = 1
    savedLabel.Text = "Saved: " .. tostring(self:_countWaypoints())
    savedLabel.Font = Enum.Font.Gotham
    savedLabel.TextSize = 12
    savedLabel.TextColor3 = Color3.fromRGB(200,200,200)
    savedLabel.TextXAlignment = Enum.TextXAlignment.Left
    savedLabel.Parent = footer
    self.ui.savedLabel = savedLabel

    -- ===== EVENTS: Buttons and actions =====
    -- Tab switching
    wayBtn.MouseButton1Click:Connect(function()
        self:_switchTo("Way")
    end)
    miscBtn.MouseButton1Click:Connect(function()
        self:_switchTo("Misc")
    end)

    -- Minimize / Close
    btnMin.MouseButton1Click:Connect(function()
        self:_toggleMinimize()
    end)
    btnClose.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.18), {Size = UDim2.new(0,0,0,0)}):Play()
        delay(0.18, function()
            if gui then gui:Destroy() end
        end)
    end)

    -- Save waypoint
    saveBtn.MouseButton1Click:Connect(function()
        self:_saveWaypointFromBox()
    end)

    -- Apply speed/jump
    self.ui.applySpeed.MouseButton1Click:Connect(function()
        local n = tonumber(self.ui.speedBox.Text)
        if not n then self:_notify("Invalid speed") return end
        n = clamp(math.floor(n), 1, 100)
        self.settings.walkSpeed = n
        self:_applyWalkSpeed()
        self:_notify("WalkSpeed set to " .. tostring(n))
    end)
    self.ui.applyJump.MouseButton1Click:Connect(function()
        local n = tonumber(self.ui.jumpBox.Text)
        if not n then self:_notify("Invalid jump power") return end
        n = clamp(math.floor(n), 1, 150)
        self.settings.jumpPower = n
        self:_applyJumpPower()
        self:_notify("JumpPower set to " .. tostring(n))
    end)

    -- Toggles: Fly, Infinite Jump, Anti AFK
    self.ui.flyBtn.MouseButton1Click:Connect(function()
        self.misc.fly = not self.misc.fly
        self.ui.flyBtn.Text = "Fly: " .. (self.misc.fly and "On" or "Off")
        if self.misc.fly then self:_enableFly() else self:_disableFly() end
    end)
    self.ui.infBtn.MouseButton1Click:Connect(function()
        self.misc.infiniteJump = not self.misc.infiniteJump
        self.ui.infBtn.Text = "Infinite Jump: " .. (self.misc.infiniteJump and "On" or "Off")
    end)
    self.ui.afkBtn.MouseButton1Click:Connect(function()
        self.misc.antiAfk = not self.misc.antiAfk
        self.ui.afkBtn.Text = "Anti AFK: " .. (self.misc.antiAfk and "On" or "Off")
        if self.misc.antiAfk then self:_enableAntiAfk() else self:_disableAntiAfk() end
    end)

    -- Loop dropdown behavior
    self.ui.loopTargetBtn.MouseButton1Click:Connect(function()
        self:_toggleLoopDropdown()
    end)

    self.ui.startLoopBtn.MouseButton1Click:Connect(function()
        local target = self._selectedLoopTarget -- nil or name or "All"
        local loops = tonumber(self.ui.loopCount.Text) or 1
        loops = math.max(1, math.floor(loops))
        local delaySec = tonumber(self.ui.loopDelay.Text) or self.settings.loopDelay
        delaySec = math.max(0.1, delaySec)
        self:_startLoop(target, loops, delaySec)
    end)

    -- Tab default
    self:_switchTo("Way")

    -- Dragging (header)
    self:_setupDragging()

    -- Ensure initial UI population
    self:_updateSavedLabel()
end

-- =========================
--  GUI HELPERS
-- =========================
function WaypointSystem:_switchTo(name)
    if name == "Way" then
        self.ui.wayPanel.Position = UDim2.new(0,0,0,0)
        self.ui.miscPanel.Position = UDim2.new(1,0,0,0)
    else
        self.ui.wayPanel.Position = UDim2.new(-1,0,0,0)
        self.ui.miscPanel.Position = UDim2.new(0,0,0,0)
    end
end

function WaypointSystem:_toggleMinimize()
    self.isMinimized = not self.isMinimized
    if self.isMinimized then
        self.ui.content.Visible = false
        TweenService:Create(self.ui.main, TweenInfo.new(0.18), {Size = MINIMIZED_SIZE}):Play()
        self.ui.minBtn.Text = "□"
    else
        self.ui.content.Visible = true
        TweenService:Create(self.ui.main, TweenInfo.new(0.18), {Size = DEFAULT_SIZE}):Play()
        self.ui.minBtn.Text = "−"
    end
end

function WaypointSystem:_setupDragging()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local header = self.ui.header
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = self.ui.main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            self.ui.main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =========================
--  WAYPOINT LIST MANAGEMENT
-- =========================
function WaypointSystem:_createWaypointEntry(name)
    -- create frame inside wayScroll
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -12, 0, 46)
    f.BackgroundColor3 = Color3.fromRGB(34,39,46)
    f.BorderSizePixel = 0
    f.Parent = self.ui.wayScroll
    f.Name = name
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.52, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "📌 " .. name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(240,240,240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f

    local goBtn = Instance.new("TextButton")
    goBtn.Size = UDim2.new(0, 70, 0, 30)
    goBtn.Position = UDim2.new(0.62, 8, 0.5, -15)
    goBtn.Text = "➜ Go"
    goBtn.Font = Enum.Font.GothamBold
    goBtn.TextSize = 12
    goBtn.Parent = f
    goBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
    Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,6)

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 46, 0, 30)
    delBtn.Position = UDim2.new(1, -60, 0.5, -15)
    delBtn.Text = "🗑"
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 13
    delBtn.Parent = f
    delBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,6)

    goBtn.MouseButton1Click:Connect(function()
        self:_teleportTo(name)
    end)

    delBtn.MouseButton1Click:Connect(function()
        self:_deleteWaypoint(name, f)
    end)
end

function WaypointSystem:_populateWaypointsList()
    -- clear existing entries
    for _, child in pairs(self.ui.wayScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    -- create entries
    local names = {}
    for k,_ in pairs(self.waypoints) do table.insert(names, k) end
    table.sort(names)
    for _, name in ipairs(names) do
        self:_createWaypointEntry(name)
    end
    self:_populateLoopDropdown()
    self:_updateSavedLabel()
end

function WaypointSystem:_saveWaypointFromBox()
    local name = tostring(self.ui.nameBox.Text or ""):match("^%s*(.-)%s*$")
    if name == "" then
        self:_notify("Please enter a waypoint name")
        return
    end
    if self.waypoints[name] then
        self:_notify("Waypoint already exists")
        return
    end
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        self:_notify("Character not ready")
        return
    end
    self.waypoints[name] = hrp.Position
    self:_saveWaypointsToFile()
    self:_populateWaypointsList()
    self.ui.nameBox.Text = ""
    self:_notify("Saved waypoint: " .. name)
end

function WaypointSystem:_teleportTo(name)
    local pos = self.waypoints[name]
    if not pos then self:_notify("Waypoint not found") return end
    local char = self.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        self:_notify("Teleported to " .. name)
    else
        self:_notify("Character not ready")
    end
end

function WaypointSystem:_deleteWaypoint(name, frame)
    self.waypoints[name] = nil
    if frame and frame.Parent then frame:Destroy() end
    self:_saveWaypointsToFile()
    self:_populateWaypointsList()
    self:_notify("Deleted: " .. name)
end

function WaypointSystem:_updateSavedLabel()
    if self.ui.savedLabel then
        self.ui.savedLabel.Text = "Saved: " .. tostring(self:_countWaypoints())
    end
end

-- =========================
--  LOOP DROPDOWN
-- =========================
function WaypointSystem:_populateLoopDropdown()
    -- clear existing dd items
    local canvas = self.ui.loopCanvas
    for _, c in pairs(canvas:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    -- "All" option
    local function addOption(text)
        local t = Instance.new("TextButton")
        t.Size = UDim2.new(1, 0, 0, 28)
        t.BackgroundColor3 = Color3.fromRGB(36,41,50)
        t.Text = text
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = canvas
        Instance.new("UICorner", t).CornerRadius = UDim.new(0,6)
        return t
    end
    local all = addOption("All")
    all.MouseButton1Click:Connect(function()
        self._selectedLoopTarget = "All"
        self.ui.loopTargetBtn.Text = "Target: All"
        self:_hideLoopDropdown()
    end)
    -- add waypoints
    local names = {}
    for n,_ in pairs(self.waypoints) do table.insert(names, n) end
    table.sort(names)
    for _, name in ipairs(names) do
        local opt = addOption(name)
        opt.MouseButton1Click:Connect(function()
            self._selectedLoopTarget = name
            self.ui.loopTargetBtn.Text = "Target: " .. name
            self:_hideLoopDropdown()
        end)
    end
    -- adjust canvas size
    local cnt = #names + 1
    local canvasSize = clamp(cnt * 32, 0, 240)
    canvas.Size = UDim2.new(1, 0, 0, canvasSize)
    self.ui.loopList.Size = UDim2.new(1, 0, 0, canvasSize)
    self.ui.loopCanvas.CanvasSize = UDim2.new(0, 0, 0, cnt * 32)
    -- default selected
    if not self._selectedLoopTarget then
        self._selectedLoopTarget = "All"
        self.ui.loopTargetBtn.Text = "Target: All"
    end
end

function WaypointSystem:_toggleLoopDropdown()
    local list = self.ui.loopList
    if not list then return end
    if list.Size.Y.Offset > 0 then
        self:_hideLoopDropdown()
    else
        self:_populateLoopDropdown()
        -- expand
        list.Size = UDim2.new(1, 0, 0, 180)
        self.ui.loopCanvas.Visible = true
    end
end

function WaypointSystem:_hideLoopDropdown()
    if self.ui.loopList then
        self.ui.loopList.Size = UDim2.new(1, 0, 0, 0)
        self.ui.loopCanvas.Visible = false
    end
end

-- =========================
--  LOOP WAYPOINTS
-- =========================
function WaypointSystem:_startLoop(target, loops, delaySec)
    if self.misc.looping then
        self:_notify("Loop already running")
        return
    end
    local list = {}
    if not target or target == "All" then
        for name,_ in pairs(self.waypoints) do table.insert(list, name) end
        table.sort(list)
    else
        if not self.waypoints[target] then
            self:_notify("Target not found")
            return
        end
        table.insert(list, target)
    end
    if #list == 0 then
        self:_notify("No waypoints to loop")
        return
    end
    self.misc.looping = true
    self:_notify("Loop started")
    spawn(function()
        for i = 1, loops do
            if not self.misc.looping then break end
            for _, name in ipairs(list) do
                if not self.misc.looping then break end
                self:_teleportTo(name)
                wait(delaySec)
            end
        end
        self.misc.looping = false
        self:_notify("Loop finished")
    end)
end

function WaypointSystem:_stopLoop()
    self.misc.looping = false
end

-- =========================
--  MOVEMENT & MISC BEHAVIORS
-- =========================
function WaypointSystem:_bindCharacterSettings()
    self.player.CharacterAdded:Connect(function(char)
        wait(0.5)
        self:_applyWalkSpeed()
        self:_applyJumpPower()
    end)
    if self.player.Character then
        self:_applyWalkSpeed()
        self:_applyJumpPower()
    end

    -- infinite jump binding
    UserInputService.JumpRequest:Connect(function()
        if self.misc.infiniteJump then
            local char = self.player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

function WaypointSystem:_applyWalkSpeed()
    local char = self.player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.WalkSpeed = tonumber(self.settings.walkSpeed) or 16 end)
    end
end

function WaypointSystem:_applyJumpPower()
    local char = self.player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.JumpPower = tonumber(self.settings.jumpPower) or 50 end)
    end
end

-- Anti AFK
function WaypointSystem:_enableAntiAfk()
    if self._afkConn then return end
    self._afkConn = self.player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
    self:_notify("Anti AFK enabled")
end
function WaypointSystem:_disableAntiAfk()
    if self._afkConn then self._afkConn:Disconnect(); self._afkConn = nil end
    self:_notify("Anti AFK disabled")
end

-- Fly implementation (smooth)
function WaypointSystem:_enableFly()
    if self._flyConn then return end
    local char = self.player.Character
    if not char then self:_notify("Character required for Fly"); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then self:_notify("Invalid character for Fly"); return end

    -- create controllers
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.P = 2500
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    self._flyBV = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(4e5,4e5,4e5)
    bg.P = 2000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    self._flyBG = bg

    self._flyConn = RunService.RenderStepped:Connect(function()
        if not self._flyBV or not hrp then return end
        local cam = workspace.CurrentCamera
        local forward = cam and cam.CFrame.LookVector or Vector3.new(0,0,-1)
        local right = cam and cam.CFrame.RightVector or Vector3.new(1,0,0)
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(forward.X, 0, forward.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Vector3.new(forward.X, 0, forward.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Vector3.new(right.X, 0, right.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(right.X, 0, right.Z) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move + Vector3.new(0,-1,0) end

        local spd = tonumber(self.settings.flySpeed) or 120
        spd = clamp(spd, 20, 1000)
        local vel = (move.Magnitude > 0) and move.Unit * spd or Vector3.new(0,0,0)
        self._flyBV.Velocity = hrp.CFrame:VectorToWorldSpace(Vector3.new(vel.X, vel.Y, vel.Z))
        self._flyBG.CFrame = workspace.CurrentCamera.CFrame
    end)

    self:_notify("Fly enabled — use WASD + Space/Ctrl")
end

function WaypointSystem:_disableFly()
    if self._flyConn then self._flyConn:Disconnect(); self._flyConn = nil end
    if self._flyBV then self._flyBV:Destroy(); self._flyBV = nil end
    if self._flyBG then self._flyBG:Destroy(); self._flyBG = nil end
    self:_notify("Fly disabled")
end

-- =========================
--  LOOP, CLEANUP & FINAL
-- =========================
function WaypointSystem:Destroy()
    -- cleanup
    self:_disableFly()
    self:_disableAntiAfk()
    self:_stopLoop()
    if self.ui.gui then self.ui.gui:Destroy() end
end

-- expose for usage
local system = WaypointSystem.new()

-- Populate dropdown initial
system:_populateLoopDropdown()

-- ensure misc UI updates when waypoints change
-- (hook Save/Delete functions already call populate; here we provide fallback)
spawn(function()
    while system and system.ui and system.ui.gui and system.ui.gui.Parent do
        system:_updateSavedLabel()
        wait(2)
    end
end)

-- Optional: Return system for console manipulation
return system
