defmodule RRuleTest do
  use ExUnit.Case
  doctest RRule

  test "Lists occurrences between for RRULE" do
    {:ok, occurrences} =
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

  test "Lists all occurrences with limit for RRULE" do
    {:ok, occurrences} =
      RRule.all(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        1
      )

    assert occurrences == [~N[2012-01-01 09:30:00]]
  end

  test "Reports error for all_between when rule can't be parsed" do
    {:error, msg} =
      RRule.all_between(
        "DTSTART:2012010=DAILY;COUNT=5",
        ~N[2012-01-01 09:00:00],
        ~N[2012-02-01 09:00:00]
      )

    assert msg ==
             "RRule parsing error: `2012010=DAILY;COUNT=5` is not a valid datetime format for `DTSTART`."
  end

  test "Reports error for all when rule can't be parsed" do
    {:error, msg} =
      RRule.all(
        "DTSTART:20120101T093000Z\nRRULE:FREQDAILY;COUNT=5",
        10
      )

    assert msg ==
             "RRule parsing error: `FREQDAILY` is a malformed property parameter. Parameter should be specified as `key=value`"
  end
end
