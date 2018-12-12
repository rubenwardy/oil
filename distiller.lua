minetest.register_node("oil:distillation_column", {
	description = "Distillation Column",
	tiles = { "oil_distillation_column.png"},
	groups = { fluid_consumer = 1 },
	after_place_node = node_io.update_neighbors,
	after_dig_node = node_io.update_neighbors,
})

local function always_return(v)
	return function()
		return v
	end
end

local init_node = node_io.update_neighbors
local burner_can_put_liquid = always_return(true)

local MAX_LEVEL = 100

local function burner_room(pos, node, side, liquid, millibuckets)
	if liquid ~= "oil:crude_source" then
		minetest.log("error", "Attempt to put non-crude liquid into burner!")
		return true
	end

	local meta = minetest.get_meta(pos)
	local to_store = MAX_LEVEL - meta:get_int("level")
	if millibuckets > to_store then
		return to_store
	else
		return millibuckets
	end
end

local function burner_put_liquid(pos, node, side, putter, liquid, millibuckets)
	local meta = minetest.get_meta(pos)
	local level = meta:get_int("level")
	local to_add = millibuckets
	if level + to_add > MAX_LEVEL then
		to_add = MAX_LEVEL - level
	end
	meta:set_int("level", level + to_add)
	meta:set_string("infotext", (level + to_add) .. " / " .. MAX_LEVEL)
	return millibuckets - to_add
end

local function burner_get_stack(pos, node, side, index)
	local meta = minetest.get_meta(pos)

	local stack = ItemStack("oil:crude_source")
	stack:set_count(meta:get_int("level"))
	return stack
end

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
	node_io_can_put_liquid = burner_can_put_liquid,
	node_io_accepts_millibuckets = always_return(true),
	node_io_room_for_liquid = always_return(false),
	node_io_get_liquid_size = always_return(0),
	node_io_get_liquid_name = always_return(nil),
	node_io_get_liquid_stack = burner_get_stack,
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
	after_dig_node = init_node,
	node_io_can_put_liquid = burner_can_put_liquid,
	node_io_put_liquid = burner_put_liquid,
	node_io_accepts_millibuckets = always_return(true),
	node_io_room_for_liquid = burner_room,
	node_io_get_liquid_size = always_return(1),
	node_io_get_liquid_name = always_return("oil:crude_source"),
	node_io_get_liquid_stack = burner_get_stack,
})
