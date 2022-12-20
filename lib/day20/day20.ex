defmodule AOC2022.Day20 do
  require Util

  def parse_input(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> elem(Integer.parse(line), 0) end)
    |> Enum.to_list()
    |> Kernel.then(&convert_numbers_to_data/1)
  end

  def convert_numbers_to_data(numbers) do
    indexed_numbers = Enum.with_index(numbers, fn element, index -> {index, element} end)

    n = Enum.count(numbers)

    nodes =
      Enum.reduce(
        indexed_numbers,
        Map.new(),
        fn {i, number}, acc ->
          node = %{
            value: number,
            prev: Integer.mod(i - 1, n),
            next: Integer.mod(i + 1, n)
          }

          Map.put(acc, i, node)
        end
      )

    instructions = indexed_numbers

    %{
      instructions: instructions,
      nodes: nodes
    }
  end

  def apply_instruction(nodes, {_i, 0}) do
    nodes
  end

  def apply_instruction(nodes, {i, offset}) do
    node = Map.get(nodes, i)

    nodes =
      nodes
      |> Map.update!(node.prev, &Map.replace!(&1, :next, node.next))
      |> Map.update!(node.next, &Map.replace!(&1, :prev, node.prev))

    n = Kernel.map_size(nodes)

    offset =
      if offset < 0 do
        rem(offset - 1, n - 1)
      else
        rem(offset, n - 1)
      end

    node_left = traverse(node, nodes, offset)
    node_right = Map.get(nodes, node_left.next)

    i_left = node_right.prev
    i_right = node_left.next

    node =
      node
      |> Map.replace!(:next, i_right)
      |> Map.replace!(:prev, i_left)

    nodes
    |> Map.update!(i_left, &Map.replace!(&1, :next, i))
    |> Map.update!(i_right, &Map.replace!(&1, :prev, i))
    |> Map.put(i, node)
  end

  def traverse(node, _nodes, 0) do
    node
  end

  def traverse(node, nodes, offset) when offset > 0 do
    traverse(Map.get(nodes, node.next), nodes, offset - 1)
  end

  def traverse(node, nodes, offset) when offset < 0 do
    traverse(Map.get(nodes, node.prev), nodes, offset + 1)
  end

  def find(nodes, value) do
    do_find(Map.get(nodes, 0), nodes, value)
  end

  defp do_find(current, nodes, value) do
    cond do
      current.value == value -> current
      true -> do_find(Map.get(nodes, current.next), nodes, value)
    end
  end

  def mix(data) do
    nodes =
      data.instructions
      |> Enum.reduce(
        data.nodes,
        fn instruction, acc ->
          apply_instruction(acc, instruction)
        end
      )

    Map.put(data, :nodes, nodes)
  end

  def get_grove_coordinats(nodes) do
    start = find(nodes, 0)

    Enum.reduce(
      1..3,
      {[], start},
      fn _, {acc, node} ->
        next_node = traverse(node, nodes, 1000)
        {[next_node.value | acc], next_node}
      end
    )
    |> Kernel.then(&elem(&1, 0))
    |> Enum.sum()
  end

  def decrypt(data, decryption_key) do
    instructions =
      Enum.map(
        data.instructions,
        fn {i, shift} -> {i, shift * decryption_key} end
      )

    nodes =
      Enum.reduce(
        data.nodes,
        Map.new(),
        fn {i, node}, acc ->
          Map.put(
            acc,
            i,
            Map.update!(node, :value, &(&1 * decryption_key))
          )
        end
      )

    %{
      instructions: instructions,
      nodes: nodes
    }
  end

  def part1(data) do
    nodes = mix(data).nodes

    get_grove_coordinats(nodes)
  end

  def part2(data) do
    decryption_key = 811_589_153
    decrypted_data = decrypt(data, decryption_key)

    nodes =
      Enum.reduce(
        1..10,
        decrypted_data,
        fn _, acc -> mix(acc) end
      ).nodes

    get_grove_coordinats(nodes)
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
