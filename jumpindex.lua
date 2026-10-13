--[[
    jumpindex.lua
    Botão de pular para EXECUTORES DE ROBLOX.
    - Botão principal ⬆ (canto superior direito)
    - Botão de ativar/desativar Infinite Jump (embaixo do principal)
    - Sem pulo duplo ao clicar
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
screenGui.Parent = playerGui

------------------------------------------------------------
-- BOTÃO PRINCIPAL ⬆
------------------------------------------------------------
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
-- BOTÃO DE INFINITE JUMP (embaixo do principal)
------------------------------------------------------------
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ContainerToggle"
toggleContainer.Size = UDim2.new(0, 50, 0, 22)
toggleContainer.Position = UDim2.new(1, -70, 0, 78)
toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
toggleContainer.BorderSizePixel = 0
toggleContainer.Parent = screenGui

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
-- ANIMAÇÕES DO BOTÃO PRINCIPAL
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
-- ESTADO DO INFINITE JUMP
------------------------------------------------------------
local infiniteJumpAtivado = false

local function atualizarVisualToggle()
    if infiniteJumpAtivado then
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

toggleBtn.MouseButton1Click:Connect(function()
    infiniteJumpAtivado = not infiniteJumpAtivado
    atualizarVisualToggle()
    print("[jumpindex] Infinite Jump: " .. (infiniteJumpAtivado and "ATIVADO" or "DESATIVADO"))
end)

toggleBtn.MouseEnter:Connect(function()
    if not infiniteJumpAtivado then
        toggleContainer.BackgroundColor3 = Color3.fromRGB(50, 65, 90)
    else
        toggleContainer.BackgroundColor3 = Color3.fromRGB(35, 90, 55)
    end
end)

toggleBtn.MouseLeave:Connect(function()
    atualizarVisualToggle()
end)

------------------------------------------------------------
-- FUNÇÃO DE PULO (sem pulo duplo)
------------------------------------------------------------
local ultimoPulo = 0

local function pular()
    local agora = tick()
    if agora - ultimoPulo < 0.1 then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Não pula se já estiver pulando ou caindo (evita pulo duplo)
    local estado = humanoid:GetState()
    if estado == Enum.HumanoidStateType.Jumping 
       or estado == Enum.HumanoidStateType.Freefall then
        return
    end

    -- Não pula se estiver no ar
    if humanoid.FloorMaterial == Enum.Material.Air then return end

    ultimoPulo = agora

    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

botao.MouseButton1Click:Connect(pular)
botao.TouchTap:Connect(pular)

UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end
    if input.KeyCode == Enum.KeyCode.Space then
        pular()
    end
end)

------------------------------------------------------------
-- LOOP DO INFINITE JUMP (só roda quando ativado)
------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not infiniteJumpAtivado then return end

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
print("[jumpindex] Botão de pular carregado!")
