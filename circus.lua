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
-- Entry of the Gladiators, Op.68 - Julius Fučík - Arranged for Strings by GregorQuendel -- https://freesound.org/s/735154/ -- License: Attribution NonCommercial 4.0

-- Graphics misappropriated: Bear blind graphic from BelenosBear


math.randomseed(os.time())

local unc_rare_circus_jokers = {"j_circus_trapeze", "j_circus_fire_eater",  "j_circus_joker_cannonball", 
    "j_circus_palm_reader", "j_circus_strongman", "j_circus_ringmaster", "j_circus_lion_tamer"}

--Creates an atlas for cards to use
SMODS.Atlas {
  -- Key for code to find it with
  key = "a_circus",
  -- The name of the file, for the code to pull the atlas from
  path = "jokers1.png",
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

SMODS.Sound {
  key = 'cannonball',
  path = 'cannonball.ogg'
}
SMODS.Sound {
  key = 'entrance',
  path = 'entrance.ogg'
}
SMODS.Sound {
  key = 'strongman',
  path = 'strongman.ogg'
}

SMODS.load_file('circus/common_jokers.lua')()
SMODS.load_file('circus/other_jokers.lua')()

--- New Decks
--- 
--- 

SMODS.Back {
  name = "Proprioception Deck",
  key = "proprioception",
  pos = { x = 1, y = 3 },
  atlas = 'a_circus',
  loc_txt = {
    name = "Proprioception",
    text = {
      "Only face cards and {C:attention}2 copies{}",
      "of each even-rank card"
    }
  },
  apply = function(self)
    G.E_MANAGER:add_event(Event({
      func = function()
        local even_out = { ['Ace'] = '2', ['3'] = '4', ['5'] = '6', ['7'] = '8', ['9'] = '10' }
        for _, card in ipairs(G.playing_cards) do
          if even_out[card.base.value] ~= nil then
            assert(SMODS.change_base(card, nil, even_out[card.base.value]))
          end
        end
        return true
      end
    }))
  end
}

SMODS.Back {
  name = "Sideshow Deck",
  key = "sideshow",
  pos = { x = 2, y = 3 },
  atlas = 'a_circus',
  loc_txt = {
    name = "Sideshow",
    text = {
      "Start with a random", 
      "uncommon or rare",
      "Circus joker"
    }
  },
  apply = function(self)
    
    local joker_name = pseudorandom_element(unc_rare_circus_jokers, pseudoseed('sideshow' .. os.date('%Y%m%d%H%M%S')))
    sendInfoMessage(joker_name)
    G.E_MANAGER:add_event(Event({
      func = function()
        if G.jokers then
          local njoker = create_card("Joker", G.jokers, nil, 2, nil, nil, joker_name)
          njoker:add_to_deck()
          G.jokers:emplace(njoker)
          return true
        end
    end
    }))
  end
}
--- 
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


