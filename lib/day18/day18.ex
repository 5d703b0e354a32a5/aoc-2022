defmodule AOC2022.Day18 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def parse_line(line) do
    [_, x, y, z] = Regex.run(~r/(-?\d+),(-?\d+),(-?\d+)/, line)

    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    {z, ""} = Integer.parse(z)

    Vector.scale({x, y, z}, 2)
  end

  def get_side_face_points(center) do
    {x, y, z} = center

    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1}
    ]
    |> MapSet.new()
  end

  def get_side_face_points_with_orientation(center) do
    [
      {1, 0, 0},
      {-1, 0, 0},
      {0, 1, 0},
      {0, -1, 0},
      {0, 0, 1},
      {0, 0, -1}
    ]
    |> Enum.reduce(
      MapSet.new(),
      fn delta, acc ->
        p = Vector.add(center, delta)
        MapSet.put(acc, {p, delta})
      end
    )
  end

  def add_cube(droplets, cube) do
    cube_droplet = get_side_face_points(cube)

    intersecting_droplets =
      Enum.filter(
        droplets,
        fn droplet -> not MapSet.disjoint?(droplet, cube_droplet) end
      )

    merged_droplet = merge_droplets([cube_droplet | intersecting_droplets])

    Enum.reduce(
      intersecting_droplets,
      droplets,
      fn droplet, acc -> MapSet.delete(acc, droplet) end
    )
    |> MapSet.put(merged_droplet)
  end

  def merge_droplets([droplet]) do
    droplet
  end

  def merge_droplets([droplet1 | [droplet2 | rest]]) do
    intersection = MapSet.intersection(droplet1, droplet2)

    droplet =
      MapSet.union(droplet1, droplet2)
      |> MapSet.difference(intersection)

    merge_droplets([droplet | rest])
  end

  def same_surface_points(point, orientations) do
    orientation = Map.get(orientations, point)

    point_candidates(point, orientation)
    |> Enum.map(fn candidates ->
      Enum.find(
        candidates,
        fn candidate ->
          Map.has_key?(orientations, candidate)
        end
      )
    end)
    |> Enum.reject(&is_nil(&1))
  end

  def point_candidates(point, orientation) do
    point_candidates_offsets(orientation)
    |> Enum.map(fn offsets ->
      Enum.map(offsets, fn offset -> Vector.add(point, offset) end)
    end)
  end

  def point_candidates_offsets({x, 0, 0}) do
    [
      [{x, 1, 0}, {0, 2, 0}, {-x, 1, 0}],
      [{x, -1, 0}, {0, -2, 0}, {-x, -1, 0}],
      [{x, 0, 1}, {0, 0, 2}, {-x, 0, 1}],
      [{x, 0, -1}, {0, 0, -2}, {-x, 0, -1}]
    ]
  end

  def point_candidates_offsets({0, y, 0}) do
    [
      [{1, y, 0}, {2, 0, 0}, {1, -y, 0}],
      [{-1, y, 0}, {-2, 0, 0}, {-1, -y, 0}],
      [{0, y, 1}, {0, 0, 2}, {0, -y, 1}],
      [{0, y, -1}, {0, 0, -2}, {0, -y, -1}]
    ]
  end

  def point_candidates_offsets({0, 0, z}) do
    [
      [{1, 0, z}, {2, 0, 0}, {1, 0, -z}],
      [{-1, 0, z}, {-2, 0, 0}, {-1, 0, -z}],
      [{0, 1, z}, {0, 2, 0}, {0, 1, -z}],
      [{0, -1, z}, {0, -2, 0}, {0, -1, -z}]
    ]
  end

  def find_surfaces(points, orientations) do
    do_find_surfaces(Enum.to_list(points), orientations, [], MapSet.new())
  end

  def do_find_surfaces([], _orientations, surfaces, _handled) do
    surfaces
  end

  def do_find_surfaces([point | rest], orientations, surfaces, handled) do
    if MapSet.member?(handled, point) do
      do_find_surfaces(rest, orientations, surfaces, handled)
    else
      surface = expand_surface(point, orientations)
      surfaces = [surface | surfaces]

      handled =
        Enum.reduce(
          surface,
          handled,
          fn point, acc ->
            MapSet.put(acc, point)
          end
        )

      do_find_surfaces(rest, orientations, surfaces, handled)
    end
  end

  def expand_surface(point, orientations) do
    do_expand_surface([point], orientations, MapSet.new(), MapSet.new())
  end

  defp do_expand_surface([], _orientations, surface, _visited) do
    surface
  end

  defp do_expand_surface([point | rest], orientations, surface, visited) do
    if MapSet.member?(visited, point) do
      do_expand_surface(rest, orientations, surface, visited)
    else
      neighbours = same_surface_points(point, orientations)

      surface =
        Enum.reduce(
          neighbours,
          surface,
          fn point, acc -> MapSet.put(acc, point) end
        )

      rest =
        Enum.reduce(
          neighbours,
          rest,
          fn point, acc -> [point | acc] end
        )

      visited = MapSet.put(visited, point)
      do_expand_surface(rest, orientations, surface, visited)
    end
  end

  def part1(cubes) do
    Enum.reduce(
      cubes,
      MapSet.new(),
      fn cube, acc -> add_cube(acc, cube) end
    )
    |> Enum.map(fn droplet -> MapSet.size(droplet) end)
    |> Enum.sum()
  end

  def part2(cubes) do
    orientations =
      Enum.reduce(
        cubes,
        %{},
        fn cube, acc ->
          get_side_face_points_with_orientation(cube)
          |> Enum.reduce(
            acc,
            fn {point, orientation}, acc -> Map.put(acc, point, orientation) end
          )
        end
      )

    Enum.reduce(
      cubes,
      MapSet.new(),
      fn cube, acc -> add_cube(acc, cube) end
    )
    |> Enum.reduce(fn droplet, acc ->
      MapSet.union(acc, droplet)
    end)
    |> Kernel.then(fn points ->
      find_surfaces(points, orientations)
    end)
    |> Enum.map(&MapSet.size(&1))
    |> Enum.max()
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
