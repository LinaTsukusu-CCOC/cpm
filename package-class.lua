local lon = require "lon"
local instance = require "class"

--- パッケージ操作クラス
local Package = {}

function Package.new(data)
    local obj = instance(Package)

    if data then
        obj.author = data.author or ""
        obj.name = data.name or ""
        obj.description = data.description or ""
        obj.repository = data.repository or ""
        obj.version = data.version or ""
        obj.files = data.files or {}
        obj.dependencies = data.dependencies or {}
    else
        obj.author = ""
        obj.name = ""
        obj.description = ""
        obj.repository = ""
        obj.version = ""
        obj.files = {}
        obj.dependencies = {}
    end
    return obj
end

function Package:isExistsDependencies(packageName)
    for i, v in pairs(self.dependencies) do
        if v == packageName then
            return true
        end
    end
    return false
end

function Package:addDependencies(packageName)
    table.insert(self.dependencies, packageName)
end

function Package:removeDependencies(packageName)
    for i, v in ipairs(self.dependencies) do
        if packageName == v then
            table.remove(self.dependencies, i)
            return
        end
    end
end

function Package:save(file)
    lon.save(file, self)
end

function Package.Load(file)
    return Package.new(lon.load(file))
end


return Package