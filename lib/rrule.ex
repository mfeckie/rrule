defmodule RRule do
  use Rustler, otp_app: :rrule, crate: :rrule

  @moduledoc """
  Wrapper functions for interacting with the Rust based rrule library
  """

  @spec parse(String.t()) :: String.t()
  @doc """
  Given a RRule, returns the expanded representation if parsed successfully

  ## Example

      iex> RRule.parse( "DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5")
      {:ok, "DTSTART:20120101T093000Z\\nFREQ=daily;COUNT=5;BYHOUR=9;BYMINUTE=30;BYSECOND=0"}
  """
  def parse(_RRule_string), do: :erlang.nif_error(:not_loaded)

  @doc """
  Given a RRule, return all occurrences between the given UTC DateTimes.

  In the success case, the return will be `{:ok, {occurrences, has_more }}`.  The `has_more` boolean is used to inform you if there
  are more occurrences that weren't returned due to the limits.  Generally you'll only care about the `occurrences`

  *Note* Maximum occurrences is limited to 65,535 to avoid order to prevent infinite loops

  ## Example
      iex> RRule.all_between("DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5", ~U[2012-01-01 09:00:00Z], ~U[2012-02-01 09:00:00Z])
      {:ok,
      {[~U[2012-01-01 09:30:00Z], ~U[2012-01-02 09:30:00Z], ~U[2012-01-03 09:30:00Z],
      ~U[2012-01-04 09:30:00Z], ~U[2012-01-05 09:30:00Z]], false}}
  """
  @spec all_between(String.t(), DateTime.t(), DateTime.t()) ::
          {:ok, {[DateTime.t()], boolean()}} | {:error, String.t()}
  def all_between(string, start_date, end_date) do
    all_between(string, start_date, end_date, 65_535)
  end

  @doc """
  Given a RRule, return n occurrences between the given UTC DateTimes, where n is the limit

  *Note* Limit cannot be greater than 65,535
  """
  @spec all_between(String.t(), DateTime.t(), DateTime.t(), integer()) ::
          {:ok, {[DateTime.t()], boolean()}} | {:error, String.t()}
  def all_between(_RRule_string, _start_date, _end_date, _limit),
    do: :erlang.nif_error(:not_loaded)

  @doc """
  Given a RRule string, return the UTC DateTime when the rule starts

  ## Example
      iex> RRule.get_start_date("DTSTART:20120101T093000Z\\nRRULE:FREQ=DAILY;COUNT=5")
      {:ok, ~U[2012-01-01 09:30:00Z]}
  """
  @spec get_start_date(String.t()) :: {:ok, DateTime.t()} | {:error, String.t()}
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
