local sound = {active = {}, source = {}}

function sound:init(id, source, soundType) -- Cargar los sonidos, soundType puede ser static o streamed
	assert(self.source[id] == nil, "Sonido con esa id ya existe") -- Assert comprueba si se cumple una condición, y si no muestra un mensaje
	
	if type(source) == "table" then -- Si source es una tabla con varios sonidos
		self.source[id] = {} -- Crea una nueva tabla en el indice id
		for i=1, #source do
			self.source[id][i] = love.audio.newSource(source[i], soundType) -- Inserta cada uno de los sonidos en esta tabla
		end
	else -- Si source no es una tabla, se carga el sonido de forma normal
		self.source[id] = love.audio.newSource(source, soundType)
	end
end

function sound:play(id, channel, volume, pitch, loop) -- Reproducir sonidos
	local source
	if type(sound.source[id]) == "table" then
		source = sound.source[id][math.random(1, #sound.source[id])]
	else
		source = sound.source[id]
	end
	local channel = channel or "default"
	local clone = source:clone() -- Crea una copia del sonido que se va a reproducir
	clone:setVolume(volume or 1)
	clone:setPitch(pitch or 1)
	clone:setLooping(loop or false)
	clone:play()

	if sound.active[channel] == nil then -- Si el canal donde se va a reproducir no existe, lo crea
		sound.active[channel] = {}
	end
	table.insert(sound.active[channel], clone) -- Inserta la copia del sonido en la tabla
	return clone
end

function sound:clean(id)
	self.source[id] = nil
end

function sound:setPitch(channel, pitch)
	assert(sound.active[channel] ~= nil, "El canal no existe")
	for k, sound in pairs(sound.active[channel]) do
		sound:setPitch(pitch)
	end
end

function sound:setVolume(channel, volume)
	assert(sound.active[channel] ~= nil, "El canal no existe")
	for k, sound in pairs(sound.active[channel]) do
		sound:setVolume(volume)
	end
end

function sound:stop(channel) -- Detiene todos los sonidos de un canal específico
	assert(sound.active[channel] ~= nil, "El canal no existe")
	for k, sound in pairs(sound.active[channel]) do
		sound:stop()
	end
end

function sound:update() -- Actualizar la tabla de sonidos, remover los que ya no se están reproduciendo
	for k, channel in pairs(sound.active) do
		-- print(#channel)
		if channel[1] ~= nil and not channel[1]:isPlaying() then -- Si esta condición se cumple significa que existe un sonido que ya no se está reproduciendo
			table.remove(channel, 1) -- Elimina el sonido de la tabla
		end
	end
end

return sound