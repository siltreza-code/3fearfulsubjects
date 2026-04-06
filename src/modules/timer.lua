local Async = {}

local tasks = {}

-- internal update (call this from love.update)
function Async.update(dt)
    for i = #tasks, 1, -1 do
        local task = tasks[i]
        task.time = task.time - dt

        if task.time <= 0 then
            local ok, waitTime = coroutine.resume(task.co)

            if not ok or coroutine.status(task.co) == "dead" then
                table.remove(tasks, i)
            else
                task.time = waitTime or 0
            end
        end
    end
end

-- sleep function for coroutines
function Async.sleep(seconds)
    coroutine.yield(seconds)
end

-- run async function
function Async.run(func)
    local co = coroutine.create(func)

    local ok, waitTime = coroutine.resume(co)

    if ok and coroutine.status(co) ~= "dead" then
        table.insert(tasks, {
            co = co,
            time = waitTime or 0
        })
    end
end

-- simple after(delay, func)
function Async.after(delay, func)
    Async.run(function()
        Async.sleep(delay)
        func()
    end)
end

return Async