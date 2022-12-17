defmodule CircleBufferTest do
  use ExUnit.Case

  test "once around" do
    cb = CircleBuffer.new([1, 2])

    {val, cb} = CircleBuffer.next(cb)
    assert val == 1
    {val, cb} = CircleBuffer.next(cb)
    assert val == 2
    {val, cb} = CircleBuffer.next(cb)
    assert val == 1
    {val, cb} = CircleBuffer.next(cb)
    assert val == 2
  end
end
