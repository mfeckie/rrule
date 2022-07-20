defmodule RRuleTest do
  use ExUnit.Case
  doctest RRule

  test "Lists occurrences between for RRULE" do
    occurrences =
      RRule.all_between(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~N[2012-01-01 09:00:00],
        ~N[2012-02-01 09:00:00]
      )

    assert occurrences == [
             ~N[2012-01-01 09:30:00],
             ~N[2012-01-02 09:30:00],
             ~N[2012-01-03 09:30:00],
             ~N[2012-01-04 09:30:00],
             ~N[2012-01-05 09:30:00]
           ]
  end
end
