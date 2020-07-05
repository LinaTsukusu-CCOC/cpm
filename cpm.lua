---
--- Computers Package Manager
--- version: beta 2.0
--- プログラムを管理するプログラム
--- @author Lina Tsukusu
local CC = "ComputerCraft"
local OC = "OpenComputers"

--- "OpenComputers" or "ComputerCraft"
local MOD = OC
if _ENV._HOST ~= nil then
    MOD = CC
end

if MOD == OC then
    fs = filesystem
end

local lon = require("lon")
local Package = require("package-class")

--- インストール先ディレクトリ
local INSTALL_DIR = "/home/"
if MOD == CC then
    INSTALL_DIR = "/"
end

--- カレントDIR
local CURRENT_DIR
if MOD == OC then
    CURRENT_DIR = shell.getWorkingDirectory()
else
    CURRENT_DIR = "/" .. shell.dir()
end


local currentPackage = Package.new()
if fs.exists(CURRENT_DIR .. "/package.lon") then
    currentPackage = Package.Load(CURRENT_DIR .. "/package.lon")
end

local function _error(tbl)
    error(lon.stringify(tbl), 0)
end


--------------------------------------------------------------------------------
local function loading()
    local arr = {
        "|", "/", "-", "*",
    }

    local i = 0
    while true do
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.write(arr[i + 1])
        sleep(0.1)
        i = (i + 1) % 4
    end
end

local function finishLoading()
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y)
    term.write(" ")
end


---getProgramName
---@param packageName string
---@return string
local function getProgramName(packageName)
    return string.sub(string.match(packageName, "/.*"), 2)
end

--- インターネットにつながっているかの確認
--- @return boolean 接続があればtrue
local function ping()
    return http.get("http://google.com") ~= nil
end


--- GitHub rawファイル取得URL生成
--- @param url string URL文字列
--- @return string  URL文字列
local function makeURL(url)
    url = "https://raw.githubusercontent.com/" .. url .. "/master/"
    return url
end


--- URLへGETでアクセス、レスポンスを返却
--- @param url string 接続先URL
--- @return string    レスポンス文字列
local function getResponse(url)
    local res = http.get(url)
    if res == nil then
        _error({code = 1002, detail = url})
    end
    local str = res.readAll()
    return str
end

--- ファイルのダウンロード
---@param packageName string ファイルURL
---@param filename string 保存先ファイル名
---@return string 保存先ファイルパス
local function download(packageName, filename)
    local url = makeURL(packageName) .. filename
    local source = getResponse(url)
    if source == nil then
        error({code = 1002, detail = url })
    end
    local filePath = INSTALL_DIR .. packageName .. "/" .. filename
    local file = fs.open(filePath, "w")
    file.write(source)
    file.close()
    return filePath
end


local function pad(str, plen)
    local ret = ""
    local len = math.abs(plen) - string.len(str)
    if plen >= 0 then
        ret = string.rep(" ", plen) .. str
    else
        ret = str .. string.rep(" ", len)
    end
    return ret
end

---------------------------------------------------------------------------

---install
---@param packageName string GitHub Namespace
---@param isDependencies boolean
---@param isGlobal boolean
local function install(packageName, isDependencies, isGlobal)
    -- カレントパッケージに依存追加
    if not isDependencies and not isGlobal then
        if currentPackage:isExistsDependencies(packageName) then
            return
        end
        currentPackage:addDependencies(packageName)
    end

    if fs.exists(INSTALL_DIR .. packageName) then
        return
    end

    -- パッケージファイルのダウンロード
    local filePath = download(packageName, "package.lon")
    local newPackage = Package.Load(filePath)
    -- init.luaのダウンロード
    local initFile = download(packageName, "init.lua")

    -- filesのダウンロード
    for i, v in pairs(newPackage.files) do
        download(packageName, v)
    end

    -- 依存パッケージのダウンロード
    for i, v in pairs(newPackage.dependencies) do
        install(v, true)
    end

    if isGlobal then
        shell.setAlias(getProgramName(packageName), initFile)
    end
end

local function uninstall(packageName, isGlobal)
    -- パッケージから依存削除
    if not isGlobal then
        currentPackage:removeDependencies(packageName)
    else
        local programName = getProgramName(packageName)
        if MOD == OC then
            shell.setAlias(programName, nil)
        else
            shell.clearAlias(programName)
        end
    end
end

--- パッケージファイルを最新状態へアップデート
---  cpt update
--local function update()
--    local old = Package:new(lon.load(PKG_FILE))
--    local master = Package:new()
--
--    -- アップデート処理
--    local run = function()
--        for i, v in ipairs(old.pkg) do
--            term.write("  GET[" .. tostring(i) .. "] " .. v.packageUrl)
--            local package = lon.parse(getResponse(v.packageUrl))
--            package.packageUrl = v.packageUrl
--            local success, err = pcall(master.addPackage, master, package)
--            if not success then
--                print("GetPackageError: " .. v.packageUrl)
--                table.insert(master.pkg, v)
--            end
--            finishLoading()
--            print()
--        end
--    end
--
--    -- 実行
--    parallel.waitForAny(run, loading)
--
--    lon.save(PKG_FILE, master.pkg)
--end


--- インストールされているプログラムを最新へアップグレード
---  cpt upgrade
--local function upgrade()
--    local run = function()
--        local master = Package:new(lon.load(PKG_FILE))
--        local installed = Package:new(lon.load(INSTALLED_FILE))
--        local newIns = master:findAllProgram(installed:getProgramNameList())
--
--        for i, v in ipairs(newIns:getProgramList()) do
--            -- バージョンが変更されているもののみ
--            if v.version ~= installed:findProgram(v.name).programs[1].version then
--                term.write("  GET[".. tostring(i) .."] " .. makeURL(v.url))
--                local path = v.path or "/"
--                download(v.url, v.name, path)
--                finishLoading()
--                print()
--            end
--        end
--
--        lon.save(INSTALLED_FILE, newIns.pkg)
--    end
--
--    -- 実行
--    parallel.waitForAny(run, loading)
--    print("Done.")
--
--end


--local function list()
--    local master = Package:new(lon.load(PKG_FILE))
--    local installed = Package:new(lon.load(INSTALLED_FILE))
--    local list = master:getProgramList()
--    -- ソートついでに文字数取得
--    local len = 0
--    table.sort(list, function(a, b)
--        local al = string.len(a.name)
--        local bl = string.len(b.name)
--        len = al > bl and al or bl
--        return a.name < b.name
--    end)
--    for i, v in ipairs(list) do
--        print(pad(v.name, -len) .. " : ver " .. v.version)
--    end
--end

--main---------------------------------------------------------------------

--- エラーコードからエラーメッセージを取得して表示
---  @param err table エラーオブジェクト
local function showError(err)
    local errtbl = lon.parse(err)
    if errtbl ~= nil and errtbl.code == 1001 then
        print("No Internet connection.")
    elseif errtbl ~= nil then
        local message = lon.load("error.lon")
        print(message[errtbl.code])
    else
        print(err)
    end
end


local function showHelp()
    print("install")
    print("uninstall")
end



local function main(args, opt)
    if opt.h or opt.help then
        showHelp()
        return
    end
    local success, err = pcall(function()
        if not ping() then
            error({code = 1001})
        end

        local command = args[1]
        local packageName = args[2]
        if command == "install" or command == "i" then
            install(packageName, false, opt.g or opt.global)
        elseif command == "uninstall" or command == "un"
            or command == "remove" or command == "r" then
            uninstall(packageName, opt.g or opt.global)
        end
        currentPackage:save(CURRENT_DIR .. "/package.lon")
    end, args)
    if not success then
        showError(err)
    end
end

return main