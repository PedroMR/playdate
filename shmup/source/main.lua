

-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.


import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/ui"
import "starfield"
import "asteroid"

local StatePlaying = {}

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.
local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil
local playerImageTable = nil
local ticksUntilIdle = 0
local playerImageIndex = 1

local ticksToAddAsteroid = 30
local ticksBetweenAsteroids = 30

local targetPlayerY = 15
local mainStarfield = nil

-- A function to set up our game environment.

function loadAssets()
    if playerImageTable ~= nil then return end
    playerImageTable = gfx.imagetable.new("Images/player")
    assert(playerImageTable)

end

playdate.ui.crankIndicator:start()

function StatePlaying:init()
    loadAssets()

    -- game values setup
    ticksToAddAsteroid = 30
    ticksBetweenAsteroids = 30

    Enemy:removeAll();

    -- Set up the player sprite.
    if playerSprite ~= nil then playerSprite:remove() end
    playerSprite = gfx.sprite.new( playerImageTable:getImage(1, 1) )
    --playerSprite:setCenter()
    playerSprite:moveTo( 40, getYPosFromCrank() ) 
    playerSprite:add() -- This is critical!

    if mainStarfield ~= nil then
        mainStarfield.remove()

     end
    gfx.setBackgroundColor(gfx.kColorBlack)
    mainStarfield = Starfield:new()
    mainStarfield:addTo(gfx)
end

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function getYPosFromCrank()
    local crankPos = playdate.getCrankPosition()
    if crankPos > 180 then
        if crankPos > 270 then
            crankPos = 0
        else
            crankPos = 180
        end
    end

    local minTargetY = 10
    local maxTargetY = 230
    if not playdate.isCrankDocked() then
        return minTargetY + crankPos * (maxTargetY-minTargetY) / 180
    else
        return minTargetY
    end
end

function updatePlayerMovement()
    if playdate.buttonJustPressed(playdate.kButtonB) then
        SetState(StatePlaying)
        return
    end

    targetPlayerY = getYPosFromCrank()
    
    local maxSpeed = 20
    local playerX, playerY = playerSprite:getPosition()
    local deltaY = targetPlayerY - playerY    
    --if deltaY ~= 0 then print(playerX, playerY, targetPlayerY, deltaY, crankPos) end

    playerImageIndex = -playerImageIndex
    if deltaY < 0 then
        playerSprite:moveBy(0, math.max(deltaY, -maxSpeed))
        if deltaY < 1 then
            playerImageIndex = 4
            ticksUntilIdle = 5
        end
    elseif deltaY > 0 then
        playerSprite:moveBy(0, math.min(deltaY, maxSpeed))
        if deltaY > 1 then
            playerImageIndex = 5
            ticksUntilIdle = 5
        end
    end
    ticksUntilIdle -= 1
    if playerImageIndex < 0 then
        if ticksUntilIdle <= 0 then
            playerImageIndex = 1
            ticksUntilIdle = 0
        else   
            playerImageIndex = -playerImageIndex
        end
    end
    playerSprite:setImage(playerImageTable:getImage(1, playerImageIndex))
end

function StatePlaying:update()
    updatePlayerMovement()

    ticksToAddAsteroid -= 1
    if ticksToAddAsteroid <= 0 then
        ticksToAddAsteroid = ticksBetweenAsteroids
        local a = Asteroid()
        local yPos = math.random(20,220)
        local xPos = 400
        a.sprite:moveTo(xPos, yPos)
        a:addToStage()
    end

    for _, e in pairs(Enemy.enemies) do
        e:update()
    end

    mainStarfield:update()
end

function playdate.update()
    gfx.clear()

    CurrentState:update()

    gfx.sprite.update()
    playdate.timer.updateTimers()

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
    end
end

function SetState(state)
    CurrentState = state
    CurrentState:init()
end

SetState(StatePlaying)

