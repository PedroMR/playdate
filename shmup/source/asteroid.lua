import "CoreLibs/graphics"
import "const"
import "enemy"

class("Asteroid").extends(Enemy)

local gfx = playdate.graphics
local asteroidImageTable = gfx.imagetable.new("Images/asteroid")

function Asteroid:init()
    Asteroid.super.init()
    self.sprite = gfx.sprite.new(asteroidImageTable:getImage(1))
    self.anim = gfx.animation.loop.new(500, asteroidImageTable, true)
    self.deltaX = -5
    self.deltaY = math.random()*3 - 1.5
    self.sprite:setGroups(GROUP_ENEMIES)
    self.sprite:setCollidesWithGroups(GROUP_PLAYER)
    self.sprite:setCollideRect( 0, 0, self.sprite:getSize() ) --TODO smaller
end

function Asteroid:addToStage()
    self.sprite:add()
    table.insert(Enemy.enemies, self)
end

function Asteroid:update()    
    Asteroid.super.update()
    self.sprite:setImage(self.anim:image())     
    self.sprite:moveBy(self.deltaX, self.deltaY)
end

function Asteroid:remove()
    Asteroid.super.remove(self)
    self.sprite:remove()
end