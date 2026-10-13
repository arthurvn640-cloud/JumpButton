--[[
    ═══════════════════════════════════════════════════════════
    jumpindex.lua
    ═══════════════════════════════════════════════════════════
    Botão de pular reutilizável para jogos feitos com LÖVE / Love2D.

    Características:
    - Botão azul circular com seta ⬆ no canto superior direito
    - Suporte a mouse (desktop) e toque (mobile)
    - Animações suaves de hover e clique
    - Callback configurável (onPular)
    - Compatível com require() e loadstring()
    - Totalmente configurável (cores, tamanho, posição)

    Uso básico:
        local BotaoPular = require("jumpindex")
        botao = BotaoPular.new({
            onPular = function() print("Pulou!") end,
        })

    Licença: MIT
    ═══════════════════════════════════════════════════════════
--]]

local BotaoPular = {}
BotaoPular.__index = BotaoPular

------------------------------------------------------------
-- CONSTRUTOR
------------------------------------------------------------
function BotaoPular.new(config)
    config = config or {}
    local self = setmetatable({}, BotaoPular)

    -- Dimensões e posição
    self.largura = config.largura or 70
    self.margem  = config.margem  or 20
    self.y       = config.y       or self.margem
    self.x       = 0

    -- Cores (RGB 0-1)
    self.cor        = config.cor        or {0.20, 0.51, 1.00}
    self.corHover   = config.corHover   or {0.31, 0.63, 1.00}
    self.corPressed = config.corPressed or {0.13, 0.38, 0.85}
    self.corSeta    = config.corSeta    or {1, 1, 1}
    self.corBorda   = config.corBorda   or {1, 1, 1, 0.7}

    -- Estado
    self.visivel     = config.visivel ~= false
    self.hover       = false
    self.pressionado = false
    self.escala      = 1
    self.escalaAlvo  = 1
    self.escalaHover = config.escalaHover or 1.12
    self.escalaClick = config.escalaClick or 0.90

    -- Callback
    self.onPular = config.onPular or function() end

    self:atualizarPosicao()
    return self
end

------------------------------------------------------------
-- POSIÇÃO
------------------------------------------------------------
function BotaoPular:atualizarPosicao()
    local w = love.graphics.getWidth()
    self.x = w - self.largura - self.margem
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------
function BotaoPular:update(dt)
    local v = math.min(dt * 15, 1)
    self.escala = self.escala + (self.escalaAlvo - self.escala) * v
end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------
function BotaoPular:draw()
    if not self.visivel then return end

    local tamanho = self.largura * self.escala
    local cx = self.x + self.largura / 2
    local cy = self.y + self.largura / 2
    local raio = tamanho / 2

    -- Cor conforme estado
    local cor = self.cor
    if self.pressionado then
        cor = self.corPressed
    elseif self.hover then
        cor = self.corHover
    end

    -- Sombra
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.circle("fill", cx + 3, cy + 3, raio)

    -- Círculo principal
    love.graphics.setColor(cor[1], cor[2], cor[3], 1)
    love.graphics.circle("fill", cx, cy, raio)

    -- Borda
    love.graphics.setColor(
        self.corBorda[1],
        self.corBorda[2],
        self.corBorda[3],
        self.corBorda[4] or 1
    )
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", cx, cy, raio)

    -- Seta ⬆
    love.graphics.setColor(self.corSeta[1], self.corSeta[2], self.corSeta[3], 1)
    local tamSeta = tamanho * 0.45

    -- Cabeça da seta (triângulo)
    love.graphics.polygon("fill",
        cx, cy - tamSeta / 2,
        cx - tamSeta / 2, cy + tamSeta / 4,
        cx + tamSeta / 2, cy + tamSeta / 4
    )

    -- Haste da seta (retângulo)
    local lH = tamSeta * 0.25
    local aH = tamSeta * 0.5
    love.graphics.rectangle("fill",
        cx - lH / 2,
        cy + tamSeta / 4 - 2,
        lH,
        aH
    )
end

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
function BotaoPular:mouseEmCima(mx, my)
    local cx = self.x + self.largura / 2
    local cy = self.y + self.largura / 2
    local dx = mx - cx
    local dy = my - cy
    return (dx * dx + dy * dy) <= (self.largura / 2) * (self.largura / 2)
end

function BotaoPular:setVisivel(v)
    self.visivel = v
end

function BotaoPular:isVisivel()
    return self.visivel
end

------------------------------------------------------------
-- INPUT - MOUSE
------------------------------------------------------------
function BotaoPular:mousepressed(x, y, button)
    if not self.visivel or button ~= 1 then return false end
    if self:mouseEmCima(x, y) then
        self.pressionado = true
        self.escalaAlvo = self.escalaClick
        return true
    end
    return false
end

function BotaoPular:mousereleased(x, y, button)
    if button ~= 1 then return false end

    local clicou = false
    if self.pressionado and self:mouseEmCima(x, y) then
        self.onPular()
        clicou = true
    end

    self.pressionado = false

    if self:mouseEmCima(x, y) then
        self.escalaAlvo = self.escalaHover
    else
        self.escalaAlvo = 1
    end

    return clicou
end

function BotaoPular:mousemoved(x, y)
    if not self.visivel then return end

    if self:mouseEmCima(x, y) then
        self.hover = true
        if not self.pressionado then
            self.escalaAlvo = self.escalaHover
        end
    else
        self.hover = false
        if not self.pressionado then
            self.escalaAlvo = 1
        end
    end
end

------------------------------------------------------------
-- INPUT - TOQUE (MOBILE)
------------------------------------------------------------
function BotaoPular:touchpressed(id, x, y)
    if not self.visivel then return false end
    if self:mouseEmCima(x, y) then
        self.pressionado = true
        self.escalaAlvo = self.escalaClick
        self.hover = true
        return true
    end
    return false
end

function BotaoPular:touchreleased(id, x, y)
    local clicou = false
    if self.pressionado and self:mouseEmCima(x, y) then
        self.onPular()
        clicou = true
    end

    self.pressionado = false
    self.hover = false
    self.escalaAlvo = 1

    return clicou
end

------------------------------------------------------------
-- REDIMENSIONAMENTO
------------------------------------------------------------
function BotaoPular:resize()
    self:atualizarPosicao()
end

------------------------------------------------------------
-- LOADSTRING / GLOBAL
------------------------------------------------------------
_G.BotaoPular = BotaoPular

return BotaoPular
