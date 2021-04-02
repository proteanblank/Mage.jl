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

# ╔═╡ f313719e-56c1-11eb-0151-7fdc92bc5635
using DrWatson

# ╔═╡ 5d891788-56c2-11eb-1723-8361ac5bd415
begin
	@quickactivate

	using Images
	using PlutoUI
	using Serialization
	using ImageFiltering
	using ImageTransformations

	pd = projectdir()

	md"""
	## Custom EDH Cards
	"""
end

# ╔═╡ 9891eb6c-88f8-11eb-261a-e5efa12c84ac
md"""
Mage.jl Deck directory path: $(@bind DECK_DIR TextField(default="/home/dusty/Shared/PlaymatProjects/PlaymatGames/Mage.jl/EDH/decks/Vannifar's Circus"))
"""

# ╔═╡ b28c3a68-88f8-11eb-0175-779fdb2da838
DECK_NAME = split(DECK_DIR, '/')[end]

# ╔═╡ 8a3f6140-56c4-11eb-1cea-ff327a21d57b
deck = deserialize("$DECK_DIR/$DECK_NAME.jls")

# ╔═╡ f78a72a0-5d48-11eb-198c-d742de310200
sz = size(deck[:CARD_BACK_IMG])

# ╔═╡ 0152ba30-5ba1-11eb-013e-8dc5191b3c17
md"""
## Custom PNGs, JPGs, etc.!
"""

# ╔═╡ 2f5a332c-56c4-11eb-259b-8b7d51af1b04
begin
	custom_card_faces = [ fn => load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if !occursin(split(fn,".")[begin], join(deck[:commander_names])) && (occursin("png", fn) || occursin("gif",fn))  ]

	card_names = [ k for (k,v) in custom_card_faces ]
	card_imgs = [ v for (k,v) in custom_card_faces ]

	for i in 1:length(card_imgs)
		csz = size(card_imgs[i])
		rat = csz[1] / csz[2]
		card_imgs[i] = imresize(card_imgs[i], ceil(Int, sz[2]*rat), sz[2])
	end
end;

# ╔═╡ 64e4a3a6-5d54-11eb-25f7-9dfff5507992
md"""
### Cards
"""

# ╔═╡ 70971440-5985-11eb-3d51-cdedac799904
md"""
card index: $(@bind card_index Slider(1:length(card_imgs), show_value=true))
"""

# ╔═╡ 898434cc-5ee6-11eb-0e99-6d69667336d9
card_imgs[card_index]

# ╔═╡ 08063488-5973-11eb-0fcd-97b6d199dd11
card_info = [ [v,k,i,size(v[begin]),size(v[begin])[1]/size(v[begin])[2] ] for (i,(k,v)) in enumerate(deck[:CARD_FACES]) if occursin(k, card_names[card_index]) ][begin]

# ╔═╡ 77ce8398-5989-11eb-2d3c-d3d0957ae270
md"""
"Replace card face with custom png / gif?" $(@bind swap_card_face CheckBox())
"""

# ╔═╡ e010eb3a-597a-11eb-19da-01375b1d8367
if swap_card_face
	deck[:CARD_FACES][ card_info[3] ] =
	card_names[card_index] => [ card_imgs[card_index] ]
end

# ╔═╡ cd27bfd0-5ba0-11eb-0bd4-559470d3907a
md"""
### Custom GIFs!
"""

# ╔═╡ 437c0424-56c5-11eb-29ce-7f0090186512
custom_gifs = [ fn=>LocalResource("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("gif", fn) ];

# ╔═╡ 2d187afa-598b-11eb-1dec-7b3c22ea634d
md"""
custom gif index: $(@bind gif_index Slider(1:length(custom_gifs), show_value=true))
"""

# ╔═╡ dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
custom_gif_names = [ k for (k,v) in custom_gifs ];

# ╔═╡ 74abf0a2-5802-11eb-3bcf-79a66eabe3e5
custom_gifs[gif_index]

# ╔═╡ 3c25d5f2-5ba1-11eb-0229-0fbfc8dbbf44
md"""
save custom card face data? $(@bind save_data CheckBox())
"""

# ╔═╡ 72de84ba-598d-11eb-139d-975970c19cc0
if save_data
	serialize("$DECK_DIR/Vannifar's Circus.jls", deck)
end

# ╔═╡ Cell order:
# ╟─f313719e-56c1-11eb-0151-7fdc92bc5635
# ╟─5d891788-56c2-11eb-1723-8361ac5bd415
# ╟─9891eb6c-88f8-11eb-261a-e5efa12c84ac
# ╟─b28c3a68-88f8-11eb-0175-779fdb2da838
# ╟─8a3f6140-56c4-11eb-1cea-ff327a21d57b
# ╟─f78a72a0-5d48-11eb-198c-d742de310200
# ╟─0152ba30-5ba1-11eb-013e-8dc5191b3c17
# ╟─2f5a332c-56c4-11eb-259b-8b7d51af1b04
# ╟─64e4a3a6-5d54-11eb-25f7-9dfff5507992
# ╟─70971440-5985-11eb-3d51-cdedac799904
# ╟─898434cc-5ee6-11eb-0e99-6d69667336d9
# ╟─08063488-5973-11eb-0fcd-97b6d199dd11
# ╟─77ce8398-5989-11eb-2d3c-d3d0957ae270
# ╟─e010eb3a-597a-11eb-19da-01375b1d8367
# ╟─cd27bfd0-5ba0-11eb-0bd4-559470d3907a
# ╟─2d187afa-598b-11eb-1dec-7b3c22ea634d
# ╠═437c0424-56c5-11eb-29ce-7f0090186512
# ╠═dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
# ╠═74abf0a2-5802-11eb-3bcf-79a66eabe3e5
# ╟─3c25d5f2-5ba1-11eb-0229-0fbfc8dbbf44
# ╠═72de84ba-598d-11eb-139d-975970c19cc0
