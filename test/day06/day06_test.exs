defmodule AOC2022.Day06Test do
  use ExUnit.Case
  require Util

  setup do
    Enum.reduce(
      1..5,
      [],
      fn i, acc ->
        test_file = Util.relative_filename("test_input_" <> to_string(i))
        test_data = AOC2022.Day06.parse_input(test_file)
        test_name = String.to_atom("test" <> to_string(i))
        [{test_name, test_data} | acc]
      end
    )
  end

  test "Part 1", test_data do
    assert AOC2022.Day06.part1(test_data[:test1]) == 7
    assert AOC2022.Day06.part1(test_data[:test2]) == 5
    assert AOC2022.Day06.part1(test_data[:test3]) == 6
    assert AOC2022.Day06.part1(test_data[:test4]) == 10
    assert AOC2022.Day06.part1(test_data[:test5]) == 11
  end

  test "Part 2", test_data do
    assert AOC2022.Day06.part2(test_data[:test1]) == 19
    assert AOC2022.Day06.part2(test_data[:test2]) == 23
    assert AOC2022.Day06.part2(test_data[:test3]) == 23
    assert AOC2022.Day06.part2(test_data[:test4]) == 29
    assert AOC2022.Day06.part2(test_data[:test5]) == 26
  end
end
