
Starfield = {}
Starfield.__index = Starfield

function Starfield:new()
    local self = { stars={} }

    local xMin, xMax = 0, 400
    local yMin, yMax = 0, 240
    local bgSprite

    for i = 1,100 do
        table.insert(self.stars, {x=math.random(xMin, xMax), y=math.random(yMin, yMax), s=math.random()*0.7+0.5})
    end

    function self:addTo(gfx)
        bgSprite = gfx.sprite.setBackgroundDrawingCallback(
            function( x, y, width, height )
                gfx.setColor(gfx.kColorWhite)
                for _, star in pairs(self.stars) do
                    gfx.fillCircleAtPoint(star.x, star.y, math.ceil(star.s))
                end
            end
        )
    end

    function self:remove()
        bgSprite:remove()
        bgSprite = nil
    end

    function self:update()
        for _, star in pairs(self.stars) do
            star.x -= star.s
            if star.x < xMin then
                star.x += xMax-xMin
            end
        end
    end

    return self;
end
