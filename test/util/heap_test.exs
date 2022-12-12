defmodule HeapTest do
  use ExUnit.Case

  test "insert and pop" do
    heap =
      Heap.new()
      |> Heap.push(1)

    {x, heap} = Heap.pop(heap)

    assert x == 1
  end

  test "insert antiordered" do
    heap =
      Heap.new()
      |> Heap.push(5)
      |> Heap.push(4)
      |> Heap.push(3)
      |> Heap.push(2)

    {x, heap} = Heap.pop(heap)
    assert x == 2
    {x, heap} = Heap.pop(heap)
    assert x == 3
    {x, heap} = Heap.pop(heap)
    assert x == 4
    {x, heap} = Heap.pop(heap)
    assert x == 5
  end

  test "insert random" do
    heap =
      Heap.new()
      |> Heap.push(5)
      |> Heap.push(2)
      |> Heap.push(3)
      |> Heap.push(4)

    {x, heap} = Heap.pop(heap)
    assert x == 2
    {x, heap} = Heap.pop(heap)
    assert x == 3
    {x, heap} = Heap.pop(heap)
    assert x == 4
    {x, heap} = Heap.pop(heap)
    assert x == 5
  end

  test "insert two" do
    heap =
      Heap.new()
      |> Heap.push(1)
      |> Heap.push(2)

    {x, heap} = Heap.pop(heap)
    assert x != 2
    {x, heap} = Heap.pop(heap)
    assert x != 1
  end

  test "max heap" do
    heap =
      Heap.new(&(&1 > &2))
      |> Heap.push(3)
      |> Heap.push(1)
      |> Heap.push(2)

    {x, heap} = Heap.pop(heap)
    assert x == 3
    {x, heap} = Heap.pop(heap)
    assert x == 2
    {x, heap} = Heap.pop(heap)
    assert x == 1
  end
end
