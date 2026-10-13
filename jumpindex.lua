local f = io.open("jumpindex.lua", "r")
local codigo = f:read("*a")
f:close()

local BotaoPular = (loadstring or load)(codigo)()

botao = BotaoPular.new({
    onPular = function() print("Pulou!") end,
})
