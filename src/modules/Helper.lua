local json = require("src.modules.json")

local BASE_W, BASE_H = 1280, 720 -- your design resolution
local screenSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}

local helper = {}

-- Call this every frame to update screen size
helper.update = function()
    screenSize.x = love.graphics.getWidth()
    screenSize.y = love.graphics.getHeight()
end

-- Returns the scale factor for X/Y based on BASE resolution
helper.scale = {
    X = function() return screenSize.x / BASE_W end,
    Y = function() return screenSize.y / BASE_H end
}

-- Automatically scale mouse coordinates to base resolution
helper.Mouse = {
    Position = function()
        local x, y = love.mouse.getPosition()
        return x / helper.scale.X(), y / helper.scale.Y()
    end
}

helper.color = {
    hexToClr = function(hexInput, alpha)
        if type(hexInput) ~= "string" then
            error("entered hex must be a string")
        end
        hexInput = hexInput:gsub("^#", "")
        if string.len(hexInput) == 3 then
            hexInput = hexInput:gsub(".", "%1%1")
        end
        if string.len(hexInput) ~= 6 then
            error("entered hex string is not 6 letters long")
        end
        local r = tonumber(hexInput:sub(1, 2), 16)
        local g = tonumber(hexInput:sub(3, 4), 16)
        local b = tonumber(hexInput:sub(5, 6), 16)
        return r/255, g/255, b/255, (alpha/255) or 1
    end,
    rgbToClr = function(r, g, b, a)
        return (r or 255)/255, (g or 255)/255, (b or 255)/255, (a or 255)/255
    end
}

helper.size = {
    PercentY = function(percent)
        return BASE_H * (percent or 1)
    end,
    PercentX = function(percent)
        return BASE_W * (percent or 1)
    end,
    InBounds = function(x1, y1, x2, y2, x2Size, y2Size)
        return x1 >= x2 and
               x1 <= x2 + x2Size and
               y1 >= y2 and
               y1 <= y2 + y2Size
    end,
    IsPointInCenteredBox = function(px, py, cx, cy, w, h)
        local left = cx - w/2
        local top = cy - h/2
        return helper.size.InBounds(px, py, left, top, w, h)
    end,
}

helper.math = {
    Clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end,
    Lerp = function(a, b, t)
        return a + (b - a) * t
    end,
}

helper.file = {
    SaveSettings = function(Settings)
        local a, b = pcall(function()
            love.filesystem.write("settings.dat", json.encode(Settings)) -- save as data file
        end)
        return a, b
    end,
    LoadSettings = function()
        if love.filesystem.getInfo("settings.dat") then
            local a, b = pcall(function()
                return json.decode(love.filesystem.read("settings.dat"))
            end)
            return a, b
        else
            return false, "No settings file found"
        end
    end,
}

return helper