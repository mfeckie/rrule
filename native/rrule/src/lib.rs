extern crate rustler;
use chrono::prelude::*;
use chrono_tz::{Tz, UTC};
use lazy_static;
use rrule::RRuleSet;
use rustler::{Atom, Encoder, Env, NifStruct, OwnedEnv, Term};

#[rustler::nif]
fn parse<'a>(env: Env<'a>, string: &str) -> Term<'a> {
    let rrule: RRuleSet = string.parse().unwrap();

    (rrule.to_string()).encode(env)
}

lazy_static::lazy_static! {
    static ref CALENDAR_ATOM: Atom = OwnedEnv::new().run(|env| Atom::from_str(env, "Elixir.Calendar.ISO")).unwrap();
}

#[derive(Debug, NifStruct)]
#[module = "NaiveDateTime"]
struct NaiveDateTime {
    calendar: Atom,
    day: u32,
    month: u32,
    year: i32,
    hour: u32,
    minute: u32,
    second: u32,
    microsecond: (i32, i32),
}

#[rustler::nif]
fn all_between<'a>(
    env: Env<'a>,
    string: &str,
    start_date_raw: NaiveDateTime,
    end_date_raw: NaiveDateTime,
) -> Term<'a> {
    let start_date = elixir_date_to_chrono(start_date_raw);

    let end_date = elixir_date_to_chrono(end_date_raw);

    let rrule: RRuleSet = string.parse().unwrap();
    let results = rrule.all_between(start_date, end_date, true).unwrap();

    let mapped: Vec<NaiveDateTime> = results.iter().map(|item| chrono_to_elixir(item)).collect();

    (mapped).encode(env)
}

#[rustler::nif]
fn all<'a>(env: Env<'a>, string: &str, limit: u16) -> Term<'a> {
    let rrule: RRuleSet = string.parse().unwrap();
    let results = rrule.all(limit).unwrap();

    let mapped: Vec<NaiveDateTime> = results.iter().map(|item| chrono_to_elixir(item)).collect();

    (mapped).encode(env)
}

fn elixir_date_to_chrono(input: NaiveDateTime) -> chrono::DateTime<Tz> {
    Utc.ymd(input.year, input.month, input.day)
        .and_hms(input.hour, input.minute, input.second)
        .with_timezone(&UTC)
}

fn chrono_to_elixir(input: &chrono::DateTime<Tz>) -> NaiveDateTime {
    NaiveDateTime {
        calendar: *CALENDAR_ATOM,
        day: input.day(),
        month: input.month(),
        year: input.year(),
        hour: input.hour(),
        minute: input.minute(),
        second: input.second(),
        microsecond: (0, 0),
    }
}

rustler::init!("Elixir.RRule", [all, all_between, parse]);
