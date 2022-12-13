defmodule AOC2022.Day13 do
  require Util

  defguard is_digit(char) when "0" <= char and char <= "9"

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&parse_packet/1)
    |> Enum.to_list()
  end

  def parse_packet(line) do
    chars = String.codepoints(line)

    parse_list(chars)
  end

  def parse_list(chars) do
    [list] = do_parse_list(chars, [])
    list
  end

  def do_parse_list([], acc) do
    Enum.reverse(acc)
  end

  def do_parse_list(["[" | rest], acc) do
    {list, rest} = do_parse_list(rest, [])
    do_parse_list(rest, [list | acc])
  end

  def do_parse_list(["]" | rest], acc) do
    acc = Enum.reverse(acc)
    {acc, rest}
  end

  def do_parse_list(["," | rest], acc) do
    do_parse_list(rest, acc)
  end

  def do_parse_list([digit | rest], acc) when is_digit(digit) do
    further_digits = Enum.take_while(rest, &is_digit/1)
    rest = Enum.drop_while(rest, &is_digit/1)
    {num, ""} = Integer.parse(Enum.join([digit | further_digits]))

    do_parse_list(rest, [num | acc])
  end

  def right_order?(l, r) do
    case do_right_order?(l, r) do
      :ok -> true
      _ -> false
    end
  end

  def do_right_order?([], []) do
    :cont
  end

  def do_right_order?([_h | _t], []) do
    :err
  end

  def do_right_order?([], [_h | _t]) do
    :ok
  end

  def do_right_order?([l | tl], [r | tr]) when is_integer(l) and is_integer(r) do
    cond do
      l < r -> :ok
      l > r -> :err
      true -> do_right_order?(tl, tr)
    end
  end

  def do_right_order?([l | tl], [r | tr]) when is_integer(l) and is_list(r) do
    do_right_order?([[l] | tl], [r | tr])
  end

  def do_right_order?([l | tl], [r | tr]) when is_list(l) and is_integer(r) do
    do_right_order?([l | tl], [[r] | tr])
  end

  def do_right_order?([l | tl], [r | tr]) when is_list(l) and is_list(r) do
    case do_right_order?(l, r) do
      :ok -> :ok
      :err -> :err
      :cont -> do_right_order?(tl, tr)
    end
  end

  def part1(packets) do
    packets
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.with_index(1)
    |> Enum.filter(fn {{l, r}, _index} -> right_order?(l, r) end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.reduce(0, &(&1 + &2))
  end

  def part2(packets) do
    distress1 = [[2]]
    distress2 = [[6]]

    sorted =
      ([distress1, distress2] ++ packets)
      |> Enum.sort(&right_order?/2)

    index1 = Enum.find_index(sorted, &(&1 == distress1)) + 1
    index2 = Enum.find_index(sorted, &(&1 == distress2)) + 1

    index1 * index2
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
