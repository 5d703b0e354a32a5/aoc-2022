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

  def to_list(array) do
    array
    |> Tuple.to_list()
    |> Enum.map(&Tuple.to_list/1)
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

  def merge(left, right, fun) do
    for i <- 1..rows(left), j <- 1..cols(left) do
      {i, j}
    end
    |> Enum.reduce(
      Array2D.new(rows(left), rows(left)),
      fn {i, j}, acc ->
        Array2D.put(
          acc,
          i,
          j,
          fun.(
            get(left, i, j),
            get(right, i, j)
          )
        )
      end
    )
  end

  def product(left, right) do
    n = rows(left)
    m = cols(left)
    l = cols(right)

    for i <- 1..n, j <- 1..l do
      {i, j}
    end
    |> Enum.reduce(
      Array2D.new(n, l),
      fn {i, j}, acc ->
        entry =
          for k <- 1..m, reduce: 0 do
            acc -> acc + Array2D.get(left, i, k) * Array2D.get(right, k, j)
          end

        Array2D.put(acc, i, j, entry)
      end
    )
  end

  def transpose(array) do
    for j <- 1..cols(array) do
      for i <- 1..rows(array) do
        get(array, i, j)
      end
    end
    |> from_list()
  end
end
