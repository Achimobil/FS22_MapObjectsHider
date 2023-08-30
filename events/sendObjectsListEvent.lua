--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

SendObjectsListEvent = {}
local SendObjectsListEvent_mt = Class(SendObjectsListEvent, Event)

InitEventClass(SendObjectsListEvent, "SendObjectsListEvent")

---@return table
function SendObjectsListEvent.emptyNew()
    local o = Event.new(SendObjectsListEvent_mt)
    o.className = "SendObjectsListEvent"
    ---@type HiddenObject[]
    o.hiddenObjects = {}
    return o
end

---@param hiddenObjects HideObject[]
---@return table
function SendObjectsListEvent.new(hiddenObjects)
    local o = SendObjectsListEvent.emptyNew()

    for _, ho in pairs(hiddenObjects) do
        ---@class HiddenObject
        local pho = {
            index = ho.index,
            id = 0,
            name = "",
            datetime = "",
            timestamp = ho.timestamp,
            player = ho.player,
            onlyDecollide = ho.onlyDecollide
        }
        table.insert(o.hiddenObjects, pho)
    end
    return o
end

---@param streamId integer
function SendObjectsListEvent:writeStream(streamId, _)
    streamWriteUInt16(streamId, #self.hiddenObjects)
    for _, ho in pairs(self.hiddenObjects) do
        streamWriteString(streamId, ho.index)
        streamWriteString(streamId, ho.player)
        streamWriteUIntN(streamId, ho.timestamp, 28)
        streamWriteBool(streamId, ho.onlyDecollide)
    end
end

---@param streamId integer
---@param connection Connection
function SendObjectsListEvent:readStream(streamId, connection)
    local hoCount = streamReadUInt16(streamId)
    for i = 1, hoCount, 1 do
        ---@type HiddenObject
        local ho = {index = streamReadString(streamId)}
        ho.player = streamReadString(streamId)
        ho.timestamp = streamReadUIntN(streamId, 28)
        ho.onlyDecollide = streamReadBool(streamId)
        table.insert(self.hiddenObjects, ho)
    end
    self:run(connection)
end

---@param connection Connection
function SendObjectsListEvent:run(connection)
    MapObjectsHider.gui.target:onHiddenObjectsReceived(self.hiddenObjects)
end
