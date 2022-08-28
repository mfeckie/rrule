defmodule RRule do
  use Rustler, otp_app: :rrule, crate: :rrule

  def parse(_string), do: :erlang.nif_error(:not_loaded)
  def all(_string, _limit), do: :erlang.nif_error(:not_loaded)
  def all_between(_string, _start_date, _end_date, _inclusive), do: :erlang.nif_error(:not_loaded)
  def get_start_date(_rrule_string), do: :erlang.nif_error(:not_loaded)
  def just_before(_string, _date, _inclusive), do: :erlang.nif_error(:not_loaded)
  def just_after(_string, _date, _inclusive), do: :erlang.nif_error(:not_loaded)
  def validate(_string), do: :erlang.nif_error(:not_loaded)
end
