use cron::error::Error as CronError;
use mlua::Error as MluaError;
use mysql_async::{Error as MysqlError, UrlError};
use std::fmt;
use std::num::ParseIntError;
use std::time::SystemTimeError;

#[derive(Debug)]
pub struct Error(String);

pub type Result<T, E = Error> = std::result::Result<T, E>;

impl Error {
    pub fn new<T>(message: T) -> Self
    where
        T: Into<String>,
    {
        Self(message.into())
    }
}

impl std::error::Error for Error {}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl From<UrlError> for Error {
    fn from(value: UrlError) -> Self {
        Error::new(value.to_string())
    }
}

impl From<SystemTimeError> for Error {
    fn from(value: SystemTimeError) -> Self {
        Error::new(value.to_string())
    }
}

impl From<ParseIntError> for Error {
    fn from(value: ParseIntError) -> Self {
        Error::new(value.to_string())
    }
}

impl From<MysqlError> for Error {
    fn from(value: MysqlError) -> Self {
        Error::new(value.to_string())
    }
}

impl From<MluaError> for Error {
    fn from(value: MluaError) -> Self {
        Error::new(value.to_string())
    }
}

impl From<CronError> for Error {
    fn from(value: CronError) -> Self {
        Error::new(value.to_string())
    }
}
