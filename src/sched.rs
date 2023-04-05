use crate::error::Result;
use chrono::{Duration, Local};
use cron::Schedule;
use mlua::prelude::*;
use std::{future::Future, pin::Pin, str::FromStr};
use tokio::time::sleep;

pub struct Sched(pub Vec<Pin<Box<dyn Future<Output = Result<()>>>>>);

pub fn create_sched(lua: &Lua) -> LuaResult<LuaFunction> {
    lua.create_function(|_, ()| Ok(Sched(Vec::new())))
}

impl LuaUserData for Sched {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(_methods: &mut M) {
        _methods.add_method_mut(
            "add",
            |_, this, (expression, func): (String, LuaFunction)| {
                let func: LuaFunction<'static> = unsafe { std::mem::transmute(func) };
                let schedule = Schedule::from_str(&expression).to_lua_err()?;
                let mut scheduler = schedule.upcoming_owned(Local);
                let zero = Duration::zero();
                let fut = async move {
                    while let Some(datetime) = scheduler.next() {
                        let now = Local::now();
                        let dur = datetime - now;
                        if dur > zero {
                            let dur = dur.to_std().to_lua_err()?;
                            sleep(dur).await;
                            func.call_async(()).await.to_lua_err()?;
                        }
                    }
                    Ok(())
                };
                this.0.push(Box::pin(fut));
                Ok(())
            },
        );
    }
}
