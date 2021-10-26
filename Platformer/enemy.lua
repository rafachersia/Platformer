local enemy = {}
local player = require("player")
enemy.__index = enemy -- Crea una metatabla cuyo indice apunta a si misma
local activeEnemy = {}

function enemy:load()
	
end

function enemy:update(dt)
	self:syncPhysics()
	self:animate(dt)
end

function enemy:draw()
	local scaleX = 1
	if self.velX < 0 then
		scaleX = -1
	end
	love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, self.r, scaleX, 1, self.width / 2, self.height / 2)
end

function enemy:updateAll(dt)
	for i, instance in ipairs(activeEnemy) do
		instance:update(dt)
	end
end

function enemy:drawAll()
	for i, instance in ipairs(activeEnemy) do
		instance:draw()
	end
end

function enemy.loadAssets()
	enemy.runAnim = {}
	for i=1,4 do
		enemy.runAnim[i] = love.graphics.newImage("assets/enemy/run/"..i..".png")
	end
	enemy.walkAnim = {}
	for i=1,4 do
		enemy.walkAnim[i] = love.graphics.newImage("assets/enemy/walk/"..i..".png")
	end
	enemy.width = enemy.runAnim[1]:getWidth()
	enemy.height = enemy.runAnim[1]:getHeight()
end

function enemy:new(x, y)
	instance = setmetatable({}, enemy)
	instance.x = x
	instance.y = y
	instance.offsetY = -10
	instance.r = 0 -- Rotación

	instance.state = "walk"
	instance.damage = 1
	instance.speed = 100
	instance.speedModifier = 1
	instance.velX = instance.speed

	instance.rageCounter = 0
	instance.rageTrigger = 2

	instance.animation = {timer = 0, rate = 0.1}
	instance.animation.run = {total = 4, current = 1, img = enemy.runAnim}
	instance.animation.walk = {total = 4, current = 1, img = enemy.walkAnim}
	instance.animation.draw = instance.animation.walk.img[1] -- Imagen inicial para el enemigo

	instance.physics = {}
	instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
	instance.physics.body:setFixedRotation(true)
	instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75) -- Reduce el espacio del cuerpo físico
	instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
	instance.physics.body:setMass(15)
	table.insert(activeEnemy, instance)
end

function enemy:animate(dt)
	self.animation.timer = self.animation.timer + dt
	if self.animation.timer > self.animation.rate then
		self.animation.timer = 0
		self:setNewFrame()
	end
end

function enemy:setNewFrame()
	local anim = self.animation[self.state]
	if anim.current < anim.total then
		anim.current = anim.current + 1
	else 
		anim.current = 1
	end
	self.animation.draw = anim.img[anim.current]
end

function enemy:syncPhysics() -- Sincroniza el cuerpo creado, con la imagen del objeto
	self.x, self.y = self.physics.body:getPosition()
	self.physics.body:setLinearVelocity(self.velX * self.speedModifier, 100)
end

function enemy:flipDirection()
	self.velX = -self.velX
end

function enemy:rage()
	self.rageCounter = self.rageCounter + 1
	if self.rageCounter > self.rageTrigger then
		self.rageCounter = 0
		self.state = "run"
		self.speedModifier = 3
	else
		self.state = "walk"
		self.speedModifier = 1
	end
end

function enemy:beginContact(a, b, collision)
	for i, instance in ipairs(activeEnemy) do
		if a == instance.physics.fixture or b == instance.physics.fixture then
			if a == player.physics.fixture or b == player.physics.fixture then
				player:takeDamage(instance.damage)
				print(player.health.currentHealth)
			end
			instance:flipDirection()
			instance:rage()
		end
	end
end

function enemy:deleteAll()
	for i, instance in ipairs(activeEnemy) do
		instance.physics.body:destroy()
	end
	activeEnemy = {}
end

return enemy