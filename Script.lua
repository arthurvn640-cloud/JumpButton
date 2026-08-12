local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "JumpButton"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 55, 0, 55)
button.Position = UDim2.new(1, -70, 0, 15)
button.BackgroundColor3 = Color3.fromRGB(140, 50, 220)
button.Text = "↑"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 32
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

button.Activated:Connect(function()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.Jump = true
    end
end)
