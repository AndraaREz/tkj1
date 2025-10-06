-- Waypoint & Misc GUI for Roblox
-- Fixed Version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Wait for player to load properly
local player = Players.LocalPlayer
repeat wait() until player
repeat wait() until player:FindFirstChild("PlayerGui")

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

-- Load saved waypoints
local function loadWaypoints()
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

-- Protection against multiple instances
if player.PlayerGui:FindFirstChild("WaypointGUI") then
    player.PlayerGui.WaypointGUI:Destroy()
end

ScreenGui.Parent = player.PlayerGui

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

-- Add UI Corner
local function addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    return corner
end

addCorner(MainFrame, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

addCorner(TopBar, 8)

-- Cover bottom corners of top bar
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
Title.Font = Enum.Font.SourceSansBold
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
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TopBar

addCorner(MinimizeBtn, 4)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

addCorner(CloseBtn, 4)

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 40)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

-- Waypoint Tab
local WaypointTab = Instance.new("TextButton")
WaypointTab.Name = "WaypointTab"
WaypointTab.Size = UDim2.new(0.48, 0, 1, 0)
WaypointTab.Position = UDim2.new(0, 0, 0, 0)
WaypointTab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
WaypointTab.Text = "Waypoints"
WaypointTab.TextColor3 = Color3.fromRGB(255, 255, 255)
WaypointTab.TextSize = 14
WaypointTab.Font = Enum.Font.SourceSansBold
WaypointTab.BorderSizePixel = 0
WaypointTab.Parent = TabFrame

addCorner(WaypointTab, 6)

-- Misc Tab
local MiscTab = Instance.new("TextButton")
MiscTab.Name = "MiscTab"
MiscTab.Size = UDim2.new(0.48, 0, 1, 0)
MiscTab.Position = UDim2.new(0.52, 0, 0, 0)
MiscTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MiscTab.Text = "Misc"
MiscTab.TextColor3 = Color3.fromRGB(255, 255, 255)
MiscTab.TextSize = 14
MiscTab.Font = Enum.Font.SourceSansBold
MiscTab.BorderSizePixel = 0
MiscTab.Parent = TabFrame

addCorner(MiscTab, 6)

-- Waypoint Content
local WaypointContent = Instance.new("Frame")
WaypointContent.Name = "WaypointContent"
WaypointContent.Size = UDim2.new(1, -20, 1, -90)
WaypointContent.Position = UDim2.new(0, 10, 0, 80)
WaypointContent.BackgroundTransparency = 1
WaypointContent.Visible = true
WaypointContent.Parent = MainFrame

-- Set Waypoint Section
local SetLabel = Instance.new("TextLabel")
SetLabel.Size = UDim2.new(1, 0, 0, 20)
SetLabel.Position = UDim2.new(0, 0, 0, 0)
SetLabel.BackgroundTransparency = 1
SetLabel.Text = "Set Waypoint:"
SetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SetLabel.TextSize = 12
SetLabel.Font = Enum.Font.SourceSans
SetLabel.TextXAlignment = Enum.TextXAlignment.Left
SetLabel.Parent = WaypointContent

local WaypointNameBox = Instance.new("TextBox")
WaypointNameBox.Name = "WaypointNameBox"
WaypointNameBox.Size = UDim2.new(0.65, 0, 0, 30)
WaypointNameBox.Position = UDim2.new(0, 0, 0, 25)
WaypointNameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WaypointNameBox.PlaceholderText = "Enter waypoint name"
WaypointNameBox.Text = ""
WaypointNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WaypointNameBox.TextSize = 12
WaypointNameBox.Font = Enum.Font.SourceSans
WaypointNameBox.BorderSizePixel = 0
WaypointNameBox.Parent = WaypointContent

addCorner(WaypointNameBox, 4)

local SetWaypointBtn = Instance.new("TextButton")
SetWaypointBtn.Name = "SetWaypointBtn"
SetWaypointBtn.Size = UDim2.new(0.32, 0, 0, 30)
SetWaypointBtn.Position = UDim2.new(0.68, 0, 0, 25)
SetWaypointBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
SetWaypointBtn.Text = "Set"
SetWaypointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetWaypointBtn.TextSize = 12
SetWaypointBtn.Font = Enum.Font.SourceSansBold
SetWaypointBtn.BorderSizePixel = 0
SetWaypointBtn.Parent = WaypointContent

addCorner(SetWaypointBtn, 4)

-- Waypoint List Section
local ListLabel = Instance.new("TextLabel")
ListLabel.Size = UDim2.new(1, 0, 0, 20)
ListLabel.Position = UDim2.new(0, 0, 0, 65)
ListLabel.BackgroundTransparency = 1
ListLabel.Text = "Saved Waypoints:"
ListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ListLabel.TextSize = 12
ListLabel.Font = Enum.Font.SourceSans
ListLabel.TextXAlignment = Enum.TextXAlignment.Left
ListLabel.Parent = WaypointContent

local WaypointList = Instance.new("ScrollingFrame")
WaypointList.Name = "WaypointList"
WaypointList.Size = UDim2.new(1, 0, 1, -90)
WaypointList.Position = UDim2.new(0, 0, 0, 90)
WaypointList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WaypointList.BorderSizePixel = 0
WaypointList.ScrollBarThickness = 6
WaypointList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
WaypointList.Parent = WaypointContent

addCorner(WaypointList, 6)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = WaypointList

-- Misc Content
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
MiscScroll.ScrollBarThickness = 6
MiscScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
MiscScroll.Parent = MiscContent

local MiscLayout = Instance.new("UIListLayout")
MiscLayout.SortOrder = Enum.SortOrder.LayoutOrder
MiscLayout.Padding = UDim.new(0, 10)
MiscLayout.Parent = MiscScroll

-- Helper function to create misc items
local function createMiscItem(name, height)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = MiscScroll
    addCorner(frame, 6)
    return frame
end

-- Speed Control
local SpeedFrame = createMiscItem("SpeedFrame", 60)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.Position = UDim2.new(0, 5, 0, 5)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed (1-100):"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.SourceSansBold
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
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.BorderSizePixel = 0
SpeedBox.Parent = SpeedFrame

addCorner(SpeedBox, 4)

-- Jump Power Control
local JumpFrame = createMiscItem("JumpFrame", 60)
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -10, 0, 20)
JumpLabel.Position = UDim2.new(0, 5, 0, 5)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "Jump Power (1-150):"
JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.SourceSansBold
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
JumpBox.Font = Enum.Font.SourceSans
JumpBox.BorderSizePixel = 0
JumpBox.Parent = JumpFrame

addCorner(JumpBox, 4)

-- Toggle buttons helper
local function createToggleButton(parent, text, onColor, offColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 1, -10)
    btn.Position = UDim2.new(0, 5, 0, 5)
    btn.BackgroundColor3 = offColor
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    addCorner(btn, 4)
    return btn
end

-- Infinite Jump
local InfJumpFrame = createMiscItem("InfJumpFrame", 40)
local InfJumpBtn = createToggleButton(
    InfJumpFrame, 
    "Infinite Jump", 
    Color3.fromRGB(60, 180, 80),
    Color3.fromRGB(200, 50, 50)
)

-- Fly
local FlyFrame = createMiscItem("FlyFrame", 40)
local FlyBtn = createToggleButton(
    FlyFrame,
    "Fly",
    Color3.fromRGB(60, 180, 80),
    Color3.fromRGB(200, 50, 50)
)

-- Anti AFK
local AntiAfkFrame = createMiscItem("AntiAfkFrame", 40)
local AntiAfkBtn = createToggleButton(
    AntiAfkFrame,
    "Anti AFK",
    Color3.fromRGB(60, 180, 80),
    Color3.fromRGB(200, 50, 50)
)

-- Update canvas sizes
local function updateCanvasSizes()
    WaypointList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    MiscScroll.CanvasSize = UDim2.new(0, 0, 0, MiscLayout.AbsoluteContentSize.Y + 10)
end

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSizes)
MiscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSizes)

-- Functions
local function createWaypointItem(name, position)
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Name = name
    ItemFrame.Size = UDim2.new(1, -10, 0, 35)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = WaypointList
    
    addCorner(ItemFrame, 4)
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 11
    NameLabel.Font = Enum.Font.SourceSans
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
    GotoBtn.Font = Enum.Font.SourceSansBold
    GotoBtn.BorderSizePixel = 0
    GotoBtn.Parent = ItemFrame
    
    addCorner(GotoBtn, 4)
    
    local DeleteBtn = Instance.new("TextButton")
    DeleteBtn.Size = UDim2.new(0.25, 0, 0, 25)
    DeleteBtn.Position = UDim2.new(0.7, 0, 0, 5)
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    DeleteBtn.Text = "Delete"
    DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeleteBtn.TextSize = 10
    DeleteBtn.Font = Enum.Font.SourceSansBold
    DeleteBtn.BorderSizePixel = 0
    DeleteBtn.Parent = ItemFrame
    
    addCorner(DeleteBtn, 4)
    
    GotoBtn.MouseButton1Click:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
    
    DeleteBtn.MouseButton1Click:Connect(function()
        waypoints[name] = nil
        ItemFrame:Destroy()
        saveWaypoints()
        updateCanvasSizes()
    end)
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
    
    updateCanvasSizes()
end

-- Event Handlers
SetWaypointBtn.MouseButton1Click:Connect(function()
    local name = WaypointNameBox.Text
    if name ~= "" and name ~= " " and character and character:FindFirstChild("HumanoidRootPart") then
        waypoints[name] = character.HumanoidRootPart.Position
        WaypointNameBox.Text = ""
        refreshWaypointList()
        saveWaypoints()
    end
end)

-- Tab switching
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

-- Minimize/Close
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

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if flyConnection then
        flyConnection:Disconnect()
    end
end)

-- Misc Features
SpeedBox.FocusLost:Connect(function()
    local speed = tonumber(SpeedBox.Text)
    if speed and speed >= 1 and speed <= 100 and character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = speed
    else
        SpeedBox.Text = "16"
    end
end)

JumpBox.FocusLost:Connect(function()
    local jump = tonumber(JumpBox.Text)
    if jump and jump >= 1 and jump <= 150 and character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = jump
    else
        JumpBox.Text = "50"
    end
end)

-- Infinite Jump
InfJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        InfJumpBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        InfJumpBtn.Text = "Infinite Jump: ON"
    else
        InfJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        InfJumpBtn.Text = "Infinite Jump: OFF"
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and character and character:FindFirstChild("Humanoid") then
        character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Fly
local function enableFly()
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = rootPart.CFrame
    bg.Parent = rootPart
    
    local bv = Instance.new("BodyVelocity")
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = rootPart
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then
            bg:Destroy()
            bv:Destroy()
            if flyConnection then
                flyConnection:Disconnect()
            end
            return
        end
        
        local cam = workspace.CurrentCamera
        local moveDirection = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        bv.velocity = moveDirection * flySpeed
        bg.cframe = cam.CFrame
    end)
end

FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        FlyBtn.Text = "Fly: ON"
        if character and character:FindFirstChild("HumanoidRootPart") then
            rootPart = character.HumanoidRootPart
            enableFly()
        end
    else
        FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        FlyBtn.Text = "Fly: OFF"
    end
end)

-- Anti AFK
AntiAfkBtn.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled
    if antiAfkEnabled then
        AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        AntiAfkBtn.Text = "Anti AFK: ON"
        
        spawn(function()
            while antiAfkEnabled and player do
                wait(300)
                if antiAfkEnabled then
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end
        end)
    else
        AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AntiAfkBtn.Text = "Anti AFK: OFF"
    end
end)

-- Character reset handler
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    wait(1)
    
    local speed = tonumber(SpeedBox.Text)
    if speed and speed >= 1 and speed <= 100 then
        humanoid.WalkSpeed = speed
    end
    
    local jump = tonumber(JumpBox.Text)
    if jump and jump >= 1 and jump <= 150 then
        humanoid.JumpPower = jump
    end
    
    if flyEnabled then
        wait(0.5)
        enableFly()
    end
end)

-- Initialize
loadWaypoints()
refreshWaypointList()
updateCanvasSizes()

print("✅ Waypoint GUI loaded successfully!")
