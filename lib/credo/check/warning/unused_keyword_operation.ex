defmodule Credo.Check.Warning.UnusedKeywordOperation do
  @moduledoc """
  The result of a call to the Keyword module's functions has to be used.

  # TODO: write example

  Keyword operations never work on the variable you pass in, but return a new
  variable which has to be used somehow.
  """

  @explanation [check: @moduledoc]

  alias Credo.Check.Warning.UnusedFunctionReturnHelper

  use Credo.Check, base_priority: :high

  @doc false
  def run(%SourceFile{} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    all_unused_calls =
      UnusedFunctionReturnHelper.find_unused_calls(source_file, params,
                                                                [:Keyword], nil)

    all_unused_calls
    |> Enum.reduce([], fn(invalid_call, issues) ->
        {_, meta, _} = invalid_call
        trigger =
          invalid_call
          |> Macro.to_string
          |> String.split("(")
          |> List.first
        issues ++ [issue_for(meta[:line], trigger, issue_meta)]
      end)
  end

  defp issue_for(line_no, trigger, issue_meta) do
    format_issue issue_meta,
      message: "There should be no unused return values for Keyword functions.",
      trigger: trigger,
      line_no: line_no
  end
end
