-- WAYPOINT GUI - COMPLETE FIXED VERSION
print("🚀 Starting Complete Waypoint GUI...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Player & Character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Wait for PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old GUI if exists
if playerGui:FindFirstChild("WaypointGUI") then
    playerGui.WaypointGUI:Destroy()
    wait(0.5)
end

print("✅ Player loaded, creating GUI...")

-- Variables
_G.Waypoints = _G.Waypoints or {}
local loopWaypoints = {}
local loopEnabled = false
local loopSpeed = 2
local currentIndex = 1
local flyEnabled = false
local infJumpEnabled = false
local antiAfkEnabled = false
local flyConnection

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 450)
main.Position = UDim2.new(0.5, -160, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 255, 255)
main.Active = true
main.Draggable = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = main

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🗺️ Waypoint System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -55, 0, 2)
minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = minBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = main

-- Waypoint Tab Button
local waypointTabBtn = Instance.new("TextButton")
waypointTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
waypointTabBtn.Position = UDim2.new(0, 0, 0, 0)
waypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
waypointTabBtn.Text = "Waypoints"
waypointTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
waypointTabBtn.TextSize = 12
waypointTabBtn.Font = Enum.Font.GothamBold
waypointTabBtn.BorderSizePixel = 0
waypointTabBtn.Parent = tabContainer

local wpTabCorner = Instance.new("UICorner")
wpTabCorner.CornerRadius = UDim.new(0, 4)
wpTabCorner.Parent = waypointTabBtn

-- Misc Tab Button
local miscTabBtn = Instance.new("TextButton")
miscTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
miscTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
miscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
miscTabBtn.Text = "Misc"
miscTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miscTabBtn.TextSize = 12
miscTabBtn.Font = Enum.Font.GothamBold
miscTabBtn.BorderSizePixel = 0
miscTabBtn.Parent = tabContainer

local miscTabCorner = Instance.new("UICorner")
miscTabCorner.CornerRadius = UDim.new(0, 4)
miscTabCorner.Parent = miscTabBtn

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, -20, 1, -75)
contentContainer.Position = UDim2.new(0, 10, 0, 70)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = main

-- ============= WAYPOINT TAB =============
local waypointTab = Instance.new("Frame")
waypointTab.Name = "WaypointTab"
waypointTab.Size = UDim2.new(1, 0, 1, 0)
waypointTab.BackgroundTransparency = 1
waypointTab.Visible = true
waypointTab.Parent = contentContainer

-- Name Input
local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(0.65, 0, 0, 30)
nameInput.Position = UDim2.new(0, 0, 0, 0)
nameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
nameInput.PlaceholderText = "Waypoint Name"
nameInput.Text = ""
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.TextSize = 12
nameInput.Font = Enum.Font.Gotham
nameInput.BorderSizePixel = 0
nameInput.Parent = waypointTab

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 4)
nameCorner.Parent = nameInput

-- Set Button
local setBtn = Instance.new("TextButton")
setBtn.Size = UDim2.new(0.33, 0, 0, 30)
setBtn.Position = UDim2.new(0.67, 0, 0, 0)
setBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
setBtn.Text = "SET"
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.TextSize = 12
setBtn.Font = Enum.Font.GothamBold
setBtn.BorderSizePixel = 0
setBtn.Parent = waypointTab

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 4)
setCorner.Parent = setBtn

-- Loop Section
local loopSection = Instance.new("Frame")
loopSection.Size = UDim2.new(1, 0, 0, 80)
loopSection.Position = UDim2.new(0, 0, 0, 40)
loopSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
loopSection.BorderSizePixel = 0
loopSection.Parent = waypointTab

local loopCorner = Instance.new("UICorner")
loopCorner.CornerRadius = UDim.new(0, 6)
loopCorner.Parent = loopSection

-- Loop Title
local loopTitle = Instance.new("TextLabel")
loopTitle.Size = UDim2.new(1, -10, 0, 20)
loopTitle.Position = UDim2.new(0, 5, 0, 5)
loopTitle.BackgroundTransparency = 1
loopTitle.Text = "🔄 LOOP WAYPOINTS"
loopTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
loopTitle.TextSize = 11
loopTitle.Font = Enum.Font.GothamBold
loopTitle.TextXAlignment = Enum.TextXAlignment.Left
loopTitle.Parent = loopSection

-- Speed Input
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 50, 0, 20)
speedLabel.Position = UDim2.new(0, 5, 0, 28)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 10
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = loopSection

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 40, 0, 20)
speedInput.Position = UDim2.new(0, 55, 0, 28)
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.Text = "2"
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.TextSize = 10
speedInput.Font = Enum.Font.Gotham
speedInput.BorderSizePixel = 0
speedInput.Parent = loopSection

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 3)
speedCorner.Parent = speedInput

-- Loop Status
local loopStatus = Instance.new("TextLabel")
loopStatus.Size = UDim2.new(0, 80, 0, 20)
loopStatus.Position = UDim2.new(1, -85, 0, 28)
loopStatus.BackgroundTransparency = 1
loopStatus.Text = "Status: OFF"
loopStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
loopStatus.TextSize = 9
loopStatus.Font = Enum.Font.GothamBold
loopStatus.TextXAlignment = Enum.TextXAlignment.Right
loopStatus.Parent = loopSection

-- Loop Buttons
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.3, -3, 0, 22)
startBtn.Position = UDim2.new(0, 5, 0, 53)
startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startBtn.Text = "START"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 10
startBtn.Font = Enum.Font.GothamBold
startBtn.BorderSizePixel = 0
startBtn.Parent = loopSection

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 4)
startCorner.Parent = startBtn

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.3, -3, 0, 22)
stopBtn.Position = UDim2.new(0.35, 0, 0, 53)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.Text = "STOP"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 10
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.Parent = loopSection

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 4)
stopCorner.Parent = stopBtn

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.3, -3, 0, 22)
clearBtn.Position = UDim2.new(0.7, 0, 0, 53)
clearBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 50)
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 10
clearBtn.Font = Enum.Font.GothamBold
clearBtn.BorderSizePixel = 0
clearBtn.Parent = loopSection

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 4)
clearCorner.Parent = clearBtn

-- Waypoint List
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, 0, 0, 20)
listLabel.Position = UDim2.new(0, 0, 0, 130)
listLabel.BackgroundTransparency = 1
listLabel.Text = "📍 SAVED WAYPOINTS"
listLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
listLabel.TextSize = 11
listLabel.Font = Enum.Font.GothamBold
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = waypointTab

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -160)
scrollFrame.Position = UDim2.new(0, 0, 0, 155)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = waypointTab

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- ============= MISC TAB =============
local miscTab = Instance.new("Frame")
miscTab.Name = "MiscTab"
miscTab.Size = UDim2.new(1, 0, 1, 0)
miscTab.BackgroundTransparency = 1
miscTab.Visible = false
miscTab.Parent = contentContainer

-- Speed Section
local speedSection = Instance.new("Frame")
speedSection.Size = UDim2.new(1, 0, 0, 60)
speedSection.Position = UDim2.new(0, 0, 0, 0)
speedSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedSection.BorderSizePixel = 0
speedSection.Parent = miscTab

local speedSectionCorner = Instance.new("UICorner")
speedSectionCorner.CornerRadius = UDim.new(0, 6)
speedSectionCorner.Parent = speedSection

local speedLabel2 = Instance.new("TextLabel")
speedLabel2.Size = UDim2.new(1, -10, 0, 20)
speedLabel2.Position = UDim2.new(0, 5, 0, 5)
speedLabel2.BackgroundTransparency = 1
speedLabel2.Text = "⚡ Walk Speed (16-100)"
speedLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel2.TextSize = 11
speedLabel2.Font = Enum.Font.GothamBold
speedLabel2.TextXAlignment = Enum.TextXAlignment.Left
speedLabel2.Parent = speedSection

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -10, 0, 25)
speedBox.Position = UDim2.new(0, 5, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 11
speedBox.Font = Enum.Font.Gotham
speedBox.BorderSizePixel = 0
speedBox.Parent = speedSection

local speedBoxCorner = Instance.new("UICorner")
speedBoxCorner.CornerRadius = UDim.new(0, 4)
speedBoxCorner.Parent = speedBox

-- Jump Section
local jumpSection = Instance.new("Frame")
jumpSection.Size = UDim2.new(1, 0, 0, 60)
jumpSection.Position = UDim2.new(0, 0, 0, 70)
jumpSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpSection.BorderSizePixel = 0
jumpSection.Parent = miscTab

local jumpSectionCorner = Instance.new("UICorner")
jumpSectionCorner.CornerRadius = UDim.new(0, 6)
jumpSectionCorner.Parent = jumpSection

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -10, 0, 20)
jumpLabel.Position = UDim2.new(0, 5, 0, 5)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "🦘 Jump Power (50-150)"
jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLabel.TextSize = 11
jumpLabel.Font = Enum.Font.GothamBold
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = jumpSection

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, -10, 0, 25)
jumpBox.Position = UDim2.new(0, 5, 0, 30)
jumpBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBox.Text = "50"
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.TextSize = 11
jumpBox.Font = Enum.Font.Gotham
jumpBox.BorderSizePixel = 0
jumpBox.Parent = jumpSection

local jumpBoxCorner = Instance.new("UICorner")
jumpBoxCorner.CornerRadius = UDim.new(0, 4)
jumpBoxCorner.Parent = jumpBox

-- Toggle Buttons Section
local toggleSection = Instance.new("Frame")
toggleSection.Size = UDim2.new(1, 0, 1, -140)
toggleSection.Position = UDim2.new(0, 0, 0, 140)
toggleSection.BackgroundTransparency = 1
toggleSection.Parent = miscTab

-- Fly Button
local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, 0, 0, 35)
flyBtn.Position = UDim2.new(0, 0, 0, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flyBtn.Text = "✈️ Fly: OFF"
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.TextSize = 12
flyBtn.Font = Enum.Font.GothamBold
flyBtn.BorderSizePixel = 0
flyBtn.Parent = toggleSection

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyBtn

-- Infinite Jump Button
local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(1, 0, 0, 35)
infJumpBtn.Position = UDim2.new(0, 0, 0, 45)
infJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
infJumpBtn.Text = "♾️ Infinite Jump: OFF"
infJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpBtn.TextSize = 12
infJumpBtn.Font = Enum.Font.GothamBold
infJumpBtn.BorderSizePixel = 0
infJumpBtn.Parent = toggleSection

local infJumpCorner = Instance.new("UICorner")
infJumpCorner.CornerRadius = UDim.new(0, 6)
infJumpCorner.Parent = infJumpBtn

-- Anti AFK Button
local antiAfkBtn = Instance.new("TextButton")
antiAfkBtn.Size = UDim2.new(1, 0, 0, 35)
antiAfkBtn.Position = UDim2.new(0, 0, 0, 90)
antiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
antiAfkBtn.Text = "⏰ Anti AFK: OFF"
antiAfkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
antiAfkBtn.TextSize = 12
antiAfkBtn.Font = Enum.Font.GothamBold
antiAfkBtn.BorderSizePixel = 0
antiAfkBtn.Parent = toggleSection

local antiAfkCorner = Instance.new("UICorner")
antiAfkCorner.CornerRadius = UDim.new(0, 6)
antiAfkCorner.Parent = antiAfkBtn

-- ============= FUNCTIONS =============

-- Update canvas size function
local function updateCanvas()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
end

-- Create waypoint item function
local function createItem(name, pos)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, -10, 0, 30)
    item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    item.BorderSizePixel = 0
    item.Parent = scrollFrame
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 4)
    itemCorner.Parent = item
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = item
    
    local goBtn = Instance.new("TextButton")
    goBtn.Size = UDim2.new(0, 35, 0, 22)
    goBtn.Position = UDim2.new(0.42, 0, 0, 4)
    goBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    goBtn.Text = "GO"
    goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    goBtn.TextSize = 9
    goBtn.Font = Enum.Font.GothamBold
    goBtn.BorderSizePixel = 0
    goBtn.Parent = item
    
    local goCorner = Instance.new("UICorner")
    goCorner.CornerRadius = UDim.new(0, 3)
    goCorner.Parent = goBtn
    
    local addBtn = Instance.new("TextButton")
    addBtn.Size = UDim2.new(0, 35, 0, 22)
    addBtn.Position = UDim2.new(0.6, 0, 0, 4)
    addBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    addBtn.Text = "+"
    addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addBtn.TextSize = 12
    addBtn.Font = Enum.Font.GothamBold
    addBtn.BorderSizePixel = 0
    addBtn.Parent = item
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 3)
    addCorner.Parent = addBtn
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 35, 0, 22)
    delBtn.Position = UDim2.new(0.78, 0, 0, 4)
    delBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    delBtn.Text = "DEL"
    delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delBtn.TextSize = 9
    delBtn.Font = Enum.Font.GothamBold
    delBtn.BorderSizePixel = 0
    delBtn.Parent = item
    
    local delCorner = Instance.new("UICorner")
    delCorner.CornerRadius = UDim.new(0, 3)
    delCorner.Parent = delBtn
    
    -- Button functions
    goBtn.MouseButton1Click:Connect(function()
        if hrp and pos then
            hrp.CFrame = CFrame.new(pos)
            print("✅ Teleported to:", name)
        end
    end)
    
    addBtn.MouseButton1Click:Connect(function()
        if not table.find(loopWaypoints, name) then
            table.insert(loopWaypoints, name)
            addBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            addBtn.Text = "✓"
            print("✅ Added to loop:", name)
        else
            for i, v in ipairs(loopWaypoints) do
                if v == name then
                    table.remove(loopWaypoints, i)
                    break
                end
            end
            addBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
            addBtn.Text = "+"
            print("❌ Removed from loop:", name)
        end
    end)
    
    delBtn.MouseButton1Click:Connect(function()
        _G.Waypoints[name] = nil
        for i, v in ipairs(loopWaypoints) do
            if v == name then
                table.remove(loopWaypoints, i)
                break
            end
        end
        item:Destroy()
        updateCanvas()
        print("🗑️ Deleted:", name)
    end)
    
    -- Check if in loop
    if table.find(loopWaypoints, name) then
        addBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        addBtn.Text = "✓"
    end
    
    updateCanvas()
end

-- Refresh list function
local function refreshList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for name, pos in pairs(_G.Waypoints) do
        createItem(name, pos)
    end
end

-- Loop functions
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
    currentIndex = 1
    loopStatus.Text = "Status: RUNNING"
    loopStatus.TextColor3 = Color3.fromRGB(50, 255, 50)
    
    print("🔄 Loop started with", #loopWaypoints, "waypoints")
    
    spawn(function()
        while loopEnabled and #loopWaypoints > 0 do
            local waypointName = loopWaypoints[currentIndex]
            local pos = _G.Waypoints[waypointName]
            
            if pos and hrp then
                hrp.CFrame = CFrame.new(pos)
                print("📍 Loop ->", waypointName, "(" .. currentIndex .. "/" .. #loopWaypoints .. ")")
            end
            
            wait(loopSpeed)
            
            currentIndex = currentIndex + 1
            if currentIndex > #loopWaypoints then
                currentIndex = 1
            end
        end
    end)
end

local function stopLoop()
    loopEnabled = false
    loopStatus.Text = "Status: OFF"
    loopStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    print("⏹️ Loop stopped")
end

local function clearLoop()
    stopLoop()
    loopWaypoints = {}
    refreshList()
    print("🗑️ Loop queue cleared")
end

-- ============= BUTTON EVENTS =============

-- Set waypoint
setBtn.MouseButton1Click:Connect(function()
    local name = nameInput.Text:match("^%s*(.-)%s*$")
    if name ~= "" and hrp then
        _G.Waypoints[name] = hrp.Position
        nameInput.Text = ""
        refreshList()
        print("✅ Waypoint saved:", name)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Waypoint Saved";
            Text = name;
            Duration = 2;
        })
    end
end)

-- Speed input
speedInput.FocusLost:Connect(function()
    local speed = tonumber(speedInput.Text)
    if speed and speed >= 0.5 and speed <= 10 then
        loopSpeed = speed
    else
        speedInput.Text = tostring(loopSpeed)
    end
end)

-- Loop buttons
startBtn.MouseButton1Click:Connect(startLoop)
stopBtn.MouseButton1Click:Connect(stopLoop)
clearBtn.MouseButton1Click:Connect(clearLoop)

-- Tab switching
waypointTabBtn.MouseButton1Click:Connect(function()
    waypointTab.Visible = true
    miscTab.Visible = false
    waypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    miscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    title.Text = "🗺️ Waypoint System"
end)

miscTabBtn.MouseButton1Click:Connect(function()
    waypointTab.Visible = false
    miscTab.Visible = true
    miscTabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    waypointTabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    title.Text = "⚙️ Misc Features"
end)

-- Minimize button
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        main:TweenSize(UDim2.new(0, 320, 0, 30), "Out", "Quad", 0.3, true)
        minBtn.Text = "+"
    else
        main:TweenSize(UDim2.new(0, 320, 0, 450), "Out", "Quad", 0.3, true)
        minBtn.Text = "—"
    end
end)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    stopLoop()
    gui:Destroy()
    print("❌ GUI Closed")
end)

-- Speed control
speedBox.FocusLost:Connect(function()
    local speed = tonumber(speedBox.Text)
    if speed and speed >= 16 and speed <= 100 and humanoid then
        humanoid.WalkSpeed = speed
        print("⚡ Speed set to:", speed)
    else
        speedBox.Text = tostring(humanoid.WalkSpeed)
    end
end)

-- Jump control
jumpBox.FocusLost:Connect(function()
    local jump = tonumber(jumpBox.Text)
    if jump and jump >= 50 and jump <= 150 and humanoid then
        humanoid.JumpPower = jump
        print("🦘 Jump power set to:", jump)
    else
        jumpBox.Text = tostring(humanoid.JumpPower)
    end
end)

-- Fly toggle
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        flyBtn.Text = "✈️ Fly: ON"
        
        local bg = Instance.new("BodyGyro")
        local bv = Instance.new("BodyVelocity")
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bg.Parent = hrp
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled then
                bg:Destroy()
                bv:Destroy()
                flyConnection:Disconnect()
                return
            end
            
            local cam = workspace.CurrentCamera
            local moveVector = Vector3.new()
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            bv.velocity = moveVector.Unit * 50
            bg.cframe = cam.CFrame
        end)
        
        print("✈️ Fly enabled")
    else
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        flyBtn.Text = "✈️ Fly: OFF"
        print("✈️ Fly disabled")
    end
end)

-- Infinite jump
infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        infJumpBtn.Text = "♾️ Infinite Jump: ON"
        print("♾️ Infinite Jump enabled")
    else
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        infJumpBtn.Text = "♾️ Infinite Jump: OFF"
        print("♾️ Infinite Jump disabled")
    end
end)

UIS.JumpRequest:Connect(function()
    if infJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti AFK
antiAfkBtn.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled
    if antiAfkEnabled then
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        antiAfkBtn.Text = "⏰ Anti AFK: ON"
        
        spawn(function()
            while antiAfkEnabled do
                wait(300)
                if antiAfkEnabled then
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                end
            end
        end)
        
        print("⏰ Anti AFK enabled")
    else
        antiAfkBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        antiAfkBtn.Text = "⏰ Anti AFK: OFF"
        print("⏰ Anti AFK disabled")
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    print("🔄 Character respawned")
end)

-- Load existing waypoints
refreshList()

-- Parent GUI to PlayerGui
gui.Parent = playerGui

print("✅ Complete GUI Created Successfully!")

-- Show notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Waypoint GUI Pro";
    Text = "Loaded Successfully!";
    Duration = 3;
})
