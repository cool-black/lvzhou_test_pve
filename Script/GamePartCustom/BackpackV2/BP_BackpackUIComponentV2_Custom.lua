local BP_BackpackUIComponentV2_Custom = {}
local GameData = UGCGameSystem.UGCRequire("Script.Blueprint.UGCGameData")

local LOBBY_BACKPACK_MODE = 3
local RUN_BACKPACK_MODE = 1

local function Log(Message)
    ugcprint("[BackpackV2Custom] " .. tostring(Message))
end

local function GetModeID()
    local ModeID = UGCMultiMode.GetModeID()
    if ModeID == 0 then
        return GameData.DefaultModeID
    end

    return ModeID
end

local function IsLobbyMode()
    return GameData.GetGameModeName(GetModeID()) == GameData.ModeName.Lobby
end

---开始运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveBeginPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

---默认背包模式OverrideDefaultMode可配置
---生效范围：客户端
---@return number @背包模式 [1-3]
-- function BP_BackpackUIComponentV2_Custom:GetDefaultMode()
-- end

---获取背包入口按钮控件
---生效范围：客户端
---@return UWidget @背包按钮控件
-- function BP_BackpackUIComponentV2_Custom:GetHUDBtn()
-- end

---显示背包入口按钮逻辑
---生效范围：客户端
-- function BP_BackpackUIComponentV2_Custom:ShowHUDBtn()
-- end

---关闭背包界面逻辑
---生效范围：客户端
-- function BP_BackpackUIComponentV2_Custom:CloseBattleMainPanel()
--     BP_BackpackUIComponentV2_Custom.SuperClass.CloseBattleMainPanel(self)
-- end

---打开背包界面逻辑
---生效范围：客户端
---@param Style number @0全屏，1半屏
---@param Mode number @1:背包+装备栏 2:背包+仓库 3:背包+装备栏+仓库
function BP_BackpackUIComponentV2_Custom:OpenBattleMainUIStyle(Style, Mode)
    Log(string.format("OpenBattleMainUIStyle ModeID=%s Style=%s Mode=%s IsLobby=%s", tostring(GetModeID()), tostring(Style), tostring(Mode), tostring(IsLobbyMode())))

    if IsLobbyMode() then
        self:OpenLobbyBackpackMainUI(LOBBY_BACKPACK_MODE)
        return
    end

    self:OpenBattleMainPanel(Style, RUN_BACKPACK_MODE)
end

function BP_BackpackUIComponentV2_Custom:ClosePanel()
    Log(string.format("ClosePanel ModeID=%s IsLobby=%s", tostring(GetModeID()), tostring(IsLobbyMode())))

    if IsLobbyMode() then
        self:CloseLobbyPanel()
        return
    end

    self:CloseBattleMainPanel()
end

---打开删除弹窗
---生效范围：客户端
---@param InstanceID number @物品实例ID
---@param type string @类型 是否销毁/丢弃/脱下背包
---@param AdditionData table @额外携带数据
-- function BP_BackpackUIComponentV2_Custom:OpenDeletePanel(InstanceID, type, AdditionData)
--     BP_BackpackUIComponentV2_Custom.SuperClass.OnOpenDeletePanel(self, InstanceID, type, AdditionData)
-- end

---点击未解锁物品格子响应
---生效范围：客户端
---@param DataType string @类型 [0:背包数据, 1:仓库数据]
-- function BP_BackpackUIComponentV2_Custom:OnClickLockBackpackItem(DataType)
-- end

---是否显示丢弃区域
---生效范围：客户端
---return boolean @是否显示丢弃区域
-- function BP_BackpackUIComponentV2_Custom:IsDiscardAreaVisible()
-- end

---RPC函数声明
---@return string[] @RPC函数列表
-- function BP_BackpackUIComponentV2_Custom:GetAvailableServerRPCs()
--     local rpcList = BP_BackpackUIComponentV2_Custom.SuperClass.GetAvailableServerRPCs(self)
--     table.insert(rpcList, "");

--     return table.unpack(rpcList)
-- end

---默认排序函数, 组件上配置
---生效范围: 客户端
---@param Data1 table @物品数据1
---@param Data2 table @物品数据2
---@return boolean @是否不交换
-- function BP_BackpackUIComponentV2_Custom.CompareQuality(Data1,Data2)
-- end

return BP_BackpackUIComponentV2_Custom
