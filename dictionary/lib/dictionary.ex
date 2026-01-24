defmodule Dictionary do

  # Module attribute (to cache words)
  # Created at compile time
  @word_list "assets/words.txt"
    |> File.read!
    |> String.split(~r/\n/, trim: true)

  def random_word do
    @word_list
    |> Enum.random
  end
end
