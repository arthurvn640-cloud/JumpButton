--[[
    jumpindex.lua
    - ∞ OFF: clicar ⬆ = 1 pulo normal
    - ∞ ON: SEGURAR ⬆ = pula infinitamente / soltar = para
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antiga = playerGui:FindFirstChild("BotaoPularGui")
if antiga then antiga:Destroy() end

------------------------------------------------------------
-- SCREEN GUI
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotaoPularGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

------------------------------------------------------------
-- BOTÃO ⬆
------------------------------------------------------------
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 50, 0, 50)
container.Position = UDim2.new(1, -70, 0, 20)
container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = container

local botao = Instance.new("TextButton")
botao.Size = UDim2.new(1, 0, 1, 0)
botao.BackgroundTransparency = 1
botao.Text = "⬆"
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.TextScaled = true
botao.Font = Enum.Font.GothamBold
botao.AutoButtonColor = false
botao.Parent = container

local textSize = Instance.new("UITextSizeConstraint")
textSize.MaxTextSize = 30
textSize.Parent = botao

------------------------------------------------------------
-- TOGGLE ∞
------------------------------------------------------------
local toggleContainer = Instance.new("Frame")
toggleContainer.Size = UDim2.new(0, 50, 0, 22)
toggleContainer.Position = UDim2.new(1, -70, 0, 78)
toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleContainer

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "∞ OFF"
toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = toggleContainer

local toggleTextSize = Instance.new("UITextSizeConstraint")
toggleTextSize.MaxTextSize = 13
toggleTextSize.Parent = toggleBtn

------------------------------------------------------------
-- ESTADOS
------------------------------------------------------------
local infiniteArmado = false
local segurando      = false

------------------------------------------------------------
-- VISUAL DO TOGGLE
------------------------------------------------------------
local function atualizarToggle()
    if infiniteArmado then
        toggleBtn.Text = "∞ ON"
        toggleBtn.TextColor3 = Color3.fromRGB(120, 255, 160)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(25, 70, 40)
    else
        toggleBtn.Text = "∞ OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    infiniteArmado = not infiniteArmado
    atualizarToggle()
end)

------------------------------------------------------------
-- PULO NORMAL (∞ OFF)
------------------------------------------------------------
local ultimoPulo = 0

local function pularNormal()
    local agora = tick()
    if agora - ultimoPulo < 0.25 then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local estado = humanoid:GetState()
    if estado == Enum.HumanoidStateType.Jumping
       or estado == Enum.HumanoidStateType.Freefall then
        return
    end
    if humanoid.FloorMaterial == Enum.Material.Air then return end

    ultimoPulo = agora

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

------------------------------------------------------------
-- INPUT NO BOTÃO ⬆
------------------------------------------------------------
-- Segurar
botao.MouseButton1Down:Connect(function()
    if infiniteArmado then
        segurando = true
        container.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
    else
        pularNormal()
    end
end)

-- Soltar
botao.MouseButton1Up:Connect(function()
    if segurando then
        segurando = false
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    end
end)

botao.MouseLeave:Connect(function()
    if segurando then
        segurando = false
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    end
end)

-- Mobile
botao.TouchLongPress:Connect(function()
    if infiniteArmado then
        segurando = true
        container.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
    end
end)

botao.TouchEnded:Connect(function()
    if segurando then
        segurando = false
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
    end
end)

------------------------------------------------------------
-- LOOP: só pula infinito se estiver armado E segurando
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not (infiniteArmado and segurando) then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end)

------------------------------------------------------------
atualizarToggle()
