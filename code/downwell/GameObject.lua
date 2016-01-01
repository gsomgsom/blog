local GameObject = Object:extend()

function GameObject:new(type, x, y, opts)
    self.type = type
    self.dead = false
    self.x, self.y = x, y
    self.previous_x, self.previous_y = x, y
    local opts = opts or {} -- this handles the case where opts is nil
    for k, v in pairs(opts) do self[k] = v end

    timer.every(0.01, function() createGameObject('Trail', self.x, self.y, {r = 20, xm = self.xm, ym = self.ym, angle = self.angle}) end)
end

function GameObject:update(dt)
    local x, y = love.mouse.getPosition()
    self.x, self.y = x/3, y/3

    self.angle = math.atan2(self.y - self.previous_y, self.x - self.previous_x)
    self.vmag = Vector(self.x - self.previous_x, self.y - self.previous_y):len()
    -- print(self.vmag)
    self.xm = map(self.vmag, 0, 20, 1, 2)
    self.ym = map(self.vmag, 0, 20, 1, 0.25)
    -- print(math.deg(self.angle))
    self.previous_x, self.previous_y = self.x, self.y
end

function GameObject:draw()
    pushRotate(self.x, self.y, self.angle)
    love.graphics.ellipse('fill', self.x, self.y, self.xm*15, self.ym*15)
    love.graphics.pop()
end

return GameObject
