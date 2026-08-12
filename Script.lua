local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BlueJumpButton"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "JumpButton"
button.Size = UDim2.fromOffset(60, 60)
button.Position = UDim2.new(1, -75, 0, 15)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
button.Text = "↑"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 38
button.Font = Enum.Font.GothamBold
button.TextXAlignment = Enum.TextXAlignment.Center
button.TextYAlignment = Enum.TextYAlignment.Center
button.BorderSizePixel = 0
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = button

button.Activated:Connect(function()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Jump = true
    end
end)
