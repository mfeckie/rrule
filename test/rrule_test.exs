defmodule RRuleTest do
  use ExUnit.Case, async: true
  doctest RRule

  test "Lists occurrences between for RRULE" do
    {:ok, occurrences} =
      RRule.all_between(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-02-01 09:00:00Z],
        true
      )

    assert occurrences == [
             ~U[2012-01-01 09:30:00Z],
             ~U[2012-01-02 09:30:00Z],
             ~U[2012-01-03 09:30:00Z],
             ~U[2012-01-04 09:30:00Z],
             ~U[2012-01-05 09:30:00Z]
           ]
  end

  test "Lists occurrences between for RRULESET" do
    {:ok, occurrences} =
      RRule.all_between(
        ~s(DTSTART:20120101T093000Z\nRRULE:FREQ=MONTHLY;COUNT=5\nRDATE:20120201T023000Z,20120702T023000Z\nEXRULE:FREQ=MONTHLY;COUNT=2\nEXDATE:20120601T023000Z),
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-12-01 09:00:00Z],
        true
      )

    assert occurrences == [
             ~U[2012-02-01 02:30:00Z],
             ~U[2012-03-01 09:30:00Z],
             ~U[2012-04-01 09:30:00Z],
             ~U[2012-05-01 09:30:00Z],
             ~U[2012-07-02 02:30:00Z]
           ]
  end

  test "Lists all occurrences with limit for RRULE" do
    {:ok, occurrences} =
      RRule.all(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        1
      )

    assert occurrences == [~U[2012-01-01 09:30:00Z]]
  end

  test "Reports error for all_between when rule can't be parsed" do
    {:error, msg} =
      RRule.all_between(
        "DTSTART:2012010=DAILY;COUNT=5",
        ~U[2012-01-01 09:00:00Z],
        ~U[2012-02-01 09:00:00Z],
        true
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

  test "Gets occurrence just_before date" do
    {:ok, occurrences} =
      RRule.just_before(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2012-02-01 09:30:00Z],
        true
      )

    assert occurrences == ~U[2012-01-05 09:30:00Z]
  end

  test "Gets occurrence just_after date" do
    {:ok, occurrences} =
      RRule.just_after(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2012-01-01 09:30:00Z],
        true
      )

    assert occurrences == ~U[2012-01-01 09:30:00Z]
  end

  test "Error tuple for just_after when no results" do
    {:error, msg} =
      RRule.just_after(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2012-02-01 09:30:00Z],
        true
      )

    assert msg == "No matches found"
  end

  test "Error tuple for just_before when no results" do
    {:error, msg} =
      RRule.just_before(
        "DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5",
        ~U[2011-02-01 09:30:00Z],
        true
      )

    assert msg == "No matches found"
  end

  test "Validates RRULE" do
    assert :ok ==
             RRule.validate("DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")
  end

  test "Error for invalid RRULE" do
    assert {:error,
            "RRule parsing error: `DTSTA` is not a valid property name, expected one of: `RRULE,EXRULE,DTSTART,RDATE,EXDATE`"} ==
             RRule.validate("DTSTA:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")
  end

  test "Retrieve DTSTART for RRULE" do
    {:ok, start_date} = RRule.get_start_date("DTSTART:20120101T093000Z\nRRULE:FREQ=DAILY;COUNT=5")

    assert start_date == ~U[2012-01-01 09:30:00Z]
  end
end
