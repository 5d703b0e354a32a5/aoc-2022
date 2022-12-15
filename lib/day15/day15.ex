defmodule AOC2022.Day15 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
  end

  def parse_line(line) do
    %{
      "sensor_x" => sensor_x,
      "sensor_y" => sensor_y,
      "beacon_x" => beacon_x,
      "beacon_y" => beacon_y
    } =
      Regex.named_captures(
        ~r/Sensor at x=(?<sensor_x>-?\d+), y=(?<sensor_y>-?\d+): closest beacon is at x=(?<beacon_x>-?\d+), y=(?<beacon_y>-?\d+)/,
        line
      )

    {sensor_x, ""} = Integer.parse(sensor_x)
    {sensor_y, ""} = Integer.parse(sensor_y)
    {beacon_x, ""} = Integer.parse(beacon_x)
    {beacon_y, ""} = Integer.parse(beacon_y)

    sensor = {sensor_x, sensor_y}
    beacon = {beacon_x, beacon_y}
    distance = manhattan_distance(sensor, beacon)

    edges = [
      {{sensor_x + distance, sensor_y}, {sensor_x, sensor_y + distance}},
      {{sensor_x - distance, sensor_y}, {sensor_x, sensor_y - distance}},
      {{sensor_x, sensor_y + distance}, {sensor_x - distance, sensor_y}},
      {{sensor_x, sensor_y - distance}, {sensor_x + distance, sensor_y}}
    ]

    %{
      sensor: sensor,
      beacon: beacon,
      distance: distance,
      edges: edges
    }
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def intersect?(edge1, edge2) do
    {a1, b1} = edge1
    {a2, b2} = edge2

    orientation(a1, b1, a2) != orientation(a1, b1, b2) and
      orientation(a2, b2, a1) != orientation(a2, b2, b1)
  end

  def orientation({x1, y1}, {x2, y2}, {x3, y3}) do
    sign((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3))
  end

  def intersect(edge1, edge2) do
    {a1, b1} = edge1
    {a2, _b2} = edge2

    v = Vector.subtract(a2, a1)
    w = Vector.subtract(b1, a1)

    if v == {0, 0} or w == {0, 0} do
      a1
    else
      cosalpha = Vector.dot(v, w) / (Vector.norm(v) * Vector.norm(w))
      hypotenuse = Vector.norm(Vector.subtract(a2, a1))
      l = hypotenuse * cosalpha

      w0 = Vector.normalize(w)

      {x, y} = Vector.add(a1, Vector.scale(w0, l))

      {round(x), round(y)}
    end
  end

  def sign(x) do
    cond do
      x > 0 -> 1
      x == 0 -> 0
      true -> -1
    end
  end

  def get_excluded_zone(beacon_data) do
    do_get_excluded_zone(beacon_data, MapSet.new())
  end

  defp do_get_excluded_zone([], acc) do
    acc
  end

  defp do_get_excluded_zone([beacon_datum | rest], acc) do
    acc = exclude_beacon(beacon_datum, acc)
    do_get_excluded_zone(rest, acc)
  end

  def exclude_beacon(%{sensor: sensor, distance: distance}, acc) do
    {sensor_x, sensor_y} = sensor

    x_min = sensor_x - distance
    x_max = sensor_x + distance
    y_min = sensor_y - distance
    y_max = sensor_y + distance

    for x <- x_min..x_max,
        y <- y_min..y_max,
        manhattan_distance(sensor, {x, y}) <= distance,
        reduce: acc do
      acc -> MapSet.put(acc, {x, y})
    end
  end

  def calculate_x_min(sensor_data) do
    sensor_data
    |> Enum.map(fn %{beacon: beacon, sensor: sensor} ->
      distance = manhattan_distance(beacon, sensor)
      {x, _y} = sensor
      x - distance
    end)
    |> Enum.min()
  end

  def calculate_x_max(sensor_data) do
    sensor_data
    |> Enum.map(fn %{beacon: beacon, sensor: sensor} ->
      distance = manhattan_distance(beacon, sensor)
      {x, _y} = sensor
      x + distance
    end)
    |> Enum.max()
  end

  def range_edge_intersections(sensor_data) do
    do_range_edge_intersections(sensor_data, MapSet.new())
  end

  def do_range_edge_intersections([_sensor_datum], acc) do
    acc
  end

  def do_range_edge_intersections([sensor_datum | rest], acc) do
    acc =
      Enum.reduce(
        rest,
        acc,
        fn other_sensor_datum, acc ->
          update_intersections(sensor_datum, other_sensor_datum, acc)
        end
      )

    do_range_edge_intersections(rest, acc)
  end

  def update_intersections(sensor_datum1, sensor_datum2, acc) do
    edges1 = sensor_datum1.edges
    edges2 = sensor_datum2.edges

    for edge1 <- edges1, reduce: acc do
      acc ->
        for edge2 <- edges2, reduce: acc do
          acc ->
            if intersect?(edge1, edge2) do
              MapSet.put(acc, intersect(edge1, edge2))
            else
              acc
            end
        end
    end
  end

  def find_diamonds(point_map) do
    do_find_diamonds(point_map, [])
  end

  def do_find_diamonds([_, _], acc) do
    acc
  end

  def do_find_diamonds([{x0, ys0} | rest], acc) do
    [{_x1, ys1}, {_x2, ys2}] = Enum.take(rest, 2)

    acc =
      Enum.reduce(
        ys0,
        acc,
        fn y, acc ->
          if diamond?(y, ys1, ys2) do
            [{x0 + 1, y} | acc]
          else
            acc
          end
        end
      )

    do_find_diamonds(rest, acc)
  end

  def diamond?(y, ys1, ys2) do
    MapSet.member?(ys1, y + 1) and
      MapSet.member?(ys1, y - 1) and
      not MapSet.member?(ys1, y) and
      MapSet.member?(ys2, y)
  end

  def seen?(point, sensor_data) do
    Enum.any?(
      sensor_data,
      fn sensor_datum -> inside_range?(point, sensor_datum) end
    )
  end

  def inside_range?(point, %{sensor: sensor, distance: distance}) do
    manhattan_distance(point, sensor) <= distance
  end

  def part1(sensor_data, y_to_check) do
    x_min = calculate_x_min(sensor_data)
    x_max = calculate_x_max(sensor_data)

    beacons =
      Enum.reduce(
        sensor_data,
        MapSet.new(),
        fn %{beacon: beacon}, acc ->
          MapSet.put(acc, beacon)
        end
      )

    x_min..x_max
    |> Enum.map(fn x -> {x, y_to_check} end)
    |> Enum.filter(fn coord -> seen?(coord, sensor_data) end)
    |> Enum.reject(fn coord -> MapSet.member?(beacons, coord) end)
    |> Enum.count()
  end

  def part2(sensor_data, _limit) do
    range_edge_intersections(sensor_data)
    |> Enum.sort()
    |> Enum.chunk_by(fn {x, _y} -> x end)
    |> Enum.reverse()
    |> Enum.reduce(
      [],
      fn chunk = [{x, _y} | _], acc ->
        ys = Enum.reduce(chunk, MapSet.new(), fn {_x, y}, acc -> MapSet.put(acc, y) end)
        [{x, ys} | acc]
      end
    )
    |> find_diamonds()
    |> Enum.reject(fn coord -> seen?(coord, sensor_data) end)
    |> Kernel.then(fn [{x, y}] -> x * 4_000_000 + y end)
  end

  def main() do
    filename = Util.relative_filename("input")

    data = parse_input(filename)

    IO.puts("Part 1")

    part1(data, 2_000_000)
    |> IO.puts()

    IO.puts("")

    IO.puts("Part 2")

    part2(data, 4_000_000)
    |> IO.puts()
  end
end
