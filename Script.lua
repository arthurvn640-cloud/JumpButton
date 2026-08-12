local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove versões anteriores
local oldGui = playerGui:FindFirstChild("JumpButton")
if oldGui then
    oldGui:Destroy()
end

-- Criar interface
local gui = Instance.new("ScreenGui")
gui.Name = "JumpButton"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- ÚNICO BOTÃO
local button = Instance.new("TextButton")
button.Name = "Jump"
button.Size = UDim2.fromOffset(55, 55)
button.Position = UDim2.new(1, -70, 0, 15)
button.BackgroundColor3 = Color3.fromRGB(140, 50, 220)
button.Text = "↑"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 32
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Active = true
button.ZIndex = 10
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Pulo
local function jump()
    local character = player.Character
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    humanoid.Jump = true
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

-- Clique no computador / toque no celular
button.Activated:Connect(jump)
