### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ c7952ee6-45b5-11eb-1158-5bb2ff274ce9
begin
	using DrWatson
	
	function ingredients(path::String)
		# this is from the Julia source code (evalfile in base/loading.jl)
		# but with the modification that it returns the module instead of the last object
		name = Symbol(basename(path))
		m = Module(name)
		Core.eval(m,
			Expr(:toplevel,
				 :(eval(x) = $(Expr(:core, :eval))($name, x)),
				 :(include(x) = $(Expr(:top, :include))($name, x)),
				 :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
				 :(include($path))))
		m
	end
	
	mtg_dir = projectdir() * "/games/MtG"
end;

# ╔═╡ 0c145632-3927-11eb-19b9-877e05c1bcdc
begin
	@quickactivate
	
	using JSON
	using HTTP
	using Plots
	using Images
	using PlutoUI
	using Serialization
	using ImageTransformations: imresize
	
	plotly()
	
	GS = ingredients("$mtg_dir/MtG.jl/notebooks/game_settings.jl")
	
	md"""
	*game settings loaded!*
	
	## MtG EDH Kraum and Tymna by ???
	"""
end

# ╔═╡ 621b08a4-384e-11eb-0109-61e9b9ecf125
deck = Dict{Symbol,Any}(
    :commanders => [
        "Kraum, Ludevic's Opus",
        "Tymna the Weaver"
        ],        
    :cards => [
        "Ajani Vengeant",
        "Arid Mesa",
        "Aven Mindcensor",
        "Badlands",
        "Baleful Strix",
        "Blood Crypt",
        "Bloodstained Mire",
        "Brain Maggot",
        "Brainstorm",
        "Brazen Borrower",
        "Breya, Etherium Shaper",
        "Celestial Colonnade",
        "Chain Lightning",
        "City of Brass",
        "Command Tower",
        "Counterspell",
        "Creeping Tar Pit",
        "Dark Confidant",
        "Dardslick Shores",
        "Daze",
        "Deadly Rollick",
        "Demonic Tutor",
        "Duress",
        "Evasive Action",
        "Fatal Push",
        "Fiery Islet",
        "Fire // Ice",
        "Flawless Maneuver",
        "Flooded Strand",
        "Force of Negation",
        "Force of Will",
        "Force Spike",
        "Chop Down // Giant Killer",
        "Gitaxian Probe",
        "Giver of Runes",
        "Godless Shrine",
        "Grim Lavamancer",
        "Hallowed Fountain",
        "Inquisition of Kozilek",
        "Island",
        "Jace, the Mind Sculptor",
        "Kitesail Freebooter",
        "Kraum, Ludevic's Opus",
        "Lightning Bolt",
        "Lightning Helix",
        "Mana Confluence",
        "Mana Leak",
        "Mana Tithe",
        "Marsh Flats",
        "Mausoleum_Wanderer",
        "Memory Lapse",
        "Mental Misstep",
        "Mesmeric Fiend",
        "Miscalculation",
        "Misty Rainforest",
        "Mother of Runes",
        "Plains",
        "Plateau",
        "Polluted Delta",
        "Ponder",
        "Preordain",
        "Prismatic Vista",
        "Reflecting Pool",
        "Remorseful Cleric",
        "Sacred Foundry",
        "Scalding Tarn",
        "Scrubland",
        "Seachrome Coast",
        "Selfless Spirit",
        "Silent Clearing",
        "Smuggler's Copter",
        "Snapcaster Mage",
        "Spell Pierce",
        "Spell Queller",
        "Spell Snare",
        "Spirebluff Canal",
        "Steam Vents",
        "Stoneorge Mystic",
        "Sunbaked Canyon",
        "Swamp",
        "Sword of Feast and Famine",
        "Swords to Plowshares",
        "Tainted Pact",
        "Thoughtseize",
        "Tidehollow Sculler",
        "Tollegeist",
        "Tribal Flames",
        "True-Name Nemesis",
        "Tundra",
        "Umezawa's Jitte",
        "Underground Sea",
        "Vendillion Clique",
        "Verdant Catacombs",
        "Vindicate",
        "Volcanic Island",
        "Watery Grave",
        "Windswept Heath",
        "Wooded Foothills",
        ]
    )

# ╔═╡ fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
md"""
Found $(length(deck[:cards]) + length(deck[:commanders])) cards!
"""

# ╔═╡ c61fa79e-4583-11eb-3b71-2d334aca843d
begin
	mtg_cards = JSON.parsefile("$mtg_dir/MtG.jl/json/oracle-cards-20201224220555.json")
	
	md"""
	###### MtG database loaded. Found $(length(mtg_cards)) unique cards (by name).
	Most recent data available here: https://scryfall.com/docs/api/bulk-data
	"""
end

# ╔═╡ 7420cf10-45cc-11eb-2780-4f320bd8a2cf
begin  # note: this func only downloads the first card with a matching name and then moves to the next.
	deck_cards = []
	
	for n in vcat(deck[:cards], deck[:commanders])
		
		for c in mtg_cards
			
			if n == c["name"]
				push!(deck_cards, c)
				break
			end
		end
	end
	
	deck_cards
end

# ╔═╡ 2ec9a2fe-4660-11eb-2b73-7127019757b5
deck[:cardnames] = vcat(deck[:cards], deck[:commanders])

# ╔═╡ 9f64efdc-4660-11eb-2333-45a14af374c6
missing_cards = [ c for c in deck[:cardnames] if !(c in [ n for n in deck[:cardnames] ]) ]

# ╔═╡ 489f3da8-4681-11eb-26af-f75d8ecc552e
@bind i Slider(1:length(deck_cards), show_value=true)

# ╔═╡ 4666005c-4d62-11eb-1215-e7e010c3125c
md"""
#### Look good? These images will be displayed in-game.
TODO: write support for previews of double-sided cards
"""

# ╔═╡ fb0a03ea-4ed5-11eb-1280-e70793eac293
@bind ratio Slider(0.1:0.05:1, show_value=true)

# ╔═╡ 5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
begin
	CARD_BACK_PATH = "$mtg_dir/MtG.jl/ui/cards/card_back.png"
	im = imresize(load(CARD_BACK_PATH), ratio=ratio)
	
	md"""
	`CARD_BACK_IMG`: 
	
	$(CARD_BACK_IMG = im)
	"""
end

# ╔═╡ 457f0ee2-4d6f-11eb-310f-cf4784a06469
html"""<br><br><br><br><br><br>"""

# ╔═╡ 9ded258e-468d-11eb-3428-d915bfe9e13e
function get_card_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ e67591a6-4ed5-11eb-215e-e3497b7ef30e
deck_card_img = imresize(get_card_img(deck_cards[i]["image_uris"]["border_crop"]), ratio=ratio
)

# ╔═╡ a26b32f4-468d-11eb-1ddd-7958d61b4ac6
function search_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ cb8e3b6c-4661-11eb-152e-3f2ce56cdd9d
search_cards_by_keyword("Lotus", mtg_cards)

# ╔═╡ d491b248-4da5-11eb-115b-193dfb0e1979
begin
	deck[:CARD_BACK_PATH] = CARD_BACK_PATH
	deck[:CARD_RATIO] = ratio
end

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╟─fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╟─5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
# ╟─c61fa79e-4583-11eb-3b71-2d334aca843d
# ╟─7420cf10-45cc-11eb-2780-4f320bd8a2cf
# ╟─2ec9a2fe-4660-11eb-2b73-7127019757b5
# ╟─9f64efdc-4660-11eb-2333-45a14af374c6
# ╠═cb8e3b6c-4661-11eb-152e-3f2ce56cdd9d
# ╟─e67591a6-4ed5-11eb-215e-e3497b7ef30e
# ╟─489f3da8-4681-11eb-26af-f75d8ecc552e
# ╟─4666005c-4d62-11eb-1215-e7e010c3125c
# ╠═fb0a03ea-4ed5-11eb-1280-e70793eac293
# ╟─457f0ee2-4d6f-11eb-310f-cf4784a06469
# ╟─9ded258e-468d-11eb-3428-d915bfe9e13e
# ╟─a26b32f4-468d-11eb-1ddd-7958d61b4ac6
# ╠═d491b248-4da5-11eb-115b-193dfb0e1979
