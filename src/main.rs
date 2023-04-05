mod error;
#[cfg(feature = "mysql")]
mod mysql;
mod sched;
#[cfg(feature = "time")]
mod time; // 目前没什么用

use crate::error::Result;
#[cfg(feature = "mysql")]
use crate::mysql::create_mysql;
use crate::sched::create_sched;
use crate::sched::Sched;
use clap::Parser;
use mlua::prelude::*;

#[derive(Parser, Debug)]
struct Args {
    #[arg(short, long, default_value = "index.lua")]
    file: String,
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<()> {
    let args = Args::parse();
    let lua = Lua::new();

    let globals = lua.globals();
    globals.set("sched", create_sched(&lua)?)?;
    #[cfg(feature = "mysql")]
    globals.set("mysql", create_mysql(lua)?)?;

    let file = tokio::fs::read_to_string(args.file)
        .await
        .expect("read file failed");

    let handler: LuaAnyUserData = lua.load(&file).eval()?;
    let tasks = handler.take::<Sched>()?;
    let local = tokio::task::LocalSet::new();
    for task in tasks.0 {
        local.spawn_local(async move {
            let _ = task.await;
        });
    }
    local.await;
    Ok(())
}
