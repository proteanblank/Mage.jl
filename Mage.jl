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

# ╔═╡ e90001ca-4b3f-11eb-0ccd-7785902a32e3
using DrWatson

# ╔═╡ 6e33e012-4b3d-11eb-30ea-2b5f82c16b8e
begin
	@quickactivate

	using PlaymatSimulator
	using Serialization
	using GameZero
	using PlutoUI
	using Colors


	md"""
	# Welcome to Mage.jl!
	#### Choose a game variant below to get started ☮
	"""
end

# ╔═╡ 63b7dc70-839f-11eb-0701-4389ed6b3380
md"""PlaymatSimulator game direcory: $(@bind GAME_DIR TextField(default="/home/dusty/Shared/PlaymatProjects/PlaymatGames/Mage.jl"))"""

# ╔═╡ 65e7c338-4b42-11eb-014a-017404d2040a
begin
	GAMES = [ gn=>gn for gn in readdir(GAME_DIR) if !(occursin(".", gn)) ]
	pushfirst!(GAMES,""=>"")

	md"""
	Select a game to play: $( @bind GAME_NAME Select(GAMES) )
	"""
end

# ╔═╡ e86a6936-4b43-11eb-33b9-3ddefed762c7
if GAME_NAME != ""
	DECKS = [ gn=>gn for gn in readdir("$GAME_DIR/$GAME_NAME/decks") if !(occursin(".", gn)) ]
	pushfirst!(DECKS,""=>"")

	md"""
	Select a deck to play: $( @bind DECK_NAME Select(DECKS) )
	"""
end

# ╔═╡ eb1a3e94-4cca-11eb-2b39-a5794006c375
if GAME_NAME != "" && DECK_NAME != ""
	
	US = Dict(
		:GAME_NAME => GAME_NAME,
		:DECK_NAME => DECK_NAME,
	)

	serialize("tmp/user_selection.jls", US)
end

# ╔═╡ e11fc3c8-4b44-11eb-0c25-3d787ef9da0a
if GAME_NAME != "" && DECK_NAME != ""
	md"""
	###### Simulating an $GAME_NAME game with a $DECK_NAME deck, please wait...

	*press alt+F4 to quit*
	"""
end

# ╔═╡ a6cc0f5c-4cab-11eb-10d1-b351e17004e3
if (@isdefined DECK_NAME) && !(DECK_NAME == "")
	rungame("$GAME_NAME/notebooks/$GAME_NAME.jl")
end

# ╔═╡ 386f2d76-4ef1-11eb-032b-1715050b4952
md"""
*Want to develop your own PlaymatSimulator games? Check out the docs!
"""

# ╔═╡ 1816db80-4b62-11eb-0a61-91f0662ae287
html"""<br><br><br><br><br><br>"""

# ╔═╡ Cell order:
# ╟─e90001ca-4b3f-11eb-0ccd-7785902a32e3
# ╠═6e33e012-4b3d-11eb-30ea-2b5f82c16b8e
# ╟─63b7dc70-839f-11eb-0701-4389ed6b3380
# ╟─65e7c338-4b42-11eb-014a-017404d2040a
# ╟─e86a6936-4b43-11eb-33b9-3ddefed762c7
# ╠═eb1a3e94-4cca-11eb-2b39-a5794006c375
# ╠═e11fc3c8-4b44-11eb-0c25-3d787ef9da0a
# ╠═a6cc0f5c-4cab-11eb-10d1-b351e17004e3
# ╟─386f2d76-4ef1-11eb-032b-1715050b4952
# ╟─1816db80-4b62-11eb-0a61-91f0662ae287
