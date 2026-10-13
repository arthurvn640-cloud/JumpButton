--[[
    jumpindex.lua
    - ∞ OFF: clicar ⬆ = 1 pulo normal
    - ∞ ON: SEGURAR ⬆ = pula infinitamente / soltar = para
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
-- ESTADOS
------------------------------------------------------------
local infiniteArmado = false
local segurando      = false
local loopRodando    = false

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
    if segurando then
        container.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 255, 160)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 140, 60))
        })
    elseif infiniteArmado then
        container.BackgroundColor3 = Color3.fromRGB(40, 110, 70)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 160, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 50))
        })
    else
        container.BackgroundColor3 = Color3.fromRGB(50, 130, 255)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 200))
        })
    end
end

------------------------------------------------------------
-- PULO NORMAL
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
-- LOOP DO INFINITE (usando task.spawn)
------------------------------------------------------------
local function loopInfinite()
    if loopRodando then return end
    loopRodando = true

    task.spawn(function()
        while segurando and infiniteArmado do
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
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
    print("[jumpindex] Toggle: " .. (infiniteArmado and "ON" or "OFF"))
end)

------------------------------------------------------------
-- INPUT DO BOTÃO ⬆
------------------------------------------------------------
local function aoPressionar()
    print("[jumpindex] Pressionou ⬆ | ∞ = " .. tostring(infiniteArmado))

    if infiniteArmado then
        segurando = true
        atualizarVisualBotao()
        loopInfinite()
    else
        pularNormal()
    end
end

local function aoSoltar()
    if segurando then
        print("[jumpindex] Soltou ⬆")
        segurando = false
        atualizarVisualBotao()
    end
end

-- Eventos diretos do botão
botao.MouseButton1Down:Connect(aoPressionar)
botao.MouseButton1Up:Connect(aoSoltar)

-- Eventos globais (para pegar quando solta fora do botão)
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
