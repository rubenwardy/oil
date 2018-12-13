local MAX_BURNER_LEVEL = 100
local MAX_DISTIL_LEVEL = 20
local BURNER_OUTPUT    = 40

-- Note: this doesn't add up to 1 because some production is lost
local PRODUCTS = {
	{ "oil:asphalt_source",   0.10 },
	{ "oil:naphtha_source",   0.23 },
	{ "oil:petrol_source",    0.43 },
}

local function always_return(v)
	return function()
		return v
	end
end

local function add_liquid(pos, liquid, millibuckets, max)
	local meta  = minetest.get_meta(pos)
	local level = meta:get_int("level") + millibuckets
	if not(not meta:get("liquid") or meta:get_string("liquid") == liquid) then
		minetest.set_node(pos, {name="air"})
		return millibuckets
	end

	if level > max then
		millibuckets = level - max
		level = max
	else
		millibuckets = 0
	end

	meta:set_string("liquid", liquid)
	meta:set_int("level", level)
	meta:set_string("infotext", level .. " / " .. max)

	node_io.update_neighbors(pos)
	return millibuckets
end

local function burner_room(pos, node, side, liquid, millibuckets)
	if liquid ~= "oil:crude_source" then
		minetest.log("error", "Attempt to put non-crude liquid into burner!")
		return true
	end

	local meta = minetest.get_meta(pos)
	local to_store = MAX_BURNER_LEVEL - meta:get_int("level")
	if millibuckets > to_store then
		return to_store
	else
		return millibuckets
	end
end

local function burner_get_stack(pos, node, side, index)
	local meta = minetest.get_meta(pos)
	local stack = ItemStack("oil:crude_source")
	stack:set_count(meta:get_int("level"))
	return stack
end

local function init_node(pos, ...)
	minetest.get_node_timer(pos):start(1)
	return node_io.update_neighbors(pos, ...)
end

local function waste_burst(pos, amt)
	amt = amt / 50
	if amt > 1 then
		amt = 1
	end

	pos.y = pos.y - 0.5

	local s = 1
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -s, y = s/4, z = -s},
		maxvel = {x = s, y = s, z = s},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 1.5,
		minsize = amt * 3,
		maxsize = amt * 5,
		texture = "oil_smoke.png",
	})
end

minetest.register_node("oil:distillation_column", {
	description = "Distillation Column",
	tiles = { "oil_distillation_column.png"},
	groups = { fluid_consumer = 1, snappy = 3 },
	after_place_node = node_io.update_neighbors,
	after_dig_node = node_io.update_neighbors,
	node_io_can_take_liquid = always_return(true),
	node_io_accepts_millibuckets = always_return(true),
	node_io_take_liquid = function(pos, node, side, taker, liquid, millibuckets)
		local meta = minetest.get_meta(pos)
		local name = meta:get("liquid")
		if not name or name ~= liquid then
			return nil
		end

		local level   = meta:get_int("level")
		local to_take = level
		if to_take > millibuckets then
			to_take = millibuckets
		end

		meta:set_int("level", level - to_take)
		return { name=name, millibuckets=to_take }
	end,
	node_io_get_liquid_size = always_return(1),
	node_io_get_liquid_name = function(pos, node, side, index)
		local meta = minetest.get_meta(pos)
		return meta:get("liquid")
	end,
	node_io_get_liquid_stack = function(pos, node, side, index)
		local meta = minetest.get_meta(pos)
		if meta:contains("liquid") then
			local stack = ItemStack(meta:get("liquid"))
			stack:set_count(meta:get_int("level"))
			return stack
		else
			return nil
		end
	end,
})

minetest.register_node("oil:burner", {
	description = "Burner",
	tiles = {
		"oil_burner_end.png", "oil_burner_end.png",
		"oil_burner_end.png", "oil_burner_end.png",
		"oil_burner_end.png", "oil_burner_off.png",
	},
	groups = { fluid_consumer = 1, snappy=3 },
	paramtype2 = "facedir",
	after_place_node = init_node,
	after_dig_node = init_node,
	node_io_can_put_liquid = always_return(true),
	node_io_accepts_millibuckets = always_return(true),
	node_io_room_for_liquid = always_return(false),
	node_io_get_liquid_size = always_return(0),
	node_io_get_liquid_name = always_return(nil),
	node_io_get_liquid_stack = burner_get_stack,
	on_timer = always_return(nil),
})

minetest.register_node("oil:burner_active", {
	description = "Active Burner",
	tiles = {
		"oil_burner_end.png", "oil_burner_end.png",
		"oil_burner_end.png", "oil_burner_end.png",
		"oil_burner_end.png", "oil_burner_on.png",
	},
	groups = { fluid_consumer = 1, snappy=3 },
	light_source = 8,
	paramtype2 = "facedir",
	after_place_node = init_node,
	after_dig_node = node_io.update_neighbors,
	node_io_can_put_liquid = always_return(true),
	node_io_put_liquid = function(pos, _, _, _, liquid, millibuckets)
		return add_liquid(pos, liquid, millibuckets, MAX_BURNER_LEVEL)
	end,
	node_io_accepts_millibuckets = always_return(true),
	node_io_room_for_liquid = burner_room,
	node_io_get_liquid_size = always_return(1),
	node_io_get_liquid_name = always_return("oil:crude_source"),
	node_io_get_liquid_stack = burner_get_stack,
	on_timer = function(pos)
		minetest.get_node_timer(pos):start(1)

		local meta = minetest.get_meta(pos)
		local level = meta:get_int("level")
		if level >= BURNER_OUTPUT then
			level = level - BURNER_OUTPUT

			local pos2
			local waste = 0
			for y=1, #PRODUCTS do
				local prod = PRODUCTS[y]
				pos2 = vector.add(pos, { x = -1, y = y - 1, z = 0 })
				if minetest.get_node(pos2).name ~= "oil:distillation_column" then
					minetest.log("error", "Expected distillation_column at " .. minetest.pos_to_string(pos2))
					while y <= #PRODUCTS do
						waste = waste + BURNER_OUTPUT * prod[2]
						y = y + 1
					end
					break
				end
				waste = waste + add_liquid(pos2, prod[1],
						BURNER_OUTPUT * prod[2], MAX_DISTIL_LEVEL)
			end

			if waste > 0 then
				while minetest.get_node(pos2).name == "oil:distillation_column" do
					pos2.y = pos2.y + 1
				end

				waste_burst(pos2, waste)
			end
		end

		meta:set_int("level", level)
		meta:set_string("infotext", level .. " / " .. MAX_BURNER_LEVEL)
	end,
})
