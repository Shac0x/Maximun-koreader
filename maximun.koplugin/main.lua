--[[--
Maximum plugin for KOReader
@module koplugin.maximun
@credits @shac0x
]]--

local InputContainer = require("ui/widget/container/inputcontainer")

local Settings = require("settings")
local AutoRotate = require("autorotate")
local Grid = require("grid")
local Menu = require("menu")

local SUPPORTED_EXTENSIONS = {
    cbz = true,
    cbr = true,
    pdf = true,
}

local Maximun = InputContainer:extend{
    name = "maximun",
    is_doc_only = true,
}

function Maximun:init()
    self.ui.menu:registerToMainMenu(self)
end

function Maximun:onReaderReady()
    Grid:init(self.ui, Settings)
    Grid:setupTouchZones(function(quadrant, ges)
        return self:onGridGesture(quadrant, ges)
    end)
    AutoRotate:init(Settings)
end

function Maximun:isComic()
    local doc = self.ui and self.ui.document
    if not doc or not doc.file then return false end
    local ext = doc.file:match("%.([^%.]+)$")
    return ext and SUPPORTED_EXTENSIONS[ext:lower()] or false
end

function Maximun:onPageUpdate(pageno)
    if self:isComic() then
        AutoRotate:onPageUpdate(self.ui.document, pageno)
    end
end

function Maximun:onGridGesture(quadrant, ges)
    if not self:isComic() then return false end
    return Grid:onGesture(quadrant)
end

function Maximun:addToMainMenu(menu_items)
    menu_items.maximun = Menu:build(self, Grid, AutoRotate, Settings)
end

function Maximun:onCloseDocument()
    Grid:reset()
    if AutoRotate.enabled then
        AutoRotate:restorePortrait()
    end
    AutoRotate:reset()
end

return Maximun
