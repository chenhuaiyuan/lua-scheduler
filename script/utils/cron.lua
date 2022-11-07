local _M = {}

function _M:add(expression, func)
  local c = cron(expression)
  local sched = {}
  sched.cron = c
  local run_func = function()
    if sched.timestamp == nil then
      local timestamp = sched.cron:next()
      sched.timestamp = timestamp
    end
    -- print(sched.timestamp)
    -- print(os.time())
    if sched.timestamp <= os.time() then
      func()
      sched.timestamp = sched.cron:next()
    end
  end
  sched.func = run_func
  if self._sched == nil then
    self._sched = {}
  end
  table.insert(self._sched, sched)
end

function _M:sched()
  return self._sched
end

return _M
