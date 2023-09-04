class("Enemy").extends()

Enemy.enemies = {}

function Enemy:update()
end

function Enemy.removeAll()
    while #Enemy.enemies > 0 do                
        Enemy.enemies[1]:remove()
    end
end

function Enemy:remove()
    table.remove(Enemy.enemies, table.indexOfElement(Enemy.enemies, self))
end