defmodule Issues.TableFormatter do
  import Enum, only: [ each: 2, map: 2, map_join: 3, max: 1 ]
  
  def print_table_for_columns(rows, headers) do
    with data_by_columns = split_into_columns(rows, headers),
         column_widths   = widths_of(data_by_columns),
         format          = format_for(column_widths)
    do
      puts_one_line_in_columns(headers, format)
      IO.puts(separator(column_widths))
      puts_in_columns(data_by_columns, format)
    end
  end
  
  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  @doc """
    Return a binary (string) version of our parameter.
    ## Examples
      iex> Issues.TableFormatter.printable("a")
      "a"
      iex> Issues.TableFormatter.printable(99)
      "99"
  """
  def printable(str) when is_binary(str), do: str
  
  def printable(str), do: to_string(str)
  
  @doc """
  Given a list containing sublists, where each sublist contains the data for
  a column, return a list containing the maximum width of each column
  ## Example
    iex> data = [ [ "cat", "wombat", "elk"], ["mongoose", "ant", "gnu"]]
    iex> Issues.TableFormatter.widths_of(data)
    [ 6, 8 ]
  """
  def widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  @doc """
  Return a format string that hard codes the widths of a set of columns.
  We put `" | "` between each column.
  ## Example
    iex> widths = [5,6,99]
    iex> Issues.TableFormatter.format_for(widths)
    "~-5s | ~-6s | ~-99s~n"
  """
  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end
  
  @doc """
  Generate the line that goes below the column headings. It is a string of
  hyphens, with + signs where the vertical bar between the columns goes.
  ## Example
  iex> widths = [5,6,9]
  iex> Issues.TableFormatter.separator(widths)
  "------+--------+----------"
  """
  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end
  
  @doc """
  Given a list containing rows of data, a list containing the header selectors,
  and a format string, write the extracted data under control of the format string.
  """
  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end
  
  def puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end