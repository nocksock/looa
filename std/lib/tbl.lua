-- table helpers

local tbl = {}

function tbl.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

function tbl.filter(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    if f(v) then
      t[k] = v
    end
  end
  return t
end

function tbl.reduce(t, func, initial)
  local accumulator = initial
  for i = 1, #t do
    accumulator = func(accumulator, t[i])
  end
  return accumulator
end

function tbl:reduceRight(func, initial)
  local accumulator = initial
  for i = #self, 1, -1 do
    accumulator = func(accumulator, self[i])
  end
  return accumulator
end

function tbl.has(t, item)
  for i, v in ipairs(t) do
    if v == item then
      return true
    end
  end
  return false
end

return tbl
