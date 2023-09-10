class("Enemy").extends()

Enemy.enemies = {}

function Enemy:updateAll()
    for _, e in pairs(self.enemies) do
        e:update()
    end
end

function Enemy:update()
end

function Enemy:collidesWithPlayer()
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