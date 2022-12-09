defmodule AOC2022.Day09 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
  end

  def parse_line(line) do
    [direction, count] = String.split(line, " ")

    direction =
      case direction do
        "U" -> :up
        "D" -> :down
        "L" -> :left
        "R" -> :right
      end

    {count, ""} = Integer.parse(count)
    {direction, count}
  end

  def update_head({x, y}, :up), do: {x, y + 1}
  def update_head({x, y}, :down), do: {x, y - 1}
  def update_head({x, y}, :left), do: {x - 1, y}
  def update_head({x, y}, :right), do: {x + 1, y}

  def update_tail(tail = {xt, yt}, {xh, yh}) do
    do_update_tail(tail, {xh - xt, yh - yt})
  end

  defp do_update_tail({x, y}, {2, 0}), do: {x + 1, y}
  defp do_update_tail({x, y}, {-2, 0}), do: {x - 1, y}
  defp do_update_tail({x, y}, {0, 2}), do: {x, y + 1}
  defp do_update_tail({x, y}, {0, -2}), do: {x, y - 1}

  defp do_update_tail({x, y}, {1, 2}), do: {x + 1, y + 1}
  defp do_update_tail({x, y}, {2, 1}), do: {x + 1, y + 1}
  defp do_update_tail({x, y}, {2, 2}), do: {x + 1, y + 1}

  defp do_update_tail({x, y}, {-1, -2}), do: {x - 1, y - 1}
  defp do_update_tail({x, y}, {-2, -1}), do: {x - 1, y - 1}
  defp do_update_tail({x, y}, {-2, -2}), do: {x - 1, y - 1}

  defp do_update_tail({x, y}, {1, -2}), do: {x + 1, y - 1}
  defp do_update_tail({x, y}, {2, -1}), do: {x + 1, y - 1}
  defp do_update_tail({x, y}, {2, -2}), do: {x + 1, y - 1}

  defp do_update_tail({x, y}, {-1, 2}), do: {x - 1, y + 1}
  defp do_update_tail({x, y}, {-2, 1}), do: {x - 1, y + 1}
  defp do_update_tail({x, y}, {-2, 2}), do: {x - 1, y + 1}

  defp do_update_tail(tail, _), do: tail

  def update_rope([head | rest], direction) do
    head = update_head(head, direction)
    do_update_rope(rest, [head])
  end

  defp do_update_rope([], acc) do
    Enum.reverse(acc)
  end

  defp do_update_rope([next | rest], acc = [parent | _]) do
    next = update_tail(next, parent)
    do_update_rope(rest, [next | acc])
  end

  def get_rope_end(rope) do
    do_get_rope_end(rope)
  end

  defp do_get_rope_end([tail]) do
    tail
  end

  defp do_get_rope_end([_ | rest]) do
    do_get_rope_end(rest)
  end

  def simulate_rope([], _rope, visited_by_tail) do
    MapSet.size(visited_by_tail)
  end

  def simulate_rope([{_direction, 0} | rest], rope, visited_by_tail) do
    simulate_rope(rest, rope, visited_by_tail)
  end

  def simulate_rope([{direction, count} | rest], rope, visited_by_tail) do
    rope = update_rope(rope, direction)
    visited_by_tail = MapSet.put(visited_by_tail, get_rope_end(rope))
    simulate_rope([{direction, count - 1} | rest], rope, visited_by_tail)
  end

  def part1(moves) do
    rope =
      for _ <- 1..2 do
        {0, 0}
      end

    simulate_rope(
      moves,
      rope,
      MapSet.new()
    )
  end

  def part2(moves) do
    rope =
      for _ <- 1..10 do
        {0, 0}
      end

    simulate_rope(
      moves,
      rope,
      MapSet.new()
    )
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
