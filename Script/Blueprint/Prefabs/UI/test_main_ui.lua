---@class test_main_ui_C:UUserWidget
---@field btn_return_lobby UButton
---@field btn_start_match UButton
--Edit Below--
local test_main_ui = { bInitDoOnce = false } 
local LOBBY_MODE_ID = 1001
local COMMON_LEVEL_MODE_ID = 1002

function test_main_ui:Construct()
    self.btn_start_match.OnClicked:Add(self.OnStartMatchClicked, self)
    self.btn_return_lobby.OnClicked:Add(self.OnReturnLobbyClicked, self)

    self:RefreshButtonVisible()
end

function test_main_ui:Destruct()
    self.btn_start_match.OnClicked:Remove(self.OnStartMatchClicked, self)
    self.btn_return_lobby.OnClicked:Remove(self.OnReturnLobbyClicked, self)
end

function test_main_ui:RefreshButtonVisible()
    local ModeID = UGCMultiMode.GetModeID()
    if ModeID == 0 then
        ModeID = LOBBY_MODE_ID
    end

    local bIsLobby = ModeID == LOBBY_MODE_ID
    self.btn_start_match:SetVisibility(bIsLobby and ESlateVisibility.Visible or ESlateVisibility.Collapsed)
    self.btn_return_lobby:SetVisibility(bIsLobby and ESlateVisibility.Collapsed or ESlateVisibility.Visible)
end

function test_main_ui:OnStartMatchClicked()
    local bRequested = UGCMultiMode.RequestMatch(COMMON_LEVEL_MODE_ID, nil, self, true)
    if not bRequested then
        UGCWidgetManagerSystem.ShowTipsUI("开始匹配失败")
    end
end

function test_main_ui:OnReturnLobbyClicked()
    local bRequested = UGCMultiMode.RequestMatch(LOBBY_MODE_ID, nil, self)
    if not bRequested then
        UGCWidgetManagerSystem.ShowTipsUI("返回大厅失败")
    end
end

-- function test_main_ui:Tick(MyGeometry, InDeltaTime)

-- end

return test_main_ui
