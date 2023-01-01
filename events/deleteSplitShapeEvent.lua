--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

DeleteSplitShapeEvent = {}
local DeleteSplitShapeEvent_mt = Class(DeleteSplitShapeEvent, Event)

InitEventClass(DeleteSplitShapeEvent, "DeleteSplitShapeEvent")

function DeleteSplitShapeEvent.emptyNew()
    local e = Event.new(DeleteSplitShapeEvent_mt)
    return e
end

---@param splitShapeId integer
---@return table
function DeleteSplitShapeEvent.new(splitShapeId)
    local e = DeleteSplitShapeEvent.emptyNew()
    e.splitShapeId = splitShapeId
    return e
end

---@param streamId integer
function DeleteSplitShapeEvent:writeStream(streamId)
    writeSplitShapeIdToStream(streamId, self.splitShapeId)
end

---@param streamId integer
---@param connection Connection
function DeleteSplitShapeEvent:readStream(streamId, connection)
    self.splitShapeId = readSplitShapeIdFromStream(streamId)
    self:run(connection)
end

function DeleteSplitShapeEvent:run()
    if self.splitShapeId ~= 0 then
        delete(self.splitShapeId)
    end
end

---@param splitShapeId integer
function DeleteSplitShapeEvent.sendEvent(splitShapeId)
    g_client:getServerConnection():sendEvent(DeleteSplitShapeEvent.new(splitShapeId))
end
