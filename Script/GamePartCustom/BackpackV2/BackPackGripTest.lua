---@class BackPackGripTest_C:UUserWidget
---@field Image_83 UImage
--Edit Below--
local BackPackGripTest = { bInitDoOnce = false } 

--[==[ Construct
function BackPackGripTest:Construct()
	
end
-- Construct ]==]

-- function BackPackGripTest:Tick(MyGeometry, InDeltaTime)

-- end

-- function BackPackGripTest:Destruct()

-- end
-- 
-- 递归打印table的辅助函数
local function PrintTable(t, indent)
    indent = indent or 0
    local prefix = string.rep("    ", indent)
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.format("%s[%s] => {", prefix, tostring(k)))
            PrintTable(v, indent + 1)
            print(string.format("%s}", prefix))
        elseif type(v) == "function" then
            print(string.format("%s[%s] => function", prefix, tostring(k)))
        elseif type(v) == "userdata" then
            print(string.format("%s[%s] => <userdata: %s>", prefix, tostring(k), tostring(v)))
        else
            print(string.format("%s[%s] => %s", prefix, tostring(k), tostring(v)))
        end
    end
end

function BackPackGripTest:InitData(DataTable)
    print("========== InitData DataTable Start ==========")
    if DataTable == nil then
        print("DataTable is nil")
    elseif type(DataTable) ~= "table" then
        print(string.format("DataTable type is %s, value: %s", type(DataTable), tostring(DataTable)))
    else
        print(string.format("DataTable is a table with %d entries", #DataTable))
        print("--- Raw pairs ---")
        for k, v in pairs(DataTable) do
            print(string.format("pairs key: %s, value: %s", tostring(k), tostring(v)))
        end
        print("--- Full recursive dump ---")
        PrintTable(DataTable)
    end
    print("========== InitData DataTable End ==========")
end

return BackPackGripTest