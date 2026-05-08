---@class test_main_ui_C:UUserWidget
---@field btn_return_lobby UButton
---@field btn_start_match UButton
---@field text_btn_start_match UTextBlock
--Edit Below--
local test_main_ui = { bInitDoOnce = false } 
local LobbyStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.LobbyStateService')
local LOBBY_MODE_ID = 1001
local COMMON_LEVEL_MODE_ID = 1002
local START_MATCH_TEXT = "开始匹配"
local CANCEL_MATCH_TEXT = "取消匹配"

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
    self:RefreshStartMatchText()
end

function test_main_ui:RefreshStartMatchText()
    if not self.text_btn_start_match then
        return
    end

    local Text = LobbyStateService.IsReady() and CANCEL_MATCH_TEXT or START_MATCH_TEXT
    self.text_btn_start_match:SetText(Text)
end

function test_main_ui:OnStartMatchClicked()
    if LobbyStateService.IsReady() then
        local bCancelRequested = UGCMultiMode.RequestCancelMatch()
        if bCancelRequested then
            LobbyStateService.SetIdle()
            self:RefreshStartMatchText()
            UGCWidgetManagerSystem.ShowTipsUI("已取消匹配")
        else
            UGCWidgetManagerSystem.ShowTipsUI("取消匹配失败")
        end
        return
    end
    local bRequested = UGCMultiMode.RequestMatch(COMMON_LEVEL_MODE_ID, self.OnStartMatchResponse, self, true)
    if bRequested then
        LobbyStateService.SetReady()
        self:RefreshStartMatchText()
        UGCWidgetManagerSystem.ShowTipsUI("开始匹配")
    else
        UGCWidgetManagerSystem.ShowTipsUI("开始匹配失败")
    end
end
function test_main_ui:OnStartMatchResponse(bSuccess)
    if bSuccess then
        LobbyStateService.SetReady()
        self:RefreshStartMatchText()
        return
    end
    LobbyStateService.SetIdle()
    self:RefreshStartMatchText()
    UGCWidgetManagerSystem.ShowTipsUI("匹配失败")
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
