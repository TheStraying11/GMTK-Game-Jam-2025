local button = require('simpleConcepts').ui.button

local vx, vy

local statemachine = {
	current = {}
}

local states = {
	menu = {},
	main = {},
	settings = {}
}

local function indexof(tbl, val)
	for i, v in ipairs(tbl) do
		if v == val then
			return i
		end
	end
	return nil
end

function statemachine:switch(state)
	self.current = {state}
	if state.enter ~= nil then
		state:enter()
	end
end

function statemachine:push(state)
	table.insert(self.current, state)
	if state.enter ~= nil then
		state:enter()
	end
end

function statemachine:pop(state)
	table.remove(self.current, indexof(self.current, state))
	if state.exit ~= nil then
		state:exit()
	end
end

--region menu
function states.menu:enter() -- the `love.load()` of this state
	self.buttons = {
		button(
			'New Game',
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			100,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				statemachine:switch(states.main)
			end
		),
		button(
			'+ 100 Gold',
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			170,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				statemachine:switch(states.settings)
			end
		)
	}
end

function states.menu:update(dt) -- the `love.update()` of this state
	
end

function states.menu:draw() -- the `love.draw()` of this state
	for _, btn in ipairs(states.menu.buttons) do
		btn:draw()
	end
end

function states.menu:mousemoved(x, y, dx, dy, istouch)

end

function states.menu:mousepressed(x, y, button, istouch, presses)
	for _, btn in ipairs(states.menu.buttons) do
		btn:handleTouch(x, y, button, istouch, presses)
	end
end

function states.menu:keypressed(key, scancode, isrepeat)

end
--endregion

--region main
function states.main:draw()
	love.graphics.print("Game Running", 400, 300)
end
--endregion

--region settings
function states.settings:draw()
	love.graphics.print("Settings", 400, 300)
end
--endregion

--region State machine hooking
function love.load()
	vx, vy = love.graphics.getDimensions()
	statemachine:switch(states.menu)
end

function love.resize(w, h)
	vx, vy = w, h
end

function love.update(dt)
	for _, state in ipairs(statemachine.current) do
		if state.update ~= nil then
			state:update(dt)
		end
	end
end

function love.draw()
	for _, state in ipairs(statemachine.current) do
		if state.draw ~= nil then
			state:draw()
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	for _, state in ipairs(statemachine.current) do
		if state.keypressed ~= nil then
			state:keypressed(key, scancode, isrepeat)
		end
	end
end

function love.keyreleased(key, scancode, isrepeat)
	for _, state in ipairs(statemachine.current) do
		if state.keyreleased ~= nil then
			state:keyreleased(key, scancode, isrepeat)
		end
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	for _, state in ipairs(statemachine.current) do
		if state.mousemoved ~= nil then
			state:mousemoved(x, y, dx, dy, istouch)
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	for _, state in ipairs(statemachine.current) do
		if state.mousepressed ~= nil then
			state:mousepressed(x, y, button, istouch, presses)
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	for _, state in ipairs(statemachine.current) do
		if state.mousereleased ~= nil then
			state:mousereleased(x, y, button, istouch, presses)
		end
	end
end
--endregion

function love.quit()
	local areYouSure = true

	return not areYouSure -- returning true stops the quit, returning false allows it to continue
end