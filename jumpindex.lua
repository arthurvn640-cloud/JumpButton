--[[
    jumpindex.lua
    - ∞ OFF: clicar ⬆ = 1 pulo normal (ChangeState + velocidade, sai de cadeira/carro)
    - ∞ ON: SEGURAR ⬆ = pula infinitamente / soltar = para
    - Botão ⬆ pisca azul claro ao clicar no OFF
    - Anti-spam: ignora clique se não estiver no chão
    - Intro com 6 etapas + textos PT/EN com MESMO tamanho de letra
    - Tela preta PERMANECE até o load ficar 100% pronto
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antiga = playerGui:FindFirstChild("BotaoPularGui")
if antiga then antiga:Destroy() end
local antigaIntro = playerGui:FindFirstChild("JumpIndexIntro")
if antigaIntro then antigaIntro:Destroy() end

------------------------------------------------------------
-- SCREEN GUI PRINCIPAL
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BotaoPularGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 900
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 60, 0, 90)
mainFrame.Position = UDim2.new(1, -80, 0, 20)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

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
-- CORES / ESTADOS
------------------------------------------------------------
local COR_AZUL_NORMAL = Color3.fromRGB(50, 130, 255)
local COR_AZUL_CLARO  = Color3.fromRGB(200, 230, 255)
local COR_VERDE_ARM   = Color3.fromRGB(40, 110, 70)
local COR_VERDE_ATIVO = Color3.fromRGB(80, 220, 120)

local GRAD_NORMAL = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
})
local GRAD_CLARO = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 230, 255))
})
local GRAD_ARM = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 160, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 50))
})
local GRAD_ATIVO = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 255, 160)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 140, 60))
})

local infiniteArmado = false
local segurando      = false
local loopRodando    = false
local piscando       = false
local FORCA_PULO     = 50

------------------------------------------------------------
-- FUNÇÕES DO BOTÃO
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

local function atualizarVisualBotao()
    if piscando then return end
    if segurando then
        container.BackgroundColor3 = COR_VERDE_ATIVO
        gradient.Color = GRAD_ATIVO
    elseif infiniteArmado then
        container.BackgroundColor3 = COR_VERDE_ARM
        gradient.Color = GRAD_ARM
    else
        container.BackgroundColor3 = COR_AZUL_NORMAL
        gradient.Color = GRAD_NORMAL
    end
end

local function piscarAzulClaro()
    piscando = true
    container.BackgroundColor3 = COR_AZUL_CLARO
    gradient.Color = GRAD_CLARO
    task.spawn(function()
        task.wait(0.15)
        piscando = false
        atualizarVisualBotao()
    end)
end

local function estaNoChao(humanoid)
    local estado = humanoid:GetState()
    if estado == Enum.HumanoidStateType.Jumping
    or estado == Enum.HumanoidStateType.Freefall then
        return false
    end
    if humanoid.FloorMaterial == Enum.Material.Air then
        return false
    end
    return true
end

local function aplicarPulo()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)

    local vel = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, FORCA_PULO, vel.Z)
end

local ultimoPulo = 0
local COOLDOWN = 0.35

local function pularNormal()
    local agora = tick()
    if agora - ultimoPulo < COOLDOWN then return end

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if humanoid.Sit then
        ultimoPulo = agora
        pcall(function() humanoid.Sit = false end)
        task.spawn(function()
            task.wait(0.08)
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if estaNoChao(hum) then aplicarPulo() end
        end)
        return
    end

    if not estaNoChao(humanoid) then return end
    ultimoPulo = agora
    aplicarPulo()
end

local function loopInfinite()
    if loopRodando then return end
    loopRodando = true

    task.spawn(function()
        while segurando and infiniteArmado do
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if humanoid and hrp then
                    pcall(function()
                        if humanoid.Sit then humanoid.Sit = false end
                    end)
                    pcall(function()
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                    local vel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, FORCA_PULO, vel.Z)
                end
            end
            task.wait(0.05)
        end
        loopRodando = false
    end)
end

toggleBtn.MouseButton1Click:Connect(function()
    infiniteArmado = not infiniteArmado
    if not infiniteArmado then segurando = false end
    atualizarToggle()
    atualizarVisualBotao()
end)

local function aoPressionar()
    if infiniteArmado then
        segurando = true
        atualizarVisualBotao()
        loopInfinite()
    else
        piscarAzulClaro()
        pularNormal()
    end
end

local function aoSoltar()
    if segurando then
        segurando = false
        atualizarVisualBotao()
    end
end

botao.MouseButton1Down:Connect(aoPressionar)
botao.MouseButton1Up:Connect(aoSoltar)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        aoSoltar()
    end
end)

atualizarToggle()
atualizarVisualBotao()

------------------------------------------------------------
-- INTRO
------------------------------------------------------------
local introGui = Instance.new("ScreenGui")
introGui.Name = "JumpIndexIntro"
introGui.ResetOnSpawn = false
introGui.IgnoreGuiInset = true
introGui.DisplayOrder = 9999
introGui.Parent = playerGui

local telaPreta = Instance.new("Frame")
telaPreta.Size = UDim2.new(1, 0, 1, 0)
telaPreta.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
telaPreta.BackgroundTransparency = 0
telaPreta.BorderSizePixel = 0
telaPreta.Parent = introGui

local painel = Instance.new("Frame")
painel.Size = UDim2.new(0, 400, 0, 220)
painel.Position = UDim2.new(0.5, -200, 0.5, -110)
painel.BackgroundColor3 = Color3.fromRGB(15, 30, 75)
painel.BackgroundTransparency = 1
painel.BorderSizePixel = 0
painel.Parent = introGui

local painelCorner = Instance.new("UICorner")
painelCorner.CornerRadius = UDim.new(0, 16)
painelCorner.Parent = painel

local painelGrad = Instance.new("UIGradient")
painelGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 20, 55)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 55, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 130, 220))
})
painelGrad.Rotation = 45
painelGrad.Parent = painel

local painelStroke = Instance.new("UIStroke")
painelStroke.Color = Color3.fromRGB(80, 130, 220)
painelStroke.Thickness = 1.5
painelStroke.Transparency = 1
painelStroke.Parent = painel

local introLogo = Instance.new("TextLabel")
introLogo.Size = UDim2.new(1, 0, 0, 40)
introLogo.Position = UDim2.new(0, 0, 0, 20)
introLogo.BackgroundTransparency = 1
introLogo.Text = "⬆ JUMPINDEX ⬆"
introLogo.TextColor3 = Color3.fromRGB(120, 180, 255)
introLogo.TextScaled = true
introLogo.Font = Enum.Font.GothamBlack
introLogo.TextTransparency = 1
introLogo.Parent = painel

local logoSize = Instance.new("UITextSizeConstraint")
logoSize.MaxTextSize = 26
logoSize.Parent = introLogo

-- ========== TEXTOS PT/EN COM MESMO TAMANHO ==========
local TAMANHO_TEXTO = 15

-- Texto PT
local textoPT = Instance.new("TextLabel")
textoPT.Size = UDim2.new(1, -40, 0, 22)
textoPT.Position = UDim2.new(0, 20, 0, 78)
textoPT.BackgroundTransparency = 1
textoPT.Text = ""
textoPT.TextColor3 = Color3.fromRGB(220, 235, 255)
textoPT.TextScaled = true
textoPT.Font = Enum.Font.GothamBold
textoPT.TextXAlignment = Enum.TextXAlignment.Left
textoPT.TextTransparency = 1
textoPT.Parent = painel

local ptSize = Instance.new("UITextSizeConstraint")
ptSize.MaxTextSize = TAMANHO_TEXTO
ptSize.Parent = textoPT

-- Texto EN (mesmo tamanho)
local textoEN = Instance.new("TextLabel")
textoEN.Size = UDim2.new(1, -40, 0, 22)
textoEN.Position = UDim2.new(0, 20, 0, 101)
textoEN.BackgroundTransparency = 1
textoEN.Text = ""
textoEN.TextColor3 = Color3.fromRGB(150, 180, 220)
textoEN.TextScaled = true
textoEN.Font = Enum.Font.Gotham
textoEN.TextXAlignment = Enum.TextXAlignment.Left
textoEN.TextTransparency = 1
textoEN.Parent = painel

local enSize = Instance.new("UITextSizeConstraint")
enSize.MaxTextSize = TAMANHO_TEXTO
enSize.Parent = textoEN
-- ====================================================

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 320, 0, 8)
barBg.Position = UDim2.new(0.5, -160, 0, 145)
barBg.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
barBg.BorderSizePixel = 0
barBg.BackgroundTransparency = 1
barBg.Parent = painel

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(1, 0)
barBgCorner.Parent = barBg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.BackgroundTransparency = 1
barFill.Parent = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

local percentLabel = Instance.new("TextLabel")
percentLabel.Size = UDim2.new(0, 320, 0, 18)
percentLabel.Position = UDim2.new(0.5, -160, 0, 160)
percentLabel.BackgroundTransparency = 1
percentLabel.Text = "0%"
percentLabel.TextColor3 = Color3.fromRGB(180, 200, 230)
percentLabel.TextScaled = true
percentLabel.Font = Enum.Font.GothamMedium
percentLabel.TextTransparency = 1
percentLabel.Parent = painel

local pctSize = Instance.new("UITextSizeConstraint")
pctSize.MaxTextSize = 13
pctSize.Parent = percentLabel

------------------------------------------------------------
-- ANIMAÇÃO DE INTRO
------------------------------------------------------------
task.spawn(function()
    task.wait(0.4)

    TweenService:Create(painel, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
    TweenService:Create(painelStroke, TweenInfo.new(0.6), {Transparency = 0.4}):Play()
    TweenService:Create(introLogo, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(textoPT, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(textoEN, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(barFill, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(percentLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    task.wait(0.7)

    local etapas = {
        {tempo = 1, pt = "Inicializando",                 en = "Initializing",              fill = 1/6, pct = "17%"},
        {tempo = 1, pt = "Criando botão",                 en = "Creating button",           fill = 2/6, pct = "33%"},
        {tempo = 1, pt = "Criando infinite jump",         en = "Creating infinite jump",    fill = 3/6, pct = "50%"},
        {tempo = 1, pt = "Conectando ao Roblox",          en = "Connecting to Roblox",      fill = 4/6, pct = "67%"},
        {tempo = 5, pt = "Fazendo o load do código",      en = "Loading the code",          fill = 5/6, pct = "83%"},
        {tempo = 1, pt = "Load do Jump Button completo",  en = "Jump Button load complete", fill = 6/6, pct = "100%"},
    }

    for _, etapa in ipairs(etapas) do
        textoPT.Text = etapa.pt
        textoEN.Text = etapa.en
        percentLabel.Text = etapa.pct

        TweenService:Create(barFill, TweenInfo.new(etapa.tempo, Enum.EasingStyle.Linear), {
            Size = UDim2.new(etapa.fill, 0, 1, 0)
        }):Play()

        task.wait(etapa.tempo)

        textoPT.Text = "Completo"
        textoEN.Text = "Complete"
        task.wait(0.03)
    end

    -- Garante que a barra chegou em 100%
    barFill.Size = UDim2.new(1, 0, 1, 0)
    percentLabel.Text = "100%"
    task.wait(0.3)

    -- Painel some primeiro
    TweenService:Create(painel, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(painelStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    TweenService:Create(introLogo, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(textoPT, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(textoEN, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(barFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(percentLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()

    -- Depois a tela preta some
    task.wait(0.45)
    TweenService:Create(telaPreta, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()

    task.wait(0.45)
    introGui:Destroy()

    print("[jumpindex] Load pronto! Tela preta removida.")
end)

print("[jumpindex] Carregado! Iniciando animação...")
