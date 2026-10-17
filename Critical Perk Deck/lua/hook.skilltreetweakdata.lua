Hooks:PostHook(SkillTreeTweakData, "init", "CriticalPerkDeckInit", function(self)
	local pc1, pc3, pc5, pc7, pc9 = 0, 0, 0, 0, 0
	table.insert(self.specializations, {
			custom = true,
			custom_id = "Critical",
			name_id = "critical_perk_name",
			desc_id = "critical_perk_desc",
			{
				custom = true,
				upgrades = {
					"player_critical_to_all"
				},
				cost = pc1,
				texture_bundle_folder = "critical_perk_deck",
				icon_xy = {
					6,
					1
				},
				name_id = "critical_tier_1_name",
				desc_id = "critical_tier_1_desc"
			},
			self.specializations[1][2],
			{
				custom = true,
				upgrades = {
					"player_critical_tier_1",
					"player_ct_reload_speed_multiplier_1"
				},
				cost = pc3,
				texture_bundle_folder = "critical_perk_deck",
				icon_xy = {
					0,
					12
				},
				name_id = "critical_tier_3_name",
				desc_id = "critical_tier_3_desc"
			},
			self.specializations[1][4],
			{
				custom = true,
				upgrades = {
					"player_critical_tier_2",
					"player_ct_reload_speed_multiplier_2"
				},
				cost = pc5,
				texture_bundle_folder = "critical_perk_deck",
				icon_xy = {
					0,
					12
				},
				name_id = "critical_tier_5_name",
				desc_id = "critical_tier_5_desc"
			},
			self.specializations[1][6],
			{
				custom = true,
				upgrades = {
					"player_critical_gain_health_1"
				},
				cost = pc7,
				texture_bundle_folder = "critical_perk_deck",
				icon_xy = {
					4,
					11
				},
				name_id = "critical_tier_7_name",
				desc_id = "critical_tier_7_desc"
			},
			self.specializations[1][8],
			{
				custom = true,
				upgrades = {
					"player_critical_gain_health_2",
					"player_passive_loot_drop_multiplier"
				},
				cost = pc9,
				texture_bundle_folder = "critical_perk_deck",
				icon_xy = {
					4,
					11
				},
				name_id = "critical_tier_9_name",
				desc_id = "critical_tier_9_desc"
			}
		}
	)
end)