require 'globals'
local b = {
  -- TODO: implement iterations and calculate means etc
  iterations = 1
}

local function initalState(label)
  return {
    label = label,
    variations = {},
    results = {}
  }
end

local currentBenchmark = initalState()

local function renderResult(result)
  print("## " .. result.label)

  for label, variation in pairs(currentBenchmark.results) do
    print("\n### Variation: " .. label)
    print("Duration:\t" .. variation.duration .. " seconds")
    print("Memory:  \t" .. variation.memory .. " kilobytes")
  end

  print("\n### Total")
  print("Duration:\t " .. result.totalDuration .. " seconds")
  print("Memory:  \t " .. result.totalMemory .. " kilobytes")
end


function b.benchmark(label, fn)
  currentBenchmark = initalState(label)

  local totalDuration, totalMemory = b.trackMemory(b.trackTime, fn)

  collectgarbage("restart")

  currentBenchmark.totalDuration = totalDuration
  currentBenchmark.totalMemory = totalMemory

  renderResult(currentBenchmark)
end

function b.variation(label, fn)
  if not currentBenchmark.label then
    error("variation must be called within a benchmark")
  end

  if currentBenchmark.variations[label] then
    error("duplicate variation: " .. label)
  end

  local duration, memory = b.trackMemory(b.trackTime, fn)

  currentBenchmark.results[label] = {
    memory = memory,
    duration = b.trackTime(fn)
  }
end

--- useful to get rid of hints
function done()
  -- do nothing atm
end

function b.trackTime(func)
  local start = os.clock()
  func(done)
  return os.clock() - start
end

function b.trackMemory(fn, args)
  collectgarbage("collect")
  collectgarbage("stop")

  local baseline = collectgarbage("count")
  local result = fn(args)
  local after = collectgarbage("count")

  collectgarbage("restart")
  return result, after - baseline
end

return b
