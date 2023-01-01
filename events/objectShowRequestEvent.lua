--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

ObjectShowRequestEvent = {}
local ObjectShowRequestEvent_mt = Class(ObjectShowRequestEvent, Event)

InitEventClass(ObjectShowRequestEvent, "ObjectShowRequestEvent")

---@return table
function ObjectShowRequestEvent.emptyNew()
    local o = Event.new(ObjectShowRequestEvent_mt)
    o.className = "ObjectShowRequestEvent"
    return o
end

---@param objectIndex string
---@return table
function ObjectShowRequestEvent.new(objectIndex)
    local o = ObjectShowRequestEvent.emptyNew()
    o.objectIndex = objectIndex
    return o
end

---@param streamId integer
function ObjectShowRequestEvent:writeStream(streamId, _)
    streamWriteString(streamId, self.objectIndex)
end

---@param streamId integer
---@param connection Connection
function ObjectShowRequestEvent:readStream(streamId, connection)
    self.objectIndex = streamReadString(streamId)
    self:run(connection)
end

---@param connection Connection
function ObjectShowRequestEvent:run(connection)
    if g_server ~= nil then
        MapObjectsHider:showObject(self.objectIndex)
    end
end

---@param objectIndex string
function ObjectShowRequestEvent.sendToServer(objectIndex)
    g_client:getServerConnection():sendEvent(ObjectShowRequestEvent.new(objectIndex))
end
