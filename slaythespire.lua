--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "CardSpire",
	-- The name of the file, for the code to pull the atlas from
	path = "ModdedVanilla.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}
SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
}

SMODS.Joker {
	key = 'demonform',
	loc_txt = {
		name = 'Demon Form',
		text = {
			"Gains {X:mult,C:white} X0.5 {} Mult",
			"at the end of the {C:attention}shop{}",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive})"
		}
	},
	config = { extra = { Xmult = 0.5, XMult_gain = 0.5 } },
	rarity = 4,
	atlas = 'CardSpire',
	pos = { x = 1, y = 0 },
	cost = 20,
	
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.XMult_gain } }
	end,
	calculate = function(self, card, context)
    	if context.joker_main then
        	return {
            	message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
            	Xmult_mod = card.ability.extra.Xmult
       		}
    	end
		
		if context.ending_shop then
			card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.XMult_gain
			return {
				message = '+Strength!',
				colour = G.C.CHIPS,
				card = card
			}
		end
	end
}

SMODS.Joker {
	key = 'echoform',
	loc_txt = {
		name = 'Echo Form',
		text = {
			"{C:attention}Retriggers{} all {C:attention}jokers{}",

		}
	},
	config = { extra = { retriggers = 1 } },
	rarity = 4,
	atlas = 'CardSpire',
	pos = { x = 0, y = 0 },
	cost = 20,
	blueprint_compat = false,
	calculate = function(self, card, context)
    if not context.blueprint then
		if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self then
			if G.jokers.cards then
                for _, joker_card in ipairs(G.jokers.cards) do
                    if joker_card ~= self then
                        return {
                            message = localize("k_again_ex"),
                            repetitions = card.ability.extra.retriggers,
                            card = joker_card,
				}
			else
				return nil, true
						end
					end
				end
			end
		end
	end
}

SMODS.Joker {
    key = 'devaform',
    loc_txt = {
        name = 'Deva Form',
        text = {
            "{C:blue}+#1#{} hand",
            "Increases by {C:attention}1{} when",
            "{C:attention}boss blind{} is defeated"
        }
    },
    config = { extra = { hands_size = 1, hands_gain = 1 } },
    rarity = 4,
    atlas = 'CardSpire',
    pos = { x = 2, y = 0 },
    cost = 20,
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.hands_size
            }
        }
    end,
    calculate = function(self, card, context)
    -- Trigger when the blind is selected
    if context.blind_selected and context.cardarea == G.jokers and not context.blueprint then
        return {
            message = '+1',
            colour = G.C.CHIPS,
            card = card
        }
    end

    -- Trigger when the boss blind is defeated
    if context.end_of_round and context.cardarea == G.jokers and context.main_eval then
        if G.GAME.blind.boss and not context.blueprint then
            -- Increment hands_size
            card.ability.extra.hands_size = card.ability.extra.hands_size + (card.ability.extra.hands_gain or 1)

            -- Reapply the updated hands_size to the deck
            G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) + (card.ability.extra.hands_gain or 1)

            return {
                message = 'Deva!',
                colour = G.C.CHIPS,
                card = card
            }
        end
    end
end,
add_to_deck = function(self, card, from_debuff)
    G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) + (card.ability.extra.hands_size or 1)
end,
remove_from_deck = function(self, card, from_debuff)
    G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 0) - (card.ability.extra.hands_size or 1)
end

}

SMODS.Joker {
	key = 'wraithform',
	loc_txt = {
		name = 'Wraith Form',
		text = {
			"Win the current {c:attention}blind{}",
			"when {C:attention}sold{}",
		}
	},
	config = { extra = { Xmult = 0.5, XMult_gain = 0.5 } },
	rarity = 4,
	atlas = 'CardSpire',
	pos = { x = 1, y = 1 },
	cost = 20,
	
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.Xmult, card.ability.extra.XMult_gain } }
	end,
	calculate = function(self, card, context)
    	if context.selling_self then
			if G.STATE == G.STATES.SELECTING_HAND then
				G.GAME.chips = G.GAME.blind.chips
				G.STATE = G.STATES.HAND_PLAYED
				G.STATE_COMPLETE = true
				end_round()
			end
		end
	end
}