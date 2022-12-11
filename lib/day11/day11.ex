defmodule AOC2022.Day11 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(fn line -> line == "" end)
    |> Stream.reject(fn chunk -> chunk == [""] end)
    |> Stream.map(&parse_monkey/1)
    |> Enum.to_list()
    |> List.to_tuple()
  end

  def parse_monkey(chunk) do
    [
      _monkey_head,
      "Starting items: " <> starting_items,
      "Operation: " <> operation,
      "Test: divisible by " <> modulus,
      "If true: throw to monkey " <> target_true,
      "If false: throw to monkey " <> target_false
    ] = chunk

    starting_items = parse_starting_items(starting_items)
    operation = parse_operation(operation)
    {modulus, ""} = Integer.parse(modulus)
    {target_true, ""} = Integer.parse(target_true)
    {target_false, ""} = Integer.parse(target_false)

    %{
      items: starting_items,
      operation: operation,
      modulus: modulus,
      target_true: target_true,
      target_false: target_false
    }
  end

  def parse_starting_items(starting_items) do
    starting_items
    |> String.split(", ")
    |> Enum.map(fn item ->
      {item, ""} = Integer.parse(item)
      item
    end)
    |> List.to_tuple()
  end

  def parse_operation("new = old * old") do
    fn old -> old * old end
  end

  def parse_operation("new = old * " <> factor) do
    {factor, ""} = Integer.parse(factor)
    fn old -> old * factor end
  end

  def parse_operation("new = old + " <> summand) do
    {summand, ""} = Integer.parse(summand)
    fn old -> old + summand end
  end

  def play_round({monkeys, counts}, common_modulus \\ nil) do
    Enum.reduce(
      0..(tuple_size(monkeys) - 1),
      {monkeys, counts},
      fn monkey_index, {monkeys, counts} ->
        monkey = elem(monkeys, monkey_index)
        items_count = tuple_size(monkey.items)

        counts =
          put_elem(
            counts,
            monkey_index,
            elem(counts, monkey_index) + items_count
          )

        monkeys = play_monkey(monkey, monkeys, common_modulus)
        monkey = Map.put(monkey, :items, {})
        monkeys = put_elem(monkeys, monkey_index, monkey)
        {monkeys, counts}
      end
    )
  end

  def play_monkey(monkey, monkeys, common_modulus) do
    items = monkey.items |> Tuple.to_list()
    do_play_monkey(monkey, monkeys, items, common_modulus)
  end

  def do_play_monkey(_monkey, monkeys, [], _common_modulus) do
    monkeys
  end

  def do_play_monkey(monkey, monkeys, [item | rest], common_modulus) do
    new = monkey.operation.(item)

    new =
      if common_modulus == nil do
        div(new, 3)
      else
        rem(new, common_modulus)
      end

    target =
      if rem(new, monkey.modulus) == 0 do
        monkey.target_true
      else
        monkey.target_false
      end

    monkeys =
      put_elem(
        monkeys,
        target,
        Map.update!(
          elem(monkeys, target),
          :items,
          fn items -> Tuple.append(items, new) end
        )
      )

    do_play_monkey(monkey, monkeys, rest, common_modulus)
  end

  def calculate_monkey_business(monkeys, rounds, dont_worry \\ true) do
    # All moduli are distinct prime numbers
    common_modulus =
      if dont_worry do
        nil
      else
        monkeys
        |> Tuple.to_list()
        |> Enum.map(& &1.modulus)
        |> Enum.reduce(1, &(&1 * &2))
        |> IO.inspect()
      end

    counts = for(_ <- 1..tuple_size(monkeys), do: 0) |> List.to_tuple()

    {_monkeys, counts} =
      Enum.reduce(
        1..rounds,
        {monkeys, counts},
        fn round, acc ->
          play_round(acc, common_modulus)
        end
      )

    counts
    |> Tuple.to_list()
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def part1(monkeys) do
    calculate_monkey_business(monkeys, 20)
  end

  def part2(monkeys) do
    calculate_monkey_business(monkeys, 10_000, false)
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
