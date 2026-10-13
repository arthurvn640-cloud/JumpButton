--[[
    jumpindex.lua
    Botão de pular para EXECUTORES DE ROBLOX.
    - Toggle "∞ ON / ∞ OFF" arma o infinite jump
    - Com infinite ON, SEGURAR o botão ⬆ ativa o voo/pulo infinito
    - Soltar o botão ⬆ para o infinite
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
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
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

------------------------------------------------------------
-- FRAME PAI
------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 60, 0, 90)
mainFrame.Position = UDim2.new(1, -80, 0, 20)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

------------------------------------------------------------
-- BOTÃO PRINCIPAL ⬆
------------------------------------------------------------
local container = Instance.new("Frame")
container.Name = "ContainerBotao"
container.Size = UDim2.new(0, 50, 0, 50)
container.Position = UDim2.new(0, 5, 0, 0)
container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
container.BorderSizePixel = 0
container.Parent = mainFrame

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
-- TOGGLE INFINITE JUMP
------------------------------------------------------------
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ContainerToggle"
toggleContainer.Size = UDim2.new(0, 50, 0, 22)
toggleContainer.Position = UDim2.new(0, 5, 0, 60)
toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleContainer

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(80, 130, 220)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleContainer

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "BtnToggle"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "∞ OFF"
toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = toggleContainer

local toggleTextSize = Instance.new("UITextSizeConstraint")
toggleTextSize.MaxTextSize = 13
toggleTextSize.Parent = toggleBtn

------------------------------------------------------------
-- ANIMAÇÕES
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
    animar(UDim2.new(0, 58, 0, 58), UDim2.new(0, 1, 0, -4))
end)

botao.MouseLeave:Connect(function()
    animar(UDim2.new(0, 50, 0, 50), UDim2.new(0, 5, 0, 0))
end)

------------------------------------------------------------
-- ESTADOS
------------------------------------------------------------
local infiniteArmado = false   -- toggle ∞ ON ?
local infiniteAtivo  = false   -- segurando o botão ⬆ ?
local segurando      = false   -- botão está sendo pressionado ?

-- Atualiza o visual do toggle
local function atualizarVisualToggle()
    if infiniteArmado then
        toggleBtn.Text = "∞ ON"
        toggleBtn.TextColor3 = Color3.fromRGB(120, 255, 160)
        toggleStroke.Color = Color3.fromRGB(80, 255, 130)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(25, 70, 40)
    else
        toggleBtn.Text = "∞ OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(180, 200, 230)
        toggleStroke.Color = Color3.fromRGB(80, 130, 220)
        toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    end
end

-- Atualiza o visual do botão de pular conforme o estado
local function atualizarVisualBotao()
    if infiniteAtivo then
        -- Verde (infinite voando)
        container.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 255, 160)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 140, 60))
        })
    elseif infiniteArmado then
        -- Verde escuro (armado, esperando segurar)
        container.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 160, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 50))
        })
    else
        -- Azul normal
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
        })
    end
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------
toggleBtn.MouseButton1Click:Connect(function()
    infiniteArmado = not infiniteArmado

    if not infiniteArmado then
        infiniteAtivo = false
        segurando = false
    end

    atualizarVisualToggle()
    atualizarVisualBotao()
    print("[jumpindex] Infinite Jump: " .. (infiniteArmado and "ON" or "OFF"))
end)

toggleBtn.MouseEnter:Connect(function()
    if not infiniteArmado then
        toggleContainer.BackgroundColor3 = Color3.fromRGB(50, 65, 90)
    else
        toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 90, 55)
    end
end)

toggleBtn.MouseLeave:Connect(function()
    atualizarVisualToggle()
end)

------------------------------------------------------------
-- FUNÇÃO DE PULO NORMAL
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
-- INPUT DO BOTÃO ⬆ (segurar / soltar)
------------------------------------------------------------
-- PRESSIONAR
local function aoPressionar()
    segurando = true
    animar(UDim2.new(0, 44, 0, 44), UDim2.new(0, 8, 0, 3))

    if infiniteArmado then
        -- Ativa o infinite enquanto estiver segurando
        infiniteAtivo = true
        atualizarVisualBotao()
        print("[jumpindex] Infinite Jump ATIVO (segurando)")
    else
        -- Pulo normal
        pularNormal()
    end
end

-- SOLTAR
local function aoSoltar()
    segurando = false
    animar(UDim2.new(0, 50, 0, 50), UDim2.new(0, 5, 0, 0))

    if infiniteAtivo then
        infiniteAtivo = false
        atualizarVisualBotao()
        print("[jumpindex] Infinite Jump PARADO (soltou)")
    end
end

botao.MouseButton1Down:Connect(aoPressionar)
botao.MouseButton1Up:Connect(aoSoltar)
botao.MouseLeave:Connect(function()
    if segurando then
        aoSoltar()
    end
    animar(UDim2.new(0, 50, 0, 50), UDim2.new(0, 5, 0, 0))
end)

-- Suporte a toque (mobile) — segurar e soltar
botao.TouchLongPress:Connect(aoPressionar)
botao.TouchEnded:Connect(aoSoltar)

------------------------------------------------------------
-- LOOP DO INFINITE (só quando infiniteAtivo)
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not infiniteAtivo then return end

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
-- INICIALIZAR
------------------------------------------------------------
atualizarVisualToggle()
atualizarVisualBotao()
print("[jumpindex] Carregado!")
