Object = require 'classic/classic'
Timer = require 'hump.timer'
Vector = require 'hump.vector'
GameObject = require 'GameObject'
Trail = require 'Trail'

function love.load()
    love.mouse.setVisible(false)

    timer = Timer()
    -- timer.after(4, function() game_object.dead = true end)

    game_objects = {}
    game_object = createGameObject('GameObject', 100, 100)

    main_canvas = love.graphics.newCanvas(320, 240)
    main_canvas:setFilter('nearest', 'nearest')
    game_object_canvas = love.graphics.newCanvas(320, 240)
    game_object_canvas:setFilter('nearest', 'nearest')
    trail_canvas = love.graphics.newCanvas(320, 240)
    trail_canvas:setFilter('nearest', 'nearest')

    love.window.setMode(960, 720)
    love.graphics.setLineStyle('rough')

    trail_lines_extra_draw = {}
    timer.every(0.1, function()
        for i = -360, 720, 2 do
            if love.math.random(1, 10) >= 2 then trail_lines_extra_draw[i] = false
            else trail_lines_extra_draw[i] = true end
        end
    end)
end

function love.update(dt)
    timer.update(dt)
    for i = #game_objects, 1, -1 do
        local game_object = game_objects[i]
        game_object:update(dt)
        if game_object.dead then table.remove(game_objects, i) end
    end
end

function love.draw()
    love.graphics.setCanvas(trail_canvas)
    love.graphics.clear()
    for _, game_object in ipairs(game_objects) do
        if game_object.type == 'Trail' then
            game_object:draw()
        end
    end

    pushRotate(160, 120, randomp(-math.pi/12, math.pi/12))
    love.graphics.setBlendMode('subtract')
    for i = -360, 720, 2 do
        love.graphics.line(i, -240, i, 480)
        if trail_lines_extra_draw[i] then
            love.graphics.line(i+1, -240, i+1, 480)
        end
    end
    love.graphics.setBlendMode('alpha')
    love.graphics.pop()
    love.graphics.setCanvas()

    love.graphics.setCanvas(game_object_canvas)
    love.graphics.clear()
    for _, game_object in ipairs(game_objects) do
        if game_object.type == 'GameObject' then
            game_object:draw()
        end
    end
    love.graphics.setCanvas()

    love.graphics.setCanvas(main_canvas)
    love.graphics.clear()
    love.graphics.draw(trail_canvas, 0, 0)
    love.graphics.draw(game_object_canvas, 0, 0)
    love.graphics.setCanvas()

    love.graphics.draw(main_canvas, 0, 0, 0, 3, 3)
end

function createGameObject(type, x, y, opts)
    local game_object = _G[type](type, x, y, opts)
    table.insert(game_objects, game_object)
    return game_object -- return the instance in case we wanna do anything with it
end

function randomp(min, max)
    return (min > max and (love.math.random()*(min - max) + max)) or (love.math.random()*(max - min) + min)
end

function pushRotate(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x, -y)
end

function map(old_value, old_min, old_max, new_min, new_max)
    local new_min = new_min or 0
    local new_max = new_max or 1
    local new_value = 0
    local old_range = old_max - old_min
    if old_range == 0 then new_value = new_min
    else
        local new_range = new_max - new_min
        new_value = (((old_value - old_min)*new_range)/old_range) + new_min
    end
    return new_value
end

--[[
function love.mousepressed(x, y, button)
    if button == 1 then -- 1 = left click
        game_object.dead = true
    end
end
]]--
