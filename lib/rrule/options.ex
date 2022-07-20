defmodule Rrule.Options do
  @moduledoc """
  freq: Frequency
  interval: u16
  until: DateTime
  byweekday: Vec<NWeekDay>

  pub enum Frequency {
    Yearly,
    Monthly,
    Weekly,
    Daily,
    Hourly,
    Minutely,
    Secondly,
  }

  pub enum NWeekday {
    Every(Weekday),
    Nth(i16, Weekday),
  }
  """

  defstruct [:freq, :interval, :until, :byweekday]
end
