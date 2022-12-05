defmodule AOC2022.Day05 do
  require Util

  def parse_input(filename) do
    [crates_input, [""], moves_input] =
      File.stream!(filename)
      |> Stream.map(&String.trim(&1, "\n"))
      |> Enum.chunk_by(fn line -> line == "" end)

    crates = parse_crates(crates_input)
    moves = parse_moves(moves_input)
    {crates, moves}
  end

  def parse_crates(crates_input) do
    [numbers | content] = Enum.reverse(crates_input)
    n_crates = div(String.length(numbers) + 1, 4)

    do_parse_crates(
      content,
      n_crates,
      1,
      {}
    )
  end

  defp do_parse_crates(_content, n_crates, i, acc) when i > n_crates do
    acc
  end

  defp do_parse_crates(content, n_crates, i, acc) do
    index = (i - 1) * 4 + 1

    crates =
      Enum.reduce_while(content, [], fn line, stack ->
        crate = String.at(line, index)

        case crate do
          " " -> {:halt, stack}
          x -> {:cont, [x | stack]}
        end
      end)

    do_parse_crates(content, n_crates, i + 1, Tuple.append(acc, crates))
  end

  def parse_moves(moves_input) do
    moves_input
    |> Stream.map(fn move_input ->
      Regex.named_captures(~r/move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)/, move_input)
    end)
    |> Enum.map(fn %{"count" => count, "from" => from, "to" => to} ->
      [count, from, to]
      |> Enum.map(fn num_string -> elem(Integer.parse(num_string), 0) end)
      |> List.to_tuple()
    end)
  end

  def apply_move(move, crates) do
    {count, from, to} = move
    from_stack = elem(crates, from - 1)
    to_stack = elem(crates, to - 1)
    {from_stack, to_stack} = Enum.reduce(1..count, {from_stack, to_stack}, &do_apply_move/2)

    crates
    |> put_elem(from - 1, from_stack)
    |> put_elem(to - 1, to_stack)
  end

  defp do_apply_move(_, {[from_head | from_tail], to}) do
    {from_tail, [from_head | to]}
  end

  def apply_move_9001(move, crates) do
    {count, from, to} = move
    from_stack = elem(crates, from - 1)
    to_stack = elem(crates, to - 1)

    from_front = Enum.take(from_stack, count)
    from_back = Enum.drop(from_stack, count)

    from_stack = from_back
    to_stack = from_front ++ to_stack

    crates
    |> put_elem(from - 1, from_stack)
    |> put_elem(to - 1, to_stack)
  end

  def top_crates_to_string(crates) do
    crates
    |> Tuple.to_list()
    |> Enum.map(&Kernel.hd/1)
    |> Enum.join("")
  end

  def part1({crates, moves}) do
    Enum.reduce(moves, crates, &apply_move/2)
    |> top_crates_to_string()
  end

  def part2({crates, moves}) do
    Enum.reduce(moves, crates, &apply_move_9001/2)
    |> top_crates_to_string()
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
