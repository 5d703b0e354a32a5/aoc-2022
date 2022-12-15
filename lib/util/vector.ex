defmodule Vector do
  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def subtract({x1, y1}, {x2, y2}) do
    {x1 - x2, y1 - y2}
  end

  def scale({x1, y1}, s) do
    {s * x1, s * y1}
  end

  def norm(v) do
    :math.sqrt(Vector.dot(v, v))
  end

  def normalize(v = {x1, y1}) do
    n = norm(v)
    {x1 / n, y1 / n}
  end

  def dot({x1, y1}, {x2, y2}) do
    x1 * x2 + y1 * y2
  end
end
