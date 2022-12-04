defmodule AOC2022.Day04 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&parse_range/1)
  end

  def parse_range(range_string) do
    range_string
    |> String.split("-")
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
    |> List.to_tuple()
  end

  def is_including?({low1, high1}, {low2, high2}) do
    low1 <= low2 and high1 >= high2
  end

  def is_overlapping?({low1, high1}, {low2, high2}) do
    (low2 <= low1 and high2 >= low1) or
      (low2 >= low1 and high2 <= high1) or
      (low2 <= high1 and high2 >= high1)
  end

  def part1(data) do
    data
    |> Stream.filter(fn [range1, range2] ->
      is_including?(range1, range2) or
        is_including?(range2, range1)
    end)
    |> Enum.count()
  end

  def part2(data) do
    data
    |> Stream.filter(fn [range1, range2] ->
      is_overlapping?(range1, range2)
    end)
    |> Enum.count()
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
