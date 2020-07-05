--- クラス実装

---instance
---@param class table
---@param super table
function instance(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

return instance