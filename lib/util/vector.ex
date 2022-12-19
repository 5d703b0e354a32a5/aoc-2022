defmodule Vector do
  def new(n, default \\ nil) do
    for _ <- 1..n do
      default
    end
    |> List.to_tuple()
  end

  def from_list(list) when is_list(list) do
    list
    |> List.to_tuple()
  end

  def size(v) do
    tuple_size(v)
  end

  def get(v, i) do
    elem(v, i - 1)
  end

  def put(v, i, item) do
    put_elem(v, i - 1, item)
  end

  def add(v1, v2) do
    n = size(v1)

    Enum.reduce(
      1..n,
      new(n),
      fn i, result ->
        put(result, i, get(v1, i) + get(v2, i))
      end
    )
  end

  def subtract(v1, v2) do
    n = size(v1)

    Enum.reduce(
      1..n,
      new(n),
      fn i, result ->
        put(result, i, get(v1, i) - get(v2, i))
      end
    )
  end

  def scale(v, s) do
    n = size(v)

    Enum.reduce(
      1..n,
      new(n),
      fn i, result ->
        put(result, i, s * get(v, i))
      end
    )
  end

  def norm(v) do
    :math.sqrt(Vector.dot(v, v))
  end

  def normalize(v) do
    n = norm(v)
    scale(v, 1 / n)
  end

  def dot(v1, v2) do
    n = size(v1)

    Enum.reduce(
      1..n,
      0,
      fn i, result ->
        result + get(v1, i) * get(v2, i)
      end
    )
  end

  def all?(v, pred) do
    v
    |> Tuple.to_list()
    |> Enum.all?(pred)
  end
end
