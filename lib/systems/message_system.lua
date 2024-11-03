MessageSystem = System.create({
    init = function(self)
        self.subscribers = {}  -- Could be a table of tables/functions
    end,

    subscribe = function(self, eventName, callback)
        -- Initialize subscriber list for this event if needed
        self.subscribers[eventName] = self.subscribers[eventName] or {}
        table.insert(self.subscribers[eventName], callback)
    end,

    emit = function(self, eventName, data)
        if self.subscribers[eventName] then
            for _, callback in ipairs(self.subscribers[eventName]) do
                callback(data)
            end
        end
    end
})
