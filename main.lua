local button = require('simpleConcepts').ui.button

local vx, vy

local statemachine = {
	current = {}
}

local function serialize(obj, level)
	level = level or 1
	local s = ""
	if type(obj) == "number" then
		s = s..tostring(obj)
	elseif type(obj) == "string" then
		s = s..string.format("%q", obj)
	elseif type(obj) == "boolean" then
		s = s..tostring(obj)
	elseif type(obj) == "table" then
		s = s.."{\n"
		for k,v in pairs(obj) do
			s = s..string.rep("\t",level)..k.." = "..serialize(v, level+1)..",\n"
		end
		s = s..string.rep("\t", level-1).."}"
	else
		error("Cannot serialize type: "..type(obj))
	end
	return s
end

local function saveTable(name, tbl)
	return love.filesystem.write(name..".lua", "return "..serialize(tbl))
end

local function loadTable(name)
	return love.filesystem.load(name..".lua")()
end

local states = {
	menu = {},
	main = {},
	settings = {},
	popup = {}
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
	print("switch")
	self.current = {state}
	if state.enter ~= nil then
		state:enter()
	end
end

function statemachine:push(state)
	print("push")
	table.insert(self.current, state)
	if state.enter ~= nil then
		state:enter()
	end
	print("Stack after push:")
	for i, s in ipairs(self.current) do
		print(i, s)
	end
	print("Stack length:", #statemachine.current)
end

function statemachine:pop(state)
	print("pop")
	table.remove(self.current, indexof(self.current, state))
	if state.exit ~= nil then
		state:exit()
	end
end

--region menu
function states.menu:enter() -- the `love.load()` of this state
	self.buttons = {
		button(
			'New Save',
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			100,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				saveTable("save", {gold=0})
			end
		),
		button(
			'Add 100 Gold',
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			170,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				local s = loadTable("save")
				s.gold = s.gold + 100
				saveTable("save", s)
			end
		),
		button(
			'Print gold',
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			340,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				print('popup!')
				statemachine:push(states.popup)
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

function states.popup:enter()
	self.buttons = {
		button(
			"Close",
			{1, 1, 1, 1},
			{1, 0, 0, 1},
			100,
			340,
			100,
			50,
			function(ins, x, y, button, istouch, presses)
				print("pop button")
				statemachine:pop(states.popup)
			end
		)
	}
end

function states.popup:draw()
	print("making popup!")
	love.graphics.print(loadTable("save").gold, 500, 500)
	for index, btn in ipairs(self.buttons) do
		btn:draw()
	end
end

function states.popup:mousepressed(x, y, button, istouch, presses)
	for _, btn in ipairs(self.buttons) do
		btn:handleTouch(x, y, button, istouch, presses)
	end
end

--region State machine hooking
function love.load()
	vx, vy = love.graphics.getDimensions()
	love.filesystem.load(love.filesystem.getSaveDirectory().."/save.lua")
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
	love.graphics.clear()
	print(#statemachine.current)
	for _, state in ipairs(statemachine.current) do
		if state.draw ~= nil then
			print('state: '..tostring(state)..' has draw')
			state:draw()
		else
			print('state: '..tostring(state)..' doesnt have draw')
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	local topState = statemachine.current[#statemachine.current]
	if topState and topState.keypressed then
		topState:keypressed(key, scancode, isrepeat)
	end
end

function love.keyreleased(key, scancode, isrepeat)
	local topState = statemachine.current[#statemachine.current]
	if topState and topState.keyreleased then
		topState:keyreleased(key, scancode, isrepeat)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	local topState = statemachine.current[#statemachine.current]
	if topState and topState.mousemoved then
		topState:mousemoved(x, y, dx, dy, istouch)
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	local topState = statemachine.current[#statemachine.current]
	if topState and topState.mousepressed then
		topState:mousepressed(x, y, button, istouch, presses)
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	local topState = statemachine.current[#statemachine.current]
	if topState and topState.mousereleased then
		topState:mousereleased(x, y, button, istouch, presses)
	end
end
--endregion

function love.quit()
	local areYouSure = true

	return not areYouSure -- returning true stops the quit, returning false allows it to continue
end