--!strict
--[[
    Waypoint System GUI for Roblox
    Features:
    - Set Waypoint at current player position with a custom name.
    - Go To Waypoint: Teleports player to a selected waypoint.
    - Delete Waypoint: Removes a selected waypoint.
    - Minimize/Maximize GUI: Collapses/expands the GUI.
    - Close GUI: Destroys the GUI.
    - Draggable GUI: Can be moved around the screen.
    - Small and non-obtrusive design.
]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local waypoints: { [string]: Vector3 } = {} -- Table to store waypoints (name -> Vector3 position)

--// GUI Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "WaypointGUI"
MainFrame.Size = UDim2.new(0, 220, 0, 250) -- Slightly adjusted size for better fit
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true -- Important for minimizing
MainFrame.Parent = PlayerGui

-- Make the MainFrame draggable
local isDragging = false
local dragStartPos: Vector2
local frameStartPos: UDim2

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = UserInputService:GetMouseLocation()
        frameStartPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input
    