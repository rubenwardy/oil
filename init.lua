if minetest.get_modpath("basic_materials") then
	minetest.register_alias("oil:paraffin",      "basic_materials:paraffin")
	minetest.register_alias("oil:plastic_sheet", "basic_materials:plastic_sheet")
	minetest.register_alias("oil:plastic_strip", "basic_materials:plastic_strip")
else
	minetest.register_craftitem("oil:paraffin", {
		description = "Paraffin",
		inventory_image = "oil_paraffin.png",
	})

	minetest.register_craftitem("oil:plastic_sheet", {
		description = "Plastic Sheeting",
		inventory_image = "oil_plastic_sheet.png",
	})

	minetest.register_craftitem("oil:plastic_strip", {
		description = "Plastic Strip",
		inventory_image = "oil_plastic_strip.png",
	})
end

minetest.register_node("oil:crude_source", {
	description = "Crude Oil",
	drawtype = "liquid",
	tiles = {
		{
			name = "oil_crude_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "oil_crude_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	alpha = 250,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "oil:crude_flowing",
	liquid_alternative_source = "oil:crude_source",
	liquid_viscosity = 7,
	liquid_range = 2,
	post_effect_color = {a = 153, r = 30, g = 30, b = 30},
	groups = {liquid = 3},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("oil:crude_flowing", {
	description = "Flowing Water",
	drawtype = "flowingliquid",
	tiles = {"oil_crude.png"},
	special_tiles = {
		{
			name = "oil_crude_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "oil_crude_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	alpha = 250,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "oil:crude_flowing",
	liquid_alternative_source = "oil:crude_source",
	liquid_viscosity = 7,
	liquid_range = 2,
	post_effect_color = {a = 250, r = 0, g = 0, b = 0},
	groups = {liquid = 3, not_in_creative_inventory = 1},
	sounds = default.node_sound_water_defaults(),
})
