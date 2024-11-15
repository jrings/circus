--- STEAMODDED HEADER
--- MOD_NAME: The Circus
--- MOD_ID: VSMODS
--- MOD_AUTHOR: [jrings]
--- MOD_DESCRIPTION: A first mod
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- BADGE_COLOR: fb8b73
--- PREFIX: circus
----------------------------------------------
------------MOD CODE -------------------------

-- Using sounds from
-- Strong Man Noises.mp3 by Volvion -- https://freesound.org/s/609795/ -- License: Creative Commons 0
-- Cannon boom by Quassorr -- https://freesound.org/s/758072/ -- License: Creative Commons 0

-- Graphics misappropriated: Bear blind graphic from BelenosBear

--Creates an atlas for cards to use
SMODS.Atlas {
  -- Key for code to find it with
  key = "a_circus",
  -- The name of the file, for the code to pull the atlas from
  path = "sheet1.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.Atlas {
  key = "a_circus_blinds",
  path = "blinds.png",
	px = 34,
	py = 34
}


SMODS.Joker {
  key = 'trapeze',
  loc_txt = {
    name = 'Trapezist',
    text = {
      "{C:mult}#1#{} Mult",
      "Goes up by {C:mult}#2#{} Mult",
      "when exactly scoring a blind."
    }
  },
  config = { extra = { mult = 10, mult_gain = 10} },
  rarity = 2,
  atlas = 'a_circus',
  pos = { x = 0, y = 0 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return {mult = card.ability.extra.mult,
      message = localize {
          type = 'variable',
          key = 'a_mult',
          vars = { card.ability.extra.mult}
      }}
    elseif not context.individual and not context.repetition and 
      context.end_of_round and not context.blueprint then
      
      if G.GAME.chips == G.GAME.blind.chips then
          card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
          return {
            message = 'Upgraded!',
            colour = G.C.MULT,
            card=card
          }
      end
    end
  end
}

SMODS.Joker {
  key = 'fire_eater',
  loc_txt = {
    name = 'Fire Eater',
    text = {
      "{C:chips}#1#{} Chips",
      "Goes up by {C:chips}#2#{} Chips",
      "when exactly scoring a blind."
    }
  },
  config = { extra = { chips = 50, chip_gain = 50} },
  rarity = 2,
  atlas = 'a_circus',
  pos = { x = 1, y = 2 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips, card.ability.extra.chip_gain } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return {chips = card.ability.extra.chips,
      message = localize {
          type = 'variable',
          key = 'a_chips',
          vars = { card.ability.extra.chips}
      }}
    elseif not context.individual and not context.repetition and 
      context.end_of_round and not context.blueprint then
      
      if G.GAME.chips == G.GAME.blind.chips then
          card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_gain
          return {
            message = 'Upgraded!',
            colour = G.C.MULT,
            card=card
          }
      end
    end
  end
}


SMODS.Joker {
  key = 'trickster',
  loc_txt = {
    name = 'Trickster',
    text = {
      "Gives {C:chips}+#1#{} Chips and",
      "{C:mult}+#2#{} Mult when scored.",
      "Sell to add a random joker that ",
      "costs {C:money}1{} to sell."
    }
  },
  config = { extra = { chips = 25, mult = 2 } },
  rarity = 1,
  atlas = 'a_circus',
  eternal_compat = false,
  pos = { x = 1, y = 0 },
  cost = 3,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
  end,
  calculate = function(self, card, context)
    if context.selling_self then
      local ccard = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'trik')

      ccard.sell_cost = -1
      ccard:start_materialize()
      ccard:add_to_deck()
      G.jokers:emplace(ccard)
    end
    if context.joker_main then
      return {
        message = "25 chips, 2 mult",
        chip_mod = card.ability.extra.chips,
        mult_mod = card.ability.extra.mult
        }
      end
    end,
  add_to_deck = function(self, card, from_debuff)
    card.sell_cost = -1
  end
}

SMODS.Joker {
  key = 'sword',
  loc_txt = {
    name = 'Sword Swallower',
    text = {
      "Gives {C:mult}+#1#{} Mult when scored."
    }
  },
  config = { extra = { mult = 25 } },
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 2, y = 0 },
  cost = 15,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return { mult_mod = card.ability.extra.mult,
      message = localize {
          type = 'variable',
          key = 'a_mult',
          vars = { card.ability.extra.mult}
      }}
      end
    end
 
}

local loophole = SMODS.Joker {
  key = 'loophole',
  loc_txt = {
    name = 'Attorney Loophole',
    text = {
      "Four of a kinds trigger two pair jokers",
    }
  },
  config = { type = "Four of a Kind"},
  rarity = 3,
  atlas = 'a_circus',
  pos = { x = 3, y = 0 },
  cost = 4,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and context.scoring_name == "Four of a Kind" then
      sendInfoMessage("Triggering two pair jokers")
      local other_joker_ret = {}
      for _, other_joker in ipairs(G.jokers.cards) do
        sendInfoMessage("Checking joker " .. other_joker.label)
        if other_joker.label == "Mad Joker" then
          sendInfoMessage("Triggering" .. other_joker.label)
          if other_joker_ret.mult_mod then
            other_joker_ret.mult_mod = other_joker_ret.mult_mod + 10
          else
            other_joker_ret.mult_mod = 10
          end
          other_joker_ret.message = "Lawyered!"
          G.E_MANAGER:add_event(Event({delay=0.15, func = function() other_joker:juice_up(); return true end }))
        end
        if other_joker.label == "Clever Joker" then
          sendInfoMessage("Triggering" .. other_joker.label)
          if other_joker_ret.chip_mod then
            other_joker_ret.chip_mod = other_joker_ret.chip_mod + 80
          else
            other_joker_ret.chip_mod = 80
          end
          other_joker_ret.message = "Lawyered!"
          G.E_MANAGER:add_event(Event({delay=0.15, func = function() other_joker:juice_up(); return true end }))
        end
      end
      return other_joker_ret
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    card:set_edition({negative = true}, true)
  end,
}
    
local balancing_act = SMODS.Joker {
  key = 'balancing_act',
  loc_txt = {
    name = 'Balancing Act',
    text = {
      "Rounds chips up to the next",
      "highest multiple of 100."
    }
  },
  config = {},
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 4, y = 0 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return {}
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      local rounded_chips = math.ceil(hand_chips / 100) * 100
      local chip_difference = rounded_chips - hand_chips
      return {
        chip_mod = chip_difference,
        message = "Rounded to " .. rounded_chips .. " chips!"
      }
    end
  end
}
    
local stilt_walker = SMODS.Joker {
  key = 'stilt_walker',
  loc_txt = {
    name = 'Stilt Walker',
    text = {
      "Rounds mult up to the next",
      "highest multiple of 10."
    }
  },
  config = {},
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 2, y = 1 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return {}
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      local rounded_mult = math.ceil(mult / 10) * 10
      local mult_difference = rounded_mult - mult
      return {
        mult_mod = mult_difference,
        message = "Rounded to " .. rounded_mult .. " mult!"
      }
    end
  end
}
    
local candy_butcher = SMODS.Joker {
  key = 'candy_butcher',
  loc_txt = {
    name = 'Candy Butcher',
    text = {
      "Gain {C:mult}#1#{} Mult on",
      "the {C:attention}first hand{} of each round"
    }
  },
  config = { extra = { mult = 10 } },
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 3, y = 1 },
  cost = 3,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult } }
  end,
  calculate = function(self, card, context)
    if context.joker_main and G.GAME.current_round.hands_played == 0 then
      return { mult_mod = card.ability.extra.mult,
      message = localize {
          type = 'variable',
          key = 'a_mult',
          vars = { card.ability.extra.mult}
        }
      }
    end
  end
}

SMODS.Sound {
  key = 'cannonball',
  path = 'cannonball.ogg'
}

local joker_cannonball = SMODS.Joker{
  key = 'joker_cannonball',
  loc_txt = {
    name = 'Joker Cannonball',
    text = {
      "Create a random five-card hand {C:planet}Planet{} card",
      'whenever the {C:attention}first hand{} has {C:attention}five{} scored cards'
    }
  },
  config = { },
  rarity = 2,
  atlas = 'a_circus',
  pos = { x = 1, y = 1 },
  cost = 5,
  calculate = function(self, card, context)
    if context.joker_main and G.GAME.current_round.hands_played == 0 and #context.scoring_hand == 5 then
      local five_hands = {"Straight", "Straight Flush", "Flush"}
      if G.GAME.hands["Five of a Kind"].played > 0 then
        table.insert(five_hands, "Five of a Kind")
      end
      if G.GAME.hands["Flush Five"].played > 0 then
        table.insert(five_hands, "Flush Five")
      end
      local pchoice = pseudorandom_element(five_hands, pseudoseed('joker_cannonball'))
        play_sound('circus_cannonball')
        local pcard = create_card("Planet", G.consumeables, nil, nil, nil, pchoice)
        pcard:add_to_deck()
        G.consumeables:emplace(pcard)
        card:juice_up(0.3, 0.5)
    end
  end
}

local palm_reader = SMODS.Joker{
  key = 'palm_reader',
  loc_txt = {
    name = 'Palm Reader',
    text = {
      "After you use your last discard,",
      "Creates a {C:tarot}Tarot{} card you need."
    }
  },
  config = { },
  rarity = 3,
  atlas = 'a_circus',
  pos = { x = 4, y = 1 },
  cost = 6,
  calculate = function(self, card, context)
    if context.discard  and G.GAME.current_round.discards_left == 1 then  -- triggers once for each discard still...
      if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        local hand_on = G.GAME.current_round.hands_played
        local hands_left = G.GAME.current_round.hands_left
        local best_hand_level = G.GAME.hands[G.GAME.current_round.most_played_poker_hand].level
        -- Choose good, medium or bad tree
        local r = 1 -- pseudorandom('palm_reader', 1, 3)
        local tcard
        sendInfoMessage("Palm reader chose " .. r)
        if r == 1 then -- good tree give something actually helpful
          if hands_left >= 2 then
            if G.GAME.dollars <= 4 then
              if G.GAME.round_resets.ante <= 4 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_devil') -- Tested
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_magician') -- Tested
              end
            else
              if best_hand_level < 3 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_high_priestess')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_emperor')
              end
            end
          else -- only 1 hand left
            if G.GAME.chips / G.GAME.blind.chips < 0.5 then
              if #G.GAME.jokers.cards <= 1 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_judgement')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_justice')
              end
            else
              if best_hand_level < 3 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_empress')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_hierophant')
              end
            end
          end
        elseif r == 2 then -- might be helpful, somewhat targeted
          if G.GAME.round_resets.ante > #G.joker.cards then
            if G.GAME.dollars > 8 then
              if #G.deck.cards > 51 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_hanged_man")
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, "c_temperance")
              end
            else  
              if #G.jokers.cards > 2 then
                tcard = create_card("Spectral", G.consumeables, nil, nil, nil, nil, "c_immolate")
              else
                tcard = create_card("Spectral", G.consumeables, nil, nil, nil, nil, "c_ouija")
              end
            end
          else
            local n_enhanced = 0
            for _, val in ipairs(G.hand.cards) do
                if val.ability.set == 'Enhanced' then n_enhanced = n_enhanced + 1 end
            end
            if n_enhanced > 1 then
              if #G.consumeables > 0 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_fool')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_death')
              end
            else
              if hands_left < 2 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_chariot')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_hermit')
              end
            end
          end
        else -- bad tree, give something mostly unhelpful
          if hands_left >= 2 then
            if G.GAME.chips / G.GAME.blind.chips < 0.5 then
              local nglass = 0
              for _, val in ipairs(G.hand.cards) do
                  if val.ability.name == 'Glass Card' then nglass = nglass + 1 end
              end
              if nglass >= 1 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_star')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_tower')
              end
            else
              if G.GAME.removed then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_strength')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_world')
              end
            end
          else
            local nwild = 0
            for _, val in ipairs(G.hand.cards) do
                if val.ability.name == 'Wild Card' then nwild = nwild + 1 end
            end
            if nwild == 0 then
              if #G.jokers.cards > 2 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_wheel_of_fortune')
              else
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_sun')
              end
            else
              if #G.consumeables == 0 then
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_lovers')
              else 
                tcard = create_card("Tarot", G.consumeables, nil, nil, nil, nil, 'c_moon')
              end
            end
          end 
        end
        tcard:add_to_deck()
        G.consumeables:emplace(tcard)
      end
    end
  end 
}

local entrance_of_the_gladiators = SMODS.Joker {
  key = 'entrance_of_the_gladiators',
  loc_txt = {
    name = 'Entrance of the Gladiators',
    text = {
        "This Joker gains {X:mult,C:white} X#2# {} Mult",
        "every time you buy a {C:attention}Circus joker{}",
        "{C:inactive}(Currently {X:mult,C:white} X#1# {C:inactive} Mult)"
    }
  },
  config = { extra = { xmult = 1.5, xmult_gain = 0.25 } },
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 0, y = 1 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_gain } }
  end,
  calculate = function(self, card, context)
    if context.buying_card and not context.blueprint and not (context.card == card) then
      if string.find(context.card.config.center.key, "j_circus_") then
        card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_gain
        G.E_MANAGER:add_event(Event({delay=0.15, func = function() card:juice_up(); return true end }))
      end
    end
    if context.joker_main then
      return { Xmult_mod = card.ability.extra.xmult,
      message = localize {
          type = 'variable',
          key = 'a_xmult',
          vars = { card.ability.extra.xmult}
      }}
    end
  end
}


local mucker = SMODS.Joker {
  key = 'mucker',
  loc_txt = {
    name = 'Mucker',
    text = {
      "{X:mult,C:white}X#1#{} Mult",
      "if this is the leftmost joker"
    }
  },
  config = { extra = { xmult = 2 } },
  rarity = 1,
  atlas = 'a_circus',
  pos = { x = 2, y = 2 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      if G.jokers.cards and card == G.jokers.cards[1] then
        return { Xmult_mod = card.ability.extra.xmult,
        message = localize {
            type = 'variable',
            key = 'a_xmult',
            vars = { card.ability.extra.xmult}
        }}
    end
    end
  end
}

SMODS.Sound {
  key = 'strongman',
  path = 'strongman.ogg'
}

local strongman = SMODS.Joker {
  key = 'strongman',
  loc_txt = {
    name = 'Strongman',
    text = {
      "On the last hand of the round,",
      "destroys a consumeable to add",
      "Steel to a random un-enhanced card."
    }
  },
  config = { },
  rarity = 2,
  atlas = 'a_circus',
  pos = { x = 0, y = 2 },
  cost = 4,
  calculate = function(self, card, context)
    if context.before and #G.consumeables.cards > 0 and G.GAME.current_round.hands_left == 0 then
      local ccard = pseudorandom_element(G.consumeables.cards, pseudoseed('strongman'))
      
      if #G.hand.cards > 0 then 
        local plain_cards = {}
        for _, val in ipairs(G.hand.cards) do
            if not val.ability or val.ability.set ~= "Enhanced" then
              table.insert(plain_cards, val)
            end
        end
        if #plain_cards > 0 then
          play_sound('circus_strongman')
          local pcard = pseudorandom_element(plain_cards, pseudoseed('strongman_steel'))
          pcard:set_ability(G.P_CENTERS.m_steel, true)
          pcard:juice_up(0.3, 0.5)
          G.E_MANAGER:add_event(Event({
            func = function() 
              (context.blueprint_card or card):juice_up(0.3, 0.5)
              ccard:start_dissolve()
              return true
            end}))
        end
      end
    end
  end
}

-- Ringmaster
local ringmaster = SMODS.Joker {
  key = 'ringmaster',
  loc_txt = {
    name = 'Ringmaster',
    text = {
      "Earn {C:money}$1{} at",
      "end of round for each other joker, ",
      "or {C:money}$2{} if it's a Circus joker."
    }
  },
  config = { extra = { money = 1, money_circus = 2 } },
  rarity = 3,
  atlas = 'a_circus',
  pos = { x = 3, y = 2 },  
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money } }
  end,
  calc_dollar_bonus = function(self, card)
    local bonus = 0
    for _, joker in ipairs(G.jokers.cards) do
      if joker ~= card then
        if string.find(joker.config.center.key, "j_circus_") then
          bonus = bonus + card.ability.extra.money_circus
        else
          bonus = bonus + card.ability.extra.money
        end
      end
    end
    if bonus > 0 then return bonus end
  end
}


SMODS.Joker {
  key = 'oleg_popov',
  loc_txt = {
    name = 'Oleg Popov',
    text = {
      "Double your hand size"
    }
  },
  config = { extra = { size_before_double = 0 } },
  rarity = 4,
  atlas = 'a_circus',
  pos = { x = 0, y = 3 },
  -- soul_pos sets the soul sprite, only used in vanilla for legenedaries and Hologram.
  soul_pos = { x = 4, y = 3 },
  cost = 20,
  add_to_deck = function(self, card, from_debuff)
    card.ability.extra.size_before_double = G.hand.config.card_limit
    G.hand:change_size(card.ability.extra.size_before_double)
  end,
  -- Inverse of above function.
  remove_from_deck = function(self, card, from_debuff)
    -- Adds - instead of +, so they get subtracted when this card is removed.
    G.hand:change_size(-card.ability.extra.size_before_double)
  end
}

--- New Bosses
--- 



local bear = SMODS.Blind{
  key = "bear",
  loc_txt = {
   name = 'The Bear',
   text = { 'Set money to {C:money}$8{}' },
 },
  boss_colour = HEX('21b04e'),
  dollars = 0,
  mult = 2,
  boss = {
      min = 1,
      max = 10
  },
  pos = { x = 0, y = 0 },
  atlas = 'a_circus_blinds',
  set_blind = function(self)
      G.GAME.dollars = 8
  end,
  in_pool = function(self,wawa,wawa2)
      return 2
  end
}


