local st = {}
function st.init()

end


function st.enter(prev)
  st.p = em.init("player",200,120)

  st.canv = love.graphics.newCanvas(400,240)
  st.level = json.decode(helpers.read(clevel))
  st.offset = st.level.offset
  st.startbeat = st.level.startbeat or 0
  st.cbeat = 0-st.offset +st.startbeat
  st.autoplay = false
  st.length = 42
  st.pt = 0
  st.bg = love.graphics.newImage("assets/bgs/nothing.png")
  
  st.on = true
  st.beatsounds = false
  st.extend = 0
  for i,v in ipairs(st.level.events) do
    v.played = false
    v.autoplayed = false
  end
  st.vfx = {}
  st.vfx.hom = false
  st.vfx.homint = 20000
  st.lastsigbeat = math.floor(st.cbeat)
end


function st.leave()
  entities = {}
  if st.source ~= nil then
    st.source:stop()
    st.source = nil
  end
  st.sounddata = nil
end


function st.resume()

end


function st.update()
  pq = ""
  maininput:update()
  lovebird.update()
  if st.source == nil then
    st.cbeat = st.cbeat + (st.level.bpm/60) * love.timer.getDelta()
  else
    st.source:update()
    local b,sb = st.source:getBeat(1)
    st.cbeat = b+sb
    --print(b+sb)
  end

  -- read the level
  for i,v in ipairs(st.level.events) do
  -- preload events such as beats
    if v.time <= st.cbeat+st.offset and v.played == false then
      if v.type == "play" and st.sounddata == nil then
        
        st.sounddata = love.sound.newSoundData(v.file)
       pq = pq .. "      loaded sounddata"

      end
      if v.type == "beat" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle
        newbeat.startangle = v.angle
        newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "spawn here!"
        newbeat.update()
      end
      if v.type == "slice" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle
        newbeat.slice = true
        
        newbeat.startangle = v.angle
        newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "spawn here!"
        newbeat.update()
      end
      if v.type == "sliceinvert" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle
        newbeat.slice = true
        newbeat.inverse = true
        
        newbeat.startangle = v.angle
        newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "spawn here!"
        newbeat.update()
      end
      if v.type == "inverse" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle
        newbeat.startangle = v.angle
        newbeat.endangle = v.endangle or v.angle -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        newbeat.inverse = true
        pq = pq .. "    ".. "spawn here!"
        newbeat.update()
      end
      if v.type == "hold" then
        v.played = true
        local newbeat = em.init("beat",200,120)
        newbeat.angle = v.angle1
        newbeat.segments = v.segments or nil
        newbeat.hold = true
        newbeat.duration = v.duration
        newbeat.startangle = v.angle1
        newbeat.angle2 = v.angle2 or v.angle1
        newbeat.endangle = v.endangle or v.angle1 -- Funny or to make sure nothing bad happens if endangle isn't specified in the json
        newbeat.hb = v.time
        newbeat.smult = v.speedmult
        pq = pq .. "    ".. "hold spawn here!"
                newbeat.update()
      end

    end
          -- autoplay
      if v.time-0.05 <= st.cbeat and st.autoplay and v.autoplayed == false then
        if v.type == "beat" or v.type == "inverse" then
          v.autoplayed = true
          if st.ce ~= nil then
            st.ce:stop()
            st.ce = nil
          end
          st.ce = flux.to(st.p,0,{angle = v.angle}):ease("outExpo")
          pq = pq..("     easing to "..v.angle)
          
        end
      end


    -- load other events on the beat
    if v.time <= st.cbeat and v.played == false then
      
      v.played = true
      if v.type == "play" then
        st.source = lovebpm.newTrack()
          :load(st.sounddata)
          :setBPM(st.level.bpm)
          :setLooping(false)
          :play()
        
        st.source:setBeat(st.cbeat)
        pq = pq .. "    ".. "now playing ".. v.file
      end
      
      if v.type == "width" then

        
        flux.to(st.p,v.duration,{paddle_size=v.newwidth}):ease("linear")
        pq = pq.. "    width set to " .. v.newwidth
      end
      
      if v.type == "multipulse" then
        pq = pq.. "    pulsing, generating other pulses"
        st.extend = 10
        flux.to(st,10,{extend=0}):ease("linear")
        for i=1,v.reps do
          table.insert(st.level.events,{type="singlepulse",time=v.time+v.delay*i,played=false})
        end
      end

      if v.type == "singlepulse" then
        st.extend = 10
        flux.to(st,10,{extend=0}):ease("linear")
        pq = pq.. "    pulsing"
      end
      
      if v.type == "setbg" then
        st.bg = love.graphics.newImage("assets/bgs/".. v.file ..".png")
        pq = pq.. "     set bg"
      end

      if v.type == "hom" then
        st.vfx.hom = v.enable
        st.vfx.homint = v.intensity
        if st.vfx.hom then
          pq = pq .. "    ".. "Hall Of Mirrors enabled"
        else
          pq = pq .. "    ".. "Hall Of Mirrors disabled"
        end
      end

      if v.type == "circle" then
        pq = pq .. "    ".. "circle spawned"
        local nc = em.init("circlevfx",v.x,v.y)
        nc.delt = v.delta
      end
      if v.type == "square" then
        pq = pq .. "    ".. "square spawned"
        local nc = em.init("squarevfx",v.x,v.y)
        nc.r = v.r
        nc.dx = v.dx
        nc.dy = v.dy
        nc.dr = v.dr
        nc.life = v.life
        nc.update()
        
      end
      if v.type == "lua" then
        pq = pq .. "    ".. "ran lua code"
        local code = loadstring(v.code) -- NOOOOOO YOU CANT RUN ARBITRARY CODE THATS A SECURITY RISK
        code()  --haha loadstring go brrr
      end
    end
  end

  if maininput:pressed("back") then
    helpers.swap(states.songselect)
  end
  if maininput:pressed("a") then
    helpers.swap(states.rdconvert)
  end

  flux.update(1)
  em.update(dt)
end


function st.draw()
  shuv.start()

  love.graphics.rectangle("fill",0,0,400,240)
  love.graphics.setCanvas(st.canv)
    
    if not st.vfx.hom then
      love.graphics.clear()
    end
    
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)

    if st.vfx.hom then
      for i=0,st.vfx.homint do
        love.graphics.points(math.random(0,400),math.random(0,240))
      end
    end
    love.graphics.draw(st.bg)
    em.draw()
  love.graphics.setCanvas(shuv.canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(st.canv)
  if pq ~= "" then
    print(helpers.round(st.cbeat*6,true)/6 .. pq)
  end
  shuv.finish()

end


return st