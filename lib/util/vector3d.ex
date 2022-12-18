defmodule Vector3D do
  def add({x1, y1, z1}, {x2, y2, z2}) do
    {x1 + x2, y1 + y2, z1 + z2}
  end

  def scale({x, y, z}, s) do
    {s * x, s * y, s * z}
  end
end
