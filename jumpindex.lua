--[[
    jumpindex.lua
    Botão de pular para EXECUTORES DE ROBLOX.
    Cada clique = 1 pulo. Sem travar em cliques rápidos.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antiga = playerGui:FindFirstChild("BotaoPularGui")
if antiga then antiga:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotaoPularGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "ContainerBotao"
container.Size = UDim2.new(0, 50, 0, 50)
container.Position = UDim2.new(1, -70, 0, 20)
container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.5
stroke.Parent = container

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
})
gradient.Rotation = 90
gradient.Parent = container

local botao = Instance.new("TextButton")
botao.Name = "BtnPular"
botao.Size = UDim2.new(1, 0, 1, 0)
botao.BackgroundTransparency = 1
botao.Text = "⬆"
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.TextScaled = true
botao.Font = Enum.Font.GothamBold
botao.AutoButtonColor = false
botao.Active = true
botao.Parent = container

local textSize = Instance.new("UITextSizeConstraint")
textSize.MaxTextSize = 30
textSize.Parent = botao

-- ============================================================
-- ANIMAÇÕES (cancela tween anterior antes de criar outro)
-- ============================================================
local tweenAtual = nil

local function animar(tamanho, posicao)
    if tweenAtual then
        tweenAtual:Cancel()
        tweenAtual = nil
    end

    tweenAtual = TweenService:Create(container, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        Size = tamanho,
        Position = posicao
    })
    tweenAtual:Play()
end

botao.MouseEnter:Connect(function()
    animar(UDim2.new(0, 58, 0, 58), UDim2.new(1, -74, 0, 16))
end)

botao.MouseLeave:Connect(function()
    animar(UDim2.new(0, 50, 0, 50), UDim2.new(1, -70, 0, 20))
end)

botao.MouseButton1Down:Connect(function()
    animar(UDim2.new(0, 44, 0, 44), UDim2.new(1, -67, 0, 23))
end)

botao.MouseButton1Up:Connect(function()
    animar(UDim2.new(0, 58, 0, 58), UDim2.new(1, -74, 0, 16))
end)

-- ============================================================
-- PULO (sem pcall, sem verificação pesada, sem delay)
-- ============================================================
local FORCA_PULO = 50
local ultimoPulo = 0

local function pular()
    -- Cooldown baseado em tempo (mais preciso que booleano)
    local agora = tick()
    if agora - ultimoPulo < 0.08 then return end
    ultimoPulo = agora

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.FloorMaterial == Enum.Material.Air then return end

    -- Aplica pulo direto via velocidade (mais rápido que ChangeState)
    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, FORCA_PULO, vel.Z)
end

botao.MouseButton1Click:Connect(pular)
botao.TouchTap:Connect(pular)

UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end
    if input.KeyCode == Enum.KeyCode.Space then
        pular()
    end
end)

print("[jumpindex] Botão de pular carregado!")
