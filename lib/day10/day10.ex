defmodule AOC2022.Day10 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
  end

  def parse_line("noop") do
    :noop
  end

  def parse_line(<<"add", register::binary-size(1), " ">> <> val) do
    {val, ""} = Integer.parse(val)
    {:add, register, val}
  end

  def run_program(instructions) do
    start_val = 1
    do_run_program(instructions, start_val, [])
  end

  defp do_run_program([], _val, acc) do
    Enum.reverse(acc)
  end

  defp do_run_program([:noop | rest], val, acc) do
    do_run_program(rest, val, [val | acc])
  end

  defp do_run_program([{:add, _register, delta} | rest], val, acc) do
    do_run_program(rest, val + delta, [val, val | acc])
  end

  def render_crt(instructions) do
    crt_width = 40

    instructions
    |> run_program()
    |> do_render_crt(0, crt_width, [])
    |> Enum.chunk_every(crt_width)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> Kernel.then(&(&1 <> "\n"))
  end

  defp do_render_crt([], _cursor, _crt_width, acc) do
    Enum.reverse(acc)
  end

  defp do_render_crt([val | rest], cursor, crt_width, acc) do
    symbol =
      if abs(cursor - val) <= 1 do
        "#"
      else
        "."
      end

    do_render_crt(rest, rem(cursor + 1, crt_width), crt_width, [symbol | acc])
  end

  def part1(instructions) do
    instructions
    |> run_program()
    |> Stream.with_index(1)
    |> Stream.drop(19)
    |> Stream.take_every(40)
    |> Stream.map(fn {val, cycle} -> val * cycle end)
    |> Enum.reduce(0, &(&1 + &2))
  end

  def part2(instructions) do
    instructions
    |> render_crt()
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
