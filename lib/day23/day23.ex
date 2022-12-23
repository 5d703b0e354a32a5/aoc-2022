defmodule AOC2022.Day23 do
  require Util

  @directions %{
    N: {0, 1},
    NE: {1, 1},
    E: {1, 0},
    SE: {1, -1},
    S: {0, -1},
    SW: {-1, -1},
    W: {-1, 0},
    NW: {-1, 1}
  }

  @considerations %{
    northish: {[:N, :NE, :NW], :N},
    southish: {[:S, :SE, :SW], :S},
    eastish: {[:E, :SE, :NE], :E},
    westish: {[:W, :SW, :NW], :W}
  }

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.with_index(fn element, index -> {-index, element} end)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(
      MapSet.new(),
      fn line, acc ->
        MapSet.union(acc, line)
      end
    )
  end

  def parse_line({y, line}) do
    line
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(
      MapSet.new(),
      fn {char, x}, acc ->
        case char do
          "#" -> MapSet.put(acc, {x, y})
          "." -> acc
        end
      end
    )
  end

  def draw(elves) do
    {{x_min, y_min}, {x_max, y_max}} = calculate_bounding_box(elves)

    for y <- y_max..y_min do
      for x <- x_min..x_max do
        if MapSet.member?(elves, {x, y}) do
          "#"
        else
          "."
        end
      end
      |> Enum.join()
    end
  end

  def calculate_bounding_box(positions) do
    {x_min, _} = Enum.min_by(positions, &elem(&1, 0))
    {x_max, _} = Enum.max_by(positions, &elem(&1, 0))
    {_, y_min} = Enum.min_by(positions, &elem(&1, 1))
    {_, y_max} = Enum.max_by(positions, &elem(&1, 1))

    {{x_min, y_min}, {x_max, y_max}}
  end

  def rotate(list) when is_list(list) do
    [x | rest] = list
    rest ++ [x]
  end

  def consider_moves(elves, order_of_consideration) do
    Enum.reduce(
      elves,
      %{},
      fn elf, plans ->
        if should_plan?(elf, elves) do
          case make_plan(elf, elves, order_of_consideration) do
            nil -> plans
            target -> Map.put(plans, elf, target)
          end
        else
          plans
        end
      end
    )
  end

  def should_plan?(elf, elves) do
    Enum.any?(
      @directions,
      fn {_, direction} ->
        MapSet.member?(elves, Vector.add(elf, direction))
      end
    )
  end

  def make_plan(_elf, _elves, []) do
    nil
  end

  def make_plan(elf, elves, [consideration | rest]) do
    case try_move(elf, elves, consideration) do
      nil -> make_plan(elf, elves, rest)
      target -> target
    end
  end

  def try_move(elf, elves, consideration) do
    {directions, move_direction} = Map.get(@considerations, consideration)

    if move_possible?(elf, elves, directions) do
      Vector.add(elf, Map.get(@directions, move_direction))
    else
      nil
    end
  end

  def move_possible?(elf, elves, directions) do
    not Enum.any?(
      directions,
      fn direction ->
        MapSet.member?(elves, Vector.add(elf, Map.get(@directions, direction)))
      end
    )
  end

  def carry_out_plans(elves, plans) do
    target_counts =
      Enum.reduce(
        plans,
        %{},
        fn {_, target}, acc ->
          Map.update(acc, target, 1, &(&1 + 1))
        end
      )

    Enum.reduce(
      plans,
      elves,
      fn plan, elves ->
        {start, target} = plan

        if Map.get(target_counts, target) > 1 do
          elves
        else
          elves
          |> MapSet.delete(start)
          |> MapSet.put(target)
        end
      end
    )
  end

  def update_elves(elves, order_of_consideration) do
    plans = consider_moves(elves, order_of_consideration)
    carry_out_plans(elves, plans)
  end

  def simulate_elves(elves, rounds) do
    order_of_consideration = [
      :northish,
      :southish,
      :westish,
      :eastish
    ]

    Enum.reduce(
      1..rounds,
      {elves, order_of_consideration},
      fn _, {elves, order_of_consideration} ->
        {
          update_elves(elves, order_of_consideration),
          rotate(order_of_consideration)
        }
      end
    )
    |> Kernel.then(&elem(&1, 0))
  end

  def calculate_moves_to_final_state(elves) do
    order_of_consideration = [
      :northish,
      :southish,
      :westish,
      :eastish
    ]

    do_calculate_moves_to_final_state(elves, order_of_consideration, 0)
  end

  def do_calculate_moves_to_final_state(elves, order_of_consideration, count) do
    new_elves = update_elves(elves, order_of_consideration)

    if MapSet.size(MapSet.difference(elves, new_elves)) == 0 do
      count + 1
    else
      do_calculate_moves_to_final_state(
        new_elves,
        rotate(order_of_consideration),
        count + 1
      )
    end
  end

  def count_dirt(positions) do
    {{x_min, y_min}, {x_max, y_max}} = calculate_bounding_box(positions)

    total_area = (x_max - x_min + 1) * (y_max - y_min + 1)
    total_area - Enum.count(positions)
  end

  def part1(elves) do
    simulate_elves(elves, 10)
    |> Kernel.then(&count_dirt/1)
  end

  def part2(elves) do
    calculate_moves_to_final_state(elves)
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
