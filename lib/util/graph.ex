defmodule Graph do
  def adjacency_to_distances(adjacency_matrix) do
    n = Array2D.rows(adjacency_matrix)

    powers =
      Enum.reduce(
        2..n,
        %{0 => Array2D.new(n, n, 0), 1 => adjacency_matrix},
        fn i, acc ->
          prev =
            Map.get(acc, i - 1)

          Map.put(
            acc,
            i,
            Array2D.product(prev, adjacency_matrix)
          )
        end
      )

    Enum.reduce(
      n..1,
      Array2D.new(n, n, 0),
      fn i, acc ->
        Array2D.merge(
          acc,
          Map.get(powers, i),
          fn old, new ->
            if new != 0 do
              i
            else
              old
            end
          end
        )
      end
    )
  end
end
