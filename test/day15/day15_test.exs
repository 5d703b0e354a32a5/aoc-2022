defmodule AOC2022.Day15Test do
  use ExUnit.Case
  require Util

  setup do
    test_file_1 = Util.relative_filename("test_input_1")
    test_data_1 = AOC2022.Day15.parse_input(test_file_1)
    [test1: test_data_1]
  end

  test "Part 1", test_data do
    assert AOC2022.Day15.part1(test_data[:test1], 10) == 26
  end

  test "Part 2", test_data do
    assert AOC2022.Day15.part2(test_data[:test1], 20) == 56_000_011
  end
end
