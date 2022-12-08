defmodule Array2D do
  def new(rows, cols, default \\ nil) do
    for _i <- 1..rows do
      for _j <- 1..cols do
        default
      end
      |> List.to_tuple()
    end
    |> List.to_tuple()
  end

  def from_list(list) when is_list(list) do
    list
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  defp index(i) do
    i - 1
  end

  def rows(array) do
    tuple_size(array)
  end

  def cols(array) do
    tuple_size(elem(array, 0))
  end

  def get(array, row, col) do
    elem(elem(array, index(row)), index(col))
  end

  def put(array, row, col, value) do
    put_elem(
      array,
      index(row),
      put_elem(elem(array, index(row)), index(col), value)
    )
  end

  def count(array, fun) do
    for i <- 1..rows(array), j <- 1..cols(array) do
      {i, j}
    end
    |> Enum.reduce(
      0,
      fn {row, col}, acc ->
        value = get(array, row, col)

        if fun.(value) do
          acc + 1
        else
          acc
        end
      end
    )
  end
end
