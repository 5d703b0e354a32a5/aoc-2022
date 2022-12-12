defmodule Heap do
  @moduledoc """
  Provides an implementation of a binary heap using an array (tuple) for storage.

  ## Examples

  A max heap can be created by using the new/1 constructor

  iex> Heap.new(&(&1 > &2))
  """

  defstruct items: {},
            size: 0,
            comp: &(&1 < &2)

  defp left(i), do: 2 * i + 1
  defp right(i), do: 2 * i + 2
  defp parent(i), do: div(i - 1, 2)

  defp swap(items, i, j) do
    temp = elem(items, i)

    items
    |> put_elem(i, elem(items, j))
    |> put_elem(j, temp)
  end

  def new() do
    %Heap{}
  end

  def new(comp) do
    %Heap{comp: comp}
  end

  def push(%Heap{items: items, size: size, comp: comp}, item) do
    items = sift_up(Tuple.append(items, item), size, comp)
    %Heap{items: items, size: size + 1, comp: comp}
  end

  def pop(%Heap{items: items, size: size, comp: comp}) do
    first = elem(items, 0)
    last = elem(items, size - 1)

    items =
      items
      |> put_elem(0, last)
      |> Tuple.delete_at(size - 1)
      |> sift_down(0, comp)

    {
      first,
      %Heap{items: items, size: size - 1, comp: comp}
    }
  end

  def size(%Heap{size: size}) do
    size
  end

  defp sift_up(items, 0, _comp) do
    items
  end

  defp sift_up(items, i, comp) do
    parent_index = parent(i)
    parent_item = elem(items, parent_index)
    item = elem(items, i)

    if comp.(parent_item, item) do
      items
    else
      items = swap(items, i, parent_index)
      sift_up(items, parent_index, comp)
    end
  end

  defp sift_down(items, i, comp) do
    size = tuple_size(items)
    l = left(i)
    r = right(i)

    cond do
      l >= size -> items
      r >= size -> sift_down_l(items, i, comp)
      true -> sift_down_lr(items, i, comp)
    end
  end

  defp sift_down_l(items, i, comp) do
    l = left(i)
    top = i

    top_item = elem(items, top)
    left_item = elem(items, l)

    if comp.(top_item, left_item) do
      items
    else
      swap(items, top, l)
    end
  end

  defp sift_down_lr(items, i, comp) do
    l = left(i)
    r = right(i)

    item = elem(items, i)
    left_item = elem(items, l)
    right_item = elem(items, r)

    if comp.(item, left_item) do
      if comp.(item, right_item) do
        items
      else
        items = swap(items, i, r)
        sift_down(items, r, comp)
      end
    else
      if comp.(left_item, right_item) do
        items = swap(items, i, l)
        sift_down(items, l, comp)
      else
        items = swap(items, i, r)
        sift_down(items, r, comp)
      end
    end
  end
end
