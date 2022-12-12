defmodule AOC2022.Day12 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
    |> Enum.to_list()
    |> do_parse_input(1, %{start: nil, finish: nil, heights: %{}})
  end

  defp do_parse_input([], _i, acc) do
    acc
  end

  defp do_parse_input([line | rest], i, acc) do
    acc = parse_line(line, i, acc)
    do_parse_input(rest, i + 1, acc)
  end

  def parse_line(line, i, acc) do
    do_parse_line(line, i, 1, acc)
  end

  defp do_parse_line([], _i, _j, acc) do
    acc
  end

  defp do_parse_line([c | rest], i, j, acc) do
    acc =
      case c do
        "S" -> Map.put(acc, :start, {i, j})
        "E" -> Map.put(acc, :finish, {i, j})
        _ -> acc
      end

    height =
      case c do
        "S" ->
          1

        "E" ->
          26

        c ->
          [c] = String.to_charlist(c)
          c - ?a + 1
      end

    acc = Map.update!(acc, :heights, fn heights -> Map.put(heights, {i, j}, height) end)
    do_parse_line(rest, i, j + 1, acc)
  end

  def to_graph(heights) do
    do_to_graph(heights, Enum.to_list(heights), %{})
  end

  defp do_to_graph(_heights, [], acc) do
    acc
  end

  defp do_to_graph(heights, [{{x, y}, _height} | rest], acc) do
    acc =
      Map.put(
        acc,
        {x, y},
        descendants({x, y}, heights)
      )

    do_to_graph(heights, rest, acc)
  end

  def descendants({x, y}, heights) do
    height = Map.get(heights, {x, y})

    {x, y}
    |> neighbours()
    |> Enum.map(fn neighbour -> {neighbour, Map.get(heights, neighbour)} end)
    |> Enum.reject(&Kernel.is_nil/1)
    |> Enum.filter(fn {_neighbour, neighbour_height} -> neighbour_height <= height + 1 end)
    |> Enum.map(fn {neighbour, _} -> neighbour end)
  end

  def neighbours({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  def find_shortest_path_length(graph, start, finish, survey \\ []) do
    visited = MapSet.new()
    comp = fn {_coord1, dist1}, {_coord2, dist2} -> dist1 < dist2 end

    queue =
      Heap.new(comp)
      |> Heap.push({start, 0})

    queue =
      Enum.reduce(
        survey,
        queue,
        fn coord, acc -> Heap.push(acc, {coord, 0}) end
      )

    do_find_shortest_path_length(graph, finish, visited, queue)
  end

  def do_find_shortest_path_length(graph, finish, visited, queue) do
    case get_next_node(queue, visited) do
      nil ->
        nil

      {{next, dist}, queue} ->
        if next == finish do
          dist
        else
          visited = MapSet.put(visited, next)
          queue = update_queue(queue, graph, next, dist)
          do_find_shortest_path_length(graph, finish, visited, queue)
        end
    end
  end

  def get_next_node(queue, visited) do
    if Heap.size(queue) == 0 do
      nil
    else
      {{next, dist}, queue} = Heap.pop(queue)

      if MapSet.member?(visited, next) do
        get_next_node(queue, visited)
      else
        {{next, dist}, queue}
      end
    end
  end

  def update_queue(queue, graph, next, dist) do
    Enum.reduce(
      Map.get(graph, next),
      queue,
      fn node, acc ->
        Heap.push(acc, {node, dist + 1})
      end
    )
  end

  def survey(data) do
    graph = to_graph(data.heights)

    lowest =
      MapSet.new(
        data.heights
        |> Enum.filter(fn {_coord, height} -> height == 1 end)
        |> Enum.map(fn {coord, _height} -> coord end)
      )

    find_shortest_path_length(graph, data.start, data.finish, lowest)
  end

  def part1(data) do
    graph = to_graph(data.heights)

    find_shortest_path_length(graph, data.start, data.finish)
  end

  def part2(data) do
    survey(data)
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
