if SkillTreeTweakData then
	Hooks:PostHook(SkillTreeTweakData, "init", "HackerPerkDeck_SkillTree_Init", function(self)
		local deck2 = {
			cost = 0,
			desc_id = "menu_deckall_2_desc",
			name_id = "menu_deckall_2",
			upgrades = {"weapon_passive_headshot_damage_multiplier"},
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
				custom_id = "Hacker",
				name_id = "hacker_perk_name",
				desc_id = "hacker_perk_desc",
				{
					custom = true,
					upgrades = {
						"small_ecm"
					},
					cost = 0,
					icon_xy = {
						1,
						4
					},
					name_id = "hacker_tier_1_name",
					desc_id = "hacker_tier_1_desc"
				},
				deck2,
				{
					custom = true,
					upgrades = {
						"player_passive_health_multiplier_3"
					},
					cost = 0,
					icon_xy = {
						2,
						1
					},
					name_id = "hacker_tier_3_name",
					desc_id = "hacker_tier_3_desc"
				},
				deck4,
				{
					custom = true,
					upgrades = {
						"player_hacker_kill_health"
					},
					cost = 0,
					texture_bundle_folder = "ecp",
					icon_xy = {
						0,
						0
					},
					name_id = "hacker_tier_5_name",
					desc_id = "hacker_tier_5_desc"
				},
				deck6,
				{
					custom = true,
					upgrades = {
						"player_hacker_kill_dodge"
					},
					cost = 0,
					texture_bundle_folder = "max",
					icon_xy = {
						0,
						0
					},
					name_id = "hacker_tier_7_name",
					desc_id = "hacker_tier_7_desc"
				},
				deck8,
				{
					custom = true,
					upgrades = {
						"player_passive_loot_drop_multiplier"
					},
					cost = 0,
					texture_bundle_folder = "ecm_jammer",
					icon_xy = {
						6,
						3
					},
					name_id = "hacker_tier_9_name",
					desc_id = "hacker_tier_9_desc"
				}
			}
		)
	end)
end