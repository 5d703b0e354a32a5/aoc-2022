defmodule AOC2022.Day21 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Map.new()
  end

  def parse_line(line) do
    <<name::binary-size(4), ": ">> <> rest = line

    job =
      case rest do
        <<m1::binary-size(4), " + ", m2::binary-size(4)>> ->
          {:+, m1, m2}

        <<m1::binary-size(4), " - ", m2::binary-size(4)>> ->
          {:-, m1, m2}

        <<m1::binary-size(4), " * ", m2::binary-size(4)>> ->
          {:*, m1, m2}

        <<m1::binary-size(4), " / ", m2::binary-size(4)>> ->
          {:/, m1, m2}

        n ->
          {n, ""} = Integer.parse(n)
          {:num, n}
      end

    {name, job}
  end

  def determine_job(jobs, target) do
    case Map.get(jobs, target) do
      {:num, n} ->
        n

      _ ->
        jobs =
          Enum.reduce(
            jobs,
            jobs,
            fn {name, job}, acc ->
              case job do
                {:num, _} ->
                  acc

                {op, m1, m2} ->
                  job1 = Map.get(acc, m1)
                  job2 = Map.get(acc, m2)

                  case carry_out_job(op, job1, job2) do
                    :err -> acc
                    {:ok, n} -> Map.replace!(acc, name, {:num, n})
                  end
              end
            end
          )

        determine_job(jobs, target)
    end
  end

  def carry_out_job(op, {:num, n1}, {:num, n2}) do
    {
      :ok,
      do_math(op, n1, n2)
    }
  end

  def carry_out_job(_op, _job1, _job2) do
    :err
  end

  def do_math(op, n1, n2) do
    case op do
      :+ -> n1 + n2
      :- -> n1 - n2
      :* -> n1 * n2
      :/ -> div(n1, n2)
    end
  end

  def try_get_number(jobs, name) do
    case Map.get(jobs, name) do
      :unknown ->
        {:err, jobs}

      {:num, n} ->
        {n, jobs}

      {op, m1, m2} ->
        {n1, jobs} = try_get_number(jobs, m1)
        {n2, jobs} = try_get_number(jobs, m2)

        cond do
          n1 == :err or n2 == :err ->
            {:err, jobs}

          true ->
            n = do_math(op, n1, n2)
            {n, jobs}
        end
    end
  end

  def inverse_operation(num, :+, {_, other}) do
    num - other
  end

  def inverse_operation(num, :-, {:right, other}) do
    num + other
  end

  def inverse_operation(num, :-, {:left, other}) do
    other - num
  end

  def inverse_operation(num, :*, {_, other}) do
    div(num, other)
  end

  def inverse_operation(num, :/, {:right, other}) do
    num * other
  end

  def inverse_operation(num, :/, {:left, other}) do
    other / num
  end

  def walk_down(_jobs, target, target, num) do
    num
  end

  def walk_down(jobs, target, current, num) do
    {op, monkey_left, monkey_right} = Map.get(jobs, current)

    {left, jobs} = try_get_number(jobs, monkey_left)
    {right, jobs} = try_get_number(jobs, monkey_right)

    cond do
      left == :err ->
        walk_down(jobs, target, monkey_left, inverse_operation(num, op, {:right, right}))

      right == :err ->
        walk_down(jobs, target, monkey_right, inverse_operation(num, op, {:left, left}))
    end
  end

  def determine_number(jobs, target) do
    {:eq, monkey_left, monkey_right} = Map.get(jobs, "root")

    {left, jobs} = try_get_number(jobs, monkey_left)
    {right, jobs} = try_get_number(jobs, monkey_right)

    cond do
      left == :err -> walk_down(jobs, target, monkey_left, right)
      right == :err -> walk_down(jobs, target, monkey_right, left)
    end
  end

  def part1(jobs) do
    determine_job(jobs, "root")
  end

  def part2(jobs) do
    jobs =
      jobs
      |> Map.update!("root", fn {_op, m1, m2} -> {:eq, m1, m2} end)
      |> Map.replace!("humn", :unknown)

    determine_number(jobs, "humn")
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
