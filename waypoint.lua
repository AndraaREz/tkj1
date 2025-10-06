-- Waypoint & Misc GUI for Roblox
-- Save this as a .lua file and host on GitHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local waypoints = {}
local antiAfkEnabled = false
local flyEnabled = false
local infJumpEnabled = false
local flySpeed = 50
local originalJumpPower = humanoid.JumpPower
local flyConnection

-- Load saved waypoints from DataStore (simulated with table)
local function loadWaypoints()
    -- In real implementation, use DataStoreService
    -- For now, we'll use a temporary storage
    if _G.SavedWaypoints then
        waypoints = _G.SavedWaypoints
    end
end

local function saveWaypoints()
    _G.SavedWaypoints = waypoints
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WaypointGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 15)
TopBarCover.Position = UDim2.new(0, 0, 1, -15)
TopBarCover.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Waypoint System"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -65, 0, 2.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

-- Tab Buttons Frame
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 40)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

-- Waypoint Tab Button
local WaypointTab = Instance.new("TextButton")
WaypointTab.Name = "WaypointTab"
WaypointTab.Size = UDim2.new(0.48, 0, 1, 0)
WaypointTab.Position = UDim2.new(0, 0, 0, 0)
WaypointTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
WaypointTab.Text = "Waypoints"
WaypointTab.TextColor3 = Color3.fromRGB(255, 255, 255)
WaypointTab.TextSize = 14
WaypointTab.Font = Enum.Font.GothamBold
WaypointTab.Parent = TabFrame

local WayCorner = Instance.new("UICorner")
WayCorner.CornerRadius = UDim.new(0, 6)
WayCorner.Parent = WaypointTab

-- Misc Tab Button
local MiscTab = Instance.new("TextButton")
MiscTab.Name = "MiscTab"
MiscTab.Size = UDim2.new(0.48, 0, 1, 0)
MiscTab.Position = UDim2.new(0.52, 0, 0, 0)
MiscTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MiscTab.Text = "Misc"
MiscTab.TextColor3 = Color3.fromRGB(255, 255, 255)
MiscTab.TextSize = 14
MiscTab.Font = Enum.Font.GothamBold
MiscTab.Parent = TabFrame

local MiscCorner = Instance.new("UICorner")
MiscCorner.CornerRadius = UDim.new(0, 6)
MiscCorner.Parent = MiscTab

-- Waypoint Content Frame
local WaypointContent = Instance.new("Frame")
WaypointContent.Name = "WaypointContent"
WaypointContent.Size = UDim2.new(1, -20, 1, -90)
WaypointContent.Position = UDim2.new(0, 10, 0, 80)
WaypointContent.BackgroundTransparency = 1
WaypointContent.Visible = true
WaypointContent.Parent = MainFrame

-- Set Waypoint Input
local SetLabel = Instance.new("TextLabel")
SetLabel.Size = UDim2.new(1, 0, 0, 20)
SetLabel.Position = UDim2.new(0, 0, 0, 0)
SetLabel.BackgroundTransparency = 1
SetLabel.Text = "Set Waypoint:"
SetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SetLabel.TextSize = 12
SetLabel.Font = Enum.Font.Gotham
SetLabel.TextXAlignment = Enum.TextXAlignment.Left
SetLabel.Parent = WaypointContent

local WaypointNameBox = Instance.new("TextBox")
WaypointNameBox.Name = "WaypointNameBox"
WaypointNameBox.Size = UDim2.new(0.65, 0, 0, 30)
WaypointNameBox.Position = UDim2.new(0, 0, 0, 25)
WaypointNameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WaypointNameBox.PlaceholderText = "Waypoint Name"
WaypointNameBox.Text = ""
WaypointNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WaypointNameBox.TextSize = 12
WaypointNameBox.Font = Enum.Font.Gotham
WaypointNameBox.Parent = WaypointContent

local NameCorner = Instance.new("UICorner")
NameCorner.CornerRadius = UDim.new(0, 4)
NameCorner.Parent = WaypointNameBox

local SetWaypointBtn = Instance.new("TextButton")
SetWaypointBtn.Name = "SetWaypointBtn"
SetWaypointBtn.Size = UDim2.new(0.32, 0, 0, 30)
SetWaypointBtn.Position = UDim2.new(0.68, 0, 0, 25)
SetWaypointBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
SetWaypointBtn.Text = "Set"
SetWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetWaypointBtn.TextSize = 12
SetWaypointBtn.Font = Enum.Font.GothamBold
SetWaypointBtn.Parent = WaypointContent

local SetCorner = Instance.new("UICorner")
SetCorner.CornerRadius = UDim.new(0, 4)
SetCorner.Parent = SetWaypointBtn

-- Waypoint List
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, 0, 0, 20)
ListLabel.Position = UDim2.new(0, 0, 0, 65)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "Saved Waypoints:"
ListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ListLabel.TextSize = 12
ListLabel.Font = Enum.Font.Gotham
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = WaypointContent

local WaypointList = Instance.new("ScrollingFrame")
WaypointList.Name = "WaypointList"
WaypointList.Size = UDim2.new(1, 0, 1, -90)
WaypointList.Position = UDim2.new(0, 0, 0, 90)
WaypointList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WaypointList.BorderSizePixel = 0
WaypointList.ScrollBarThickness = 4
WaypointList.Parent = WaypointContent

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 6)
ListCorner.Parent = WaypointList

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = WaypointList

-- Misc Content Frame
local MiscContent = Instance.new("Frame")
MiscContent.Name = "MiscContent"
MiscContent.Size = UDim2.new(1, -20, 1, -90)
MiscContent.Position = UDim2.new(0, 10, 0, 80)
MiscContent.BackgroundTransparency = 1
MiscContent.Visible = false
MiscContent.Parent = MainFrame

local MiscScroll = Instance.new("ScrollingFrame")
MiscScroll.Name = "MiscScroll"
MiscScroll.Size = UDim2.new(1, 0, 1, 0)
MiscScroll.BackgroundTransparency = 1
MiscScroll.BorderSizePixel = 0
MiscScroll.ScrollBarThickness = 4
MiscScroll.Parent = MiscContent

local MiscLayout = Instance.new("UIListLayout")
MiscLayout.SortOrder = Enum.SortOrder.LayoutOrder
MiscLayout.Padding = UDim.new(0, 10)
MiscLayout.Parent = MiscScroll

-- Speed Control
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Name = "SpeedFrame"
SpeedFrame.Size = UDim2.new(1, 0, 0, 60)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedFrame.BorderSizePixel = 0
SpeedFrame.Parent = MiscScroll

local SpeedFrameCorner = Instance.new("UICorner")
SpeedFrameCorner.CornerRadius = UDim.new(0, 6)
SpeedFrameCorner.Parent = SpeedFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.Position = UDim2.new(0, 5, 0, 5)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed (1-100):"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Name = "SpeedBox"
SpeedBox.Size = UDim2.new(1, -10, 0, 25)
SpeedBox.Position = UDim2.new(0, 5, 0, 30)
SpeedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedBox.PlaceholderText = "16"
SpeedBox.Text = "16"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 12
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Parent = SpeedFrame

local SpeedBoxCorner = Instance.new("UICorner")
SpeedBoxCorner.CornerRadius = UDim.new(0, 4)
SpeedBoxCorner.Parent = SpeedBox

-- Jump Power Control
local JumpFrame = Instance.new("Frame")
JumpFrame.Name = "JumpFrame"
JumpFrame.Size = UDim2.new(1, 0, 0, 60)
JumpFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
JumpFrame.BorderSizePixel = 0
JumpFrame.Parent = MiscScroll

local JumpFrameCorner = Instance.new("UICorner")
JumpFrameCorner.CornerRadius = UDim.new(0, 6)
JumpFrameCorner.Parent = JumpFrame

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -10, 0, 20)
JumpLabel.Position = UDim2.new(0, 5, 0, 5)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power (1-150):"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Parent = JumpFrame

local JumpBox = Instance.new("TextBox")
JumpBox.Name = "JumpBox"
JumpBox.Size = UDim2.new(1, -10, 0, 25)
JumpBox.Position = UDim2.new(0, 5, 0, 30)
JumpBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
JumpBox.PlaceholderText = "50"
JumpBox.Text = "50"
JumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBox.TextSize = 12
JumpBox.Font = Enum.Font.Gotham
JumpBox.Parent = JumpFrame

local JumpBoxCorner = Instance.new("UICorner")
JumpBoxCorner.CornerRadius = UDim.new(0, 4)
JumpBoxCorner.Parent = JumpBox

-- Infinite Jump Toggle
local InfJumpFrame = Instance.new("Frame")
InfJumpFrame.Name = "InfJumpFrame"
InfJumpFrame.Size = UDim2.new(1, 0, 0, 40)
InfJumpFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
InfJumpFrame.BorderSizePixel = 0
InfJumpFrame.Parent = MiscScroll

local InfJumpCorner = Instance.new("UICorner")
InfJumpCorner.CornerRadius = UDim.new(0, 6)
InfJumpCorner.Parent = InfJumpFrame

local InfJumpBtn = Instance.new("TextButton")
InfJumpBtn.Name = "InfJumpBtn"
InfJumpBtn.Size = UDim2.new(1, -10, 1, -10)
InfJumpBtn.Position = UDim2.new(0, 5, 0, 5)
InfJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
InfJumpBtn.Text = "Infinite Jump: OFF"
InfJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpBtn.TextSize = 12
InfJumpBtn.Font = Enum.Font.GothamBold
InfJumpBtn.Parent = InfJumpFrame

local InfJumpBtnCorner = Instance.new("UICorner")
InfJumpBtnCorner.CornerRadius = UDim.new(0, 4)
InfJumpBtnCorner.Parent = InfJumpBtn

-- Fly Toggle
local FlyFrame = Instance.new("Frame")
FlyFrame.Name = "FlyFrame"
FlyFrame.Size = UDim2.new(1, 0, 0, 40)
FlyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlyFrame.BorderSizePixel = 0
FlyFrame.Parent = MiscScroll

local FlyFrameCorner = Instance.new("UICorner")
FlyFrameCorner.CornerRadius = UDim.new(0, 6)
FlyFrameCorner.Parent = FlyFrame

local FlyBtn = Instance.new("TextButton")
FlyBtn.Name = "FlyBtn"
FlyBtn.Size = UDim2.new(1, -10, 1, -10)
FlyBtn.Position = UDim2.new(0, 5, 0, 5)
FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FlyBtn.Text = "Fly: OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.TextSize = 12
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.Parent = FlyFrame

local FlyBtnCorner = Instance.new("UICorner")
FlyBtnCorner.CornerRadius = UDim.new(0, 4)
FlyBtnCorner.Parent = FlyBtn

-- Anti AFK Toggle
local AntiAfkFrame = Instance.new("Frame")
AntiAfkFrame.Name = "AntiAfkFrame"
AntiAfkFrame.Size = UDim2.new(1, 0, 0, 40)
AntiAfkFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AntiAfkFrame.BorderSizePixel = 0
AntiAfkFrame.Parent = MiscScroll

local AntiAfkCorner = Instance.new("UICorner")
AntiAfkCorner.CornerRadius = UDim.new(0, 6)
AntiAfkCorner.Parent = AntiAfkFrame

local AntiAfkBtn = Instance.new("TextButton")
AntiAfkBtn.Name = "AntiAfkBtn"
AntiAfkBtn.Size = UDim2.new(1, -10, 1, -10)
AntiAfkBtn.Position = UDim2.new(0, 5, 0, 5)
AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AntiAfkBtn.Text = "Anti AFK: OFF"
AntiAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAfkBtn.TextSize = 12
AntiAfkBtn.Font = Enum.Font.GothamBold
AntiAfkBtn.Parent = AntiAfkFrame

local AntiAfkBtnCorner = Instance.new("UICorner")
AntiAfkBtnCorner.CornerRadius = UDim.new(0, 4)
AntiAfkBtnCorner.Parent = AntiAfkBtn

-- Update canvas size for misc scroll
MiscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MiscScroll.CanvasSize = UDim2.new(0, 0, 0, MiscLayout.AbsoluteContentSize.Y + 10)
end)

-- Functions
local function createWaypointItem(name, position)
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Name = name
    ItemFrame.Size = UDim2.new(1, -10, 0, 35)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = WaypointList
    
    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 4)
    ItemCorner.Parent = ItemFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 11
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = ItemFrame
    
    local GotoBtn = Instance.new("TextButton")
    GotoBtn.Size = UDim2.new(0.25, 0, 0, 25)
    GotoBtn.Position = UDim2.new(0.42, 0, 0, 5)
    GotoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    GotoBtn.Text = "Go"
    GotoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GotoBtn.TextSize = 10
    GotoBtn.Font = Enum.Font.GothamBold
    GotoBtn.Parent = ItemFrame
    
    local GotoCorner = Instance.new("UICorner")
    GotoCorner.CornerRadius = UDim.new(0, 4)
    GotoCorner.Parent = GotoBtn
    
    local DeleteBtn = Instance.new("TextButton")
    DeleteBtn.Size = UDim2.new(0.25, 0, 0, 25)
    DeleteBtn.Position = UDim2.new(0.7, 0, 0, 5)
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    DeleteBtn.Text = "Delete"
    DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteBtn.TextSize = 10
    DeleteBtn.Font = Enum.Font.GothamBold
    DeleteBtn.Parent = ItemFrame
    
    local DeleteCorner = Instance.new("UICorner")
    DeleteCorner.CornerRadius = UDim.new(0, 4)
    DeleteCorner.Parent = DeleteBtn
    
    GotoBtn.MouseButton1Click:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetPos = position
            local distance = (targetPos - character.HumanoidRootPart.Position).Magnitude
            
            -- Smooth teleport
            local tweenInfo = TweenInfo.new(
                math.min(distance / 100, 3), -- Duration based on distance, max 3 seconds
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            )
            
            local tween = TweenService:Create(
                character.HumanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(targetPos)}
            )
            
            tween:Play()
        end
    end)
    
    DeleteBtn.MouseButton1Click:Connect(function()
        waypoints[name] = nil
        ItemFrame:Destroy()
        saveWaypoints()
        updateCanvasSize()
    end)
end

local function updateCanvasSize()
    WaypointList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

local function refreshWaypointList()
    for _, child in pairs(WaypointList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for name, position in pairs(waypoints) do
        createWaypointItem(name, position)
    end
    
    updateCanvasSize()
end

-- Set Waypoint Button
SetWaypointBtn.MouseButton1Click:Connect(function()
    local name = WaypointNameBox.Text
    if name ~= "" and character and character:FindFirstChild("HumanoidRootPart") then
        waypoints[name] = character.HumanoidRootPart.Position
        WaypointNameBox.Text = ""
        refreshWaypointList()
        saveWaypoints()
    end
end)

-- Tab Switching
WaypointTab.MouseButton1Click:Connect(function()
    WaypointContent.Visible = true
    MiscContent.Visible = false
    WaypointTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    MiscTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Waypoint System"
end)

MiscTab.MouseButton1Click:Connect(function()
    WaypointContent.Visible = false
    MiscContent.Visible = true
    MiscTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    WaypointTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.Text = "Misc Features"
end)

-- Minimize/Maximize
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 30), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 400), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "-"
    end
end)

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if flyConnection then
        flyConnection:Disconnect()
    end
end)

-- Speed Control
SpeedBox.FocusLost:Connect(function()
    local speed = tonumber(SpeedBox.Text)
    if speed and speed >= 1 and speed <= 100 then
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = speed
        end
    else
        SpeedBox.Text = tostring(character.Humanoid.WalkSpeed)
    end
end)

-- Jump Power Control
JumpBox.FocusLost:Connect(function()
    local jump = tonumber(JumpBox.Text)
    if jump and jump >= 1 and jump <= 150 then
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = jump
        end
    else
        JumpBox.Text = tostring(character.Humanoid.JumpPower)
    end
end)

-- Infinite Jump
InfJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        InfJumpBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        InfJumpBtn.Text = "Infinite Jump