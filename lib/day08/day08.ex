defmodule AOC2022.Day08 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
    |> Enum.to_list()
    |> Array2D.from_list()
  end

  def parse_line(line) do
    line
    |> String.codepoints()
    |> Enum.map(fn c ->
      {height, ""} = Integer.parse(c)
      height
    end)
  end

  def update_visibility_top(visibilities, heights) do
    for col <- 1..Array2D.cols(visibilities) do
      for row <- 1..Array2D.rows(visibilities) do
        {row, col}
      end
    end
    |> update_visibility_coordinates(visibilities, heights)
  end

  def update_visibility_bottom(visibilities, heights) do
    for col <- 1..Array2D.cols(visibilities) do
      for row <- Array2D.rows(visibilities)..1 do
        {row, col}
      end
    end
    |> update_visibility_coordinates(visibilities, heights)
  end

  def update_visibility_left(visibilities, heights) do
    for row <- 1..Array2D.rows(visibilities) do
      for col <- 1..Array2D.cols(visibilities) do
        {row, col}
      end
    end
    |> update_visibility_coordinates(visibilities, heights)
  end

  def update_visibility_right(visibilities, heights) do
    for row <- 1..Array2D.rows(visibilities) do
      for col <- Array2D.cols(visibilities)..1 do
        {row, col}
      end
    end
    |> update_visibility_coordinates(visibilities, heights)
  end

  def update_visibility_coordinates(coordinates2d, visibilities, heights) do
    coordinates2d
    |> Enum.reduce(
      visibilities,
      fn coordinates1d, acc ->
        update_visibility_coordinates1d(coordinates1d, acc, heights)
      end
    )
  end

  def update_visibility_coordinates1d(coordinates1d, visibilities, heights) do
    do_update_visibility_coordinates1d(coordinates1d, visibilities, heights, -1)
  end

  def do_update_visibility_coordinates1d([], visibilities, _heights, _max) do
    visibilities
  end

  def do_update_visibility_coordinates1d([{row, col} | rest], visibilities, heights, max_height) do
    height = Array2D.get(heights, row, col)

    visibilities =
      if height > max_height do
        Array2D.put(visibilities, row, col, :visible)
      else
        visibilities
      end

    do_update_visibility_coordinates1d(rest, visibilities, heights, max(max_height, height))
  end

  def calculate_scenic_score(heights, coordinate) do
    [
      calculate_scenic_factor_top(heights, coordinate),
      calculate_scenic_factor_bottom(heights, coordinate),
      calculate_scenic_factor_left(heights, coordinate),
      calculate_scenic_factor_right(heights, coordinate)
    ]
    |> Enum.reduce(1, &(&1 * &2))
  end

  def calculate_scenic_factor_top(heights, {i, j}) do
    for row <- (i - 1)..1 do
      {row, j}
    end
    |> calculate_scenic_factor(heights, {i, j})
  end

  def calculate_scenic_factor_bottom(heights, {i, j}) do
    for row <- (i + 1)..Array2D.rows(heights) do
      {row, j}
    end
    |> calculate_scenic_factor(heights, {i, j})
  end

  def calculate_scenic_factor_left(heights, {i, j}) do
    for col <- (j - 1)..1 do
      {i, col}
    end
    |> calculate_scenic_factor(heights, {i, j})
  end

  def calculate_scenic_factor_right(heights, {i, j}) do
    for col <- (j + 1)..Array2D.cols(heights) do
      {i, col}
    end
    |> calculate_scenic_factor(heights, {i, j})
  end

  def calculate_scenic_factor(coordinates, heights, {i, j}) do
    do_calculate_scenic_factor(coordinates, heights, Array2D.get(heights, i, j), 0)
  end

  def do_calculate_scenic_factor([], _heights, _treehouse_height, acc) do
    acc
  end

  def do_calculate_scenic_factor([{i, j} | rest], heights, treehouse_height, acc) do
    height = Array2D.get(heights, i, j)

    if height >= treehouse_height do
      acc + 1
    else
      do_calculate_scenic_factor(rest, heights, treehouse_height, acc + 1)
    end
  end

  def part1(heights) do
    Array2D.new(
      Array2D.rows(heights),
      Array2D.cols(heights),
      :invisible
    )
    |> update_visibility_top(heights)
    |> update_visibility_bottom(heights)
    |> update_visibility_left(heights)
    |> update_visibility_right(heights)
    |> Array2D.count(fn visibility -> visibility == :visible end)
  end

  def part2(heights) do
    for row <- 2..(Array2D.rows(heights) - 1), col <- 2..(Array2D.cols(heights) - 1) do
      {row, col}
    end
    |> Enum.map(fn coordinate -> calculate_scenic_score(heights, coordinate) end)
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
