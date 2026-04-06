local M = {}

-- ==========================================================
-- Internal state
-- ==========================================================

local Keyboard = { Down = {}, Pressed = {}, Released = {} }

local Controller = { Down = {}, Pressed = {}, Released = {}, Axis = {}, CurActive = nil }

local Mouse = {
    Down = {},
    Pressed = {},
    Released = {},
    X = 0,
    Y = 0,
    WheelX = 0,
    WheelY = 0
}

-- ==========================================================
-- Listeners
-- ==========================================================

local KeyboardListeners = { Pressed = {}, Released = {} }

local ControllerListeners = { Pressed = {}, Released = {}, Axis = {} }

local MouseListeners = {
    Pressed = {},
    Released = {},
    Moved = {},
    Wheel = {}
}

-- ==========================================================
-- Listener ID generator
-- ==========================================================

local nextListenerID = 1

local function addListener(list, callback)
    local id = nextListenerID
    nextListenerID = nextListenerID + 1

    list[id] = callback

    local funcs = {}

    function funcs.Remove()
        if list[id] then
            list[id] = nil
        end
    end

    return funcs
end

-- ==========================================================
-- LÖVE callbacks
-- ==========================================================

function love.keypressed(key, scancode, isrepeat)
    Keyboard.Down[key] = true
    if not isrepeat then Keyboard.Pressed[key] = true end

    for _, cb in pairs(KeyboardListeners.Pressed) do
        cb(key, scancode)
    end
end

function love.keyreleased(key)
    Keyboard.Down[key] = false
    Keyboard.Released[key] = true

    for _, cb in pairs(KeyboardListeners.Released) do
        cb(key)
    end
end

-- =========================
-- Mouse
-- =========================

function love.mousepressed(x, y, button)
    Mouse.Down[button] = true
    Mouse.Pressed[button] = true
    Mouse.X = x
    Mouse.Y = y

    for _, cb in pairs(MouseListeners.Pressed) do
        cb(button, x, y)
    end
end

function love.mousereleased(x, y, button)
    Mouse.Down[button] = false
    Mouse.Released[button] = true
    Mouse.X = x
    Mouse.Y = y

    for _, cb in pairs(MouseListeners.Released) do
        cb(button, x, y)
    end
end

function love.mousemoved(x, y)
    Mouse.X = x
    Mouse.Y = y

    for _, cb in pairs(MouseListeners.Moved) do
        cb(x, y)
    end
end

function love.wheelmoved(x, y)
    Mouse.WheelX = x
    Mouse.WheelY = y

    for _, cb in pairs(MouseListeners.Wheel) do
        cb(x, y)
    end
end

-- =========================
-- Controller
-- =========================

function love.joystickadded(joystick)
    local guid = joystick:getGUID()
    Controller.CurActive = guid
    Controller.Down[guid] = {}
    Controller.Pressed[guid] = {}
    Controller.Released[guid] = {}
    Controller.Axis[guid] = {}
end

function love.joystickremoved(joystick)
    local guid = joystick:getGUID()
    Controller.Down[guid] = nil
    Controller.Pressed[guid] = nil
    Controller.Released[guid] = nil
    Controller.Axis[guid] = nil
    if Controller.CurActive == guid then Controller.CurActive = nil end
end

function love.joystickpressed(joystick, button)
    local guid = joystick:getGUID()
    Controller.CurActive = guid
    Controller.Down[guid][button] = true
    Controller.Pressed[guid][button] = true

    for _, cb in pairs(ControllerListeners.Pressed) do
        cb(button, guid)
    end
end

function love.joystickreleased(joystick, button)
    local guid = joystick:getGUID()
    Controller.CurActive = guid
    Controller.Down[guid][button] = false
    Controller.Released[guid][button] = true

    for _, cb in pairs(ControllerListeners.Released) do
        cb(button, guid)
    end
end

function love.joystickaxis(joystick, axis, value)
    local guid = joystick:getGUID()
    Controller.CurActive = guid
    Controller.Axis[guid][axis] = value

    for _, cb in pairs(ControllerListeners.Axis) do
        cb(axis, value, guid)
    end
end

-- ==========================================================
-- Update (call at end of love.update)
-- ==========================================================

function M.Update()
    for k in pairs(Keyboard.Pressed) do Keyboard.Pressed[k] = nil end
    for k in pairs(Keyboard.Released) do Keyboard.Released[k] = nil end

    for k in pairs(Mouse.Pressed) do Mouse.Pressed[k] = nil end
    for k in pairs(Mouse.Released) do Mouse.Released[k] = nil end

    Mouse.WheelX = 0
    Mouse.WheelY = 0

    for guid, buttons in pairs(Controller.Pressed) do
        for btn in pairs(buttons) do buttons[btn] = nil end
    end
    for guid, buttons in pairs(Controller.Released) do
        for btn in pairs(buttons) do buttons[btn] = nil end
    end
end

-- ==========================================================
-- Listener registration
-- ==========================================================

function M.OnKeyPressed(callback) return addListener(KeyboardListeners.Pressed, callback) end
function M.OnKeyReleased(callback) return addListener(KeyboardListeners.Released, callback) end

function M.OnControllerPressed(callback) return addListener(ControllerListeners.Pressed, callback) end
function M.OnControllerReleased(callback) return addListener(ControllerListeners.Released, callback) end
function M.OnControllerAxis(callback) return addListener(ControllerListeners.Axis, callback) end

function M.OnMousePressed(callback) return addListener(MouseListeners.Pressed, callback) end
function M.OnMouseReleased(callback) return addListener(MouseListeners.Released, callback) end
function M.OnMouseMoved(callback) return addListener(MouseListeners.Moved, callback) end
function M.OnMouseWheel(callback) return addListener(MouseListeners.Wheel, callback) end

-- ==========================================================
-- Keyboard query
-- ==========================================================

function M.KeyDown(key) return Keyboard.Down[key] == true end
function M.KeyPressed(key) return Keyboard.Pressed[key] == true end
function M.KeyReleased(key) return Keyboard.Released[key] == true end

-- ==========================================================
-- Mouse query
-- ==========================================================

function M.MouseDown(button) return Mouse.Down[button] == true end
function M.MousePressed(button) return Mouse.Pressed[button] == true end
function M.MouseReleased(button) return Mouse.Released[button] == true end

function M.MousePosition()
    return Mouse.X, Mouse.Y
end

function M.MouseWheel()
    return Mouse.WheelX, Mouse.WheelY
end

-- ==========================================================
-- Controller query
-- ==========================================================

function M.ButtonDown(button, guid)
    guid = guid or Controller.CurActive
    return guid and Controller.Down[guid] and Controller.Down[guid][button] == true
end

function M.ButtonPressed(button, guid)
    guid = guid or Controller.CurActive
    return guid and Controller.Pressed[guid] and Controller.Pressed[guid][button] == true
end

function M.ButtonReleased(button, guid)
    guid = guid or Controller.CurActive
    return guid and Controller.Released[guid] and Controller.Released[guid][button] == true
end

function M.Axis(axis, guid)
    guid = guid or Controller.CurActive
    return guid and Controller.Axis[guid] and Controller.Axis[guid][axis] or 0
end

function M.ActiveController()
    return Controller.CurActive
end

return M