defmodule AOC2022.Day17 do
  require Util

  @width 7

  def parse_input(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(fn
      ">" -> :right
      "<" -> :left
    end)
    |> CircleBuffer.new()
  end

  def new_rock(0, height) do
    # ####
    [{0,0}, {1,0}, {2,0}, {3,0}]
    |> translate_rock({2, 0})
    |> translate_rock({0, height + 3})
  end

  def new_rock(1, height) do
    # .#.
    # ###
    # .#.
    [{1,0}, {0,1}, {1,1}, {2,1}, {1, 2}]
    |> translate_rock({2, 0})
    |> translate_rock({0, height + 3})
  end

  def new_rock(2, height) do
    # ..#
    # ..#
    # ###
    [{0,0}, {1,0}, {2,0}, {2,1}, {2, 2}]
    |> translate_rock({2, 0})
    |> translate_rock({0, height + 3})
  end

  def new_rock(3, height) do
    # #
    # #
    # #
    # #
    [{0,0}, {0,1}, {0,2}, {0,3}]
    |> translate_rock({2, 0})
    |> translate_rock({0, height + 3})
  end

  def new_rock(4, height) do
    # ##
    # ##
    [{0,0}, {1,0}, {0,1}, {1,1}]
    |> translate_rock({2, 0})
    |> translate_rock({0, height + 3})
  end

  def update_state(state, i) do
    rock = new_rock(rem(i - 1, 5), state.height)
    drop_rock(state, rock) 
  end

  def drop_rock(state, rock) do
    #draw(state, rock)
    {push, pushes} = CircleBuffer.next(state.pushes)
    state = Map.replace!(state, :pushes, pushes)
    rock = push_rock(rock, push, state.blocked)

    case fall_rock(rock, state.blocked) do
      {:stop, rock} ->
        add_rock(state, rock)
      {:cont, rock} ->
        drop_rock(state, rock)
    end
  end

  def push_rock(rock, push, blocked) do
    offset = case push do
      :left -> {-1, 0}
      :right -> {1, 0}
    end
    new_rock = translate_rock(rock, offset)
    if valid_rock?(new_rock, blocked) do
      new_rock
    else
      rock
    end
  end

  def fall_rock(rock, blocked) do
    offset = {0, -1}
    new_rock = translate_rock(rock, offset)
    if valid_rock?(new_rock, blocked) do
      {:cont, new_rock}
    else
      {:stop, rock}
    end
  end

  def translate_rock(rock, offset) do
    Enum.map(
      rock,
      fn p -> Vector.add(p, offset) end
    )
  end

  def valid_rock?(rock, blocked) do
    Enum.all?(
      rock,
      &(valid_point?(&1, blocked))
    )
  end

  def valid_point?(point, blocked) do
    {x, _y} = point
    x >= 0 and x < @width and not MapSet.member?(blocked, point)
  end

  def add_rock(state, rock) do
    {_, rock_top} = Enum.max_by(rock, &(elem(&1, 1)))

    state
    |> Map.update!(:height, &(max(&1, rock_top + 1)))
    |> Map.update!(:blocked, &(MapSet.union(&1, MapSet.new(rock))))
    |> Map.put(:maxes, update_maxes(state.maxes, rock))
  end

  def update_maxes(maxes, rock) do
    Enum.reduce(
      rock,
      maxes,
      fn {x, y}, acc ->
        Map.put(acc, x, max(y, Map.get(acc, x)))
      end
    )
  end

  def initialize_state(pushes) do
    blocked =
      for x <- 0..(@width - 1), reduce: MapSet.new() do
        acc -> MapSet.put(acc, {x, -1})
      end

    maxes =
      for x <- 0..(@width - 1), reduce: Map.new() do
        acc -> Map.put(acc, x, -1)
      end

    %{
      height: 0,
      blocked: blocked,
      pushes: pushes,
      maxes: maxes,
    }
  end

  def simulate(pushes, cycles) do
    do_simulate(initialize_state(pushes), cycles, 1, Map.new())
  end

  defp do_simulate(state, cycles, i, _acc) when i > cycles do
    state.height
  end

  defp do_simulate(state, cycles, i, acc) do
    key = get_key(state, i)
    case Map.fetch(acc, key) do
      {:ok, {prev_i, prev_height}} ->
        cycle_length = i - prev_i
        full_cycles = div(cycles - (i - 1), cycle_length)
        height_delta = state.height - prev_height
        
        extra_height = full_cycles * height_delta

        extra_height + do_simulate(state, cycles,
          i + full_cycles * cycle_length,
          Map.new()
        )
      :error ->
        do_simulate(
          update_state(state, i),
          cycles,
          i + 1,
          Map.put(acc, key, {i, state.height})
        )
    end
  end

  def get_key(state, i) do
    profile =
      for x <- 0..(@width - 1) do
        state.height - Map.get(state.maxes, x)
      end

    [ rem(i - 1, 5) | [ state.pushes.i | profile ] ]
  end

  def part1(pushes) do
    simulate(pushes, 2022)
  end

  def part2(pushes) do
    simulate( pushes, 1000000000000)
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
