defmodule AOC2022.Day03 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def parse_line(line) do
    n = String.length(line)
    front = String.slice(line, 0, div(n, 2))
    back = String.slice(line, div(n, 2), div(n, 2))
    {front, back}
  end

  def find_common_item({front, back}) do
    to_set = fn s ->
      s
      |> String.to_charlist()
      |> MapSet.new()
    end

    front_set = to_set.(front)
    back_set = to_set.(back)

    [common] =
      MapSet.intersection(front_set, back_set)
      |> MapSet.to_list()

    common
  end

  def to_priority(c) when ?a <= c and c <= ?z do
    c - ?a + 1
  end

  def to_priority(c) when ?A <= c and c <= ?Z do
    c - ?A + 26 + 1
  end

  def rucksack_to_set({front, back}) do
    (front <> back)
    |> String.to_charlist()
    |> MapSet.new()
  end

  def find_badge([first | rest]) do
    [badge] =
      Enum.reduce(rest, first, &MapSet.intersection/2)
      |> MapSet.to_list()

    badge
  end

  def part1(rucksacks) do
    rucksacks
    |> Stream.map(&find_common_item/1)
    |> Stream.map(&to_priority/1)
    |> Enum.sum()
  end

  def part2(rucksacks) do
    rucksacks
    |> Stream.map(&rucksack_to_set/1)
    |> Stream.chunk_every(3)
    |> Stream.map(&find_badge/1)
    |> Stream.map(&to_priority/1)
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
  end
end
