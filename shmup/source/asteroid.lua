import "CoreLibs/graphics"
import "enemy"

class("Asteroid").extends(Enemy)

local gfx = playdate.graphics
local asteroidImageTable = gfx.imagetable.new("Images/asteroid")

function Asteroid:init()
    Asteroid.super.init()
    self.sprite = gfx.sprite.new(asteroidImageTable:getImage(1))
    self.anim = gfx.animation.loop.new(500, asteroidImageTable, true)
end

function Asteroid:addToStage()
    self.sprite:add()
    table.insert(Enemy.enemies, self)
end

function Asteroid:update()
    Asteroid.super.update()
    self.sprite:setImage(self.anim:image())     
    self.sprite:moveBy(-5, 0)
end

function Asteroid:remove()
    Asteroid.super.remove(self)
    self.sprite:remove()
end