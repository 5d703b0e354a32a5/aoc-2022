defmodule AOC2022.Day16 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Map.new(&{&1.valve, &1})
  end

  def parse_line(line) do
    %{
      "valve" => valve,
      "flow_rate" => flow_rate,
      "tunnels_to" => tunnels_to
    } =
      Regex.named_captures(
        ~r/Valve (?<valve>[^ ]+) has flow rate=(?<flow_rate>\d+); tunnels? leads? to valves? (?<tunnels_to>.*)/,
        line
      )

    {flow_rate, ""} = Integer.parse(flow_rate)

    tunnels_to = MapSet.new(String.split(tunnels_to, ", "))

    %{
      valve: valve,
      flow_rate: flow_rate,
      tunnels_to: tunnels_to
    }
  end

  def calculate_distances(valves) do
    labels =
      valves
      |> Map.keys()
      |> Enum.sort()

    indices =
      labels
      |> Enum.with_index(1)
      |> Map.new()

    adjacency =
      for source_label <- labels do
        source_valve = Map.get(valves, source_label)
        targets = source_valve.tunnels_to

        for target_label <- labels do
          if MapSet.member?(targets, target_label) do
            1
          else
            0
          end
        end
      end
      |> Array2D.from_list()

    distances = Graph.adjacency_to_distances(adjacency)

    for source_label <- labels,
        target_label <- labels,
        source_label != target_label,
        reduce: %{} do
      acc ->
        source_index = Map.get(indices, source_label)
        target_index = Map.get(indices, target_label)

        distance = Array2D.get(distances, source_index, target_index)
        Map.put(acc, {source_label, target_label}, distance)
    end
  end

  def calculate_flows(state, valves, distances) do
    if MapSet.size(state.remaining) == 0 do
      [state]
    else
      [
        state
        | Enum.flat_map(
            state.remaining,
            fn next ->
              valve = Map.get(valves, next)
              distance = Map.get(distances, {state.current, next})
              minutes_remaining = state.minutes_remaining - (distance + 1)
              total = state.total + valve.flow_rate * minutes_remaining

              if minutes_remaining > 0 do
                calculate_flows(
                  state
                  |> Map.update!(:remaining, &MapSet.delete(&1, next))
                  |> Map.update!(:opened, &MapSet.put(&1, next))
                  |> Map.replace!(:minutes_remaining, minutes_remaining)
                  |> Map.replace!(:total, total)
                  |> Map.replace!(:current, next),
                  valves,
                  distances
                )
              else
                [state]
              end
            end
          )
      ]
    end
  end

  def part1(valves) do
    distances = calculate_distances(valves)

    remaining =
      valves
      |> Enum.filter(fn {_valve_label, valve} -> valve.flow_rate != 0 end)
      |> Enum.map(fn {valve_label, _valve} -> valve_label end)
      |> MapSet.new()

    state = %{
      current: "AA",
      minutes_remaining: 30,
      total: 0,
      remaining: remaining,
      opened: MapSet.new()
    }

    calculate_flows(state, valves, distances)
    |> Enum.map(& &1.total)
    |> Enum.max()
  end

  def part2(valves) do
    distances = calculate_distances(valves)

    remaining =
      valves
      |> Enum.filter(fn {_valve_label, valve} -> valve.flow_rate != 0 end)
      |> Enum.map(fn {valve_label, _valve} -> valve_label end)
      |> MapSet.new()

    state = %{
      current: "AA",
      minutes_remaining: 26,
      total: 0,
      remaining: remaining,
      opened: MapSet.new()
    }

    results =
      calculate_flows(state, valves, distances)
      |> Enum.group_by(
        & &1.opened,
        & &1.total
      )
      |> Enum.map(fn {opened, totals} -> {Enum.max(totals), opened} end)

    for {total_left, opened_left} <- results do
      right =
        results
        |> Enum.uniq()
        |> Stream.filter(fn {_, opened_right} -> MapSet.disjoint?(opened_left, opened_right) end)
        |> Stream.map(&elem(&1, 0))
        |> Enum.to_list()

      if right == [] do
        total_left
      else
        total_left + Enum.max(right)
      end
    end
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
