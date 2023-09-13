

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
import "pixelParticles"

class("State").extends()

function State:init() end
function State:update() end
function State:destroy() end

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

local score = 0
local highScore = 0
local playerShield = 2
local playerShieldTime = 0

local particles = {}

local saveData = playdate.datastore.read()
if saveData == nil then
    saveData = { highScore = 0 }
end
highScore = saveData.highScore

-- A function to set up our game environment.

function loadAssets()
    if playerImageTable ~= nil then return end
    playerImageTable = gfx.imagetable.new("Images/player")
    assert(playerImageTable)

end

playdate.ui.crankIndicator:start()

local StatePlaying = State()

function StatePlaying:init()
    StatePlaying.super.init()
    loadAssets()    

    -- game values setup
    score = 0
    ticksToAddAsteroid = 30
    ticksBetweenAsteroids = 30
    playerShield = 2
    playerShieldTime = 0

    particles = {}

    Enemy:removeAll();

    -- Set up the player sprite.
    if playerSprite ~= nil then playerSprite:remove() end
    playerSprite = gfx.sprite.new( playerImageTable:getImage(1, 1) )
    --playerSprite:setCenter()
    playerSprite:moveTo( 40, getYPosFromCrank() ) 
    playerSprite:setGroups(GROUP_PLAYER)
    playerSprite:setCollidesWithGroups(GROUP_ENEMIES)
    playerSprite:setCollideRect( 0, 0, playerSprite:getSize() ) --TODO smaller
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

    local minTargetY = 30
    local maxTargetY = 230
    if not playdate.isCrankDocked() then
        return minTargetY + crankPos * (maxTargetY-minTargetY) / 180
    else
        return minTargetY
    end
end

function updatePlayerMovement()
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
    StatePlaying.super.update()
    updatePlayerMovement()

    ticksToAddAsteroid -= 1
    if ticksToAddAsteroid <= 0 then
        ticksToAddAsteroid = ticksBetweenAsteroids
        local a = Asteroid()
        local yPos = math.random(40,220)
        local xPos = 400
        a.sprite:moveTo(xPos, yPos)
        a:addToStage()
    end

    Enemy:updateAll()

    -- print("pS 0.1 0.1 "..playerSprite:getImage():sample(0.1, 0.1))
    -- print("pS w h "..playerSprite:getImage():sample(playerSprite.width-1, playerSprite.height-1))

    if playerShieldTime > 0 then
        playerShieldTime -= 1
        gfx.drawCircleAtPoint(playerSprite.x, playerSprite.y, 11)
    else
        score += 0.05
        if highScore < score then highScore = score end
    
        local overlaps = playerSprite:overlappingSprites()
        for _, o in pairs(overlaps) do
            if playerSprite:alphaCollision(o) then
                if playerShield <= 0 then
                    -- death destroy player
                    local x, y, width, height = playerSprite:getBounds()         
                    table.insert(particles, PixelParticles{
                        x=x, y=y, width=width, height=height, img=playerSprite:getImage()
                    })
                    SetState(StateGameOver)
                else
                    playerShield -= 1
                    playerShieldTime = 80
                end            
            end
        end
    end
 
    if playerShieldTime > 0 and playerShieldTime % 8 <= 3 then
        playerSprite:setVisible(false)
    else
        playerSprite:setVisible(true)
    end

    mainStarfield:update()
    updateParticles()
    drawScoreBar()
end

function updateParticles()
    for i,p in pairs(particles) do
        p:update()
        if p.maxTicks <= 0 then particles[i] = nil end
    end
end

function drawScoreBar()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 20)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawTextAligned(string.format("%05d", math.floor(score)), 4, 2)
    gfx.drawTextAligned(string.format("HI: %05d", math.floor(highScore)), 400-4, 2, kTextAlignment.right)

    local shieldX0 = 200 - (playerShield-1)*10
    for shieldX = shieldX0, shieldX0+20*(playerShield-1), 20 do
        gfx.drawCircleAtPoint(shieldX, 10, 9)        
    end
end

function StatePlaying:destroy()
    StatePlaying.super.destroy()
    playerSprite:remove()
    -- gameover needs these
    --mainStarfield:remove()
    --Enemy:removeAll()
end

function playdate.update()
    gfx.clear()

    gfx.sprite.update()
    playdate.timer.updateTimers()

    CurrentState:update()

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:update()
    end
end

function SetState(state)
    if CurrentState ~= nil then CurrentState:destroy() end
    CurrentState = state
    CurrentState:init()
end

StateTitle = State()
function StateTitle:init()
    StateTitle.super.init()
    gfx.setBackgroundColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function StateTitle:update()    
    StateTitle.super.update()
    local titleX, titleY = 200,60
    gfx.drawTextAligned("*-= Asteroid Runner =-*", titleX, titleY, kTextAlignment.center)
    local startX, startY = 200, 120
    local startMessage = "Press A to Start!"
    if playdate.isCrankDocked() then startMessage = "Undock crank first!" end
    gfx.drawTextAligned(startMessage, startX, startY, kTextAlignment.center)
    --TODO crank align to start (warp gate)
    if playdate.buttonJustPressed(playdate.kButtonA) and not playdate.isCrankDocked() then
        SetState(StatePlaying)
        return
    end
end

function StateTitle:destroy()
    StateTitle.super.destroy()
end

StateGameOver = State()

function StateGameOver:init()
    StateGameOver.super.init()
end

function StateGameOver:update()
    StateGameOver.super.update()
    mainStarfield:update()
    updateParticles()
    drawScoreBar()
    Enemy:updateAll()
    gfx.setColor(gfx.kColorWhite)
    local gameOverX, gameOverY = 200, 216
    gfx.fillRect(0, gameOverY-4, 400, 240-gameOverY+4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawTextAligned("*GAME OVER*", gameOverX, gameOverY, kTextAlignment.center)

    if playdate.buttonJustPressed(playdate.kButtonB) or playdate.buttonJustPressed(playdate.kButtonA) then
        SetState(StateTitle)
        return
    end
end

function StateGameOver:destroy()
    mainStarfield:remove()
    playerSprite:remove()
    Enemy:removeAll()
end

function persistSaveData()
    saveData = {
        highScore = highScore
    }
    playdate.datastore.write(saveData)
end

function playdate.gameWillTerminate()
    persistSaveData()
end

function playdate.deviceWillSleep()
    persistSaveData()
end


SetState(StateTitle)
--SetState(StatePlaying)

