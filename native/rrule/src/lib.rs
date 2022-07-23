extern crate rustler;
use chrono::prelude::*;
use chrono_tz::{Tz, UTC};
use rrule::RRuleSet;
use rustler::{Atom, Encoder, Env, NifStruct, Term};

#[rustler::nif]
fn parse<'a>(env: Env<'a>, string: &str) -> Term<'a> {
    let rrule: RRuleSet = string.parse().unwrap();

    (rrule.to_string()).encode(env)
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
struct DateTime {
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
    zone_abbr: String
}

impl DateTime {
    pub fn new(input: &chrono::DateTime<Tz>) -> DateTime {
        DateTime {
            calendar: atoms::calendar_iso(),
            day: input.day(),
            month: input.month(),
            year: input.year(),
            hour: input.hour(),
            minute: input.minute(),
            second: input.second(),
            microsecond: (0, 0),
            std_offset: 0,
            utc_offset: 0,
            time_zone: "Etc/UTC".to_string(),
            zone_abbr: "UTC".to_string()
        }
    }

    fn to_chrono(&self) -> chrono::DateTime<Tz> {
        Utc.ymd(self.year, self.month, self.day)
            .and_hms(self.hour, self.minute, self.second)
            .with_timezone(&UTC)
    }
}

#[rustler::nif]
fn all_between<'a>(
    env: Env<'a>,
    string: &str,
    start_date: DateTime,
    end_date: DateTime,
) -> Result<Term<'a>, String> {
    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let results = match rrule.all_between(start_date.to_chrono(), end_date.to_chrono(), true) {
        Ok(matched) => matched,
        Err(err) => return Err(format!("{}", err)),
    };

    let mapped: Vec<DateTime> = results.iter().map(DateTime::new).collect();
    Ok((mapped).encode(env))
}

#[rustler::nif]
fn all<'a>(env: Env<'a>, string: &str, limit: u16) -> Result<Term<'a>, String> {
    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let results = match rrule.all(limit) {
        Ok(matched) => matched,
        Err(err) => return Err(format!("{}", err)),
    };

    let mapped: Vec<DateTime> = results.iter().map(DateTime::new).collect();

    Ok((mapped).encode(env))
}

#[rustler::nif]
fn just_after<'a>(
    env: Env<'a>,
    string: &str,
    after: DateTime,
    inclusive: bool,
) -> Result<Term<'a>, String> {
    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let result = match rrule.just_after(after.to_chrono(), inclusive) {
        Ok(matched) => match matched {
            Some(result) => result,
            None => return Err("No matches found".to_string()),
        },
        Err(err) => return Err(format!("{}", err)),
    };

    Ok((DateTime::new(&result)).encode(env))
}

#[rustler::nif]
fn just_before<'a>(
    env: Env<'a>,
    string: &str,
    before: DateTime,
    inclusive: bool,
) -> Result<Term<'a>, String> {
    let rrule: RRuleSet = match string.parse() {
        Ok(parsed) => parsed,
        Err(err) => return Err(format!("{}", err)),
    };

    let result = match rrule.just_before(before.to_chrono(), inclusive) {
        Ok(matched) => match matched {
            Some(result) => result,
            None => return Err("No matches found".to_string()),
        },
        Err(err) => return Err(format!("{}", err)),
    };

    Ok((DateTime::new(&result)).encode(env))
}

#[rustler::nif]
fn validate<'a>(env: Env<'a>, rrule: &str) -> Term<'a> {
    match rrule.parse::<RRuleSet>() {
        Ok(_parsed) => (rustler::types::atom::ok()).encode(env),
        Err(err) => (rustler::types::atom::error(), format!("{}", err)).encode(env),
    }
}

rustler::init!(
    "Elixir.RRule",
    [all, all_between, just_after, just_before, parse, validate]
);
