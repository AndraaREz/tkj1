-- waypoints.lua
-- Compact Waypoint System for Roblox with Persistent Storage
-- Load: loadstring(game:HttpGet(""))()

local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Storage file name
local STORAGE_FILE = "waypoints_data.json"

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    self.player = Players.LocalPlayer
    self.waypoints = {}
    self.isMinimized = false
	self.currentTab = "Waypoint" -- Tambahkan ini
    self:Initialize()
    return self
end

function WaypointSystem:Initialize()
    self:LoadWaypoints() -- Load saved waypoints first
    self:CreateGUI()
    self:SetupDragging()
    self:LoadWaypointsToGUI() -- Display loaded waypoints
	self:ApplyAntiAfk() -- Mulai anti-AFK

    print("✅ Waypoint System loaded!")
    print("📂 Loaded " .. self:CountWaypoints() .. " saved waypoints")
end

function WaypointSystem:CountWaypoints()
    local count = 0
    for _ in pairs(self.waypoints) do count = count + 1 end
    return count
end

-- Save waypoints to file
function WaypointSystem:SaveToFile()
    local success, err = pcall(function()
        local data = {}
        for name, pos in pairs(self.waypoints) do
            data[name] = {
                X = pos.X,
                Y = pos.Y,
                Z = pos.Z
            }
        end
        local jsonData = HttpService:JSONEncode(data)
        writefile(STORAGE_FILE, jsonData)
    end)

    if not success then
        warn("❌ Failed to save waypoints:", err)
    end
end

-- Load waypoints from file
function WaypointSystem:LoadWaypoints()
    local success, err = pcall(function()
        if isfile(STORAGE_FILE) then
            local jsonData = readfile(STORAGE_FILE)
            local data = HttpService:JSONDecode(jsonData)

            for name, pos in pairs(data) do
                self.waypoints[name] = Vector3.new(pos.X, pos.Y, pos.Z)
            end
        end
    end)

    if not success then
        warn("⚠️ No saved waypoints or failed to load:", err)
    end
end

-- Load saved waypoints to GUI
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

    -- Main Container
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 280, 0, 320)
    main.Position = UDim2.new(1, -300, 0.5, -160)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    self.main = main

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- Header
    self:CreateHeader(main)

    -- Content (akan di-hide saat minimize)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.content = content

	-- Tabs
	self:CreateTabs(main)

    -- Waypoint Section
    local waypointSection = Instance.new("Frame")
    waypointSection.Name = "WaypointSection"
    waypointSection.Size = UDim2.new(1, 0, 1, 0)
    waypointSection.Position = UDim2.new(0, 0, 0, 0)
    waypointSection.BackgroundTransparency = 1
    waypointSection.Parent = content
    self.waypointSection = waypointSection

    self:CreateInputSection(waypointSection)
    self:CreateWaypointsList(waypointSection)
    self:CreateFooter(waypointSection)

    -- Misc Section
    local miscSection = Instance.new("Frame")
    miscSection.Name = "MiscSection"
    miscSection.Size = UDim2.new(1, 0, 1, 0)
    miscSection.Position = UDim2.new(0, 0, 0, 0)
    miscSection.BackgroundTransparency = 1
    miscSection.Visible = false
    miscSection.Parent = content
    self.miscSection = miscSection

    self:CreateMiscSection(miscSection)

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

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "📍 Waypoints"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
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

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    self.closeBtn = closeBtn

    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    -- Button Events
    minBtn.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:CloseGUI()
    end)
end

function WaypointSystem:CreateTabs(parent)
	local tabs = Instance.new("Frame")
	tabs.Name = "Tabs"
	tabs.Size = UDim2.new(1, 0, 0, 30)
	tabs.Position = UDim2.new(0, 0, 0, 0)
	tabs.BackgroundTransparency = 1
	tabs.Parent = parent

	-- Waypoint Tab Button
	local waypointTabBtn = Instance.new("TextButton")
	waypointTabBtn.Name = "WaypointTabBtn"
	waypointTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
	waypointTabBtn.Position = UDim2.new(0, 0, 0, 0)
	waypointTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	waypointTabBtn.Text = "Waypoints"
	waypointTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	waypointTabBtn.TextSize = 12
	waypointTabBtn.Font = Enum.Font.GothamBold
	waypointTabBtn.Parent = tabs

	Instance.new("UICorner", waypointTabBtn).CornerRadius = UDim.new(0, 5)

	-- Misc Tab Button
	local miscTabBtn = Instance.new("TextButton")
	miscTabBtn.Name = "MiscTabBtn"
	miscTabBtn.Size = UDim2.new(0.5, 0, 1, 0)
	miscTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
	miscTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	miscTabBtn.Text = "Misc"
	miscTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	miscTabBtn.TextSize = 12
	miscTabBtn.Font = Enum.Font.GothamBold
	miscTabBtn.Parent = tabs

	Instance.new("UICorner", miscTabBtn).CornerRadius = UDim.new(0, 5)

	-- Tab switching logic
	local function switchTab(tabName)
		if tabName == "Waypoint" then
			self.waypointSection.Visible = true
			self.miscSection.Visible = false
			self.currentTab = "Waypoint"
			waypointTabBtn.BackgroundColor3 = Color3.fromRGB(35, 100, 180)
			miscTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		elseif tabName == "Misc" then
			self.waypointSection.Visible = false
			self.miscSection.Visible = true
			self.currentTab = "Misc"
			waypointTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
			miscTabBtn.BackgroundColor3 = Color3.fromRGB(35, 100, 180)
		end
	end

	waypointTabBtn.MouseButton1Click:Connect(function()
		switchTab("Waypoint")
	end)

	miscTabBtn.MouseButton1Click:Connect(function()
		switchTab("Misc")
	end)
end

function WaypointSystem:CreateInputSection(parent)
    local input = Instance.new("Frame")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 75)
    input.Position = UDim2.new(0, 10, 0, 10)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    input.BorderSizePixel = 0
    input.Parent = parent

    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

    -- TextBox
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

    -- Save Button
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
    self:SaveToFile() -- Save to file immediately
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

    -- Name Label
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

    -- Go Button
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

    -- Delete Button
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

    -- Events
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
    self:SaveToFile() -- Save after delete
    self:UpdateFooter()
    self:Notify("🗑️ Deleted: " .. name, Color3.fromRGB(220, 150, 50))
end

function WaypointSystem:ToggleMinimize()
    self.isMinimized = not self.isMinimized

    local targetSize
    local btnText

    if self.isMinimized then
        targetSize = UDim2.new(0, 280, 0, 35)
        btnText = "□"
    else
        targetSize = UDim2.new(0, 280, 0, 320)
        btnText = "−"
    end

    -- Menyembunyikan atau menampilkan konten berdasarkan status minimize
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

-- Bagian Misc

function WaypointSystem:CreateMiscSection(parent)
    local section = Instance.new("Frame")
    section.Name = "MiscOptions"
    section.Size = UDim2.new(1, -20, 1, -20)
    section.Position = UDim2.new(0, 10, 0, 10)
    section.BackgroundTransparency = 1
    section.Parent = parent

    -- Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.5, 0, 0, 20)
    speedLabel.Position = UDim2.new(0, 0, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed (1-100):"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = section

    local speedTextBox = Instance.new("TextBox")
    speedTextBox.Name = "SpeedTextBox"
    speedTextBox.Size = UDim2.new(0.5, -10, 0, 25)
    speedTextBox.Position = UDim2.new(0, 20, 0, 20)
    speedTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    speedTextBox.Text = "50"
    speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedTextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
    speedTextBox.TextSize = 13
    speedTextBox.Font = Enum.Font.Gotham
    speedTextBox.ClearTextOnFocus = false
    speedTextBox.Parent = section

    Instance.new("UICorner", speedTextBox).CornerRadius = UDim.new(0, 6)
    local speedPadding = Instance.new("UIPadding", speedTextBox)
    speedPadding.PaddingLeft = UDim.new(0, 8)

	speedTextBox.FocusLost:Connect(function(enterPressed)
		local speed = tonumber(speedTextBox.Text)
		if speed then
			speed = math.clamp(speed, 1, 100)
			speedTextBox.Text = tostring(speed)
			self:SetWalkSpeed(speed)
		else
			speedTextBox.Text = "50"
			self:SetWalkSpeed(50)
		end
	end)

    -- Jump Power
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0.5, 0, 0, 20)
    jumpLabel.Position = UDim2.new(0, 0, 0.2, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump Power (1-150):"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.TextSize = 12
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = section

    local jumpTextBox = Instance.new("TextBox")
    jumpTextBox.Name = "JumpTextBox"
    jumpTextBox.Size = UDim2.new(0.5, -10, 0, 25)
    jumpTextBox.Position = UDim2.new(0, 20, 0.2, 20)
    jumpTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    jumpTextBox.Text = "50"
    jumpTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpTextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
    jumpTextBox.TextSize = 13
    jumpTextBox.Font = Enum.Font.Gotham
    jumpTextBox.ClearTextOnFocus = false
    jumpTextBox.Parent = section

    Instance.new("UICorner", jumpTextBox).CornerRadius = UDim.new(0, 6)
    local jumpPadding = Instance.new("UIPadding", jumpTextBox)
    jumpPadding.PaddingLeft = UDim.new(0, 8)

	jumpTextBox.FocusLost:Connect(function(enterPressed)
		local jumpPower = tonumber(jumpTextBox.Text)
		if jumpPower then
			jumpPower = math.clamp(jumpPower, 1, 150)
			jumpTextBox.Text = tostring(jumpPower)
			self:SetJumpPower(jumpPower)
		else
			jumpTextBox.Text = "50"
			self:SetJumpPower(50)
		end
	end)

    -- Infinite Jump
    local infJumpToggle = Instance.new("TextButton")
    infJumpToggle.Name = "InfJumpToggle"
    infJumpToggle.Size = UDim2.new(0.9, 0, 0, 30)
    infJumpToggle.Position = UDim2.new(0.05, 0, 0.4, 20)
    infJumpToggle.
