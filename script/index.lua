local cron = require 'utils.cron'
local calc_fee = require 'calc_fee'
require 'config'
local mysql = loadfile 'orm/mysql.lua'

mysql().new(MYSQL_USER, MYSQL_PASS, MYSQL_HOST)

cron:add('0 15 23 * * * *', calc_fee.calc_warehouse_fee)

return cron:sched()
