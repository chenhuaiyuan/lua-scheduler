local mysql = loadfile 'orm/mysql.lua'
local datetime = require 'utils.datetime'

local _M = {}

local WAREHOUSE_FEE = { { { 8, 15 }, 0.5 }, { { 16, 30 }, 0.65 }, { { 31, 60 }, 1.0 }, { { 61, 90 }, 1.5 },
  { { 91, 120 }, 2.5 }, { { 121, 150 }, 3.5 }, { { 150, 0 }, 4.5 } }

function _M.calc_warehouse_fee()
  local date = os.date('%Y-%m-%d', datetime.time_by_day(-7))
  local data = mysql().db('cena_checkin_task'):columns('identifier', 'total_volume', 'length', 'width', 'height',
    'completion_time', 'quantity', 'user_nid'):where('status', '!=', 3):where('completion_time', '<', date):find_all()
  local timestamp = os.time()
  for _, val in ipairs(data) do
    local completion_time = datetime.time_by_date(val.completion_time)
    local sec = timestamp - completion_time
    local day_sec = 3600 * 24
    -- local remainder = sec % daySec
    local day = sec // day_sec
    -- if remainder == 0 then
    --   day = sec // daySec
    -- else
    --   day = sec // daySec + 1
    -- end
    for _, fee in ipairs(WAREHOUSE_FEE) do
      if fee[0][0] <= day <= fee[0][1] then
        local warehouse_fee = 0
        if val.total_volume >= 0 then
          warehouse_fee = val.quantity * val.total_volume * fee[1]
        elseif val.length >= 0 and val.width >= 0 and val.height >= 0 then
          warehouse_fee = val.length * val.width * val.height * val.quantity * fee[1]
        else
          warehouse_fee = 0
        end

        if warehouse_fee > 0 then
          local t = os.time()
          local insert_data = {
            ['identifier'] = val.identifier,
            ['name'] = '仓储费',
            ['description'] = '仓储费',
            ['quantity'] = val.quantity,
            ['rate'] = warehouse_fee,
            ['user_nid'] = val.user_nid,
            ['created_at'] = t,
            ['updated_at'] = t
          }
          mysql().db('cena_bills'):insert(insert_data)
        end
      end
    end
  end
end

return _M
