use crate::error::{Error, Result};
use mlua::prelude::*;
use std::time::SystemTime;

pub struct Datetime {
    pub year: i32,
    pub month: i32,
    pub day: i32,
    pub hour: i32,
    pub min: i32,
    pub sec: i32,
    time_zone: i32,
}

impl Datetime {
    pub fn new(time_zone: i32) -> Result<Datetime> {
        let timestamp = Self::timestamp()?;
        Self::new_by_timestamp(timestamp, time_zone)
    }
    pub fn new_by_timestamp(timestamp: u64, time_zone: i32) -> Result<Self> {
        let days = 24 * 3600;
        let four_years = 365 * 3 + 366;
        let days = timestamp / days + u64::from((timestamp % days) != 0);
        let year_4 = days / four_years;
        let mut remain = days % four_years;
        let mut year = 1970 + year_4 * 4;

        let mut is_leap_year = false;

        if (365..365 * 2).contains(&remain) {
            year += 1;
            remain -= 365;
        } else if (365 * 2..365 * 3).contains(&remain) {
            year += 2;
            remain -= 365 * 2;
        } else if 365 * 3 <= remain {
            year += 3;
            remain -= 365 * 3;
            is_leap_year = true;
        }

        let (month, day) = get_month_day(is_leap_year, remain as i32);
        let (h, m, s) = get_hour_min_sec(timestamp, 8);
        Ok(Datetime {
            year: year as i32,
            month,
            day,
            hour: h,
            min: m,
            sec: s,
            time_zone,
        })
    }

    pub fn new_by_day(day: i32, time_zone: i32) -> Result<Self> {
        let mut timestamp = Self::timestamp()?;
        if day < 0 {
            let day = day.abs();
            let day_sec = (24 * 3600 * day) as u64;
            timestamp -= day_sec;
        } else {
            let day_sec = (24 * 3600 * day) as u64;
            timestamp += day_sec;
        }
        Self::new_by_timestamp(timestamp, time_zone)
    }
    pub fn new_by_date<S: Into<String>>(year: S, month: S, day: S, time_zone: i32) -> Result<Self> {
        let year = year.into().parse::<i32>()?;
        let month = month.into().parse::<i32>()?;
        let day = day.into().parse::<i32>()?;
        Ok(Datetime {
            year,
            month,
            day,
            hour: 0,
            min: 0,
            sec: 0,
            time_zone,
        })
    }
    pub fn timestamp() -> Result<u64> {
        Ok(SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)?
            .as_secs())
    }
    pub fn to_timestamp(self) -> Result<u64> {
        let mut sec = year_month_day_to_second(self.year, self.month, self.day);
        let second = hour_min_sec_to_second(self.hour, self.min, self.sec, self.time_zone);
        if second < 0 {
            sec -= (second.abs()) as u64;
        } else {
            sec += second as u64;
        }
        Ok(sec)
    }
    pub fn simple_datetime_format(self) -> Result<String> {
        Ok(format!(
            "{}-{:>02}-{:>02} {:>02}:{:>02}:{:>02}",
            self.year, self.month, self.day, self.hour, self.min, self.sec,
        ))
    }
    pub fn simple_time_format(self) -> Result<String> {
        Ok(format!(
            "{:>02}:{:>02}:{:>02}",
            self.hour, self.min, self.sec
        ))
    }
    pub fn simple_date_format(self) -> Result<String> {
        Ok(format!("{}-{:>02}-{:>02}", self.year, self.month, self.day))
    }
}

fn get_hour_min_sec(timestamp: u64, time_zone: u64) -> (i32, i32, i32) {
    let hour = ((timestamp % (24 * 3600)) / 3600 + time_zone) % 24; // 东八区时间
    let min = (timestamp % 3600) / 60;
    let sec = (timestamp % 3600) % 60;
    (hour as i32, min as i32, sec as i32)
}
fn get_month_day(is_leap_year: bool, mut days: i32) -> (i32, i32) {
    let p_month: [i32; 12] = if is_leap_year {
        [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    } else {
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };
    let mut day = 0;
    let mut month = 0;

    for (i, v) in p_month.iter().enumerate() {
        let temp = days - v;
        if temp <= 0 {
            month = i + 1;
            day = if temp == 0 { *v } else { days };
            break;
        }
        days = temp;
    }

    (month as i32, day)
}

fn is_leap_year(year: i32) -> bool {
    (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0)
}

fn hour_min_sec_to_second(hour: i32, min: i32, sec: i32, time_zone: i32) -> i32 {
    (hour * 3600 + min * 60 + sec) - time_zone * 3600
}

fn year_month_day_to_second(year: i32, month: i32, day: i32) -> u64 {
    let p_month: [i32; 12] = if is_leap_year(year) {
        [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    } else {
        [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };
    let mut days = -1;
    let m = month as usize;
    for i in 0..m {
        days += p_month[i];
    }
    let year_number = year - 1970;
    let four_years = 365 * 3 + 366;
    let year_4_num = year_number / 4;
    let surplus_year = year_number % 4;
    days += year_4_num * four_years + surplus_year * four_years + day;
    (days * 24 * 3600) as u64
}
