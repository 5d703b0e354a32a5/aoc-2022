defmodule AOC2022.Day14 do
  require Util

  @sand_source_x 500
  @sand_source_y 0

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.reduce(
      MapSet.new(),
      fn rock_from_line, acc ->
        MapSet.union(acc, rock_from_line)
      end
    )
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn coord ->
      [x, y] = String.split(coord, ",")
      {x, ""} = Integer.parse(x)
      {y, ""} = Integer.parse(y)
      {x, y}
    end)
    |> do_parse_line(MapSet.new())
  end

  defp do_parse_line([_coord], acc) do
    acc
  end

  defp do_parse_line([{x1, y}, {x2, y} | rest], acc) do
    acc =
      Enum.reduce(
        x1..x2,
        acc,
        fn x, acc ->
          MapSet.put(acc, {x, y})
        end
      )

    do_parse_line([{x2, y} | rest], acc)
  end

  defp do_parse_line([{x, y1}, {x, y2} | rest], acc) do
    acc =
      Enum.reduce(
        y1..y2,
        acc,
        fn y, acc ->
          MapSet.put(acc, {x, y})
        end
      )

    do_parse_line([{x, y2} | rest], acc)
  end

  def add_sand(rock, sand, halt?) do
    do_add_sand(rock, sand, halt?, @sand_source_x, @sand_source_y)
  end

  defp do_add_sand(rock, sand, halt?, x, y) do
    cond do
      halt?.(x, y) ->
        :halt

      blocked?(rock, sand, x, y) ->
        :halt

      not blocked?(rock, sand, x, y + 1) ->
        do_add_sand(rock, sand, halt?, x, y + 1)

      not blocked?(rock, sand, x - 1, y + 1) ->
        do_add_sand(rock, sand, halt?, x - 1, y + 1)

      not blocked?(rock, sand, x + 1, y + 1) ->
        do_add_sand(rock, sand, halt?, x + 1, y + 1)

      true ->
        {:ok, MapSet.put(sand, {x, y})}
    end
  end

  def blocked?(rock, sand, x, y) do
    coord = {x, y}
    MapSet.member?(rock, coord) or MapSet.member?(sand, coord)
  end

  def count_sand_until_halt(rock, halt?) do
    do_count_sand_until_halt(rock, MapSet.new(), halt?, 0)
  end

  defp do_count_sand_until_halt(rock, sand, halt?, count) do
    case add_sand(rock, sand, halt?) do
      :halt -> count
      {:ok, sand} -> do_count_sand_until_halt(rock, sand, halt?, count + 1)
    end
  end

  def get_y_max(coords) do
    coords
    |> Enum.max_by(fn {_x, y} -> y end)
    |> Kernel.then(&elem(&1, 1))
  end

  def part1(rock) do
    y_max = get_y_max(rock)

    halt? = fn _x, y -> y >= y_max end

    count_sand_until_halt(rock, halt?)
  end

  def part2(rock) do
    y_max = get_y_max(rock)
    y_max = y_max + 2

    rock =
      Enum.reduce(
        (-y_max - 1 + @sand_source_x)..(y_max + 1 + @sand_source_x),
        rock,
        fn x, acc -> MapSet.put(acc, {x, y_max}) end
      )

    count_sand_until_halt(rock, fn _x, _y -> false end)
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
