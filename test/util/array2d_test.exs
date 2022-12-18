defmodule Array2DTest do
  use ExUnit.Case

  test "product" do
    m1 = {{1}, {2}}
    m2 = {{3, 4}}

    assert Array2D.product(m1, m2) == {{3, 4}, {6, 8}}
    assert Array2D.product(m2, m1) == {{11}}
  end
end
