### A Pluto.jl notebook ###
# v0.12.21

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

# ╔═╡ 2ffc155a-8853-11eb-0c4f-8bc96a3f08f2
begin
	using DrWatson
	
	md"""
	## EDH Deck: Kraum and Tymna

	To get started, define a `deck` Dict object below of type Dict{String,Int} where the key is the official card name and the value is the quantity of that card in the deck.
	"""
end

# ╔═╡ 2ffd3e94-8853-11eb-15b3-ffcb09c9661d
begin
	@quickactivate

	using GameZero
	using JSON
	using HTTP
	using Images: load, RGB
	using PlutoUI
	using Serialization
	using PlaymatSimulator
	using ImageTransformations: imresize

	AC = PlaymatSimulator.Actors
	
	pd = projectdir()
	
	mtg_cards = JSON.parsefile("$pd/Base/json/oracle-cards-20201224220555.json")
	
	md"**Found $(length(mtg_cards)) cards in JSON db!**"
end

# ╔═╡ 35d467ca-8853-11eb-16b5-65036e2a1f24
deck = if !(@isdefined deck)
	Dict{Symbol,Any}(
	:name => split(@__DIR__, "/")[end],
    :commander_names => [
        "Kraum, Ludevic's Opus",
		"Tymna the Weaver",
    	],
    :card_names => [
		"Ad Nauseam",
		"Alms Collector",
		"Ancient Tomb",
		"Angel's Grace",
		"Arid Mesa",
		"Aven Mindcensor",
		"Blood Crypt",
		"Bloodstained Mire",
		"Brainstorm",
		"Burning Inquiry",
		"Chain of Vapor",
		"Chrome Mox",
		"City of Brass",
		"Command Tower",
		"Counterspell",
		"Cursed Totem",
		"Cyclonic Rift",
		"Dark Confidant",
		"Dark Deal",
		"Dark Ritual",
		"Demonic Consultation",
		"Demonic Tutor",
		"Dimir Signet",
		"Dispel",
		"Dovin's Veto",
		"Enlightened Tutor",
		"Exotic Orchard",
		"Fellwar Stone",
		"Fire Covenant",
		"Flame Sweep",
		"Flooded Strand",
		"Flusterstorm",
		"Forbidden Orchard",
		"Force of Will",
		"Gemstone Caverns",
		"Gilded Drake",
		"Gitaxian Probe",
		"Godless Shrine",
		"Grim Monolith",
		"Hallowed Fountain",
		"Imperial Seal",
		"Island",
		"Jace, Wielder of Mysteries",
		"Kraum, Ludevic's Opus",
		"Laboratory Maniac",
		"Lim-Dûl's Vault",
		"Lotus Petal",
		"Mana Confluence",
		"Mana Crypt",
		"Mana Drain",
		"Mana Vault",
		"Marsh Flats",
		"Meltdown",
		"Mental Misstep",
		"Misty Rainforest",
		"Mnemonic Betrayal",
		"Morphic Pool",
		"Mox Diamond",
		"Mystic Remora",
		"Mystical Tutor",
		"Narset's Reversal",
		"Narset, Parter of Veils",
		"Necropotence",
		"Notion Thief",
		"Pact of Negation",
		"Polluted Delta",
		"Ponder",
		"Preordain",
		"Pyroclasm",
		"Reflecting Pool",
		"Rhystic Study",
		"Sacred Foundry",
		"Scalding Tarn",
		"Sea of Clouds",
		"Silence",
		"Smothering Tithe",
		"Snow-Covered Island",
		"Sol Ring",
		"Spell Pierce",
		"Steam Vents",
		"Suppression Field",
		"Swan Song",
		"Tainted Pact",
		"Talisman of Creativity",
		"Talisman of Dominance",
		"Talisman of Progress",
		"Toxic Deluge",
		"Tymna the Weaver",
		"Underground River",
		"Vampiric Tutor",
		"Verdant Catacombs",
		"Waste Not",
		"Watery Grave",
		"Wheel of Fortune",
		"Whispering Madness",
		"Windfall",
		"Winds of Change",
		"Windswept Heath",
		"Wooded Foothills",
		"Yawgmoth's Will",
    ]
)
else 
	nothing
end

# ╔═╡ 300953aa-8853-11eb-373d-f54f8766d833
md"**Found $(length(deck[:card_names])) cards in $(deck[:name]) deck**"

# ╔═╡ 301d6246-8853-11eb-0e77-791a8e2a040d
md"""
Look OK? Keep in mind that images that do not require in-game scaling will suffer less distortion.
"""

# ╔═╡ 30219d16-8853-11eb-34f9-e9ac95eea58e
begin
	cards = []

	for n in sort(deck[:card_names])

		for c in mtg_cards

			if n == c["name"]
				push!(cards, c)
			end
		end
	end

	md"""
	**Found $(length(cards)) matching cards in mtg_cards!**
	"""
end

# ╔═╡ 30252f9e-8853-11eb-0129-9d151ffb5839
missing_cards = filter!(x->!(x in [ c["name"] for c in cards ]), vcat(deck[:card_names], deck[:commander_names]))

# ╔═╡ 302c833e-8853-11eb-0039-b116bd127ba1
md"""Card #: $(@bind i Slider(1:length(cards), default=50, show_value=true))
Shrink card by $(@bind card_ratio Slider(0.1:0.05:1.25, default=0.5, show_value=true)) 

or: $(@bind customw CheckBox(default=true)) specify the default card width: $(@bind card_width NumberField(1:10; default=270)) in pixels
"""

# ╔═╡ 3037a502-8853-11eb-2884-9bfb699d081e
md"""
##### Download card imgs? $(@bind download_imgs CheckBox()) 
"""

# ╔═╡ 3046ea30-8853-11eb-39b6-ff96a085c14b
md"""
##### Save data to disk? $(@bind save_data CheckBox()) 
"""

# ╔═╡ 30534bae-8853-11eb-181a-798130ecab86
deck

# ╔═╡ 305982a8-8853-11eb-3623-db4d3a2dca4c
function get_face_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ 305f084a-8853-11eb-1514-75e789bb1d9b
function get_card_preview_img(c)
	if haskey(all_cards[i], "card_faces") && haskey(all_cards[i]["card_faces"][1], "image_uris")
		hcat([get_face_img(f["image_uris"]["border_crop"]) 
			for f in all_cards[i]["card_faces"] ]...)
	else
		get_face_img(all_cards[i]["image_uris"]["border_crop"])
	end
end

# ╔═╡ 30657cc0-8853-11eb-1d78-8bed4b88d3a3
function get_card_faces(c, faces=[])
	if haskey(c, "image_uris")
		push!(faces, get_face_img(c["image_uris"]["border_crop"]))
	
	elseif haskey(c, "card_faces")
		for f in c["card_faces"]
			push!(faces, get_face_img(f["image_uris"]["border_crop"]))
		end
	end
			
	return faces
end

# ╔═╡ 303153aa-8853-11eb-0f16-77023647c760
if length(cards) > 0 && (@isdefined cards)
	
	if customw
		fs = get_card_faces(cards[i])
		sz = size(fs[end])
		imresize.(fs, ceil(Int, card_width * sz[1]/sz[2]), card_width)[end]
	else
		imresize.(get_card_faces(cards[i]), ratio=card_ratio)[end]
	end
else
	nothing
end

# ╔═╡ 3040ea2c-8853-11eb-176f-f3ef24eeebc1
if download_imgs
	CARD_FACES = []

	for c in cards
		faces = get_card_faces(c)
		
		if customw
			sz = size(faces[end])
			faces = imresize.(faces, ceil(Int, card_width * sz[1]/sz[2]), card_width)
		else
			faces = imresize.(faces, ratio=card_ratio)
		end
		
		push!(CARD_FACES, c["name"] => faces)
		sleep(0.1)
	end
end

# ╔═╡ 30404d24-8853-11eb-2885-e1870b8c82eb
if @isdefined CARD_FACES
	CARD_FACES[i][end][end]
end

# ╔═╡ 306bec22-8853-11eb-15a3-5db375f241b7
function search_mtg_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ 3072a3f0-8853-11eb-2457-ffa9fd3857a3
function hbox(x, y, gap=16; sy=size(y), sx=size(x))
	w,h = (max(sx[1], sy[1]),
		   gap + sx[2] + sy[2])
	
	slate = fill(RGB(1,1,1), w,h)
	slate[1:size(x,1), 1:size(x,2)] .= RGB.(x)
	slate[1:size(y,1), size(x,2) + gap .+ (1:size(y,2))] .= RGB.(y)
	slate
end

# ╔═╡ 30183ea6-8853-11eb-36b5-b7b1a2229a89
begin
	CARD_BACK_PATH = "$pd/Base/ui/cards/card_back.png"
	CARD_BACK_IMG = imresize(load(CARD_BACK_PATH), ratio=card_ratio)
	
	hbox(CARD_BACK_IMG, CARD_BACK_IMG)
end

# ╔═╡ 304e1698-8853-11eb-0661-233ddd5bf224
if save_data
	deck[:CARD_BACK_IMG] = CARD_BACK_IMG
	deck[:CARD_FACES] = CARD_FACES

	fn = "$pd/EDH/decks/$(deck[:name])/$(deck[:name]).jls"
	serialize(fn, deck)
	
	md"Deck data saved to $fn"
end

# ╔═╡ 3079c428-8853-11eb-04e6-133b5af8af4a
vbox(x,y, gap=16) = hbox(x', y')'

# ╔═╡ Cell order:
# ╠═2ffc155a-8853-11eb-0c4f-8bc96a3f08f2
# ╠═2ffd3e94-8853-11eb-15b3-ffcb09c9661d
# ╠═35d467ca-8853-11eb-16b5-65036e2a1f24
# ╟─300953aa-8853-11eb-373d-f54f8766d833
# ╟─30183ea6-8853-11eb-36b5-b7b1a2229a89
# ╟─301d6246-8853-11eb-0e77-791a8e2a040d
# ╟─30219d16-8853-11eb-34f9-e9ac95eea58e
# ╠═30252f9e-8853-11eb-0129-9d151ffb5839
# ╟─302c833e-8853-11eb-0039-b116bd127ba1
# ╟─303153aa-8853-11eb-0f16-77023647c760
# ╟─3037a502-8853-11eb-2884-9bfb699d081e
# ╟─30404d24-8853-11eb-2885-e1870b8c82eb
# ╟─3040ea2c-8853-11eb-176f-f3ef24eeebc1
# ╟─3046ea30-8853-11eb-39b6-ff96a085c14b
# ╟─304e1698-8853-11eb-0661-233ddd5bf224
# ╟─30534bae-8853-11eb-181a-798130ecab86
# ╟─305982a8-8853-11eb-3623-db4d3a2dca4c
# ╟─305f084a-8853-11eb-1514-75e789bb1d9b
# ╟─30657cc0-8853-11eb-1d78-8bed4b88d3a3
# ╟─306bec22-8853-11eb-15a3-5db375f241b7
# ╟─3072a3f0-8853-11eb-2457-ffa9fd3857a3
# ╟─3079c428-8853-11eb-04e6-133b5af8af4a
