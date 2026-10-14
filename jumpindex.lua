--[[
    jumpindex.lua
    - ∞ OFF: clicar ⬆ = 1 pulo normal (ChangeState + velocidade, sai de cadeira/carro)
    - ∞ ON: SEGURAR ⬆ = pula infinitamente / soltar = para
    - Botão ⬆ pisca azul claro ao clicar no OFF
    - Anti-spam: ignora clique se não estiver no chão
--]]

local Players = game:GetService("Players")
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
-- BOTÃO ⬆
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
-- TOGGLE ∞
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
-- CORES
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

------------------------------------------------------------
-- ESTADOS
------------------------------------------------------------
local infiniteArmado = false
local segurando      = false
local loopRodando    = false
local piscando       = false
local FORCA_PULO     = 50

------------------------------------------------------------
-- VISUAIS
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

------------------------------------------------------------
-- PISCA AZUL CLARO
------------------------------------------------------------
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

------------------------------------------------------------
-- CHECA SE ESTÁ NO CHÃO
------------------------------------------------------------
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

------------------------------------------------------------
-- APLICA PULO (ChangeState + velocidade)
------------------------------------------------------------
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

------------------------------------------------------------
-- PULO NORMAL (com debounce real)
------------------------------------------------------------
local ultimoPulo = 0
local COOLDOWN = 0.35

local function pularNormal()
    local agora = tick()
    if agora - ultimoPulo < COOLDOWN then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Se está sentado (cadeira/carro), levanta e pula depois
    if humanoid.Sit then
        ultimoPulo = agora
        pcall(function()
            humanoid.Sit = false
        end)
        task.spawn(function()
            task.wait(0.08)
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if estaNoChao(hum) then
                aplicarPulo()
            end
        end)
        return
    end

    -- Só pula se estiver no chão (evita spam e voo no OFF)
    if not estaNoChao(humanoid) then return end

    ultimoPulo = agora
    aplicarPulo()
end

------------------------------------------------------------
-- LOOP DO INFINITE
------------------------------------------------------------
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
                        if humanoid.Sit then
                            humanoid.Sit = false
                        end
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

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------
toggleBtn.MouseButton1Click:Connect(function()
    infiniteArmado = not infiniteArmado
    if not infiniteArmado then
        segurando = false
    end
    atualizarToggle()
    atualizarVisualBotao()
end)

------------------------------------------------------------
-- INPUT DO BOTÃO ⬆
------------------------------------------------------------
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

------------------------------------------------------------
-- INICIALIZAR
------------------------------------------------------------
atualizarToggle()
atualizarVisualBotao()
print("[jumpindex] Carregado!")
