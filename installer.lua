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
    local res = http.get(url)
    if res == nil then
        error("Error")
        return
    end
    local str = res.readAll()
    return str
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
local package = serialization.unserialise(file.readAll())
file.close()

download("init.lua")
for i, v in pairs(package.files) do
    download(v)
end

print("CPM instal Completed!")