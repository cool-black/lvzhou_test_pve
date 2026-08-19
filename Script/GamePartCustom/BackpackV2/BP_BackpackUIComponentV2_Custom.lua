---@class BP_BackpackUIComponentV2_Custom_C:BP_BackpackUIComponentV2_C
--Edit Below--
local BP_BackpackUIComponentV2_Custom = {}
local GameData = UGCGameSystem.UGCRequire("Script.Blueprint.UGCGameData")

local LOBBY_BACKPACK_MODE = 3
local RUN_BACKPACK_MODE = 1
local BACKPACK_OVERLAY_UI_RELATIVE_PATH = "Asset/GamePartCustom/BackpackV2/BackPackTest.BackPackTest_C"
local BACKPACK_OVERLAY_SLOT = "UI.UISlot.MainUISlot_High"
local BACKPACK_OVERLAY_Z_ORDER = 20

local function Log(Message)
    ugcprint("[BackpackV2Custom] " .. tostring(Message))
end

local function IsWidgetValid(Widget)
    return Widget ~= nil and UGCObjectUtility.IsObjectValid(Widget)
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
    self.bBackpackOverlayWanted = false
    self.bBackpackOverlayLoading = false
    self.bBackpackOverlayEnding = false
    Log(string.format(
        "ReceiveBeginPlay Self=%s IsServer=%s",
        tostring(self),
        tostring(UGCGameSystem.IsServer())
    ))
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    Log("ReceiveEndPlay")
    self:DestroyBackpackOverlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

function BP_BackpackUIComponentV2_Custom:ShowBackpackOverlay()
    self.bBackpackOverlayWanted = true
    Log(string.format(
        "ShowBackpackOverlay Widget=%s Loading=%s Ending=%s",
        tostring(self.BackpackOverlayWidget),
        tostring(self.bBackpackOverlayLoading),
        tostring(self.bBackpackOverlayEnding)
    ))

    if IsWidgetValid(self.BackpackOverlayWidget) then
        if not UGCWidgetManagerSystem.IsWidgetAddedToSlot(self.BackpackOverlayWidget) then
            Log("ShowBackpackOverlay re-add widget to slot")
            UGCWidgetManagerSystem.AddToSlot(
                self.BackpackOverlayWidget,
                BACKPACK_OVERLAY_SLOT,
                BACKPACK_OVERLAY_Z_ORDER
            )
        end

        UGCWidgetManagerSystem.ShowWidget(self.BackpackOverlayWidget)
        Log("ShowBackpackOverlay reused and showed widget")
        return
    end

    self.BackpackOverlayWidget = nil
    if self.bBackpackOverlayLoading or self.bBackpackOverlayEnding then
        Log("ShowBackpackOverlay skipped because loading or ending")
        return
    end

    local WidgetPath = UGCGameSystem.GetUGCResourcesFullPath(BACKPACK_OVERLAY_UI_RELATIVE_PATH)
    self.bBackpackOverlayLoading = true
    Log(string.format(
        "CreateWidgetAsync RelativePath=%s FullPath=%s Slot=%s ZOrder=%s",
        tostring(BACKPACK_OVERLAY_UI_RELATIVE_PATH),
        tostring(WidgetPath),
        tostring(BACKPACK_OVERLAY_SLOT),
        tostring(BACKPACK_OVERLAY_Z_ORDER)
    ))
    UGCWidgetManagerSystem.CreateWidgetAsync(WidgetPath, function(Widget)
        self.bBackpackOverlayLoading = false
        Log(string.format(
            "CreateWidgetAsync callback Widget=%s Wanted=%s Ending=%s",
            tostring(Widget),
            tostring(self.bBackpackOverlayWanted),
            tostring(self.bBackpackOverlayEnding)
        ))

        if not IsWidgetValid(Widget) then
            Log("ShowBackpackOverlay failed to create widget")
            return
        end

        if self.bBackpackOverlayEnding then
            Log("CreateWidgetAsync callback destroys widget because component is ending")
            UGCWidgetManagerSystem.DestroyWidget(Widget)
            return
        end

        self.BackpackOverlayWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(
            self.BackpackOverlayWidget,
            BACKPACK_OVERLAY_SLOT,
            BACKPACK_OVERLAY_Z_ORDER
        )
        Log(string.format(
            "Overlay added to slot Added=%s",
            tostring(UGCWidgetManagerSystem.IsWidgetAddedToSlot(self.BackpackOverlayWidget))
        ))

        if self.bBackpackOverlayWanted then
            UGCWidgetManagerSystem.ShowWidget(self.BackpackOverlayWidget)
            Log("CreateWidgetAsync callback showed widget")
        else
            UGCWidgetManagerSystem.HideWidget(self.BackpackOverlayWidget)
            Log("CreateWidgetAsync callback hid widget because backpack is closed")
        end
    end)
end

function BP_BackpackUIComponentV2_Custom:HideBackpackOverlay()
    self.bBackpackOverlayWanted = false
    Log(string.format("HideBackpackOverlay Widget=%s", tostring(self.BackpackOverlayWidget)))

    if IsWidgetValid(self.BackpackOverlayWidget) then
        UGCWidgetManagerSystem.HideWidget(self.BackpackOverlayWidget)
        Log("HideBackpackOverlay hid widget")
    end
end

function BP_BackpackUIComponentV2_Custom:DestroyBackpackOverlay()
    self.bBackpackOverlayWanted = false
    self.bBackpackOverlayEnding = true
    Log(string.format("DestroyBackpackOverlay Widget=%s", tostring(self.BackpackOverlayWidget)))

    if not IsWidgetValid(self.BackpackOverlayWidget) then
        self.BackpackOverlayWidget = nil
        Log("DestroyBackpackOverlay no valid widget")
        return
    end

    if UGCWidgetManagerSystem.IsWidgetAddedToSlot(self.BackpackOverlayWidget) then
        UGCWidgetManagerSystem.RemoveFromSlot(self.BackpackOverlayWidget)
    end

    UGCWidgetManagerSystem.DestroyWidget(self.BackpackOverlayWidget)
    self.BackpackOverlayWidget = nil
    Log("DestroyBackpackOverlay destroyed widget")
end

---@param Panel UUserWidget @Backpack main panel
function BP_BackpackUIComponentV2_Custom:OnOpenBattleMainPanel(Panel)
    Log(string.format("OnOpenBattleMainPanel Panel=%s", tostring(Panel)))
    self:ShowBackpackOverlay()
end

---@param Panel UUserWidget @Backpack main panel
function BP_BackpackUIComponentV2_Custom:OnCloseBattleMainPanel(Panel)
    Log(string.format("OnCloseBattleMainPanel Panel=%s", tostring(Panel)))
    self:HideBackpackOverlay()
end

---默认背包模式OverrideDefaultMode可配置
---生效范围：客户端
---@return number @背包模式 [1-3]
function BP_BackpackUIComponentV2_Custom:GetDefaultMode()
    local DefaultMode = IsLobbyMode() and LOBBY_BACKPACK_MODE or RUN_BACKPACK_MODE
    Log(string.format(
        "GetDefaultMode ModeID=%s DefaultMode=%s",
        tostring(GetModeID()),
        tostring(DefaultMode)
    ))
    return DefaultMode
end

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
