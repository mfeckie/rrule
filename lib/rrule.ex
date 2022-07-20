defmodule RRule do
  use Rustler, otp_app: :rrule, crate: :rrule

  def parse(_string), do: :erlang.nif_error(:not_loaded)
  def all_between(_string, _start_date, _end_date), do: :erlang.nif_error(:not_loaded)
end
