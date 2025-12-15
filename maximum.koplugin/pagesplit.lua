--[[--
Page split module for Maximum plugin.
Splits landscape pages into two views.
@module maximum.pagesplit
]]--

local Device = require("device")
local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local Screen = Device.screen

local PageSplit = {
    enabled = false,
    current_half = nil,
    is_landscape_page = false,
    original_zoom_mode = nil,
    ui = nil,
    document = nil,
}

function PageSplit:init(ui, Settings)
    self.ui = ui
    self.enabled = Settings:get("pagesplit_enabled")
    self:reset()
end

function PageSplit:reset()
    self.current_half = nil
    self.is_landscape_page = false
    self.original_zoom_mode = nil
end

function PageSplit:isPageLandscape(document, pageno)
    if not document then return false end
    local page_size = document:getNativePageDimensions(pageno)
    if not page_size then return false end
    return page_size.w > page_size.h
end

function PageSplit:zoomToHalf(half)
    local view = self.ui.view
    local zooming = self.ui.zooming
    if not view or not zooming then return end

    if not self.original_zoom_mode then
        self.original_zoom_mode = zooming.zoom_mode
    end

    self.current_half = half

    self.ui:handleEvent(Event:new("SetZoomMode", "contentheight"))

    UIManager:scheduleIn(0.1, function()
        if half == "left" then
            self.ui:handleEvent(Event:new("GotoXPosBeg"))
        else
            self.ui:handleEvent(Event:new("GotoXPosEnd"))
        end
    end)
end

function PageSplit:restoreZoom()
    if self.original_zoom_mode then
        self.ui:handleEvent(Event:new("SetZoomMode", self.original_zoom_mode))
        self.original_zoom_mode = nil
    end
    self.current_half = nil
end

function PageSplit:onPageUpdate(document, pageno)
    if not self.enabled then return end

    self.document = document
    local is_landscape = self:isPageLandscape(document, pageno)

    if is_landscape and not self.is_landscape_page then
        self.is_landscape_page = true
        self:zoomToHalf("left")
    elseif not is_landscape and self.is_landscape_page then
        self.is_landscape_page = false
        self:restoreZoom()
    end
end

function PageSplit:onGotoNextPage()
    if not self.enabled or not self.is_landscape_page then
        return false
    end

    if self.current_half == "left" then
        self:zoomToHalf("right")
        return true
    elseif self.current_half == "right" then
        self.is_landscape_page = false
        self:restoreZoom()
        return false
    end

    return false
end

function PageSplit:onGotoPrevPage()
    if not self.enabled or not self.is_landscape_page then
        return false
    end

    if self.current_half == "right" then
        self:zoomToHalf("left")
        return true
    elseif self.current_half == "left" then
        self.is_landscape_page = false
        self:restoreZoom()
        return false
    end

    return false
end

function PageSplit:toggle()
    self.enabled = not self.enabled
    if not self.enabled and self.is_landscape_page then
        self:restoreZoom()
        self.is_landscape_page = false
    end
    return self.enabled
end

return PageSplit
