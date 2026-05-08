---@class test_main_ui_C:UUserWidget
---@field btn_return_lobby UButton
---@field btn_start_match UButton
---@field text_btn_start_match UTextBlock
--Edit Below--
local test_main_ui = { bInitDoOnce = false } 
local LobbyStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.LobbyStateService')
local LOBBY_MODE_ID = 1001
local START_MATCH_TEXT = "开始匹配"
local CANCEL_MATCH_TEXT = "取消匹配"

function test_main_ui:Construct()
    self.btn_start_match.OnClicked:Add(self.OnStartMatchClicked, self)
    self.btn_return_lobby.OnClicked:Add(self.OnReturnLobbyClicked, self)
    self:BindPlayerStateDelegate()
    self:RefreshButtonVisible()
end
function test_main_ui:Destruct()
    self.btn_start_match.OnClicked:Remove(self.OnStartMatchClicked, self)
    self.btn_return_lobby.OnClicked:Remove(self.OnReturnLobbyClicked, self)
    self:UnbindPlayerStateDelegate()
end

function test_main_ui:GetLocalPlayerController()
    return UGCGameSystem.GetLocalPlayerController()
end

function test_main_ui:GetLocalPlayerState()
    local PlayerController = self:GetLocalPlayerController()
    if not PlayerController then
        return nil
    end

    return UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
end

function test_main_ui:BindPlayerStateDelegate()
    if self.BoundPlayerState then
        return
    end

    local PlayerState = self:GetLocalPlayerState()
    if not PlayerState or not PlayerState.LobbyStateChangedDelegate then
        if not self.bBindPlayerStateDelegateLogged then
            self.bBindPlayerStateDelegateLogged = true
            ugcprint("[MainUI] BindPlayerStateDelegate skipped, PlayerState is nil")
        end
        return
    end

    self.BoundPlayerState = PlayerState
    PlayerState.LobbyStateChangedDelegate:Add(self.OnLobbyStateChanged, self)
    ugcprint("[MainUI] BindPlayerStateDelegate success")
end

function test_main_ui:UnbindPlayerStateDelegate()
    if self.BoundPlayerState and self.BoundPlayerState.LobbyStateChangedDelegate then
        self.BoundPlayerState.LobbyStateChangedDelegate:Remove(self.OnLobbyStateChanged, self)
    end

    self.BoundPlayerState = nil
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

    self:BindPlayerStateDelegate()

    local PlayerState = self:GetLocalPlayerState()
    local State = LobbyStateService.GetState(PlayerState)
    local Text = LobbyStateService.IsReady(PlayerState) and CANCEL_MATCH_TEXT or START_MATCH_TEXT
    self.text_btn_start_match:SetText(Text)
    ugcprint(string.format("[MainUI] RefreshStartMatchText State=%s Text=%s", tostring(State), tostring(Text)))
end

function test_main_ui:OnLobbyStateChanged(NewState)
    ugcprint("[MainUI] OnLobbyStateChanged State=" .. tostring(NewState))
    self:RefreshStartMatchText()
end

function test_main_ui:OnStartMatchClicked()
    local PlayerController = self:GetLocalPlayerController()
    if not PlayerController then
        ugcprint("[MainUI] OnStartMatchClicked failed, PlayerController is nil")
        return
    end

    if PlayerController.RequestToggleLobbyReady then
        PlayerController:RequestToggleLobbyReady()
        return
    end

    ugcprint("[MainUI] OnStartMatchClicked failed, RequestToggleLobbyReady is nil")
end

function test_main_ui:OnReturnLobbyClicked()
    local PlayerController = self:GetLocalPlayerController()
    if not PlayerController then
        ugcprint("[MainUI] OnReturnLobbyClicked failed, PlayerController is nil")
        return
    end

    if PlayerController.RequestReturnLobby then
        PlayerController:RequestReturnLobby()
        return
    end

    ugcprint("[MainUI] OnReturnLobbyClicked failed, RequestReturnLobby is nil")
end
-- function test_main_ui:Tick(MyGeometry, InDeltaTime)
-- end
return test_main_ui
