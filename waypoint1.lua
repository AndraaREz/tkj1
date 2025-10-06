-- WAYPOINT GUI SIMPLE & FIXED VERSION
print("🚀 Starting Waypoint GUI...")

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

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 255, 255)
main.Active = true
main.Draggable = true
main.Parent = gui

-- Make it rounded
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

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
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🗺️ Waypoint System"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

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

-- Content Frame
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -40)
content.Position = UDim2.new(0, 10, 0, 35)
content.BackgroundTransparency = 1
content.Parent = main

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
nameInput.Parent = content

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
setBtn.Parent = content

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 4)
setCorner.Parent = setBtn

-- Loop Section
local loopSection = Instance.new("Frame")
loopSection.Size = UDim2.new(1, 0, 0, 80)
loopSection.Position = UDim2.new(0, 0, 0, 40)
loopSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
loopSection.BorderSizePixel = 0
loopSection.Parent = content

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
listLabel.Parent = content

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -160)
scrollFrame.Position = UDim2.new(0, 0, 0, 155)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.Parent = content

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

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

-- Set waypoint
setBtn.MouseButton1Click:Connect(function()
    local name = nameInput.Text:match("^%s*(.-)%s*$") -- Trim spaces
    if name ~= "" and hrp then
        _G.Waypoints[name] = hrp.Position
        nameInput.Text = ""
        refreshList()
        print("✅ Waypoint saved:", name)
        
        -- Notification
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

-- Loop functions
local loopConnection

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

-- Loop button events
startBtn.MouseButton1Click:Connect(startLoop)
stopBtn.MouseButton1Click:Connect(stopLoop)
clearBtn.MouseButton1Click:Connect(clearLoop)

-- Close button
closeBtn.MouseButton1Click:Connect(function()
    stopLoop()
    gui:Destroy()
    print("❌ GUI Closed")
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

print("✅ GUI Created Successfully!")

-- Show notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Waypoint GUI";
    Text = "Loaded Successfully!";
    Duration = 3;
})
