if minetest.get_modpath("basic_materials") then
	minetest.register_alias("oil:plastic_sheet", "basic_materials:plastic_sheet")
	minetest.register_alias("oil:plastic_strip", "basic_materials:plastic_strip")

	minetest.clear_craft({ output = "basic_materials:oil_extract"   })
	minetest.clear_craft({ output = "basic_materials:paraffin"      })
	minetest.clear_craft({ output = "basic_materials:plastic_sheet" })
	minetest.register_alias_force("basic_materials:oil_extract", "oil:crude_source")

	minetest.override_item("basic_materials:paraffin", {
		description = "Paraffin Wax"
	})
else
	minetest.register_craftitem("oil:plastic_sheet", {
		description = "Plastic Sheeting",
		inventory_image = "oil_plastic_sheet.png",
	})

	minetest.register_craftitem("oil:plastic_strip", {
		description = "Plastic Strip",
		inventory_image = "oil_plastic_strip.png",
	})

	minetest.register_alias("basic_materials:plastic_sheet", "oil:plastic_sheet")
	minetest.register_alias("basic_materials:plastic_strip", "oil:plastic_strip")
	minetest.register_alias("basic_materials:oil_extract",   "oil:crude_source")
end

minetest.register_craft({
	output = "oil:plastic_strip 9",
	type   = "shapeless",
	recipe = { "oil:plastic_sheet 3" },
})

minetest.register_craft({
	output = "oil:plastic_sheet 9",
	type   = "cooking",
	recipe = "oil:naphtha_bucket",
})

minetest.register_craft({
	output = "oil:naphtha_bucket",
	type   = "cooking",
	recipe = "oil:crude_bucket",
})

minetest.register_craft({
	type = "fuel",
	recipe = "oil:naphtha_bucket",
	burntime = 30,
})
