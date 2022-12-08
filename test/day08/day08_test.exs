defmodule AOC2022.Day08Test do
  use ExUnit.Case
  require Util

  setup do
    test_file_1 = Util.relative_filename("test_input_1")
    test_data_1 = AOC2022.Day08.parse_input(test_file_1)
    [test1: test_data_1]
  end

  test "Part 1", test_data do
    assert AOC2022.Day08.part1(test_data[:test1]) == 21
  end

  test "Part 2", test_data do
    assert AOC2022.Day08.part2(test_data[:test1]) == 8
  end
end
