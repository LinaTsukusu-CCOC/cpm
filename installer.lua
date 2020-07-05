local CC = "ComputerCraft"
local OC = "OpenComputers"

--- "OpenComputers" or "ComputerCraft"
local MOD = OC
if _ENV._HOST ~= nil then
    MOD = CC
end

local INSTALL_DIR = "/home/lib/"
if MOD == OC then
    fs = filesystem
else
    serialization = textutils
    INSTALL_DIR = "/"

end

local function getResponse(url)
    if MOD == CC then
        local res = http.get(url)
        if res == nil then
            error("Error")
            return
        end
        local str = res.readAll()
        return str
    else
        local handle = internet.request(url)
        local result = ""
        for chunk in handle do result = result..chunk end
        return result
    end
end

local function download(filename)
    local url = "https://raw.githubusercontent.com/LinaTsukusu/cpm/master/" .. filename
    local source = getResponse(url)
    if source == nil then
        error("Error")
        return
    end
    local filePath = INSTALL_DIR .. "LinaTsukusu/cpm/" .. filename
    local file = fs.open(filePath, "w")
    file.write(source)
    file.close()
    return filePath
end

local packagefile = download("package.lon")

local file = fs.open(packagefile, "r")
local package = serialization.unserialize(file.readAll())
file.close()

download("init.lua")
for i, v in pairs(package.files) do
    download(v)
end

shell.setAlias("cpm", INSTALL_DIR .. "LinaTsukusu/cpm/init.lua")

print("CPM instal Completed!")