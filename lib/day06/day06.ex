defmodule AOC2022.Day06 do
  require Util

  def parse_input(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.codepoints()
  end

  def is_start_of_packet_marker?(seq, n) do
    set = MapSet.new(seq)
    MapSet.size(set) == n
  end

  def chars_before_marker(data, len) do
    data
    |> Stream.chunk_every(len, 1)
    |> Stream.take_while(fn seq -> not is_start_of_packet_marker?(seq, len) end)
    |> Enum.count()
    |> Kernel.then(&(&1 + len))
  end

  def part1(data) do
    data
    |> chars_before_marker(4)
  end

  def part2(data) do
    data
    |> chars_before_marker(14)
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
