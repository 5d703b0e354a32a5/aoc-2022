defmodule Util do
  defmacro relative_filename(filename) do
    quote do
      Path.join(
        Path.dirname(__ENV__.file),
        unquote(filename)
      )
    end
  end
end
