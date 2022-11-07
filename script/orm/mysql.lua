local mysql = {}

local operator = { "=", ">", "<", ">=", "<=", "!=", "LIKE", "NOT LIKE", "REGEXP", "NOT REGEXP", "RLIKE",
  "NOT RLIKE" }

---数组合并
---@param t1 table
---@param t2 table
---@return table
local function array_merge(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

---判断是否包含
---@param oper string
---@return boolean
function operator.contain(oper)
  for _, v in pairs(operator) do
    if type(v) == 'string' and v == oper:upper() then
      return true
    end
  end
  return false
end

function mysql.new(user, pass, host)
  _MYSQL = mysql_pool.new(user or MYSQL_USER, pass or MYSQL_PASS, host or MYSQL_HOST)
end

---数据库
---@param db string|nil
---@param table string
---@return table
function mysql.db(table, db)
  -- print(mysql._table)
  -- mysql._columns = nil;
  -- mysql._limit = nil;
  -- mysql._order_by = nil;
  -- mysql._wheres = nil;
  mysql._database = db or DATABASE
  mysql._table = table
  return mysql
end

---数据库字段
---@param ... any
---@return table
function mysql:columns(...)
  self._columns = { ... }
  return self
end

---数据库条件
---@param key string
---@param operator string
---@param val string|nil
---@return table
function mysql:where(key, operator, val)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if #(self._wheres.fields) == 0 then
    if val == nil then
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, '=')
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, operator)
    else
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, operator)
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, val)
    end
  else
    table.insert(self._wheres.fields, ' AND ')
    if val == nil then
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, '=')
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, operator)
    else
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, operator)
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, val)
    end
  end
  return self
end

function mysql:or_where(key, operator, val)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if #(self._wheres.fields) == 0 then
    if val == nil then
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, '=')
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, operator)
    else
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, operator)
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, val)
    end
  else
    table.insert(self._wheres.fields, ' OR ')
    if val == nil then
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, '=')
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, operator)
    else
      table.insert(self._wheres.fields, string.format(' `%s` ', key))
      table.insert(self._wheres.fields, operator)
      table.insert(self._wheres.fields, '?')
      table.insert(self._wheres.data, val)
    end
  end
  return self
end

function mysql:where_in(key, values)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if type(values) ~= 'table' then
    error('where_in function parameter must be table')
  end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  else
    table.insert(self._wheres.fields, ' AND ')
    table.insert(self._wheres.fields, string.format(' `%s` IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  end
  return self
end

function mysql:or_where_in(key, values)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if type(values) ~= 'table' then
    error('or_where_in function parameter must be table')
  end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  else
    table.insert(self._wheres.fields, ' OR ')
    table.insert(self._wheres.fields, string.format(' `%s` IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  end
  return self
end

function mysql:where_not_in(key, values)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if type(values) ~= 'table' then
    error('where_not_in function parameter must be table')
  end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` NOT IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  else
    table.insert(self._wheres.fields, ' AND ')
    table.insert(self._wheres.fields, string.format(' `%s` NOT IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  end
  return self
end

function mysql:or_where_not_in(key, values)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if self._wheres.data == nil then self._wheres.data = {} end
  if type(values) ~= 'table' then
    error('or_where_not_in function parameter must be table')
  end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` NOT IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  else
    table.insert(self._wheres.fields, ' OR ')
    table.insert(self._wheres.fields, string.format(' `%s` NOT IN (', key))
    local len = #values
    for i, v in ipairs(values) do
      table.insert(self._wheres.fields, '?')
      if i < len then
        table.insert(self._wheres.fields, ',')
      end
      table.insert(self._wheres.data, v)
    end
    table.insert(self._wheres.fields, ') ')
  end
  return self
end

function mysql:where_is_null(key)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IS NULL ', key))
  else
    table.insert(self._wheres.fields, ' AND ')
    table.insert(self._wheres.fields, string.format(' `%s` IS NULL ', key))
  end
  return self
end

function mysql:where_is_not_null(key)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IS NOT NULL ', key))
  else
    table.insert(self._wheres.fields, ' AND ')
    table.insert(self._wheres.fields, string.format(' `%s` IS NOT NULL ', key))
  end
  return self
end

function mysql:or_where_is_null(key)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IS NULL ', key))
  else
    table.insert(self._wheres.fields, ' OR ')
    table.insert(self._wheres.fields, string.format(' `%s` IS NULL ', key))
  end
  return self
end

function mysql:or_where_is_not_null(key)
  if self._wheres == nil then self._wheres = {} end
  if self._wheres.fields == nil then self._wheres.fields = {} end
  if #(self._wheres.fields) == 0 then
    table.insert(self._wheres.fields, string.format(' `%s` IS NOT NULL ', key))
  else
    table.insert(self._wheres.fields, ' OR ')
    table.insert(self._wheres.fields, string.format(' `%s` IS NOT NULL ', key))
  end
  return self
end

function mysql:limit(offset, count)
  if self._limit == nil then self._limit = {} end
  if nil ~= offset then
    self._limit.offset = offset
  end
  if nil ~= count then
    self._limit.count = count
  end
  return self
end

---排序
---@param field string
---@param sort string|nil
---@return table
function mysql:order_by(field, sort)
  if self._order_by == nil then self._order_by = {} end
  if #(self._order_by) == 0 then
    if nil == sort then
      table.insert(self._order_by, field)
      table.insert(self._order_by, 'ASC')
    else
      table.insert(self._order_by, field)
      table.insert(self._order_by, sort:upper())
    end
  else
    table.insert(self._order_by, ',')
    if nil == sort then
      table.insert(self._order_by, field)
      table.insert(self._order_by, 'ASC')
    else
      table.insert(self._order_by, field)
      table.insert(self._order_by, sort:upper())
    end
  end
  return self
end

function mysql:group_by(name)
  self._group_by = name
  return self
end

function mysql:find()
  local sql = 'SELECT '
  if self._columns ~= nil then
    for _, v in ipairs(self._columns) do
      local isExist = string.find(v, '(', 1, true)
      if isExist ~= nil then
        sql = sql .. v .. ','
      else
        sql = sql .. string.format('`%s`,', v)
      end
    end
    sql = string.sub(sql, 1, -2)
  else
    sql = sql .. '*'
  end
  sql = sql .. string.format(' FROM `%s`.`%s` ', self._database, self._table)
  if self._wheres ~= nil then
    sql = sql .. ' WHERE '
    for _, v in ipairs(self._wheres.fields) do
      sql = sql .. v
    end
  end

  if self._wheres ~= nil and self._wheres.data ~= nil then
    local data = _MYSQL:exec_first(sql, self._wheres.data)
    for i, v in pairs(data) do
      if v == CREATEDTIME or v == UPDATEDTIME or v == DELETEDTIME then
        data[i] = tonumber(v)
      end
    end
    return data
  end
  local data = _MYSQL:query_first(sql)
  for i, v in pairs(data) do
    if v == CREATEDTIME or v == UPDATEDTIME or v == DELETEDTIME then
      data[i] = tonumber(v)
    end
  end
  return data
end

function mysql:find_all()
  local sql = 'SELECT '
  if self._columns ~= nil then
    for _, v in ipairs(self._columns) do
      local isExist = string.find(v, '(', 1, true)
      if isExist ~= nil then
        sql = sql .. v .. ','
      else
        sql = sql .. string.format('`%s`,', v)
      end
    end
    sql = string.sub(sql, 1, -2)
  else
    sql = sql .. '*'
  end
  sql = sql .. string.format(' FROM `%s`.`%s` ', self._database, self._table)
  if self._wheres ~= nil then
    sql = sql .. ' WHERE '
    for _, v in ipairs(self._wheres.fields) do
      sql = sql .. v
    end
  end
  if self._group_by ~= nil then
    sql = sql .. string.format(' GROUP BY `%s` ', self._group_by)
  end
  if self._order_by ~= nil then
    sql = sql .. ' ORDER BY '
    for _, v in ipairs(self._order_by) do
      sql = sql .. v
    end
  end
  if self._limit ~= nil then
    if self._limit.count ~= nil then
      sql = sql .. string.format(' LIMIT %s, %s ', self._limit.offset, self._limit.count)
    else
      sql = sql .. ' LIMIT ' .. self._limit.offset
    end
  end

  if self._wheres ~= nil and self._wheres.data ~= nil then
    local data = _MYSQL:exec(sql, self._wheres.data)
    for i, v in ipairs(data) do
      if v[CREATEDTIME] ~= nil then data[i][CREATEDTIME] = tonumber(v[CREATEDTIME]) end
      if v[UPDATEDTIME] ~= nil then data[i][UPDATEDTIME] = tonumber(v[UPDATEDTIME]) end
      if v[DELETEDTIME] ~= nil and v[DELETEDTIME] ~= '' then data[i][DELETEDTIME] = tonumber(v[DELETEDTIME]) end
    end
    return data
  end
  local data = _MYSQL:query(sql)
  for i, v in ipairs(data) do
    if v[CREATEDTIME] ~= nil then data[i][CREATEDTIME] = tonumber(v[CREATEDTIME]) end
    if v[UPDATEDTIME] ~= nil then data[i][UPDATEDTIME] = tonumber(v[UPDATEDTIME]) end
    if v[DELETEDTIME] ~= nil and v[DELETEDTIME] ~= '' then data[i][DELETEDTIME] = tonumber(v[DELETEDTIME]) end
  end
  return data
end

function mysql:insert(data)
  local sql = 'INSERT INTO '
  local values = 'VALUES('
  sql = sql .. string.format('`%s`.`%s` (', self._database, self._table)
  local params = {}
  for key, val in pairs(data) do
    sql = sql .. string.format('`%s`,', key)
    if type(val) == 'string' and val:upper() == 'NULL' then
      values = values .. 'NULL,'
    else
      values = values .. '?,'
      table.insert(params, val)
    end
  end
  sql = string.sub(sql, 1, -2)
  values = string.sub(values, 1, -2)
  sql = sql .. ')'
  values = values .. ')'
  return _MYSQL:exec(sql .. values, params)
end

local function length(t)
  local count = 0
  for _, _ in pairs(t) do
    count = count + 1
  end
  return count
end

function mysql:save(data)
  if self._wheres ~= nil then
    local res = self:find()
    if length(res) == 0 then
      return self:insert(data)
    else
      return self:update(data)
    end
  else
    return self:insert(data)
  end
end

function mysql:update(data)
  local sql = string.format('UPDATE `%s`.`%s` SET ', self._database, self._table)
  local params = {}
  for key, val in pairs(data) do
    if type(val) == 'string' and val:upper() == 'NULL' then
      sql = sql .. string.format(' `%s` = NULL,', key)
    elseif type(val) == 'table' then
      sql = sql .. string.format(' `%s` = ', key)
      for _, v in ipairs(val) do
        sql = sql .. v
      end
      sql = sql .. ','
    else
      sql = sql .. string.format(' `%s` = ?,', key)
      table.insert(params, val)
    end
  end
  sql = string.sub(sql, 1, -2)
  if self._wheres ~= nil then
    sql = sql .. ' WHERE '
    for _, v in ipairs(self._wheres.fields) do
      sql = sql .. v
    end
    params = array_merge(params, self._wheres.data)
  end
  return _MYSQL:exec(sql, params)
end

function mysql:delete()
  local sql = string.format('UPDATE `%s`.`%s` SET deleted_at = ? ', self._database, self._table)
  local params = { os.date("%Y-%m-%d %H:%M:%S", os.time()) }
  if self._wheres ~= nil then
    sql = sql .. ' WHERE '
    for _, v in ipairs(self._wheres.fields) do
      sql = sql .. v
    end
    params = array_merge(params, self._wheres.data)
  end
  return _MYSQL:exec(sql, params)
end

function mysql:count()
  local sql = string.format('SELECT COUNT(*) as count FROM `%s`.`%s`', self._database, self._table)
  local params = {}
  if self._wheres ~= nil then
    sql = sql .. ' WHERE '
    for _, v in ipairs(self._wheres.fields) do
      sql = sql .. v
    end
    if self._wheres.data ~= nil then
      params = array_merge(params, self._wheres.data)
    end
  end
  if #params == 0 then
    local data = _MYSQL:query_first(sql)
    return data.count or 0
  else
    local data = _MYSQL:exec_first(sql, params)
    return data.count or 0
  end
end

return mysql
