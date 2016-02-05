local Trail = Object:extend()

function Trail:new(type, x, y, opts)
    self.type = type
    self.dead = false
    self.x, self.y = x, y
    local opts = opts or {} -- this handles the case where opts is nil
    for k, v in pairs(opts) do self[k] = v end

    timer.tween(0.3, self, {r = 0}, 'linear', function() self.dead = true end)
end

function Trail:update(dt)

end

function Trail:draw()
    love.graphics.setColor(255, 0, 0)
    pushRotate(self.x, self.y, self.angle)
    love.graphics.ellipse('fill', self.x, self.y, self.xm*(self.r + randomp(-2.5, 2.5)), self.ym*(self.r + randomp(-2.5, 2.5)))
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255)

    love.graphics.setBlendMode('subtract')
    for i = -80, 80, 2 do
        love.graphics.line(self.x + i, self.y - 80, self.x + i, self.y + 80)
    end
    love.graphics.setBlendMode('alpha')
end

return Trail
