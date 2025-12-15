--[[--
Menu module for Maximum plugin.
@module maximum.menu
]]--

local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")

local Menu = {}

function Menu:showMessage(text, timeout)
    UIManager:show(InfoMessage:new{
        text = text,
        timeout = timeout or 2,
    })
end

function Menu:build(plugin, Grid, AutoRotate, PageSplit, Settings)
    local self_menu = self
    return {
        text = _("Maximum"),
        sorting_hint = "typeset",
        sub_item_table = {
            {
                text = _("Enable Grid Mode"),
                checked_func = function() return Grid.enabled end,
                callback = function()
                    if not plugin:isComic() then
                        self_menu:showMessage("Open a CBZ, CBR or PDF file first.")
                        return
                    end
                    local enabled = Grid:toggle()
                    self_menu:showMessage(enabled
                        and "Grid Mode ON\n2-FINGER TAP any quadrant"
                        or "Grid Mode OFF")
                end,
                hold_callback = function()
                    Settings:set("grid_enabled", Grid.enabled)
                    self_menu:showMessage("Grid Mode default: " .. (Grid.enabled and "ON" or "OFF"))
                end,
            },
            {
                text = _("Auto-rotate landscape pages"),
                checked_func = function() return AutoRotate.enabled end,
                callback = function()
                    local enabled = AutoRotate:toggle()
                    if enabled and PageSplit.enabled then
                        PageSplit:toggle()
                    end
                    self_menu:showMessage(enabled
                        and "Auto-rotate ON\nLandscape pages will rotate automatically"
                        or "Auto-rotate OFF")
                end,
                hold_callback = function()
                    Settings:set("autorotate_enabled", AutoRotate.enabled)
                    self_menu:showMessage("Auto-rotate default: " .. (AutoRotate.enabled and "ON" or "OFF"))
                end,
            },
            {
                text = _("Rotation direction"),
                sub_item_table = {
                    {
                        text = _("Clockwise (90°)"),
                        checked_func = function() return AutoRotate.clockwise end,
                        callback = function()
                            AutoRotate:setDirection(true)
                            self_menu:showMessage("Rotation: Clockwise", 1)
                        end,
                        hold_callback = function()
                            AutoRotate:setDirection(true)
                            Settings:set("rotate_clockwise", true)
                            self_menu:showMessage("Default rotation: Clockwise")
                        end,
                    },
                    {
                        text = _("Counter-clockwise (270°)"),
                        checked_func = function() return not AutoRotate.clockwise end,
                        callback = function()
                            AutoRotate:setDirection(false)
                            self_menu:showMessage("Rotation: Counter-clockwise", 1)
                        end,
                        hold_callback = function()
                            AutoRotate:setDirection(false)
                            Settings:set("rotate_clockwise", false)
                            self_menu:showMessage("Default rotation: Counter-clockwise")
                        end,
                    },
                },
            },
            {
                text = _("Split landscape pages"),
                checked_func = function() return PageSplit.enabled end,
                callback = function()
                    local enabled = PageSplit:toggle()
                    if enabled and AutoRotate.enabled then
                        AutoRotate:toggle()
                    end
                    self_menu:showMessage(enabled
                        and "Page Split ON\nLandscape pages will show in two halves"
                        or "Page Split OFF")
                end,
                hold_callback = function()
                    Settings:set("pagesplit_enabled", PageSplit.enabled)
                    self_menu:showMessage("Page Split default: " .. (PageSplit.enabled and "ON" or "OFF"))
                end,
            },
            {
                text = _("About"),
                callback = function()
                    self_menu:showMessage(
                        "Maximum Plugin\n\n" ..
                        "2-FINGER TAP to zoom quadrant.\n" ..
                        "TAP to return.\n" ..
                        "Auto-rotates landscape pages.\n" ..
                        "Split landscape into two pages.\n\n" ..
                        "Hold option to set as default.\n\n" ..
                        "Supports: CBZ, CBR, PDF\n\n" ..
                        "@shac0x"
                    )
                end,
            },
        },
    }
end

return Menu
