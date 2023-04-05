local sched = sched()

local function test()
  print('hello world')
end

local function test1()
  print('hello test1')
end

--        sec    min hour day of month  month  day of week  year
sched:add('0/15  *   *    *             *      *            *', test)
sched:add('0 0/1 * * * * *', test1)

return sched
