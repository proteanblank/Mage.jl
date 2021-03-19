### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 1581f9f4-4b6f-11eb-34df-cb1e958aaab6
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
end;

# ╔═╡ 1a6beb1e-4b6f-11eb-2a42-5f72fd775375
begin
	@quickactivate

    using Colors
	using GameZero
	using Serialization
    using PlaymatSimulator

	import PlaymatSimulator.Actors.Image

	const pd = projectdir()

	md"""
	## Elder Dragon Highlander aka Commander

	EDH is a variant of an MtG game that uses a 100 card singleton deck with 1 or more cards designated as the "Commander" and a 40 point lifepool. The Commander should start on the battlefield and be visible to all players.
	"""
end

# ╔═╡ 2d5304e4-4e2e-11eb-1856-a594b65b33a1
begin
	USER_SETTINGS = deserialize("$pd/tmp/user_selection.jls")
	const GAME_NAME = USER_SETTINGS[:GAME_NAME]
	const DECK_NAME = USER_SETTINGS[:DECK_NAME]
end

# ╔═╡ ac00106c-4bff-11eb-29db-b1f869ba2c70
game_include("$pd/Base/notebooks/Base.jl")

# ╔═╡ 5c4fbaf4-854b-11eb-070f-affe01d25ca4
game_include("$pd/Base/notebooks/game_settings.jl")

# ╔═╡ 60c88516-854b-11eb-1c66-df73b9b6181a
game_include("$pd/Base/notebooks/game_rules.jl")

# ╔═╡ 62e19680-854b-11eb-2559-2bad48989589
game_include("$pd/$GAME_NAME/notebooks/game_state.jl")

# ╔═╡ 1e72fb94-4c0a-11eb-1186-e717e9acc1e6
begin
	merge!(gs, USER_SETTINGS)
	deck = deserialize("$pd/$GAME_NAME/decks/$DECK_NAME/$DECK_NAME.jls")
	gs[:deck] = deck
end

# ╔═╡ c811ed82-4c09-11eb-3506-9b30dae8eaa6
add_texts!(gs)

# ╔═╡ 0146b240-4c0a-11eb-371c-19ef327394c7
reset_stage!(gs)

# ╔═╡ 32229134-4cc0-11eb-2c68-d11134987c56
begin  # required GameZero variables
	const SCREEN_HEIGHT = gs[:SCREEN_HEIGHT]
	const SCREEN_WIDTH = gs[:SCREEN_WIDTH]

	SimpleDirectMediaLayer.ShowCursor(Int32(0))  # hides system mouse cursor
end

# ╔═╡ Cell order:
# ╟─1581f9f4-4b6f-11eb-34df-cb1e958aaab6
# ╟─1a6beb1e-4b6f-11eb-2a42-5f72fd775375
# ╠═2d5304e4-4e2e-11eb-1856-a594b65b33a1
# ╠═ac00106c-4bff-11eb-29db-b1f869ba2c70
# ╠═5c4fbaf4-854b-11eb-070f-affe01d25ca4
# ╠═60c88516-854b-11eb-1c66-df73b9b6181a
# ╠═62e19680-854b-11eb-2559-2bad48989589
# ╟─1e72fb94-4c0a-11eb-1186-e717e9acc1e6
# ╠═c811ed82-4c09-11eb-3506-9b30dae8eaa6
# ╠═0146b240-4c0a-11eb-371c-19ef327394c7
# ╠═32229134-4cc0-11eb-2c68-d11134987c56
