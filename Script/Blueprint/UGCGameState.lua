---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
local UGCGameState = {};
local TEST_MAIN_UI_PATH = UGCGameSystem.GetUGCResourcesFullPath(
    'Asset/Blueprint/Prefabs/UI/test_main_ui.test_main_ui_C'
)

function UGCGameState:ReceiveBeginPlay()
    if UGCGameSystem.IsServer() then
        return
    end

    self:LoadTestMainUI()
end
-- function UGCGameState:ReceiveTick(DeltaTime)

-- end

function UGCGameState:ReceiveEndPlay()
    self.bTestMainUIDestroyed = true

    if self.TestMainUI then
        UGCWidgetManagerSystem.RemoveFromSlot(self.TestMainUI)
        UGCWidgetManagerSystem.DestroyWidget(self.TestMainUI)
        self.TestMainUI = nil
    end
end

function UGCGameState:LoadTestMainUI()
    if self.TestMainUI or self.bTestMainUILoading then
        return
    end

    self.bTestMainUILoading = true
    self.bTestMainUIDestroyed = false

    UGCWidgetManagerSystem.CreateWidgetAsync(TEST_MAIN_UI_PATH, function(Widget)
        self.bTestMainUILoading = false
        if self.bTestMainUIDestroyed or not Widget then
            return
        end

        self.TestMainUI = Widget
        UGCWidgetManagerSystem.AddToSlot(self.TestMainUI, "UI.UISlot.MainUISlot_High", 10)
    end)
end

return UGCGameState;
