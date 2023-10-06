import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

class("PixelParticles").extends()

function PixelParticles:init(settings)
    self.particles = {}
    if not settings then settings = {} end
    settings.numParticles = settings.numParticles or 150
    settings.x = settings.x or 200
    settings.y = settings.y or 120
    settings.width = settings.width or 15
    settings.height = settings.height or 15
    settings.ticks = settings.ticks or 40
    local maxTicks = 0

    for i = 1,settings.numParticles do
        p = {
            x=math.random()*settings.width + settings.x - settings.width/2,
            y=math.random()*settings.height + settings.y - settings.height/2,
            ticks=math.random(settings.ticks-15, settings.ticks+15)
        }
        if settings.img ~= nil then
            local sampleX, sampleY = p.x-settings.x+settings.width/2, p.y-settings.y+settings.height/2
            local color = settings.img:sample(sampleX, sampleY)
            print('p sample ', sampleX, sampleY)
            if color ~= gfx.kColorClear then
                p.vx = (p.x - settings.x)*0.05
                p.vy = (p.y - settings.y)*0.05
                table.insert(self.particles, p)
                maxTicks = math.max(maxTicks, p.ticks)        
                -- Object.tableDump(p)
                -- Object.tableDump(settings)
                -- print('---')
            end
        end
    end
    self.maxTicks = maxTicks
    
end

function PixelParticles:update()
    gfx.setColor(gfx.kColorWhite)
    for _,p in pairs(self.particles) do
        p.ticks -= 1
        if p.ticks > 0 then
            p.x += p.vx
            p.y += p.vy
            gfx.drawPixel(p.x, p.y)
        end
    end
end
