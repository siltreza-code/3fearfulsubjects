local screenSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
local helper = require "src/modules/Helper"
local input = require "src.modules.Inputs"
local timer = require "src.modules.timer"
local currentScene = ""
local scenes = {}

local fonts = {}
local fontInfo = {
    ["jersey"] = {
        path = "src/fonts/jersey10.ttf",
        size = function() return 36 end
    },
    ["jersey-small"] = {
        path = "src/fonts/jersey10.ttf",
        size = function() return 24 end
    }
}

local tick, fps = 0, 0
local BASE_W, BASE_H = 1280, 720
local scaleX, scaleY = 1, 1

local function reloadFonts()

    scaleX = screenSize.x / BASE_W
    scaleY = screenSize.y / BASE_H

    for name, info in pairs(fontInfo) do
        fonts[name] = love.graphics.newFont(info.path, info.size())
    end
end

function love.resize(w, h)
    screenSize.x = w
    screenSize.y = h
    reloadFonts()
end

function love.load()
    reloadFonts()
    currentScene = "MainMenu"
    love.math.setRandomSeed(os.time())

    scenes["MainMenu"] = {
        imageData = nil, noiseData = nil,
        noiseVars = {
            x = math.random() * 1000, y = math.random() * 1000, t = math.random() * 1000,
            vx = (math.random() * 2 - 1) * 3, vy = (math.random() * 2 - 1) * 3, vt = (math.random() * 2 - 1),
            scale = math.random() * 0.02 + 0.005
        },
        TitleImg = love.graphics.newImage("src/imgs/title.png"),
        Buttons = {
            {
                text = "continue",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.5) end},
                size = {function() return helper.size.PercentX(0.14) end, function() return helper.size.PercentY(0.065) end},
                onPress = function()
                    scenes.MainMenu.Buttons[1].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.MainMenu.Buttons[1].color = {helper.color.rgbToClr(20, 20, 20)}
                    currentScene = "play"
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            },
            {
                text = "info",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.75) end},
                size = {function() return helper.size.PercentX(0.10) end, function() return helper.size.PercentY(0.065) end},
                onPress = function()
                    scenes.MainMenu.Buttons[2].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.MainMenu.Buttons[2].color = {helper.color.rgbToClr(20, 20, 20)}
                    currentScene = "info"
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            },
            {
                text = "quit",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.85) end},
                size = {function() return helper.size.PercentX(0.10) end, function() return helper.size.PercentY(0.065) end},
                onPress = function()
                    scenes.MainMenu.Buttons[3].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.MainMenu.Buttons[3].color = {helper.color.rgbToClr(20, 20, 20)}
                    love.event.quit()
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            },
            {
                text = "toggle fullscreen",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.65) end},
                size = {function() return helper.size.PercentX(0.22) end, function() return helper.size.PercentY(0.065) end},
                onPress = function()
                    scenes.MainMenu.Buttons[4].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.MainMenu.Buttons[4].color = {helper.color.rgbToClr(20, 20, 20)}
                    love.window.setFullscreen(not love.window.getFullscreen())

                    reloadFonts()
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            }
        },
        update = function(DT)
            local self = scenes.MainMenu
            self.noiseData = love.image.newImageData(BASE_W, BASE_H)

            -- gen perlin data
            for px = 0, BASE_W-1 do
                for py = 0, BASE_H-1 do
                    local NoiseVal = love.math.noise(
                        (px+self.noiseVars.x) * self.noiseVars.scale,
                        (py+self.noiseVars.y) * self.noiseVars.scale,
                        self.noiseVars.t
                    )
                    self.noiseData:setPixel(px, py, NoiseVal, NoiseVal, NoiseVal, 1)
                end
            end
            self.imageData = love.graphics.newImage(self.noiseData)

            -- update perlin data
            self.noiseVars.x = self.noiseVars.x + self.noiseVars.vx * DT
            self.noiseVars.y = self.noiseVars.y + self.noiseVars.vy * DT
            self.noiseVars.t = self.noiseVars.t + self.noiseVars.vt * DT

            local mx, my = input.MousePosition()
            mx = mx / scaleX
            my = my / scaleY
            if input.MousePressed(1) then -- buttons
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onPress()
                    end
                end
            end
            if input.MouseReleased(1) then
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onRelease()
                    end
                end
            end
        end,

        draw = function()
            local self = scenes.MainMenu

            love.graphics.setColor(helper.color.rgbToClr(40, 100, 40))
            love.graphics.draw(self.imageData, 0, 0)
            love.graphics.setColor(1, 1, 1, 1)
            
            local imgW = self.TitleImg:getWidth()
            local imgH = self.TitleImg:getHeight()
            
            local targetWidth = BASE_W * 0.7
            local scale = targetWidth / imgW

            love.graphics.draw(
                self.TitleImg,
                BASE_W * 0.5,
                BASE_H * 0.2,
                0,
                scale, scale,
                imgW / 2, imgH / 2
            )

            for I, V in ipairs(self.Buttons) do
                local left = V.position[1]() - (V.size[1]()/2)
                local top = V.position[2]() - (V.size[2]()/2)

                -- Draw button background
                love.graphics.setColor(unpack(V.color))
                love.graphics.rectangle("fill", left, top, V.size[1](), V.size[2](), V.rounded(), V.rounded())

                -- Draw outlined text centered
                love.graphics.setFont(V.font)

                local textW = V.font:getWidth(V.text)
                local textH = V.font:getHeight()

                local textX = V.position[1]() - textW / 2
                local textY = V.position[2]() - textH / 2

                -- Outline color
                local outlineColor = {0, 0, 0, 1} -- black
                love.graphics.setColor(outlineColor)
                love.graphics.setLineWidth(V.thickness())
                love.graphics.rectangle("line", left, top, V.size[1](), V.size[2](), V.rounded(), V.rounded())

                -- Draw main text
                love.graphics.setColor(unpack(V.textColor))
                love.graphics.setFont(V.font)
                love.graphics.print(V.text, textX, textY)
            end

            -- warning
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.setFont(fonts.jersey)
            love.graphics.print("THIS GAME DOES NOT INCLUDE SAVING FOR MOST THINGS CURRENTLY", 2, 0)
        end
    }
    scenes["info"] = {
        Buttons = {
            {
                text = "\n\n\n\n"..
                "This game is inspired by shed horror by Zytrome. Started because I wanted to have the same effect to 3FS, a youtuber I enjoy to watch."..
                "This game for the most part DOES NOT INCLUDE SAVING, I do plan to add it but currently there is only saving for small stuff. "..
                "This is also my first game that I might release so do expect bugs EVERYWHERE. "..
                "\n\n\n\n\n\n-Siltrez",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.42) end},
                size = {function() return helper.size.PercentX(0.90) end, function() return helper.size.PercentY(0.8) end},
                onPress = function()
                end,
                onRelease = function()
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            },
            {
                text = "back",
                position = {function() return helper.size.PercentX(0.5) end, function() return helper.size.PercentY(0.9) end},
                size = {function() return helper.size.PercentX(0.10) end, function() return helper.size.PercentY(0.065) end},
                onPress = function()
                    scenes.info.Buttons[2].color = {helper.color.rgbToClr(35, 45, 35)}
                end,
                onRelease = function()
                    scenes.info.Buttons[2].color = {helper.color.rgbToClr(20, 20, 20)}
                    currentScene = "MainMenu"
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0.02) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts.jersey,
            }
        },
        update = function(DT)
            local self = scenes.info

            local mx, my = input.MousePosition()
            mx = mx / scaleX
            my = my / scaleY
            if input.MousePressed(1) then -- buttons
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onPress()
                    end
                end
            end
            if input.MouseReleased(1) then
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onRelease()
                    end
                end
            end
        end,
        
        draw = function()
            local self = scenes.info

            for I, V in ipairs(self.Buttons) do
                local left = V.position[1]() - (V.size[1]()/2)
                local top = V.position[2]() - (V.size[2]()/2)
                local width = V.size[1]()
                local height = V.size[2]()

                -- Draw button background
                love.graphics.setColor(unpack(V.color))
                love.graphics.rectangle("fill", left, top, width, height, V.rounded(), V.rounded())

                -- Draw outline
                local outlineColor = {0, 0, 0, 1} -- black
                love.graphics.setColor(outlineColor)
                love.graphics.setLineWidth(V.thickness())
                love.graphics.rectangle("line", left, top, width, height, V.rounded(), V.rounded())

                -- Draw wrapped text
                love.graphics.setColor(unpack(V.textColor))
                love.graphics.setFont(V.font)
                love.graphics.printf(V.text, left, top + V.thickness(), width, "center")
            end
        end
    }
    scenes["play"] = {
        time = 0,
        light = {
            enabled = false, overlayTransparency = 0, delay = 0.075, curTime = 0},
        Buttons = {
            {
                text = "LIGHT",
                position = {function() return helper.size.PercentX(0.875) end, function() return helper.size.PercentY(0.55) end},
                size = {function() return helper.size.PercentX(0.05) end, function() return helper.size.PercentY(0.05) end},
                onPress = function()
                    scenes.play.Buttons[1].color = {helper.color.rgbToClr(45, 45, 45)}
                    scenes.play.light.enabled = true
                end,
                onRelease = function()
                    scenes.play.Buttons[1].color = {helper.color.rgbToClr(20, 20, 20)}
                    scenes.play.light.enabled = false
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts["jersey-small"],
            },
            {
                text = "<",
                position = {function() return helper.size.PercentX(0.825) end, function() return helper.size.PercentY(0.55) end},
                size = {function() return helper.size.PercentX(0.03) end, function() return helper.size.PercentY(0.05) end},
                onPress = function()
                    scenes.play.Buttons[2].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.play.Buttons[2].color = {helper.color.rgbToClr(20, 20, 20)}
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts["jersey-small"],
            },
            {
                text = ">",
                position = {function() return helper.size.PercentX(0.925) end, function() return helper.size.PercentY(0.55) end},
                size = {function() return helper.size.PercentX(0.03) end, function() return helper.size.PercentY(0.05) end},
                onPress = function()
                    scenes.play.Buttons[3].color = {helper.color.rgbToClr(45, 45, 45)}
                end,
                onRelease = function()
                    scenes.play.Buttons[3].color = {helper.color.rgbToClr(20, 20, 20)}
                end,
                color = {helper.color.rgbToClr(20, 20, 20)},
                rounded = function() return helper.size.PercentX(0) end,
                thickness = function() return helper.size.PercentX(0.04)/10 end,
                textColor = {helper.color.rgbToClr(170, 200, 170)},
                font = fonts["jersey-small"],
            },
        },
        update = function(DT)
            local self = scenes.play
            self.time = self.time + DT

            -- buttons
            local mx, my = input.MousePosition()
            mx = mx / scaleX
            my = my / scaleY
            if input.MousePressed(1) then -- buttons
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onPress()
                    end
                end
            end
            if input.MouseReleased(1) then
                for _, V in ipairs(self.Buttons) do
                    if helper.size.IsPointInCenteredBox(mx, my, V.position[1](), V.position[2](), V.size[1](), V.size[2]()) then
                        V.onRelease()
                    end
                end
            end

            self.light.curTime = self.light.curTime + DT
            if self.light.curTime >= self.light.delay then
                self.light.overlayTransparency = 1 - (math.random() * 0.25 + 0.25)
                self.light.curTime = 0
            end
        end,
        
        draw = function()
            local self = scenes.play

            if self.time < 7 then
                love.graphics.setColor(0, 0.8, 0, (self.time / 4))
                love.graphics.setFont(fonts.jersey)
                local text = "Night by night, this place degrades."
                local width = love.graphics.getFont():getWidth(text)
                love.graphics.print(text, (BASE_W - width) / 2, BASE_H * 0.5)

                love.graphics.setColor(0, 0.8, 0)
                love.graphics.rectangle("fill",0,BASE_H*0.98,BASE_W*(self.time/7),BASE_H*0.04)
                return -- hide buttons during mini cutscene
            end

            -- temp wall
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.rectangle("fill", 0, 0, BASE_W, BASE_H)

            love.graphics.setColor(0, 0, 0, self.light.enabled and self.light.overlayTransparency or 1)
            love.graphics.rectangle("fill", 0, 0, BASE_W, BASE_H)
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", BASE_W *0.75, 0, BASE_W*0.25, BASE_H) -- right
            love.graphics.rectangle("fill", 0, 0, BASE_W*0.25, BASE_H) -- left
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.rectangle("line", BASE_W *0.75, -100, BASE_W*0.5, BASE_H + 200) -- right outline
            love.graphics.rectangle("line", 0-BASE_W*0.25, -100, BASE_W*0.5, BASE_H + 200) -- left outline

            -- buttons
            for I, V in ipairs(self.Buttons) do
                local left = V.position[1]() - (V.size[1]()/2)
                local top = V.position[2]() - (V.size[2]()/2)
                local width = V.size[1]()
                local height = V.size[2]()

                -- Draw button background
                love.graphics.setColor(unpack(V.color))
                love.graphics.rectangle("fill", left, top, width, height, V.rounded(), V.rounded())

                -- Draw outline
                local outlineColor = {0, 0, 0, 1} -- black
                love.graphics.setColor(outlineColor)
                love.graphics.setLineWidth(V.thickness())
                love.graphics.rectangle("line", left, top, width, height, V.rounded(), V.rounded())

                -- Draw wrapped text
                love.graphics.setColor(unpack(V.textColor))
                love.graphics.setFont(V.font)
                love.graphics.printf(V.text, left, top + V.thickness(), width, "center")
            end
        end,
    }

    -- load settings
    local success, err = helper.file.LoadSettings()
    if success then
        if type(err) == "table" then
            love.window.setFullscreen(err.fs)
        end
    else
        error("Error loading settings: "..err, 2)
    end
end

function love.update(DT)
    screenSize = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    helper.update()
    local scene = scenes[currentScene]

    if scene and scene.update then
        scene.update(DT)
    end
    input.Update()
    timer.update(DT)

    tick = tick + 1
    timer.after(1, function() tick = tick -1 end)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)
    local scene = scenes[currentScene]

    if scene and scene.draw then
        scene.draw()
    end

    love.graphics.setColor(1, 1, 1, 1)
    --love.graphics.print("Current scene: "..currentScene, 3, helper.size.PercentY(1)-(love.graphics.getFont():getHeight()*1.1))
    
    love.graphics.pop()
    
    fps = fps + 1
    timer.after(1, function() fps = fps - 1 end)

    if input.KeyDown("f3") then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.print("FPS: "..fps.." | Ticks:"..tick, 0, 0, 0, scaleX, scaleY)
    end
end

function love.quit()
    local save = {
        fs = love.window.getFullscreen()
    }
    helper.file.SaveSettings(save)
end