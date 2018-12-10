Hooks:PostHook(SkillTreeTweakData, "init", "MagicPerkDeckInit", function(self)
	local deck2 = {
		cost = 0,
		desc_id = "menu_deckall_2_desc",
		name_id = "menu_deckall_2",
		upgrades = {
			"weapon_passive_headshot_damage_multiplier"
		},
		icon_xy = {
			1,
			0
		}
	}
	local deck4 = {
		cost = 0,
		desc_id = "menu_deckall_4_desc",
		name_id = "menu_deckall_4",
		upgrades = {
			"passive_player_xp_multiplier",
			"player_passive_suspicion_bonus",
			"player_passive_armor_movement_penalty_multiplier"
		},
		icon_xy = {
			3,
			0
		}
	}
	local deck6 = {
		cost = 0,
		desc_id = "menu_deckall_6_desc",
		name_id = "menu_deckall_6",
		upgrades = {
			"armor_kit",
			"player_pick_up_ammo_multiplier"
		},
		icon_xy = {
			5,
			0
		}
	}
	local deck8 = {
		cost = 0,
		desc_id = "menu_deckall_8_desc",
		name_id = "menu_deckall_8",
		upgrades = {
			"weapon_passive_damage_multiplier",
			"passive_doctor_bag_interaction_speed_multiplier"
		},
		icon_xy = {
			7,
			0
		}
	}
	table.insert(self.specializations, {
			custom = true,
			custom_id = "Magic",
			name_id = "magic_perk_name",
			desc_id = "magic_perk_desc",
			{
				custom = true,
				upgrades = {
					"player_magic_flamethrower_1"
				},
				cost = 0,
				texture_bundle_folder = "magic_perk_deck",
				icon_xy = {
					0,
					0
				},
				name_id = "magic_tier_1_name",
				desc_id = "magic_tier_1_desc"
			},
			deck2,
			{
				custom = true,
				upgrades = {
					"player_magic_fireball_1"
				},
				cost = 0,
				texture_bundle_folder = "magic_perk_deck",
				icon_xy = {
					1,
					0
				},
				name_id = "magic_tier_3_name",
				desc_id = "magic_tier_3_desc"
			},
			deck4,
			{
				custom = true,
				upgrades = {
					"player_magic_firebomb_1"
				},
				cost = 0,
				texture_bundle_folder = "magic_perk_deck",
				icon_xy = {
					2,
					0
				},
				name_id = "magic_tier_5_name",
				desc_id = "magic_tier_5_desc"
			},
			deck6,
			{
				custom = true,
				upgrades = {
					"player_magic_meteorite_1"
				},
				cost = 0,
				texture_bundle_folder = "magic_perk_deck",
				icon_xy = {
					3,
					0
				},
				name_id = "magic_tier_7_name",
				desc_id = "magic_tier_7_desc"
			},
			deck8,
			{
				custom = true,
				upgrades = {
					"player_magic_regeneration_1"
				},
				cost = 0,
				texture_bundle_folder = "magic_perk_deck",
				icon_xy = {
					0,
					1
				},
				name_id = "magic_tier_9_name",
				desc_id = "magic_tier_9_desc"
			}
		}
	)
end)