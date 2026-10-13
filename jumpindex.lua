--[[
    jumpindex.lua
    Botão de pular - Roblox Executor
    Aplica velocidade direta (funciona mesmo quando Jump é ignorado).
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

------------------------------------------------------------
-- BOTÃO
------------------------------------------------------------
local container = Instance.new("Frame")
container.Name = "ContainerBotao"
container.Size = UDim2.new(0, 70, 0, 70)
container.Position = UDim2.new(1, -90, 0, 20)
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
textSize.MaxTextSize = 42
textSize.Parent = botao

------------------------------------------------------------
-- ANIMAÇÕES
------------------------------------------------------------
local function tweenSize(novoTamanho)
    TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Size = novoTamanho
    }):Play()
end

local function tweenPosition(novaPosicao)
    TweenService:Create(container, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Position = novaPosicao
    }):Play()
end

botao.MouseEnter:Connect(function()
    tweenSize(UDim2.new(0, 80, 0, 80))
    tweenPosition(UDim2.new(1, -100, 0, 15))
end)

botao.MouseLeave:Connect(function()
    tweenSize(UDim2.new(0, 70, 0, 70))
    tweenPosition(UDim2.new(1, -90, 0, 20))
end)

botao.MouseButton1Down:Connect(function()
    tweenSize(UDim2.new(0, 60, 0, 60))
    tweenPosition(UDim2.new(1, -80, 0, 25))
end)

botao.MouseButton1Up:Connect(function()
    tweenSize(UDim2.new(0, 80, 0, 80))
    tweenPosition(UDim2.new(1, -100, 0, 15))
end)

------------------------------------------------------------
-- FUNÇÃO DE PULO — VERSÃO REFORÇADA
------------------------------------------------------------
local FORCA_PULO = 50 -- valor padrão do Roblox

local function pular()
    local character = player.Character
    if not character then
        print("[jumpindex] Sem personagem")
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not hrp then
        print("[jumpindex] Sem humanoid ou HumanoidRootPart")
        return
    end

    -- Verifica se está no chão
    if humanoid.FloorMaterial == Enum.Material.Air then
        print("[jumpindex] Está no ar, não pode pular")
        return
    end

    -- Método 1: propriedade padrão
    humanoid.Jump = true

    -- Método 2: força o estado
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)

    -- Método 3: aplica velocidade direta (mais confiável)
    local velocidadeAtual = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(
        velocidadeAtual.X,
        FORCA_PULO,
        velocidadeAtual.Z
    )

    print("[jumpindex] Pulo aplicado!")
end

botao.MouseButton1Click:Connect(pular)
botao.TouchTap:Connect(pular)

-- Espaço também pula
UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end
    if input.KeyCode == Enum.KeyCode.Space then
        pular()
    end
end)

print("[jumpindex] Botão de pular carregado!")
