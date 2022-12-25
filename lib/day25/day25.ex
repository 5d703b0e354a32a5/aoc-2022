defmodule AOC2022.Day25 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&String.trim/1)
  end

  def snafu_to_decimal(snafu) do
    snafu
    |> String.codepoints()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(
      0,
      fn {c, i}, acc ->
        val =
          case c do
            "2" -> 2
            "1" -> 1
            "0" -> 0
            "-" -> -1
            "=" -> -2
          end

        acc + val * 5 ** i
      end
    )
  end

  def decimal_to_snafu(decimal) do
    decimal
    |> Integer.digits(5)
    |> Enum.reverse()
    |> Kernel.then(&do_decimal_to_snafu(&1))
  end

  def do_decimal_to_snafu([]) do
    ""
  end

  def do_decimal_to_snafu([x | rest]) when 0 <= x and x <= 2 do
    do_decimal_to_snafu(rest) <> to_string(x)
  end

  def do_decimal_to_snafu([x | rest]) when x in [3, 4] do
    rest =
      rest
      |> Enum.reverse()
      |> Integer.undigits(5)
      |> Kernel.then(&(&1 + 1))
      |> Integer.digits(5)
      |> Enum.reverse()

    symbol =
      case x do
        3 -> "="
        4 -> "-"
      end

    do_decimal_to_snafu(rest) <> symbol
  end

  def part1(snafu_numbers) do
    snafu_numbers
    |> Enum.map(&snafu_to_decimal/1)
    |> Enum.sum()
    |> Kernel.then(&decimal_to_snafu/1)
  end

  def main() do
    filename = Util.relative_filename("input")

    data = parse_input(filename)

    IO.puts("Part 1")

    part1(data)
    |> IO.puts()
  end
end
