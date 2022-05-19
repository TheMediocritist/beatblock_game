TitleScene = {}

class("TitleScene").extends(NobleScene)
-- TitleScene.baseColor = Graphics.kColorWhite

function TitleScene:init()
  TitleScene.super.init(self)
  self.inputHandler = { --TODO: replace this with a Baton reimplementation that supports playdate
    AButtonDown = function()
      Noble.transition(SongSelectScene)
    end
  }
  self.pstext = gfx.getLocalizedText("pressspace")
  self.textWidth = Axolotl12:getTextWidth(self.pstext)
  self.logo = gfx.image.new("assets/title/logo")
  --self.logo:setCenter(0,0)

end

function TitleScene:enter()
  TitleScene.super.enter(self)
  cs = Noble.currentScene()
  Noble.isTransitioning = false
  --self.logo:add()
  self.i = 0

end

function TitleScene:update()
  --if not Noble.isTransitioning and maininput.pressed("accept") then
  if maininput.pressed("aButton") then
    Noble.transition(SongSelectScene)
  end

  --updateDt()

  self.i = self.i + 1

  if self.i % 2 == 0 then
    local nc = em.init("titleparticle", math.random(-16, 416), -16)
    nc.dx = math.floor((math.random() * 2) - 1)
    nc.dy = math.floor(2 + math.random() * 2)
  end

  em.update(dt)
  flux.update(dt)

end

function TitleScene:draw()
  em.draw()
  self.logo:drawCentered(200, 68 + math.sin(self.i*0.03)*10)
  -- TODO FONTS
  gfx.setFont(DigitalDisco16)
  gfx.drawText(self.pstext, 129, 156)
  
  --self.logo:moveTo(32,32+math.sin(self.i*0.03)*10) -- TODO: actually animate this
  
  -- make text bold by drawing the sprite far too many times
  -- for a=128,130 do
  --   for b=155,157 do
  --     gfx.drawText(self.pstext,a,b)
  --   end
  -- end

  
end
