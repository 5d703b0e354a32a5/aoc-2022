defmodule AOC2022.Day09Test do
  use ExUnit.Case
  require Util

  setup do
    Enum.reduce(
      1..2,
      [],
      fn i, acc ->
        test_file = Util.relative_filename("test_input_" <> to_string(i))
        test_data = AOC2022.Day09.parse_input(test_file)
        test_name = String.to_atom("test" <> to_string(i))
        [{test_name, test_data} | acc]
      end
    )
  end

  test "Part 1", test_data do
    assert AOC2022.Day09.part1(test_data[:test1]) == 13
  end

  test "Part 2", test_data do
    assert AOC2022.Day09.part2(test_data[:test1]) == 1
    assert AOC2022.Day09.part2(test_data[:test2]) == 36
  end
end
