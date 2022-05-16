function player()
	local obj = {
		layer = 0,
		uplayer = 0,
		spr = {
			idle = sprites.player.idle,
			happy = sprites.player.happy,
			miss = sprites.player.miss
		},
		x = 0,
		y = 0,
		bobi = 0,
		angle = 0,
		angleprevframe = 0,
		extend = 0,
		paddle_size = 70,
		handle_size = 15,
		paddle_width = 10,
		paddle_distance = 25,
		--cmode = not love.joystick.getJoysticks()[1],
		cemotion = "idle",
		emotimer = 0,
		lookradius = 5,
		maxouchpulse = 0.2,
		ouchpulse = 0,
		ouchtime = 15
	}


	function obj.update(dt)
		obj.angle = obj.angle % 360
		obj.emotimer = obj.emotimer - 1
		if obj.emotimer <= 0 then
			obj.cemotion = "idle"
		end
		if maininput.pressed("a") then
			obj.cmode = not obj.cmode
		end
		if not cs.autoplay then

			if obj.cmode then
				obj.angleprevframe = obj.angle --this way obj.angleprevframe is always 1 frame behind obj.angle
				if is3ds then
					local touchx, touchy = 0, 0
					for i, v in ipairs(love.touch.getTouches()) do
						touchx, touchy = love.touch.getPosition(v)
					end
					obj.angle = 0 - math.deg(math.atan2(120 - touchy / shuv.scale, touchx / shuv.scale - 160))
				else

					obj.angle = 0 - math.deg(math.atan2(obj.y - love.mouse.getY() / shuv.scale, love.mouse.getX() / shuv.scale - obj.x)) + 90
				end
			else
				if maininput:down("left") and playdate.isCrankDocked() then
					obj.angle = obj.angle - 7
				elseif maininput:down("right") and playdate.isCrankDocked() then
					obj.angle = obj.angle + 7
				elseif not playdate.isCrankDocked() then
					obj.angleprevframe = obj.angle
					-- obj.angle = math.deg(math.atan2(love.joystick.getJoysticks()[1]:getAxis(2), love.joystick.getJoysticks()[1]:getAxis(1))) + 90
					obj.angle = playdate.getCrankPosition()
				end
			end
		end
		obj.bobi = obj.bobi + 0.03
	end

	function obj.draw()
		local paddle_angle = obj.paddle_size / 2 --* math.pi / 180
		local cranky_diameter = 16
		local paddle_depth = 8

		gfx.setLineWidth(2)
		gfx.setColor(0)
		gfx.pushContext()
		
		-- draw the paddle
		-- inner paddle arc
		--g.drawEllipseInRect(x-radius, y-radius, d, d, startAngle, endAngle)	
		gfx.drawEllipseInRect(obj.x - obj.paddle_distance, obj.y - obj.paddle_distance, obj.paddle_distance * 2, obj.paddle_distance * 2, obj.angle - paddle_angle, obj.angle + paddle_angle)
		--gfx.drawArc(math.floor(obj.x), math.floor(obj.y), math.floor(obj.paddle_distance), math.floor(obj.angle - paddle_angle), math.floor(obj.angle + paddle_angle))
		-- outer paddle arc
		gfx.drawArc(math.floor(obj.x), math.floor(obj.y), math.floor(obj.paddle_distance + paddle_depth), math.floor(obj.angle - paddle_angle), math.floor(obj.angle + paddle_angle))
		-- -- lhs connector
		-- gfx.drawLine(
		-- 	obj.x, obj.y, 
		-- 	obj.x + obj.paddle_distance * math.cos((obj.angle - paddle_angle/2 - 90) * math.pi / 180), 
		-- 	obj.y + obj.paddle_distance * math.sin((obj.angle - paddle_angle/2 - 90) * math.pi / 180)
		-- )
		-- -- rhs connector
		-- gfx.drawLine(
		-- 	obj.x, obj.y, 
		-- 	obj.x + obj.paddle_distance * math.cos((obj.angle + paddle_angle/2 - 90) * math.pi / 180), 
		-- 	obj.y + obj.paddle_distance * math.sin((obj.angle + paddle_angle/2 - 90) * math.pi / 180)
		-- )
		-- -- lhs paddle
		-- gfx.drawLine(
		-- 	obj.x + obj.paddle_distance * math.cos((obj.angle + paddle_angle - 90) * math.pi / 180), 
		-- 	obj.y + obj.paddle_distance * math.sin((obj.angle + paddle_angle - 90) * math.pi / 180),
		-- 	obj.x + (obj.paddle_distance + paddle_depth) * math.cos((obj.angle + paddle_angle - 90) * math.pi / 180), 
		-- 	obj.y + (obj.paddle_distance + paddle_depth) * math.sin((obj.angle + paddle_angle - 90) * math.pi / 180)
		-- )
		-- -- rhs paddle
		-- gfx.drawLine(
		-- 	obj.x + obj.paddle_distance * math.cos((obj.angle - paddle_angle - 90) * math.pi / 180), 
		-- 	obj.y + obj.paddle_distance * math.sin((obj.angle - paddle_angle - 90) * math.pi / 180),
		-- 	obj.x + (obj.paddle_distance + paddle_depth) * math.cos((obj.angle - paddle_angle - 90) * math.pi / 180), 
		-- 	obj.y + (obj.paddle_distance + paddle_depth) * math.sin((obj.angle - paddle_angle - 90) * math.pi / 180)
		-- )
		gfx.popContext()

		gfx.pushContext()
		
		-- scaling circle and face for hurt animation
		local ouchpulsescale = 1 + obj.ouchpulse

		-- adjusting x and y so they're unaffected by scaling
		local finalx = math.floor(obj.x / ouchpulsescale)
		local finaly = math.floor(obj.y / ouchpulsescale)

		-- draw cranky
		-- draw the circle
		gfx.setColor(0)
		-- gfx.fillCircleAtPoint(finalx, finaly, 16 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)
		gfx.fillCircleAtPoint(obj.x, obj.y, 16 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)
		gfx.setColor(1)
		--gfx.drawCircleAtPoint(finalx, finaly, 16 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)
		gfx.fillCircleAtPoint(obj.x, obj.y, 14 + cs.extend / 2 + (math.sin(obj.bobi)) / 2)

		-- draw the eyes
		gfx.setColor(1)
		-- determine x and y offsets of the eyes
		local eyex = (obj.lookradius) * math.cos((obj.angle - 90) * math.pi / 180)
		local eyey = (obj.lookradius) * math.sin((obj.angle - 90) * math.pi / 180)
		obj.spr[obj.cemotion]:draw(math.floor(obj.x - cranky_diameter + eyex), math.floor(obj.y - cranky_diameter + eyey))--, 0, 1, 1, 32, 32)
		
		--temp draw debug
		gfx.setColor(0)
		local debugdot1x = 50 * math.cos((obj.angle - 90 +paddle_angle) * math.pi / 180)
		local debugdot1y = 50 * math.sin((obj.angle - 90 + paddle_angle) * math.pi / 180)
		gfx.fillCircleAtPoint(obj.x + debugdot1x, obj.y + debugdot1y,3)
		local debugdot1x = 50 * math.cos((obj.angle - 90 -paddle_angle) * math.pi / 180)
		local debugdot1y = 50 * math.sin((obj.angle - 90 - paddle_angle) * math.pi / 180)
		gfx.fillCircleAtPoint(obj.x + debugdot1x, obj.y + debugdot1y,3)
				
		gfx.popContext()
		

	end

	function obj.hurtpulse()
		obj.ouchpulse = obj.maxouchpulse
		flux.to(obj, obj.ouchtime, { ouchpulse = 0 }):ease("outSine")
	end

	return obj
end

return player
