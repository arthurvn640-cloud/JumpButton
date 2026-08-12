local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove uma versão anterior
local oldGui = playerGui:FindFirstChild("JumpButton")
if oldGui then
    oldGui:Destroy()
end

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "JumpButton"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ÚNICO BOTÃO
local button = Instance.new("TextButton")
button.Name = "Jump"
button.Size = UDim2.new(0, 55, 0, 55)
button.Position = UDim2.new(1, -70, 0, 15)
button.BackgroundColor3 = Color3.fromRGB(140, 50, 220)
button.Text = "↑"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 32
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = gui

-- Cantos arredondados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Pular
button.Activated:Connect(function()
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Jump = true
    end
end)
