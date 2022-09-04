extern crate rustler;
use chrono::{DateTime, Datelike, TimeZone, Timelike};
use rrule::{RRuleSet, Tz};
use rustler::{Atom, Encoder, Env, NifStruct, Term};

#[rustler::nif]
fn parse<'a>(env: Env<'a>, string: &str) -> Result<Term<'a>, String> {
    // let rrule: RRuleSet = string.parse().unwrap();

    // (rrule.to_string()).encode(env)
    let parsed: String = match string.parse::<RRuleSet>() {
        Ok(rrule) => rrule.to_string(),
        Err(err) => return Err(format!("{}", err)),
    };

    Ok((parsed).encode(env))
}

mod atoms {
    rustler::atoms! {
        calendar_iso = "Elixir.Calendar.ISO"
    }
}

// __struct__: DateTime,
// calendar: Calendar.ISO,
// day: 23,
// hour: 1,
// microsecond: {490236, 6},
// minute: 23,
// month: 7,
// second: 15,
// std_offset: 0,
// time_zone: "Etc/UTC",
// utc_offset: 0,
// year: 2022,
// zone_abbr: "UTC"
#[derive(Debug, NifStruct)]
#[module = "DateTime"]
struct ElixirDateTime {
    calendar: Atom,
    day: u32,
    month: u32,
    year: i32,
    hour: u32,
    minute: u32,
    second: u32,
    microsecond: (i32, i32),
    std_offset: i32,
    utc_offset: i32,
    time_zone: String,
    zone_abbr: String,
}

impl ElixirDateTime {
    pub fn new(input: &DateTime<Tz>) -> ElixirDateTime {
        ElixirDateTime {
            calendar: atoms::calendar_iso(),
            day: input.naive_utc().day(),
            month: input.naive_utc().month(),
            year: input.naive_utc().year(),
            hour: input.naive_utc().hour(),
            minute: input.naive_utc().minute(),
            second: input.naive_utc().second(),
            microsecond: (0, 0),
            std_offset: 0,
            utc_offset: 0,
            time_zone: "Etc/UTC".to_string(),
            zone_abbr: "UTC".to_string(),
        }
    }

    fn to_chrono(&self) -> DateTime<Tz> {
        Tz::UTC
            .ymd(self.year, self.month, self.day)
            .and_hms(self.hour, self.minute, self.second)
    }
}

#[rustler::nif]
fn all<'a>(env: Env<'a>, string: &str, limit: u64) -> Result<Term<'a>, String> {
    if limit > 65535 {
        return Err(format!("Limit must be below 65,535"))
    }

    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let (results, _has_more) = rrule
    .all(limit as u16);

    let mapped: Vec<ElixirDateTime> = results.iter().map(ElixirDateTime::new).collect();

    Ok((mapped).encode(env))
}

#[rustler::nif]
fn all_between<'a>(
    env: Env<'a>,
    string: &str,
    start_date: ElixirDateTime,
    end_date: ElixirDateTime,
    limit: u16,
) -> Result<Term<'a>, String> {
    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let (results, has_more) = rrule
        .after(start_date.to_chrono())
        .before(end_date.to_chrono())
        .all(limit);

    let mapped: Vec<ElixirDateTime> = results.iter().map(ElixirDateTime::new).collect();
    Ok(((mapped, has_more)).encode(env))
}

#[rustler::nif]
fn validate<'a>(env: Env<'a>, rrule: &str) -> Term<'a> {
    match rrule.parse::<RRuleSet>() {
        Ok(_parsed) => (rustler::types::atom::ok()).encode(env),
        Err(err) => (rustler::types::atom::error(), format!("{}", err)).encode(env),
    }
}

#[rustler::nif]
fn get_start_date<'a>(env: Env<'a>, rrule: &str) -> Result<Term<'a>, String> {
    let parsed_rule = match rrule.parse::<RRuleSet>() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let start_date_time = ElixirDateTime::new(parsed_rule.get_dt_start());

    Ok((start_date_time).encode(env))
}

rustler::init!(
    "Elixir.RRule",
    [all, all_between, get_start_date, parse, validate]
);
