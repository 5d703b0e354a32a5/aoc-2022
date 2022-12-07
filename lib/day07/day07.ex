defmodule AOC2022.Day07 do
  require Util

  def parse_input(filename) do
    {[], acc} =
      filename
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()
      |> do_parse_input(%{})

    acc
  end

  def do_parse_input([], acc) do
    {[], acc}
  end

  def do_parse_input(["$ cd .." | remaining], acc) do
    {remaining, acc}
  end

  def do_parse_input(["$ cd " <> dirname | rest], acc) do
    {remaining, content} = do_parse_input(rest, %{})

    acc =
      Map.put(acc, dirname, %{
        type: :dir,
        content: content
      })

    do_parse_input(remaining, acc)
  end

  def do_parse_input(["$ ls" | rest], acc) do
    do_parse_input(rest, acc)
  end

  def do_parse_input(["dir " <> dirname | rest], acc) do
    acc = Map.put(acc, dirname, %{type: :dir, content: %{}})
    do_parse_input(rest, acc)
  end

  def do_parse_input([fileinfo | rest], acc) do
    %{
      "filename" => filename,
      "size" => size
    } = Regex.named_captures(~r/^(?<size>\d+) (?<filename>.*)$/, fileinfo)

    {size, ""} = Integer.parse(size)

    file = %{
      type: :file,
      size: size
    }

    acc = Map.put(acc, filename, file)
    do_parse_input(rest, acc)
  end

  def calculate_dir_sizes(fs) do
    Enum.reduce(fs, %{}, fn {name, meta}, acc ->
      case meta.type do
        :file ->
          Map.put(acc, name, meta)

        :dir ->
          content = calculate_dir_sizes(meta.content)
          size = calculate_content_size(content)

          Map.put(acc, name, %{
            type: :dir,
            content: content,
            size: size
          })
      end
    end)
  end

  def calculate_content_size(content) do
    Enum.reduce(content, 0, fn {_name, %{size: size}}, acc -> acc + size end)
  end

  def get_directory_sizes(fs) do
    dirs =
      fs
      |> Enum.filter(fn {name, meta} -> meta.type == :dir end)

    current = Enum.map(dirs, fn {name, meta} -> {name, meta.size} end)

    lower =
      Enum.flat_map(
        dirs,
        fn {_name, meta} -> get_directory_sizes(meta.content) end
      )

    current ++ lower
  end

  def part1(data) do
    size_limit = 100_000

    data
    |> calculate_dir_sizes()
    |> get_directory_sizes()
    |> Enum.filter(fn {_name, size} -> size <= size_limit end)
    |> Enum.reduce(0, fn {_dirname, size}, acc -> acc + size end)
  end

  def part2(data) do
    space_total = 70_000_000
    space_needed = 30_000_000

    sizes =
      data
      |> calculate_dir_sizes()
      |> get_directory_sizes()

    [{"/", root_size}] = Enum.filter(sizes, fn {name, _meta} -> name == "/" end)

    space_free = space_total - root_size
    space_to_free = space_needed - space_free

    sizes
    |> Stream.map(fn {_name, size} -> size end)
    |> Stream.filter(fn size -> size >= space_to_free end)
    |> Enum.min()
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
