defmodule RRule do
  use Rustler, otp_app: :rrule, crate: :rrule

  @doc """
  Given an RRule, returns the expanded representation if parsed successfully

  ## Example

  iex> RRule.parse( "DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5")
  "DTSTART:20120101T093000Z\\nFREQ=daily;COUNT=5;BYHOUR=9;BYMINUTE=30;BYSECOND=0"
  """
  def parse(_RRule_string), do: :erlang.nif_error(:not_loaded)

  @doc """
  Given an RRule, return all occurrences between the given UTC DateTimes.

  *Note* Maximum occurrences is limited to 65,535 to avoid order to prevent infinite loops

  ## Example
  RRule.all_between("DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5", ~U[2012-01-01 09:00:00Z], ~U[2012-02-01 09:00:00Z])
  """
  @spec all_between(String.t(), DateTime.t(), DateTime.t()) :: [DateTime.t()]
  def all_between(string, start_date, end_date) do
    all_between(string, start_date, end_date, 65_535)
  end

  @doc """
  Given an RRule, return n occurrences between the given UTC DateTimes, where n is the limit

  *Note* Limit cannot be greater than 65,535
  """
  def all_between(_RRule_string, _start_date, _end_date, _limit),
    do: :erlang.nif_error(:not_loaded)

  @doc """
  Given an RRule string, return the UTC DateTime when the rule starts
  """
  def get_start_date(_rrule_RRule_string), do: :erlang.nif_error(:not_loaded)

  @doc """
  Given a RRule, return a boolean indicating if the rule is valid

  iex> RRule.validate( "DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5")
  :ok

  iex> RRule.validate( "DTSTART:20120101T0930Z\\nRRULE:FREQ=DAILY;COUNT=5")
  {:error,
  "RRule parsing error: `20120101T0930Z` is not a valid datetime format for `DTSTART`."}
  """
  @spec validate(String.t()) :: :ok | {:error, String.t()}
  def validate(_RRule_string), do: :erlang.nif_error(:not_loaded)
end
