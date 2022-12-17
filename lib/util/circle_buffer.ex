defmodule CircleBuffer do
  defstruct i: 0, size: nil, items: nil

  def new(items) do
    items =
      items
      |> Enum.to_list()
      |> List.to_tuple()
    size = tuple_size(items)
    %CircleBuffer{
      i: 0,
      size: size,
      items: items,
    }
  end

  def next(buffer) do
    {
      elem(buffer.items, buffer.i),
      struct(buffer, i: rem(buffer.i + 1, buffer.size))
    }
  end

  def size(buffer) do
    buffer.size
  end
end
