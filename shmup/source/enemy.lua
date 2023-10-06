class("Enemy").extends()

Enemy.enemies = {}

function Enemy:updateAll()
    for _, e in pairs(self.enemies) do
        e:update()
    end
end

function Enemy:update()
end

function Enemy:collidesWithPlayer(playerSprite)
    return false
end

function Enemy.anyCollidesWithPlayer(playerSprite)
    if playerSprite.y == nil then print("Nil playerSprite.y!") end
    for _, e in pairs(Enemy.enemies) do
        if e:collidesWithPlayer(playerSprite) then
            return true
        end
    end
    return false
end

function Enemy.removeAll()
    while #Enemy.enemies > 0 do                
        Enemy.enemies[1]:remove()
    end
end

function Enemy:remove()
    table.remove(Enemy.enemies, table.indexOfElement(Enemy.enemies, self))
end