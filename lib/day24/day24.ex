defmodule AOC2022.Day24 do
  require Util

  def parse_input(filename) do
    lines =
      filename
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()

    valley_width = String.length(hd(lines)) - 2
    valley_height = Enum.count(lines) - 2

    initial_blizzards =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    %{
      valley_width: valley_width,
      valley_height: valley_height,
      initial_blizzards: initial_blizzards
    }
  end

  def parse_line({line, y}) do
    line
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn {c, x} ->
      case c do
        ">" -> {{x, y}, MapSet.new([{1, 0}])}
        "<" -> {{x, y}, MapSet.new([{-1, 0}])}
        "v" -> {{x, y}, MapSet.new([{0, 1}])}
        "^" -> {{x, y}, MapSet.new([{0, -1}])}
        _ -> nil
      end
    end)
    |> Enum.reject(&Kernel.is_nil/1)
  end

  def draw(pos, blizzards, valley_width, valley_height) do
    for y <- 0..(valley_height + 1) do
      for x <- 0..(valley_width + 1) do
        cond do
          {x, y} == pos ->
            "E"

          x == 0 ->
            "#"

          x == valley_width + 1 ->
            "#"

          y == 0 and x != 1 ->
            "#"

          y == valley_height + 1 and x != valley_width ->
            "#"

          Map.has_key?(blizzards, {x, y}) ->
            case Enum.to_list(Map.get(blizzards, {x, y})) do
              [{1, 0}] -> ">"
              [{-1, 0}] -> "<"
              [{0, 1}] -> "v"
              [{0, -1}] -> "^"
              list -> Enum.count(list)
            end

          true ->
            "."
        end
      end
      |> Enum.join()
    end
  end

  def lcm(a, b) when is_integer(a) and is_integer(b) do
    div(a * b, Integer.gcd(a, b))
  end

  def initialize_blizzards(%{
        valley_width: valley_width,
        valley_height: valley_height,
        initial_blizzards: initial_blizzards
      }) do
    period = lcm(valley_width, valley_height)
    acc = %{0 => initial_blizzards}

    blizzards =
      do_initialize_blizzards(valley_width, valley_height, 0, period, initial_blizzards, acc)

    %{
      blizzards: blizzards,
      period: period
    }
  end

  def do_initialize_blizzards(_valley_width, _valley_height, period, period, _blizzards, acc) do
    acc
  end

  def do_initialize_blizzards(valley_width, valley_height, time, period, blizzards, acc) do
    blizzards = step_blizzards(valley_width, valley_height, blizzards)

    do_initialize_blizzards(
      valley_width,
      valley_height,
      time + 1,
      period,
      blizzards,
      Map.put(acc, time + 1, blizzards)
    )
  end

  def step_blizzards(valley_width, valley_height, blizzards) do
    Enum.reduce(
      blizzards,
      Map.new(),
      fn {pos, directions}, acc ->
        directions
        |> Enum.map(fn direction ->
          step_blizzard(valley_width, valley_height, {pos, direction})
        end)
        |> Enum.reduce(
          acc,
          fn {pos, direction}, acc ->
            Map.update(
              acc,
              pos,
              MapSet.new([direction]),
              &MapSet.put(&1, direction)
            )
          end
        )
      end
    )
  end

  def step_blizzard(valley_width, valley_height, blizzard) do
    {pos, direction} = blizzard
    {x, y} = Vector.add(pos, direction)

    pos =
      cond do
        x == 0 -> {valley_width, y}
        y == 0 -> {x, valley_height}
        x == valley_width + 1 -> {1, y}
        y == valley_height + 1 -> {x, 1}
        true -> {x, y}
      end

    {pos, direction}
  end

  def reachable?({x, y, _minutes}, blizzards, valley_width, valley_height) do
    cond do
      x <= 0 -> false
      x == valley_width + 1 -> false
      y < 0 -> false
      y == 0 and x != 1 -> false
      y == valley_height + 1 and x != valley_width -> false
      y > valley_height + 1 -> false
      true -> not Map.has_key?(blizzards, {x, y})
    end
  end

  def find_shortest_path(blizzards, valley_width, valley_height, period, start, target) do
    queue =
      Heap.new(fn {_, _, minutes_1}, {_, _, minutes_2} ->
        minutes_1 < minutes_2
      end)
      |> Heap.push(start)

    visited = MapSet.new()

    do_find_shortest_path(blizzards, valley_width, valley_height, period, queue, visited, target)
  end

  def do_find_shortest_path(
        blizzards,
        valley_width,
        valley_height,
        period,
        queue,
        visited,
        target
      ) do
    {node, queue} = Heap.pop(queue)
    {x, y, minutes} = node

    cond do
      {x, y} == target ->
        node

      MapSet.member?(visited, node) ->
        do_find_shortest_path(
          blizzards,
          valley_width,
          valley_height,
          period,
          queue,
          visited,
          target
        )

      MapSet.member?(visited, Vector.subtract(node, {0, 0, period})) ->
        visited = MapSet.put(visited, node)

        do_find_shortest_path(
          blizzards,
          valley_width,
          valley_height,
          period,
          queue,
          visited,
          target
        )

      true ->
        queue =
          [
            {x, y, minutes + 1},
            {x + 1, y, minutes + 1},
            {x - 1, y, minutes + 1},
            {x, y + 1, minutes + 1},
            {x, y - 1, minutes + 1}
          ]
          |> Enum.filter(
            &reachable?(
              &1,
              Map.get(blizzards, rem(minutes + 1, period)),
              valley_width,
              valley_height
            )
          )
          |> Enum.reduce(
            queue,
            &Heap.push(&2, &1)
          )

        visited = MapSet.put(visited, node)

        do_find_shortest_path(
          blizzards,
          valley_width,
          valley_height,
          period,
          queue,
          visited,
          target
        )
    end
  end

  def part1(data) do
    %{blizzards: blizzards, period: period} = initialize_blizzards(data)

    {_, _, minutes} =
      find_shortest_path(
        blizzards,
        data.valley_width,
        data.valley_height,
        period,
        {1, 0, 0},
        {data.valley_width, data.valley_height + 1}
      )

    minutes
  end

  def part2(data) do
    %{blizzards: blizzards, period: period} = initialize_blizzards(data)

    first_trip =
      find_shortest_path(
        blizzards,
        data.valley_width,
        data.valley_height,
        period,
        {1, 0, 0},
        {data.valley_width, data.valley_height + 1}
      )

    second_trip =
      find_shortest_path(
        blizzards,
        data.valley_width,
        data.valley_height,
        period,
        first_trip,
        {1, 0}
      )

    third_trip =
      find_shortest_path(
        blizzards,
        data.valley_width,
        data.valley_height,
        period,
        second_trip,
        {data.valley_width, data.valley_height + 1}
      )

    elem(third_trip, 2)
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
