--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

RequestObjectsListEvent = {}
local RequestObjectsListEvent_mt = Class(RequestObjectsListEvent, Event)

InitEventClass(RequestObjectsListEvent, "RequestObjectsListEvent")

---@return table
function RequestObjectsListEvent.emptyNew()
    local o = Event.new(RequestObjectsListEvent_mt)
    o.className = "RequestObjectsListEvent"
    return o
end

---@return table
function RequestObjectsListEvent.new()
    local o = RequestObjectsListEvent.emptyNew()
    return o
end

---@param streamId integer
function RequestObjectsListEvent:writeStream(streamId, _)
end

---@param streamId integer
---@param connection Connection
function RequestObjectsListEvent:readStream(streamId, connection)
    self:run(connection)
end

---@param connection Connection
function RequestObjectsListEvent:run(connection)
    if g_server ~= nil then
        connection:sendEvent(SendObjectsListEvent.new(MapObjectsHider.hiddenObjects))
    end
end

function RequestObjectsListEvent.sendToServer()
    g_client:getServerConnection():sendEvent(RequestObjectsListEvent.new())
end
