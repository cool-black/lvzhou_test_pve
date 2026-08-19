---@class BackPackTest_C:UUserWidget
---@field ButtonClose UButton
---@field ButtonTest UButton
---@field Image_154 UImage
--Edit Below--
local BackPackTest = { bInitDoOnce = false }

ugcprint("[BackPackTest] module loaded")

function BackPackTest:Construct()
    ugcprint(string.format(
        "[BackPackTest] Construct Self=%s ButtonClose=%s ButtonTest=%s Init=%s AddedToSlot=%s",
        tostring(self),
        tostring(self.ButtonClose),
        tostring(self.ButtonTest),
        tostring(self.bInitDoOnce),
        tostring(UGCWidgetManagerSystem.IsWidgetAddedToSlot(self))
    ))

    if self.bInitDoOnce then
        ugcprint("[BackPackTest] Construct skipped because bindings already initialized")
        return
    end

    self.bInitDoOnce = true

    if self.ButtonClose then
        self.ButtonClose.OnClicked:Add(self.OnButtonCloseClicked, self)
        ugcprint("[BackPackTest] ButtonClose OnClicked bound")
    else
        ugcprint("[BackPackTest] ButtonClose is nil, binding failed")
    end

    if self.ButtonTest then
        self.ButtonTest.OnClicked:Add(self.OnButtonTestClicked, self)
        ugcprint("[BackPackTest] ButtonTest OnClicked bound")
    else
        ugcprint("[BackPackTest] ButtonTest is nil, binding failed")
    end
end

-- function BackPackTest:Tick(MyGeometry, InDeltaTime)

-- end

function BackPackTest:Destruct()
    ugcprint(string.format("[BackPackTest] Destruct Self=%s", tostring(self)))

    if self.ButtonClose then
        self.ButtonClose.OnClicked:Remove(self.OnButtonCloseClicked, self)
    end

    if self.ButtonTest then
        self.ButtonTest.OnClicked:Remove(self.OnButtonTestClicked, self)
    end

    self.bInitDoOnce = false
end

function BackPackTest:OnButtonCloseClicked()
    ugcprint("[BackPackTest] ButtonClose clicked, hide overlay")
    UGCWidgetManagerSystem.HideWidget(self)
end

function BackPackTest:OnButtonTestClicked()
    ugcprint("[BackPackTest] test")
end

return BackPackTest
