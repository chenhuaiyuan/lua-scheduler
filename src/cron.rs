use std::str::FromStr;

use chrono::Local;
use cron::{OwnedScheduleIterator, Schedule};
use mlua::prelude::*;

pub struct Cron(OwnedScheduleIterator<Local>);

pub fn create_cron(lua: &Lua) -> LuaResult<LuaFunction> {
    lua.create_function(|_, expression: String| {
        let schedule = Schedule::from_str(&expression).to_lua_err()?;
        let scheduler = schedule.upcoming_owned(Local);
        Ok(Cron(scheduler))
    })
}

impl LuaUserData for Cron {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(_methods: &mut M) {
        _methods.add_method_mut("next", |_, this, ()| {
            let datetime = this.0.next();
            if let Some(datetime) = datetime {
                Ok(datetime.timestamp())
            } else {
                Ok(0)
            }
        });
    }
}
