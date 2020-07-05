local lon = require "lon"
local instance = require "class"

--- パッケージ操作クラス
local Package = {

    new = function()
        local obj = instance(Package)

        obj.author = ""
        obj.name = ""
        obj.description = ""
        obj.repository = ""
        obj.version = ""
        obj.files = {"init.lua",}
        obj.dependencies = {}

        return obj
    end,

    isExistsDependencies = function(self, packageName)
        for i, v in pairs(self.dependencies) do
            if v == packageName then
                return true
            end
        end
        return false
    end,

    addDependencies = function(self, packageName)
        table.insert(self.dependencies, packageName)
    end,

    removeDependencies = function(self, packageName)
        for i, v in ipairs(self.dependencies) do
            if packageName == v then
                table.remove(self.dependencies, i)
                return
            end
        end
    end,

    save = function(self, file)
        lon.save(file, self)
    end,

    Load = function(file)
        lon.load(file)
    end,
}


return Package