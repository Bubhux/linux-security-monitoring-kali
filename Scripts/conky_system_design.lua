require 'cairo'
require 'cairo_xlib'

-- Éviter les erreurs de calcul au démarrage
local function safe_tonumber(str)
    local num = tonumber(str)
    return num or 0
end

-- Fonction de copie de table (remplace table.copy)
local function table_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end
