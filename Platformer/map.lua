local map = {}
local sti = require("sti") -- Agrega la libreria Simple Tiled Implementation

local spike = require("spike")
local stone = require("stone")
local enemy = require("enemy")
local coin = require("coin")
local player = require("player")

function map:load()
	self.currentLevel = 1

	world = love.physics.newWorld(0, 2000) -- Para que box2d funcione tiene que crearse un mundo. Los argumentos son la velocidad en X y en Y
	world:setCallbacks(beginContact, endContact) -- Los callbacks son funciones que se invocan al cumplir ciertas condiciones
	self:init()
end

function map:update(dt)
	if player.x > mapWidth - 16 then
		self:nextLevel()
	end
end

function map:init()
	self.level = sti("map/"..self.currentLevel..".lua", {"box2d"}) -- Carga el archivo del mapa junto con el motor de físicas box2d
	self.level:box2d_init(world) -- Carga todos los objetos con el atributo collidable

	self.solidLayer = self.level.layers.solid
	self.groundLayer = self.level.layers.ground
	self.entityLayer = self.level.layers.entity

	self.solidLayer.visible = false -- Ocultar la visibilidad de este layer
	self.entityLayer.visible = false
	mapWidth = self.groundLayer.width * 16 -- Obtiene el ancho del mapa
	self:spawnObjects()
end

function map:nextLevel()
	self:cleanLevel()
	self.currentLevel = self.currentLevel + 1
	self:init()
	player:resetPosition()
end

function map:cleanLevel()
	self.level:box2d_removeLayer("solid")
	enemy:deleteAll()
	spike:deleteAll()
	stone:deleteAll()
	coin:deleteAll()
end

function map:spawnObjects()
	for i,v in ipairs(self.entityLayer.objects) do
		if v.type == "spike" then
			spike:new(v.x + v.width / 2, v.y + v.height / 2)
		elseif v.type == "stone" then
			stone:new(v.x + v.width / 2, v.y + v.height / 2)
		elseif v.type == "coin" then
			coin:new(v.x, v.y)
		elseif v.type == "enemy" then
			enemy:new(v.x + v.width / 2, v.y + v.height / 2)
		end
	end
end

return map
