local stone = {img = love.graphics.newImage("assets/stone.png")}
stone.__index = stone -- Crea una metatabla cuyo indice apunta a si misma
stone.width = stone.img:getWidth()
stone.height = stone.img:getHeight()
local activeStones = {}

function stone:load()
	
end

function stone:update(dt)
	self:syncPhysics()
end

function stone:draw()
	love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function stone:updateAll(dt)
	for i, instance in ipairs(activeStones) do
		instance:update(dt)
	end
end

function stone:drawAll()
	for i, instance in ipairs(activeStones) do
		instance:draw()
	end
end

function stone:new(x, y)
	instance = setmetatable({}, stone)
	instance.x = x
	instance.y = y
	instance.r = 0 -- Rotación

	instance.physics = {}
	instance.physics.body = love.physics.newBody(world, instance.x, instance.y, "dynamic")
	instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
	instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
	instance.physics.body:setMass(20)
	table.insert(activeStones, instance)
end

function stone:syncPhysics() -- Sincroniza el cuerpo creado, con la imagen del objeto
	self.x, self.y = self.physics.body:getPosition()
	self.r = self.physics.body:getAngle() -- Sincroniza la rotación de la imagen con la del cuerpo físico
end

function stone:deleteAll()
	for i, instance in ipairs(activeStones) do
		instance.physics.body:destroy()
	end
	activeStones = {}
end

return stone