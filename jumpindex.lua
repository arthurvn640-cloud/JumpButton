--[[
    jumpindex.lua
    Botão de pular para EXECUTORES DE ROBLOX.
    Versão final: pulo nativo, sai de cadeiras e não trava.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove a GUI antiga se ela já existir
local antiga = playerGui:FindFirstChild("BotaoPularGui")
if antiga then antiga:Destroy() end

------------------------------------------------------------
-- INTERFACE GRÁFICA (GUI)
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotaoPularGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Botão (Canto Superior Direito)
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

------------------------------------------------------------
-- ANIMAÇÕES DO BOTÃO
------------------------------------------------------------
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

------------------------------------------------------------
-- FUNÇÃO DE PULO (VERSÃO CORRIGIDA)
------------------------------------------------------------
local ultimoPulo = 0

local function pular()
    -- Cooldown para evitar sobrecarga em cliques rápidos
    local agora = tick()
    if agora - ultimoPulo < 0.1 then return end
    ultimoPulo = agora

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- 1. Garante que o estado de pulo está habilitado
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end)

    -- 2. Força a transição para o estado de pulo (o que faz sair da cadeira)
    local sucesso, erro = pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)

    if not sucesso then
        warn("[jumpindex] Falha ao mudar de estado: " .. tostring(erro))
    end
end

botao.MouseButton1Click:Connect(pular)
botao.TouchTap:Connect(pular)

-- A tecla de espaço também aciona a função de pular
UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end
    if input.KeyCode == Enum.KeyCode.Space then
        pular()
    end
end)

print("[jumpindex] Botão de pular carregado! (Pulo nativo corrigido)")
