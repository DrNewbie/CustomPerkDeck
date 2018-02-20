if BlackMarketTweakData then
	Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "HackPerkDeck_init_projectiles", function(self, tweak_data)
		self.projectiles.small_ecm = {
			name_id = "bm_grenade_small_ecm",
			desc_id = "bm_grenade_small_ecm_desc",
			icon = "equipment_ecm_jammer",
			ability = true,
			texture_bundle_folder = "ecm_jammer",
			max_amount = 1,
			base_cooldown = 10,
			sounds = {cooldown = "perkdeck_cooldown_over"}
		}
	end)
end