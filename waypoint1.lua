-- WAYPOINT GUI WITH LOOP FEATURE - ENHANCED VERSION
print("🔄 Loading Enhanced Waypoint GUI with Loop...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Wait for everything to load
local player = Players.LocalPlayer
if not player then
    warn("❌ Player not found!")
    return
end

repeat wait(0.1) until player:FindFirstChild("PlayerGui")
repeat wait(0.1) until player:FindFirstChild("Character")

local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")

if not humanoid or not rootPart then
    warn("❌ Character components not found!")
    return
end

print("✅ All services loaded!")

-- Remove existing GUI
pcall(function()
    if player.PlayerGui:FindFirstChild("WaypointGUI") then
        player.PlayerGui.WaypointGUI:Destroy()
        print("🗑️ Removed old GUI")
    end
end)

-- Variables
local waypoints = {}
local antiAfkEnabled = false
local flyEnabled = false
local infJumpEnabled = false
local flySpeed = 50
local flyConnection

-- ✨ NEW: Loop Variables
local loopEnabled = false
local loopConnection
local currentLoopIndex = 1
local loopSpeed = 2 -- seconds between waypoints
local loopWaypoints = {} -- Selected waypoints for loop

-- Load saved waypoints
if _G.SavedWaypoints then
    waypoints = _G.SavedWaypoints
    print("📂 Loaded saved waypoints: " .. #waypoints)
end

-- Create Main GUI
local success, error = pcall(function()
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WaypointGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = false
    
    -- Main Frame (Made taller for loop features)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 380) -- Increased height
    MainFrame.Position = UDim2.new(0, 100, 0, 100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 25)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 150, 1, 0)
    Title.Position = UDim2.new(0, 5, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Waypoint System Pro"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -22, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    
    -- Minimize Button  
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Position = UDim2.new(1, -44, 0, 2)
    MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 12
    MinBtn.Font = Enum.Font.SourceSansBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    
    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -10, 1, -35)
    ContentFrame.Position = UDim2.new(0, 5, 0, 30)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 1
    ContentFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    ContentFrame.Parent = MainFrame
    
    -- Tab Buttons
    local WaypointTabBtn = Instance.new("TextButton")
    WaypointTabBtn.Size = UDim2.new(0.48, 0, 0, 25)
    WaypointTabBtn.Position = UDim2.new(0, 5, 0, 5)
    WaypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    WaypointTabBtn.Text = "Waypoints"
    WaypointTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    WaypointTabBtn.TextSize = 11
    WaypointTabBtn.Font = Enum.Font.SourceSansBold
    WaypointTabBtn.BorderSizePixel = 0
    WaypointTabBtn.Parent = ContentFrame
    
    local MiscTabBtn = Instance.new("TextButton")
    MiscTabBtn.Size = UDim2.new(0.48, 0, 0, 25)
    MiscTabBtn.Position = UDim2.new(0.52, 0, 0, 5)
    MiscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MiscTabBtn.Text = "Misc"
    MiscTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiscTabBtn.TextSize = 11
    MiscTabBtn.Font = Enum.Font.SourceSansBold
    MiscTabBtn.BorderSizePixel = 0
    MiscTabBtn.Parent = ContentFrame
    
    -- Waypoint Tab Content
    local WaypointTab = Instance.new("Frame")
    WaypointTab.Name = "WaypointTab"
    WaypointTab.Size = UDim2.new(1, -10, 1, -40)
    WaypointTab.Position = UDim2.new(0, 5, 0, 35)
    WaypointTab.BackgroundTransparency = 1
    WaypointTab.Visible = true
    WaypointTab.Parent = ContentFrame
    
    -- Set Waypoint Section
    local NameBox = Instance.new("TextBox")
    NameBox.Size = UDim2.new(0.65, 0, 0, 25)
    NameBox.Position = UDim2.new(0, 0, 0, 5)
    NameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    NameBox.PlaceholderText = "Waypoint name"
    NameBox.Text = ""
    NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameBox.TextSize = 10
    NameBox.Font = Enum.Font.SourceSans
    NameBox.BorderSizePixel = 1
    NameBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
    NameBox.Parent = WaypointTab
    
    local SetBtn = Instance.new("TextButton")
    SetBtn.Size = UDim2.new(0.32, 0, 0, 25)
    SetBtn.Position = UDim2.new(0.68, 0, 0, 5)
    SetBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    SetBtn.Text = "Set"
    SetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SetBtn.TextSize = 10
    SetBtn.Font = Enum.Font.SourceSansBold
    SetBtn.BorderSizePixel = 0
    SetBtn.Parent = WaypointTab
    
    -- ✨ NEW: Loop Control Section
    local LoopFrame = Instance.new("Frame")
    LoopFrame.Size = UDim2.new(1, 0, 0, 75) -- Height for loop controls
    LoopFrame.Position = UDim2.new(0, 0, 0, 35)
    LoopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LoopFrame.BorderSizePixel = 1
    LoopFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    LoopFrame.Parent = WaypointTab
    
    -- Loop Title
    local LoopTitle = Instance.new("TextLabel")
    LoopTitle.Size = UDim2.new(1, -10, 0, 15)
    LoopTitle.Position = UDim2.new(0, 5, 0, 2)
    LoopTitle.BackgroundTransparency = 1
    LoopTitle.Text = "🔄 Loop Waypoints"
    LoopTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    LoopTitle.TextSize = 11
    LoopTitle.Font = Enum.Font.SourceSansBold
    LoopTitle.TextXAlignment = Enum.TextXAlignment.Left
    LoopTitle.Parent = LoopFrame
    
    -- Loop Speed Control
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.4, 0, 0, 15)
    SpeedLabel.Position = UDim2.new(0, 5, 0, 20)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed (sec):"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 9
    SpeedLabel.Font = Enum.Font.SourceSans
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = LoopFrame
    
    local SpeedSlider = Instance.new("TextBox")
    SpeedSlider.Size = UDim2.new(0.3, 0, 0, 15)
    SpeedSlider.Position = UDim2.new(0.42, 0, 0, 20)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedSlider.Text = "2"
    SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSlider.TextSize = 9
    SpeedSlider.Font = Enum.Font.SourceSans
    SpeedSlider.BorderSizePixel = 1
    SpeedSlider.BorderColor3 = Color3.fromRGB(80, 80, 80)
    SpeedSlider.Parent = LoopFrame
    
    -- Loop Status
    local LoopStatus = Instance.new("TextLabel")
    LoopStatus.Size = UDim2.new(0.25, 0, 0, 15)
    LoopStatus.Position = UDim2.new(0.75, 0, 0, 20)
    LoopStatus.BackgroundTransparency = 1
    LoopStatus.Text = "OFF"
    LoopStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    LoopStatus.TextSize = 9
    LoopStatus.Font = Enum.Font.SourceSansBold
    LoopStatus.TextXAlignment = Enum.TextXAlignment.Center
    LoopStatus.Parent = LoopFrame
    
    -- Loop Control Buttons
    local StartLoopBtn = Instance.new("TextButton")
    StartLoopBtn.Size = UDim2.new(0.3, 0, 0, 20)
    StartLoopBtn.Position = UDim2.new(0, 5, 0, 40)
    StartLoopBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
    StartLoopBtn.Text = "Start Loop"
    StartLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartLoopBtn.TextSize = 9
    StartLoopBtn.Font = Enum.Font.SourceSansBold
    StartLoopBtn.BorderSizePixel = 0
    StartLoopBtn.Parent = LoopFrame
    
    local StopLoopBtn = Instance.new("TextButton")
    StopLoopBtn.Size = UDim2.new(0.3, 0, 0, 20)
    StopLoopBtn.Position = UDim2.new(0.35, 0, 0, 40)
    StopLoopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    StopLoopBtn.Text = "Stop Loop"
    StopLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopLoopBtn.TextSize = 9
    StopLoopBtn.Font = Enum.Font.SourceSansBold
    StopLoopBtn.BorderSizePixel = 0
    StopLoopBtn.Parent = LoopFrame
    
    local ClearLoopBtn = Instance.new("TextButton")
    ClearLoopBtn.Size = UDim2.new(0.3, 0, 0, 20)
    ClearLoopBtn.Position = UDim2.new(0.7, 0, 0, 40)
    ClearLoopBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
    ClearLoopBtn.Text = "Clear"
    ClearLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearLoopBtn.TextSize = 9
    ClearLoopBtn.Font = Enum.Font.SourceSansBold
    ClearLoopBtn.BorderSizePixel = 0
    ClearLoopBtn.Parent = LoopFrame
    
    -- Loop Queue Display
    local LoopQueueLabel = Instance.new("TextLabel")
    LoopQueueLabel.Size = UDim2.new(1, -10, 0, 12)
    LoopQueueLabel.Position = UDim2.new(0, 5, 0, 62)
    LoopQueueLabel.BackgroundTransparency = 1
    LoopQueueLabel.Text = "Queue: (empty)"
    LoopQueueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    LoopQueueLabel.TextSize = 8
    LoopQueueLabel.Font = Enum.Font.SourceSans
    LoopQueueLabel.TextXAlignment = Enum.TextXAlignment.Left
    LoopQueueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    LoopQueueLabel.Parent = LoopFrame
    
    -- Waypoint List (Adjusted position for loop frame)
    local WaypointList = Instance.new("ScrollingFrame")
    WaypointList.Size = UDim2.new(1, 0, 1, -120) -- Adjusted for loop frame
    WaypointList.Position = UDim2.new(0, 0, 0, 115) -- Moved down
    WaypointList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    WaypointList.BorderSizePixel = 1
    WaypointList.BorderColor3 = Color3.fromRGB(70, 70, 70)
    WaypointList.ScrollBarThickness = 6
    WaypointList.Parent = WaypointTab
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = WaypointList
    
    -- Misc Tab Content (Same as before)
    local MiscTab = Instance.new("Frame")
    MiscTab.Name = "MiscTab"
    MiscTab.Size = UDim2.new(1, -10, 1, -40)
    MiscTab.Position = UDim2.new(0, 5, 0, 35)
    MiscTab.BackgroundTransparency = 1
    MiscTab.Visible = false
    MiscTab.Parent = ContentFrame
    
    -- Speed Control
    local SpeedLabel2 = Instance.new("TextLabel")
    SpeedLabel2.Size = UDim2.new(1, 0, 0, 15)
    SpeedLabel2.Position = UDim2.new(0, 0, 0, 5)
    SpeedLabel2.BackgroundTransparency = 1
    SpeedLabel2.Text = "Speed (1-100):"
    SpeedLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel2.TextSize = 10
    SpeedLabel2.Font = Enum.Font.SourceSans
    SpeedLabel2.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel2.Parent = MiscTab
    
    local SpeedBox = Instance.new("TextBox")
    SpeedBox.Size = UDim2.new(1, 0, 0, 20)
    SpeedBox.Position = UDim2.new(0, 0, 0, 22)
    SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedBox.Text = "16"
    SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBox.TextSize = 10
    SpeedBox.Font = Enum.Font.SourceSans
    SpeedBox.BorderSizePixel = 1
    SpeedBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
    SpeedBox.Parent = MiscTab
    
    -- Jump Power Control
    local JumpLabel = Instance.new("TextLabel")
    JumpLabel.Size = UDim2.new(1, 0, 0, 15)
    JumpLabel.Position = UDim2.new(0, 0, 0, 50)
    JumpLabel.BackgroundTransparency = 1
    JumpLabel.Text = "Jump Power (1-150):"
    JumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumpLabel.TextSize = 10
    JumpLabel.Font = Enum.Font.SourceSans
    JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    JumpLabel.Parent = MiscTab
    
    local JumpBox = Instance.new("TextBox")
    JumpBox.Size = UDim2.new(1, 0, 0, 20)
    JumpBox.Position = UDim2.new(0, 0, 0, 67)
    JumpBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    JumpBox.Text = "50"
    JumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumpBox.TextSize = 10
    JumpBox.Font = Enum.Font.SourceSans
    JumpBox.BorderSizePixel = 1
    JumpBox.BorderColor3 = Color3.fromRGB(80, 80, 80)
    JumpBox.Parent = MiscTab
    
    -- Toggle Buttons
    local FlyBtn = Instance.new("TextButton")
    FlyBtn.Size = UDim2.new(1, 0, 0, 25)
    FlyBtn.Position = UDim2.new(0, 0, 0, 95)
    FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    FlyBtn.Text = "Fly: OFF"
    FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyBtn.TextSize = 10
    FlyBtn.Font = Enum.Font.SourceSansBold
    FlyBtn.BorderSizePixel = 0
    FlyBtn.Parent = MiscTab
    
    local InfJumpBtn = Instance.new("TextButton")
    InfJumpBtn.Size = UDim2.new(1, 0, 0, 25)
    InfJumpBtn.Position = UDim2.new(0, 0, 0, 125)
    InfJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    InfJumpBtn.Text = "Infinite Jump: OFF"
    InfJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfJumpBtn.TextSize = 10
    InfJumpBtn.Font = Enum.Font.SourceSansBold
    InfJumpBtn.BorderSizePixel = 0
    InfJumpBtn.Parent = MiscTab
    
    local AntiAfkBtn = Instance.new("TextButton")
    AntiAfkBtn.Size = UDim2.new(1, 0, 0, 25)
    AntiAfkBtn.Position = UDim2.new(0, 0, 0, 155)
    AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    AntiAfkBtn.Text = "Anti AFK: OFF"
    AntiAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiAfkBtn.TextSize = 10
    AntiAfkBtn.Font = Enum.Font.SourceSansBold
    AntiAfkBtn.BorderSizePixel = 0
    AntiAfkBtn.Parent = MiscTab
    
    -- ✨ NEW: Loop Functions
    local function updateLoopQueue()
        if #loopWaypoints == 0 then
            LoopQueueLabel.Text = "Queue: (empty)"
        else
            local queueText = "Queue: "
            for i, name in ipairs(loopWaypoints) do
                if i == currentLoopIndex and loopEnabled then
                    queueText = queueText .. "[" .. name .. "] "
                else
                    queueText = queueText .. name .. " "
                end
            end
            LoopQueueLabel.Text = queueText
        end
    end
    
    local function startLoop()
        if #loopWaypoints == 0 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Loop Error";
                Text = "No waypoints in queue!";
                Duration = 3;
            })
            return
        end
        
        loopEnabled = true
        currentLoopIndex = 1
        LoopStatus.Text = "RUNNING"
        LoopStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        loopConnection = RunService.Heartbeat:Connect(function()
            if not loopEnabled or #loopWaypoints == 0 then
                return
            end
            
            -- Check if we need to move to next waypoint
            if rootPart and waypoints[loopWaypoints[currentLoopIndex]] then
                local targetPos = waypoints[loopWaypoints[currentLoopIndex]]
                local currentPos = rootPart.Position
                local distance = (targetPos - currentPos).Magnitude
                
                -- If we're close enough to current waypoint, move to next
                if distance < 5 then
                    wait(loopSpeed)
                    currentLoopIndex = currentLoopIndex + 1
                    
                    -- Loop back to start if we reached the end
                    if currentLoopIndex > #loopWaypoints then
                        currentLoopIndex = 1
                    end
                    
                    -- Teleport to next waypoint
                    local nextPos = waypoints[loopWaypoints[currentLoopIndex]]
                    if nextPos then
                        rootPart.CFrame = CFrame.new(nextPos)
                        updateLoopQueue()
                    end
                end
            end
        end)
        
        -- Teleport to first waypoint
        if waypoints[loopWaypoints[1]] then
            rootPart.CFrame = CFrame.new(waypoints[loopWaypoints[1]])
        end
        
        updateLoopQueue()
    end
    
    local function stopLoop()
        loopEnabled = false
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
        LoopStatus.Text = "STOPPED"
        LoopStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        updateLoopQueue()
    end
    
    local function clearLoop()
        stopLoop()
        loopWaypoints = {}
        currentLoopIndex = 1
        updateLoopQueue()
    end
    
    -- Functions
    local function createWaypointItem(name, position)
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, -5, 0, 25)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ItemFrame.BorderSizePixel = 1
        ItemFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
        ItemFrame.Parent = WaypointList
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0.35, 0, 1, 0)
        NameLabel.Position = UDim2.new(0, 5, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = 9
        NameLabel.Font = Enum.Font.SourceSans
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ItemFrame
        
        local GoBtn = Instance.new("TextButton")
        GoBtn.Size = UDim2.new(0.15, 0, 0, 20)
        GoBtn.Position = UDim2.new(0.37, 0, 0, 2)
        GoBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        GoBtn.Text = "Go"
        GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GoBtn.TextSize = 8
        GoBtn.Font = Enum.Font.SourceSansBold
        GoBtn.BorderSizePixel = 0
        GoBtn.Parent = ItemFrame
        
        -- ✨ NEW: Add to Loop Button
        local AddLoopBtn = Instance.new("TextButton")
        AddLoopBtn.Size = UDim2.new(0.15, 0, 0, 20)
        AddLoopBtn.Position = UDim2.new(0.54, 0, 0, 2)
        AddLoopBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        AddLoopBtn.Text = "+"
        AddLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        AddLoopBtn.TextSize = 10
        AddLoopBtn.Font = Enum.Font.SourceSansBold
        AddLoopBtn.BorderSizePixel = 0
        AddLoopBtn.Parent = ItemFrame
        
        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0.15, 0, 0, 20)
        DelBtn.Position = UDim2.new(0.71, 0, 0, 2)
        DelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        DelBtn.Text = "Del"
        DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DelBtn.TextSize = 8
        DelBtn.Font = Enum.Font.SourceSansBold
        DelBtn.BorderSizePixel = 0
        DelBtn.Parent = ItemFrame
        
        -- Button Events
        GoBtn.MouseButton1Click:Connect(function()
            if rootPart then
                rootPart.CFrame = CFrame.new(position)
            end
        end)
        
        -- ✨ NEW: Add to Loop Event
        AddLoopBtn.MouseButton1Click:Connect(function()
            if not table.find(loopWaypoints, name) then
                table.insert(loopWaypoints, name)
                AddLoopBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                AddLoopBtn.Text = "✓"
                updateLoopQueue()
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Loop";
                    Text = name .. " added to loop queue";
                    Duration = 2;
                })
            else
                -- Remove from loop
                for i, loopName in ipairs(loopWaypoints) do
                    if loopName == name then
                        table.remove(loopWaypoints, i)
                        break
                    end
                end
                AddLoopBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
                AddLoopBtn.Text = "+"
                updateLoopQueue()
            end
        end)
        
        DelBtn.MouseButton1Click:Connect(function()
            waypoints[name] = nil
            _G.SavedWaypoints = waypoints
            
            -- Remove from loop queue if exists
            for i, loopName in ipairs(loopWaypoints) do
                if loopName == name then
                    table.remove(loopWaypoints, i)
                    break
                end
            end
            
            ItemFrame:Destroy()
            WaypointList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            updateLoopQueue()
        end)
        
        -- Check if already in loop queue
        if table.find(loopWaypoints, name) then
            AddLoopBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            AddLoopBtn.Text = "✓"
        end
    end
    
    local function refreshWaypoints()
        for _, child in pairs(WaypointList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for name, pos in pairs(waypoints) do
            createWaypointItem(name, pos)
        end
        
        WaypointList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end
    
    -- Button Events
    SetBtn.MouseButton1Click:Connect(function()
        local name = NameBox.Text:gsub("^%s*(.-)%s*$", "%1")
        if name ~= "" and rootPart then
            waypoints[name] = rootPart.Position
            _G.SavedWaypoints = waypoints
            NameBox.Text = ""
            refreshWaypoints()
        end
    end)
    
    -- ✨ NEW: Loop Control Events
    SpeedSlider.FocusLost:Connect(function()
        local speed = tonumber(SpeedSlider.Text)
        if speed and speed >= 0.5 and speed <= 10 then
            loopSpeed = speed
        else
            SpeedSlider.Text = tostring(loopSpeed)
        end
    end)
    
    StartLoopBtn.MouseButton1Click:Connect(function()
        startLoop()
    end)
    
    StopLoopBtn.MouseButton1Click:Connect(function()
        stopLoop()
    end)
    
    ClearLoopBtn.MouseButton1Click:Connect(function()
        clearLoop()
    end)
    
    -- Tab Switching
    WaypointTabBtn.MouseButton1Click:Connect(function()
        WaypointTab.Visible = true
        MiscTab.Visible = false
        WaypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        MiscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Title.Text = "Waypoint System Pro"
    end)
    
    MiscTabBtn.MouseButton1Click:Connect(function()
        WaypointTab.Visible = false
        MiscTab.Visible = true
        MiscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        WaypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Title.Text = "Misc Features"
    end)
    
    -- Close/Minimize
    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 25), "Out", "Quad", 0.3, true)
            MinBtn.Text = "+"
        else
            MainFrame:TweenSize(UDim2.new(0, 300, 0, 380), "Out", "Quad", 0.3, true)
            MinBtn.Text = "-"
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        stopLoop() -- Stop loop before closing
        ScreenGui:Destroy()
    end)
    
    -- Speed Control
    SpeedBox.FocusLost:Connect(function()
        local speed = tonumber(SpeedBox.Text)
        if speed and speed >= 1 and speed <= 100 and humanoid then
            humanoid.WalkSpeed = speed
        end
    end)
    
    -- Jump Control
    JumpBox.FocusLost:Connect(function()
        local jump = tonumber(JumpBox.Text)
        if jump and jump >= 1 and jump <= 150 and humanoid then
            humanoid.JumpPower = jump
        end
    end)
    
    -- Fly Toggle
    FlyBtn.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        if flyEnabled then
            FlyBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
            FlyBtn.Text = "Fly: ON"
            
            -- Simple fly
            local bg = Instance.new("BodyGyro")
            local bv = Instance.new("BodyVelocity")
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = rootPart.CFrame
            bg.Parent = rootPart
            bv.velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = rootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled then
                    bg:Destroy()
                    bv:Destroy()
                    flyConnection:Disconnect()
                    return
                end
                
                local cam = workspace.CurrentCamera
                local moveVector = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                bv.velocity = moveVector.Unit * flySpeed
                bg.cframe = cam.CFrame
            end)
        else
            FlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            FlyBtn.Text = "Fly: OFF"
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
        if infJumpEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    -- Anti AFK
    AntiAfkBtn.MouseButton1Click:Connect(function()
        antiAfkEnabled = not antiAfkEnabled
        if antiAfkEnabled then
            AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
            AntiAfkBtn.Text = "Anti AFK: ON"
            
            spawn(function()
                while antiAfkEnabled do
                    wait(300)
                    if antiAfkEnabled then
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                    end
                end
            end)
        else
            AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            AntiAfkBtn.Text = "Anti AFK: OFF"
        end
    end)
    
    -- Load existing waypoints
    refreshWaypoints()
    updateLoopQueue()
    
    -- Parent to PlayerGui
    ScreenGui.Parent = player.PlayerGui
    
    print("✅ Enhanced GUI with Loop created successfully!")
end)

if success then
    print("🎉 Enhanced Waypoint GUI with Loop loaded successfully!")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Success!";
        Text = "Waypoint GUI Pro loaded!";
        Duration = 3;
    })
else
    warn("❌ Error creating GUI: " .. tostring(error))
end
