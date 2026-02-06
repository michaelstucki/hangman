defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    word = "wombat"
    game = Game.new_game(word)
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == word |> String.codepoints
  end

  test "state does not change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "record letters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "a letter of word is guessed" do
    game = Game.new_game("at")
    {_game, tally} = Game.make_move(game, "a")
    assert tally.game_state == :good_guess
  end

  test "a letter of word is not guessed" do
    game = Game.new_game("at")
    {_game, tally} = Game.make_move(game, "c")
    assert tally.game_state == :bad_guess
  end

  # "cat"
  test "a sequence of moves" do
    [
      # [guess, state, turns, letters, used]
      ["x", :bad_guess, 6, ["_", "_", "_"], ["x"]],
      ["x", :already_used, 6, ["_", "_", "_"], ["x"]],
      ["c", :good_guess, 6, ["c", "_", "_"], ["c", "x"]],
      ["z", :bad_guess, 5, ["c", "_", "_"], ["c", "x", "z"]],
    ]
    |> test_sequence_of_moves()
  end

  test "a winning game" do
    [
      # [guess, state, turns, letters, used]
      ["x", :bad_guess, 6, ["_", "_", "_"], ["x"]],
      ["x", :already_used, 6, ["_", "_", "_"], ["x"]],
      ["c", :good_guess, 6, ["c", "_", "_"], ["c", "x"]],
      ["z", :bad_guess, 5, ["c", "_", "_"], ["c", "x", "z"]],
      ["a", :good_guess, 5, ["c", "a", "_"], ["a", "c", "x", "z"]],
      ["t", :won, 5, ["c", "a", "t"], ["a", "c", "t", "x", "z"]],
    ]
    |> test_sequence_of_moves()
  end

  test "a losing game" do
    [
      # [guess, state, turns, letters, used]
      ["x", :bad_guess, 6, ["_", "_", "_"], ["x"]],
      ["x", :already_used, 6, ["_", "_", "_"], ["x"]],
      ["c", :good_guess, 6, ["c", "_", "_"], ["c", "x"]],
      ["z", :bad_guess, 5, ["c", "_", "_"], ["c", "x", "z"]],
      ["a", :good_guess, 5, ["c", "a", "_"], ["a", "c", "x", "z"]],
      ["b", :bad_guess, 4, ["c", "a", "_"], ["a", "b", "c", "x", "z"]],
      ["y", :bad_guess, 3, ["c", "a", "_"], ["a", "b", "c", "x", "y", "z"]],
      ["k", :bad_guess, 2, ["c", "a", "_"], ["a", "b", "c", "k", "x", "y", "z"]],
      ["l", :bad_guess, 1, ["c", "a", "_"], ["a", "b", "c", "k", "l", "x", "y", "z"]],
      ["m", :lost, 0, ["c", "a", "_"], ["a", "b", "c", "k", "l", "m", "x", "y", "z"]],
    ]
    |> test_sequence_of_moves()
  end

  defp test_sequence_of_moves(script) do
    game = Game.new_game("cat")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used
    game
  end
end
