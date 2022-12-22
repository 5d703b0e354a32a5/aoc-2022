defmodule AOC2022.Day22 do
  require Util

  @orientations %{
    up: {0, -1},
    down: {0, 1},
    left: {-1, 0},
    right: {1, 0}
  }

  @rotations %{
    xy: {
      {0, -1, 0},
      {1, 0, 0},
      {0, 0, 1}
    },
    yx: {
      {0, 1, 0},
      {-1, 0, 0},
      {0, 0, 1}
    },
    xz: {
      {0, 0, 1},
      {0, 1, 0},
      {-1, 0, 0}
    },
    zx: {
      {0, 0, -1},
      {0, 1, 0},
      {1, 0, 0}
    },
    yz: {
      {1, 0, 0},
      {0, 0, -1},
      {0, 1, 0}
    },
    zy: {
      {1, 0, 0},
      {0, 0, 1},
      {0, -1, 0}
    }
  }

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.reject(&(&1 == [""]))
    |> Enum.to_list()
    |> Kernel.then(fn [map_input, instructions_input] ->
      {
        parse_map(map_input),
        parse_instructions(instructions_input)
      }
    end)
  end

  def parse_map(map_input) do
    for {line, y} <- Enum.with_index(map_input, 1),
        {char, x} <- Enum.with_index(String.codepoints(line), 1),
        reduce: %{} do
      acc ->
        tile =
          case char do
            "." -> :open
            "#" -> :wall
            " " -> nil
          end

        case tile do
          nil -> acc
          _ -> Map.put(acc, {x, y}, tile)
        end
    end
  end

  def parse_instructions([instructions_input]) do
    do_parse_instructions(instructions_input, [])
  end

  defp do_parse_instructions("", acc) do
    Enum.reverse(acc)
  end

  defp do_parse_instructions("L" <> rest, acc) do
    do_parse_instructions(rest, [:L | acc])
  end

  defp do_parse_instructions("R" <> rest, acc) do
    do_parse_instructions(rest, [:R | acc])
  end

  defp do_parse_instructions(input, acc) do
    {n, rest} = Integer.parse(input)
    do_parse_instructions(rest, [n | acc])
  end

  def apply_instructions(state, _tiles, []) do
    state
  end

  def apply_instructions(state, tiles, [instruction | rest]) do
    apply_instructions(update(state, tiles, instruction), tiles, rest)
  end

  def update(state, _tiles, 0) do
    state
  end

  def update(state = {_position, orientation}, tiles, steps) when is_integer(steps) do
    case next_tile(tiles, state) do
      {_, :wall} ->
        state

      {position, :open} ->
        update({position, orientation}, tiles, steps - 1)
    end
  end

  def update({position, orientation}, _tiles, turn) do
    {position, change_orientation(orientation, turn)}
  end

  def change_orientation(:up, :L), do: :left
  def change_orientation(:left, :L), do: :down
  def change_orientation(:down, :L), do: :right
  def change_orientation(:right, :L), do: :up

  def change_orientation(:up, :R), do: :right
  def change_orientation(:right, :R), do: :down
  def change_orientation(:down, :R), do: :left
  def change_orientation(:left, :R), do: :up

  def next_tile(tiles, state) do
    next_pos = get_next_pos(tiles, state)
    tile = Map.get(tiles, next_pos)
    {next_pos, tile}
  end

  def get_next_pos(tiles, state = {pos, orientation}) do
    delta = Map.get(@orientations, orientation)

    maybe_next_pos = Vector.add(pos, delta)

    if Map.has_key?(tiles, maybe_next_pos) do
      maybe_next_pos
    else
      wrap_around(Map.keys(tiles), state)
    end
  end

  def wrap_around(positions, {{x, _y}, :up}) do
    positions
    |> Enum.filter(fn {tile_x, _tile_y} -> tile_x == x end)
    |> Enum.max_by(fn {_tile_x, tile_y} -> tile_y end)
  end

  def wrap_around(positions, {{x, _y}, :down}) do
    positions
    |> Enum.filter(fn {tile_x, _tile_y} -> tile_x == x end)
    |> Enum.min_by(fn {_tile_x, tile_y} -> tile_y end)
  end

  def wrap_around(positions, {{_x, y}, :right}) do
    positions
    |> Enum.filter(fn {_tile_x, tile_y} -> tile_y == y end)
    |> Enum.min_by(fn {tile_x, _tile_y} -> tile_x end)
  end

  def wrap_around(positions, {{_x, y}, :left}) do
    positions
    |> Enum.filter(fn {_tile_x, tile_y} -> tile_y == y end)
    |> Enum.max_by(fn {tile_x, _tile_y} -> tile_x end)
  end

  def calculate_password({{col, row}, orientation}) do
    1000 * row + 4 * col + get_orientation_value(orientation)
  end

  def get_orientation_value(:right), do: 0
  def get_orientation_value(:down), do: 1
  def get_orientation_value(:left), do: 2
  def get_orientation_value(:up), do: 3

  def initialize_state(tiles) do
    position =
      tiles
      |> Enum.filter(fn {{_x, y}, _tile} -> y == 1 end)
      |> Enum.min_by(fn {{x, _y}, _tile} -> x end)
      |> Kernel.then(&elem(&1, 0))

    {position, :right}
  end

  # x = const surfaces
  #
  def get_next_state_3d({{1, y, z}, {-1, 0, 0}}, cube_size) do
    cond do
      z == 0 ->
        {{0, y, 1}, {0, 0, 1}}

      z == cube_size + 1 ->
        {{0, y, cube_size}, {0, 0, -1}}

      y == 0 ->
        {{0, 1, z}, {0, 1, 0}}

      y == cube_size + 1 ->
        {{0, cube_size, z}, {0, -1, 0}}
    end
  end

  def get_next_state_3d({{cube_size, y, z}, {1, 0, 0}}, cube_size) do
    cond do
      z == 0 ->
        {{cube_size + 1, y, 1}, {0, 0, 1}}

      z == cube_size + 1 ->
        {{cube_size + 1, y, cube_size}, {0, 0, -1}}

      y == 0 ->
        {{cube_size + 1, 1, z}, {0, 1, 0}}

      y == cube_size + 1 ->
        {{cube_size + 1, cube_size, z}, {0, -1, 0}}
    end
  end

  # y = const surfaces

  def get_next_state_3d({{x, 1, z}, {0, -1, 0}}, cube_size) do
    cond do
      x == 0 ->
        {{1, 0, z}, {1, 0, 0}}

      x == cube_size + 1 ->
        {{cube_size, 0, z}, {-1, 0, 0}}

      z == 0 ->
        {{x, 0, 1}, {0, 0, 1}}

      z == cube_size + 1 ->
        {{x, 0, cube_size}, {0, 0, -1}}
    end
  end

  def get_next_state_3d({{x, cube_size, z}, {0, 1, 0}}, cube_size) do
    cond do
      x == 0 ->
        {{1, cube_size + 1, z}, {1, 0, 0}}

      x == cube_size + 1 ->
        {{cube_size, cube_size + 1, z}, {-1, 0, 0}}

      z == 0 ->
        {{x, cube_size + 1, 1}, {0, 0, 1}}

      z == cube_size + 1 ->
        {{x, cube_size + 1, cube_size}, {0, 0, -1}}
    end
  end

  # z = const surfaces

  def get_next_state_3d({{x, y, 1}, {0, 0, -1}}, cube_size) do
    cond do
      x == 0 ->
        {{1, y, 0}, {1, 0, 0}}

      x == cube_size + 1 ->
        {{cube_size, y, 0}, {-1, 0, 0}}

      y == 0 ->
        {{x, 1, 0}, {0, 1, 0}}

      y == cube_size + 1 ->
        {{x, cube_size, 0}, {0, -1, 0}}
    end
  end

  def get_next_state_3d({{x, y, cube_size}, {0, 0, 1}}, cube_size) do
    cond do
      x == 0 ->
        {{1, y, cube_size + 1}, {1, 0, 0}}

      x == cube_size + 1 ->
        {{cube_size, y, cube_size + 1}, {-1, 0, 0}}

      y == 0 ->
        {{x, 1, cube_size + 1}, {0, 1, 0}}

      y == cube_size + 1 ->
        {{x, cube_size, cube_size + 1}, {0, -1, 0}}
    end
  end

  # generic case

  def get_next_state_3d({pos, direction}, _cube_size) do
    {Vector.add(pos, direction), direction}
  end

  def turn_3d({position, orientation}, :L, cube_size) do
    {x, y, z} = position

    orientation =
      cond do
        x == cube_size + 1 ->
          Vector.transform(orientation, @rotations.yz)

        x == 0 ->
          Vector.transform(orientation, @rotations.zy)

        y == cube_size + 1 ->
          Vector.transform(orientation, @rotations.xz)

        y == 0 ->
          Vector.transform(orientation, @rotations.zx)

        z == cube_size + 1 ->
          Vector.transform(orientation, @rotations.xy)

        z == 0 ->
          Vector.transform(orientation, @rotations.yx)
      end

    {position, orientation}
  end

  def turn_3d({position, orientation}, :R, cube_size) do
    {x, y, z} = position

    orientation =
      cond do
        x == cube_size + 1 ->
          Vector.transform(orientation, @rotations.zy)

        x == 0 ->
          Vector.transform(orientation, @rotations.yz)

        y == cube_size + 1 ->
          Vector.transform(orientation, @rotations.zx)

        y == 0 ->
          Vector.transform(orientation, @rotations.xz)

        z == cube_size + 1 ->
          Vector.transform(orientation, @rotations.yx)

        z == 0 ->
          Vector.transform(orientation, @rotations.xy)
      end

    {position, orientation}
  end

  def turn_2d({position, {1, 0}}, :L), do: {position, {0, -1}}
  def turn_2d({position, {0, -1}}, :L), do: {position, {-1, 0}}
  def turn_2d({position, {-1, 0}}, :L), do: {position, {0, 1}}
  def turn_2d({position, {0, 1}}, :L), do: {position, {1, 0}}

  def turn_2d({position, {1, 0}}, :R), do: {position, {0, -1}}
  def turn_2d({position, {0, 1}}, :R), do: {position, {1, 0}}
  def turn_2d({position, {-1, 0}}, :R), do: {position, {0, 1}}
  def turn_2d({position, {0, -1}}, :R), do: {position, {-1, 0}}

  def convert_map_to_cube(map) do
    cube_size = get_cube_size(map)

    visited = :ets.new(:visited, [])
    cube_map = :ets.new(:cube_map, [])
    map_2d_coordinates = :ets.new(:map_2d_coordinates, [])

    initial_state_3d = initialize_state_3d(cube_size)

    {initial_position, _} = initialize_state(map)
    initial_direction = {1, 0}

    state = {
      {initial_position, initial_direction},
      initial_state_3d
    }

    explore(state, map, visited, cube_map, map_2d_coordinates, cube_size)

    {cube_map, map_2d_coordinates}
  end

  def explore(
        state = {state_2d, state_3d},
        map_2d,
        visited_2d,
        map_3d,
        map_2d_coordinates,
        cube_size
      ) do
    {position_2d, _orienation_2d} = state_2d
    {position_3d, _orienation_3d} = state_3d

    if :ets.member(visited_2d, position_2d) do
      nil
    else
      :ets.insert(visited_2d, {position_2d, :visited})
      :ets.insert(map_3d, {position_3d, Map.get(map_2d, position_2d)})
      :ets.insert(map_2d_coordinates, {position_3d, state_2d})

      # rotate 0 times
      rotate_0 = state
      step_0 = step_forward(rotate_0, map_2d, cube_size)

      if not is_nil(step_0) do
        explore(step_0, map_2d, visited_2d, map_3d, map_2d_coordinates, cube_size)
      end

      # rotate 1 times
      rotate_1 = rotate(rotate_0, :L, cube_size)
      step_1 = step_forward(rotate_1, map_2d, cube_size)

      if not is_nil(step_1) do
        explore(step_1, map_2d, visited_2d, map_3d, map_2d_coordinates, cube_size)
      end

      # rotate 2 times
      rotate_2 = rotate(rotate_1, :L, cube_size)
      step_2 = step_forward(rotate_2, map_2d, cube_size)

      if not is_nil(step_2) do
        explore(step_2, map_2d, visited_2d, map_3d, map_2d_coordinates, cube_size)
      end

      # rotate 3 times
      rotate_3 = rotate(rotate_2, :L, cube_size)
      step_3 = step_forward(rotate_3, map_2d, cube_size)

      if not is_nil(step_3) do
        explore(step_3, map_2d, visited_2d, map_3d, map_2d_coordinates, cube_size)
      end
    end
  end

  def rotate({state_2d, state_3d}, direction, cube_size) do
    {
      turn_2d(state_2d, direction),
      turn_3d(state_3d, direction, cube_size)
    }
  end

  def step_forward({state_2d, state_3d}, map_2d, cube_size) do
    {position_2d, orientation_2d} = state_2d

    maybe_new_position_2d = Vector.add(position_2d, orientation_2d)

    if Map.has_key?(map_2d, maybe_new_position_2d) do
      new_state_3d = get_next_state_3d(state_3d, cube_size)

      {
        {maybe_new_position_2d, orientation_2d},
        new_state_3d
      }
    else
      nil
    end
  end

  def get_cube_size(map) do
    max_x =
      map
      |> Map.keys()
      |> Enum.max_by(&elem(&1, 0))
      |> Kernel.then(&elem(&1, 0))

    max_y =
      map
      |> Map.keys()
      |> Enum.max_by(&elem(&1, 1))
      |> Kernel.then(&elem(&1, 1))

    Integer.gcd(max_x, max_y)
  end

  def initialize_state_3d(cube_size) do
    {
      {1, 1, cube_size + 1},
      {0, 1, 0}
    }
  end

  def apply_instruction_3d(state, _map_3d, cube_size, :L) do
    turn_3d(state, :L, cube_size)
  end

  def apply_instruction_3d(state, _map_3d, cube_size, :R) do
    turn_3d(state, :R, cube_size)
  end

  def apply_instruction_3d(state, _map_3d, _cube_size, 0) do
    state
  end

  def apply_instruction_3d(state, map_3d, cube_size, n) do
    maybe_next_state = get_next_state_3d(state, cube_size)
    {position_3d, _} = maybe_next_state

    case :ets.lookup(map_3d, position_3d) do
      [{_, :wall}] -> state
      [{_, :open}] -> apply_instruction_3d(maybe_next_state, map_3d, cube_size, n - 1)
    end
  end

  def invert_orientation_3d({position_3d, orienation_3d}) do
    {
      position_3d,
      case orienation_3d do
        {1, 0, 0} -> {-1, 0, 0}
        {-1, 0, 0} -> {1, 0, 0}
        {0, 1, 0} -> {0, -1, 0}
        {0, -1, 0} -> {0, 1, 0}
        {0, 0, 1} -> {0, 0, -1}
        {0, 0, -1} -> {0, 0, 1}
      end
    }
  end

  def reconstruct_orientation_2d(state_3d, map_2d_coordinates, cube_size) do
    {position_3d, _} = state_3d
    [{_, {coord_2d, _}}] = :ets.lookup(map_2d_coordinates, position_3d)

    {next_position_3d, _} = get_next_state_3d(state_3d, cube_size)
    [{_, {next_coord_2d, _}}] = :ets.lookup(map_2d_coordinates, next_position_3d)

    maybe_orientation =
      case Vector.subtract(next_coord_2d, coord_2d) do
        {1, 0} -> :right
        {-1, 0} -> :left
        {0, 1} -> :down
        {0, -1} -> :up
        _ -> nil
      end

    if is_nil(maybe_orientation) do
      state_3d = invert_orientation_3d(state_3d)
      {prev_position_3d, _} = get_next_state_3d(state_3d, cube_size)
      [{_, {prev_coord_2d, _}}] = :ets.lookup(map_2d_coordinates, prev_position_3d)

      case Vector.subtract(coord_2d, prev_coord_2d) do
        {1, 0} -> :right
        {-1, 0} -> :left
        {0, 1} -> :down
        {0, -1} -> :up
      end
    else
      maybe_orientation
    end
  end

  def part1({tiles, instructions}) do
    initialize_state(tiles)
    |> Kernel.then(&apply_instructions(&1, tiles, instructions))
    |> Kernel.then(&calculate_password(&1))
  end

  def part2({map, instructions}) do
    cube_size = get_cube_size(map)

    {map_3d, map_2d_coordinates} = convert_map_to_cube(map)

    instructions
    |> Enum.reduce(
      initialize_state_3d(cube_size),
      fn instruction, acc ->
        apply_instruction_3d(acc, map_3d, cube_size, instruction)
      end
    )
    |> Kernel.then(fn state_3d ->
      {position_3d, _} = state_3d
      [{_, state_2d}] = :ets.lookup(map_2d_coordinates, position_3d)
      {position_2d, _orientation_2d} = state_2d

      orientation_2d = reconstruct_orientation_2d(state_3d, map_2d_coordinates, cube_size)

      calculate_password({position_2d, orientation_2d})
    end)
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
