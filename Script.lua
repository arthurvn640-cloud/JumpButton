local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove versões anteriores
local old = playerGui:FindFirstChild("JumpButton")
if old then
    old:Destroy()
end

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "JumpButton"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

-- Botão
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
button.Active = true
button.AutoButtonColor = true
button.ZIndex = 10
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Função de pulo
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

-- Funciona com toque no celular e clique no computador
button.Activated:Connect(jump)
