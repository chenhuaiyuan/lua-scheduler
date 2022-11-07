local _M = {}


function _M.time_by_day(day)
  local timestamp = os.time()
  if day < 0 then
    local day_abs = math.abs(day)
    local day_sec = 24 * 3600 * day_abs
    timestamp = timestamp - day_sec
  else
    local day_sec = 24 * 3600 * day
    timestamp = timestamp - day_sec
  end
  return timestamp
end

function _M.time_by_date(date)
  local _, _, y, m, d = string.find(date, '(%d+)-(%d+)-(%d+)')
  print(y)
  print(m)
  print(d)
  local timestamp = os.time({ year = y, month = m, day = d })
  return timestamp
end

return _M
