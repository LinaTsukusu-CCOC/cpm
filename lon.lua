--- シリアライズ関数の互換対応
local serialization = serialization
if serialization == nil then
    serialization = textutils
end

--- Lonファイル操作
local lon = {}


---stringify
---@param obj any
---@return string
function lon.stringify(obj)
    return serialization.serialize(obj)
end


---parse
---@param str string
---@return any
function lon.parse(str)
    return serialization.unserialize(str)
end

--- Lonファイルにテーブルを保存
--- @param filename string 保存するファイル名
--- @param tbl      table  保存するデータ
function lon.save(filename, tbl)
    local file = fs.open(filename, "w")
    file.write(lon.stringify(tbl))
    file.close()
end


--- Lonファイルを読み込み
--- @param  filename string 保存するファイル名
--- @return string          読み込んだデータ
function lon.load(filename)
    local file = fs.open(filename, "r")
    if file == nil then
        return {}
    end
    local tbl = lon.parse(file.readAll())
    file.close()
    return tbl
end

return lon
