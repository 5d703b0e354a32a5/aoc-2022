defmodule AOC2022.Day19 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  def parse_line(line) do
    [_ | match] =
      Regex.run(
        ~r/Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian./,
        line
      )

    [id, ore_ore, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian] =
      match
      |> Enum.map(fn s ->
        {s, ""} = Integer.parse(s)
        s
      end)

    costs = %{
      ore_ore: ore_ore,
      clay_ore: clay_ore,
      obsidian_ore: obsidian_ore,
      obsidian_clay: obsidian_clay,
      geode_ore: geode_ore,
      geode_obsidian: geode_obsidian,
      max_ore: Enum.max([ore_ore, clay_ore, obsidian_ore, geode_ore]),
      max_clay: obsidian_clay,
      max_obsidian: geode_obsidian
    }

    %{
      id: id,
      costs: costs
    }
  end

  def initialize_state(minutes) do
    %{
      minutes: minutes,
      ore: 0,
      clay: 0,
      obsidian: 0,
      geode: 0,
      ore_robot: 1,
      clay_robot: 0,
      obsidian_robot: 0,
      geode_robot: 0
    }
  end

  def mine(state) do
    state
    |> Map.update!(:minutes, &(&1 - 1))
    |> Map.update!(:ore, &(&1 + state.ore_robot))
    |> Map.update!(:clay, &(&1 + state.clay_robot))
    |> Map.update!(:obsidian, &(&1 + state.obsidian_robot))
    |> Map.update!(:geode, &(&1 + state.geode_robot))
  end

  def triangle(i) do
    div(i * (i - 1), 2)
  end

  def maximize_geodes(costs, minutes) do
    seen = :ets.new(:seen, [])
    :ets.insert(seen, {"best", 0})
    state = initialize_state(minutes)
    do_maximize_geodes(state, costs, seen)
  end

  def do_maximize_geodes(state = %{minutes: minutes}, _costs, _seen) when minutes == 0 do
    state.geode
  end

  def do_maximize_geodes(state, costs, seen) do
    [{_, best}] = :ets.lookup(seen, "best")

    case :ets.lookup(seen, state) do
      [{_, result}] ->
        result

      [] ->
        result =
          cond do
            state.ore >= costs.geode_ore and state.obsidian >= costs.geode_obsidian ->
              do_maximize_geodes(
                mine(state)
                |> Map.update!(:ore, &(&1 - costs.geode_ore))
                |> Map.update!(:obsidian, &(&1 - costs.geode_obsidian))
                |> Map.update!(:geode_robot, &(&1 + 1)),
                costs,
                seen
              )

            state.geode + state.geode_robot * state.minutes + triangle(state.minutes) <= best ->
              nil

            true ->
              buy_nothing = do_maximize_geodes(mine(state), costs, seen)

              buy_ore_robot =
                if state.ore_robot < costs.max_ore and state.ore >= costs.ore_ore do
                  do_maximize_geodes(
                    mine(state)
                    |> Map.update!(:ore, &(&1 - costs.ore_ore))
                    |> Map.update!(:ore_robot, &(&1 + 1)),
                    costs,
                    seen
                  )
                end

              buy_clay_robot =
                if state.clay_robot < costs.max_clay and state.ore >= costs.clay_ore do
                  do_maximize_geodes(
                    mine(state)
                    |> Map.update!(:ore, &(&1 - costs.clay_ore))
                    |> Map.update!(:clay_robot, &(&1 + 1)),
                    costs,
                    seen
                  )
                end

              buy_obsidian_robot =
                if state.obsidian_robot < costs.max_obsidian and
                     state.ore >= costs.obsidian_ore and
                     state.clay >= costs.obsidian_clay do
                  do_maximize_geodes(
                    mine(state)
                    |> Map.update!(:ore, &(&1 - costs.obsidian_ore))
                    |> Map.update!(:clay, &(&1 - costs.obsidian_clay))
                    |> Map.update!(:obsidian_robot, &(&1 + 1)),
                    costs,
                    seen
                  )
                end

              [buy_nothing, buy_ore_robot, buy_clay_robot, buy_obsidian_robot]
              |> Enum.reject(&Kernel.is_nil/1)
              |> Enum.max(&>=/2, fn -> 0 end)
          end

        :ets.insert(seen, {state, result})
        :ets.insert(seen, {"best", max(best, result)})
        result
    end
  end

  def part1(blueprints) do
    blueprints
    |> Enum.map(fn blueprint ->
      blueprint.id * maximize_geodes(blueprint.costs, 24)
    end)
    |> Enum.sum()
  end

  def part2(blueprints) do
    blueprints
    |> Enum.take(3)
    |> Enum.map(fn blueprint ->
      maximize_geodes(blueprint.costs, 32)
    end)
    |> IO.inspect()
    |> Enum.reduce(1, &(&1 * &2))
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
