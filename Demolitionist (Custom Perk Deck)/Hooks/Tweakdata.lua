local ThisModPath = ModPath
local ThisModIds = Idstring(ThisModPath):key()
local __Name = function(__id)
	return "C4BOMB_"..Idstring(tostring(__id).."::"..ThisModIds):key()
end
local __LoadOnce = __Name("TweakdataLoadOnce")

if UpgradesTweakData and not UpgradesTweakData[__LoadOnce] then
	UpgradesTweakData[__LoadOnce] = true
	Hooks:PostHook(UpgradesTweakData, "_player_definitions", __Name("UpgradesTweakData:_player_definitions"), function(self)
		self.values.player.c4_bomb_recharge_by_ammo = {
			true
		}
		self.definitions.player_c4_bomb_recharge_by_ammo = {
			name_id = "menu_player_c4_bomb_recharge_by_ammo",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "c4_bomb_recharge_by_ammo",
				category = "player"
			}
		}
		self.values.temporary.armor_break_invulnerable[501] = {
			0.8,
			5
		}
		self.definitions.temporary_armor_break_invulnerable_c4_bomb_1 = {
			name_id = "menu_player_health_multiplier",
			category = "temporary",
			upgrade = {
				value = 501,
				upgrade = "armor_break_invulnerable",
				category = "temporary"
			}
		}
		self.values.player.c4_bomb_self_destruct = {
			true
		}
		self.definitions.player_c4_bomb_self_destruct = {
			name_id = "menu_player_c4_bomb_self_destruct",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "c4_bomb_self_destruct",
				category = "player"
			}
		}
		self.values.player.weapon_c4_loss_ammo = {
			0.33
		}
		self.definitions.player_weapon_c4_loss_ammo_1 = {
			name_id = "menu_player_weapon_c4_loss_ammo_1",
			category = "feature",		
			upgrade = {
				value = 1,
				upgrade = "weapon_c4_loss_ammo",
				category = "player"
			}
		}
		self.values.player.addition_ammo_pickup_weapon_c4 = {
			0.50
		}
		self.definitions.player_addition_ammo_pickup_weapon_c4 = {
			name_id = "menu_player_addition_ammo_pickup_weapon_c4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "addition_ammo_pickup_weapon_c4",
				category = "player"
			}
		}
		self.values.player.c4_bomb_cheat_death = {
			true
		}
		self.definitions.player_c4_bomb_cheat_death = {
			name_id = "menu_player_c4_bomb_cheat_death",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "c4_bomb_cheat_death",
				category = "player"
			}
		}
	end)	
	Hooks:PostHook(UpgradesTweakData, "_grenades_definitions", __Name("_grenades_definitions"), function(self)
		self.definitions.weapon_c4 = {category = "grenade"}
	end)
end

if SkillTreeTweakData and not SkillTreeTweakData[__LoadOnce] then
	SkillTreeTweakData[__LoadOnce] = true
	Hooks:PostHook(SkillTreeTweakData, "init", __Name("SkillTreeTweakData:init"), function(self)
		local NewPerkDeck = {
			name_id = "weapon_c4_perk_name",
			desc_id = "weapon_c4_perk_desc"
		}
		NewPerkDeck[1] = {
			custom = "C4_Bomb_Perk_Deck",
			cost = 0,
			desc_id = "menu_c4bombdeck_1_desc",
			name_id = "menu_c4bombdeck_1_name",
			upgrades = {
				"weapon_c4",
				"player_weapon_c4_loss_ammo_1"
			},
			texture_bundle_folder = "weapon_c4",
			icon_xy = {0, 0}
		}
		NewPerkDeck[3] = {
			cost = 0,
			desc_id = "menu_c4bombdeck_3_desc",
			name_id = "menu_c4bombdeck_3_name",
			upgrades = {
				"player_c4_bomb_recharge_by_ammo",
				"player_addition_ammo_pickup_weapon_c4"
			},
			texture_bundle_folder = "weapon_c4",
			icon_xy = {0, 0}
		}
		NewPerkDeck[5] = {
			cost = 0,
			desc_id = "menu_c4bombdeck_5_desc",
			name_id = "menu_c4bombdeck_5_name",
			upgrades = {
				"player_c4_bomb_self_destruct"
			},
			texture_bundle_folder = "weapon_c4",
			icon_xy = {0, 0}
		}
		NewPerkDeck[7] = {
			cost = 0,
			desc_id = "menu_c4bombdeck_7_desc",
			name_id = "menu_c4bombdeck_7_name",
			upgrades = {
				"temporary_armor_break_invulnerable_c4_bomb_1"
			},
			texture_bundle_folder = "weapon_c4",
			icon_xy = {0, 0}
		}
		NewPerkDeck[9] = {
			cost = 0,
			desc_id = "menu_c4bombdeck_9_desc",
			name_id = "menu_c4bombdeck_9_name",
			upgrades = {
				"player_c4_bomb_cheat_death",
				"player_passive_loot_drop_multiplier"
			},
			texture_bundle_folder = "weapon_c4",
			icon_xy = {0, 0}
		}
		NewPerkDeck[2] = {
			cost = 0,
			desc_id = "menu_deckall_2_desc",
			name_id = "menu_deckall_2",
			upgrades = {
				"weapon_passive_headshot_damage_multiplier"
			},
			icon_xy = {1, 0}
		}
		NewPerkDeck[4] = {
			cost = 0,
			desc_id = "menu_deckall_4_desc",
			name_id = "menu_deckall_4",
			upgrades = {
				"passive_player_xp_multiplier",
				"player_passive_suspicion_bonus",
				"player_passive_armor_movement_penalty_multiplier"
			},
			icon_xy = {3, 0}
		}
		NewPerkDeck[6] = {
			cost = 0,
			desc_id = "menu_deckall_6_desc",
			name_id = "menu_deckall_6",
			upgrades = {
				"armor_kit",
				"player_pick_up_ammo_multiplier"
			},
			icon_xy = {5, 0}
		}
		NewPerkDeck[8] = {
			cost = 0,
			desc_id = "menu_deckall_8_desc",
			name_id = "menu_deckall_8",
			upgrades = {
				"weapon_passive_damage_multiplier",
				"passive_doctor_bag_interaction_speed_multiplier"
			},
			icon_xy = {7, 0}
		}
		table.insert(self.specializations, NewPerkDeck)
	end)
end

if BlackMarketTweakData and not BlackMarketTweakData[__LoadOnce] then
	BlackMarketTweakData[__LoadOnce] = true	
	Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", __Name("_init_projectiles"), function(self, tweak_data)
		local __max_amount = 3
		if type(tweak_data.equipments) == "table" and type(tweak_data.equipments.trip_mine) == "table" then
			if type(tweak_data.equipments.trip_mine.quantity) == "table" and type(tweak_data.equipments.trip_mine.quantity[1]) == "number" then
				__max_amount = math.max(math.round(tweak_data.equipments.trip_mine.quantity[1]), 1)
			end
		end
		self.projectiles.weapon_c4 = {
			name_id = "bm_grenade_weapon_c4",
			desc_id = "bm_grenade_weapon_c4_desc",
			icon = "equipment_c4",
			ability = true,
			throwable = nil,
			texture_bundle_folder = "weapon_c4",
			max_amount = __max_amount,
			base_cooldown = 240,
			sounds = {}
		}		
	end)
end