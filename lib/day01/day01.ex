defmodule AOC2022.Day01 do
  require Util

  def parse_input(filename) do
    File.stream!(filename)
    |> Stream.map(fn s -> String.trim(s) end)
    |> Stream.chunk_by(fn s -> s != "" end)
    |> Stream.reject(fn s -> s == [""] end)
    |> Stream.map(fn nums -> Enum.map(nums, fn num -> elem(Integer.parse(num), 0) end) end)
    |> Enum.to_list()
  end

  def part1(data) do
    data
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part2(data) do
    data
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
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
