defmodule AOC2022.Day02 do
  require Util

  @points_shape [
    rock: 1,
    paper: 2,
    scissors: 3
  ]

  @points_outcome [
    lose: 0,
    draw: 3,
    win: 6
  ]

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def parse_line(<<first::binary-size(1), " ", second::binary-size(1)>>) do
    first =
      case first do
        "A" -> :rock
        "B" -> :paper
        "C" -> :scissors
      end

    second =
      case second do
        "X" -> :X
        "Y" -> :Y
        "Z" -> :Z
      end

    {first, second}
  end

  def determine_outcome(shape, shape) do
    :draw
  end

  def determine_outcome(:rock, :paper) do
    :win
  end

  def determine_outcome(:rock, :scissors) do
    :lose
  end

  def determine_outcome(:paper, :rock) do
    :lose
  end

  def determine_outcome(:paper, :scissors) do
    :win
  end

  def determine_outcome(:scissors, :rock) do
    :win
  end

  def determine_outcome(:scissors, :paper) do
    :lose
  end

  def round_points({first, second}) do
    outcome = determine_outcome(first, second)
    @points_shape[second] + @points_outcome[outcome]
  end

  def interpret_as_shape({first, :X}), do: {first, :rock}
  def interpret_as_shape({first, :Y}), do: {first, :paper}
  def interpret_as_shape({first, :Z}), do: {first, :scissors}

  def interpret_as_outcome({first, :X}), do: {first, :lose}
  def interpret_as_outcome({first, :Y}), do: {first, :draw}
  def interpret_as_outcome({first, :Z}), do: {first, :win}

  def determine_second_shape(shape, :draw) do
    shape
  end

  def determine_second_shape(:rock, :lose) do
    :scissors
  end

  def determine_second_shape(:rock, :win) do
    :paper
  end

  def determine_second_shape(:paper, :lose) do
    :rock
  end

  def determine_second_shape(:paper, :win) do
    :scissors
  end

  def determine_second_shape(:scissors, :lose) do
    :paper
  end

  def determine_second_shape(:scissors, :win) do
    :rock
  end

  def part1(data) do
    data
    |> Stream.map(&interpret_as_shape/1)
    |> Stream.map(&round_points/1)
    |> Enum.sum()
  end

  def part2(data) do
    data
    |> Stream.map(&interpret_as_outcome/1)
    |> Stream.map(fn {first_shape, outcome} ->
      second_shape = determine_second_shape(first_shape, outcome)
      {first_shape, second_shape}
    end)
    |> Stream.map(&round_points/1)
    |> Enum.sum()
  end

  def main() do
    filename = Util.relative_filename("input")
    data = parse_input(filename)
    IO.puts("Part 1")

    part1(data)
    |> IO.puts()

    IO.puts("")

    IO.puts("Part 2")

    part2(data)
    |> IO.puts()

    IO.puts("")
  end
end
