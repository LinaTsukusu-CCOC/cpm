local Table = require("table-util")


function getopt(_args, _options)
    local options = Table(_options)
    local args = Table(_args)

    local retopt = Table({})
    local retarg = Table({})

    local isOpt = false
    local optType = ""
    local optName = ""

    local function func(n)
        if options[n] then
            if options[n] == "boolean" then
                retopt:add(n, true)
            else
                isOpt = true
                optType = options[n]
                optName = n
            end
        end
    end

    args:each(function(v, i)
        if not isOpt then
            if v:sub(1, 2) == "--" then
                local opt = v:sub(3)
                if opt:len() > 1 then
                    func(opt)
                end
            elseif v:sub(1, 1) == "-" then
                local opt = v:sub(2)
                for n in opt:gmatch(".") do
                    func(n)
                end

            else
                -- プログラムの引数
                retarg:add(v)
            end
        else
            -- オプションの引数
            local arg
            if optType == "number" then
                arg = tonumber(v)
            elseif optType == "path" then
                arg = v
            else
                arg = v
            end

            retopt[optName] = arg
            isOpt = false
            optType = ""
            optName = ""
        end
    end)

    return retarg, retopt
end

return getopt