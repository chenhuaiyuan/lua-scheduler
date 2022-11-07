mod cron;
mod error;
mod mysql;
mod time;

use crate::cron::create_cron;
use crate::error::Result;
use clap::Parser;
// use cron::{Schedule, ScheduleIterator};
use crate::mysql::MysqlPool;
use mlua::prelude::*;
use std::time::Duration;
use tokio::time::sleep;

#[derive(Parser, Debug)]
struct Args {
    #[arg(short, long)]
    file: String,
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<()> {
    let args = Args::parse();
    let lua = Lua::new();

    let globals = lua.globals();
    globals.set("cron", create_cron(&lua)?)?;
    globals.set("mysql_pool", lua.create_proxy::<MysqlPool>()?)?;

    let file = tokio::fs::read_to_string(args.file)
        .await
        .expect("read file failed");

    let handlers: LuaTable = lua.load(&file).eval()?;
    loop {
        let h = handlers.clone();
        for pair in h.pairs::<LuaValue, LuaTable>() {
            let (_, sched) = pair?;
            let func: LuaFunction = sched.get("func")?;
            func.call_async(()).await?;
        }
        sleep(Duration::from_millis(1000)).await;
    }
    Ok(())
}
