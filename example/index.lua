local sched = sched()
local time = os.time

local function test()
  print('hello world; timestamp =', time())
end

local function test1()
  print('hello test1; timestamp =', time())
end

--        sec    min hour day of month  month  day of week  year
sched:add('0/15  *   *    *             *      *            *', test)
sched:add('0 0/1 * * * * *', test1)

return sched
