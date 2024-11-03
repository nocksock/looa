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

function tbl.reduceRight(t, func, initial)
  local accumulator = initial
  for i = #t, 1, -1 do
    accumulator = func(accumulator, t[i])
  end
  return accumulator
end

return tbl
