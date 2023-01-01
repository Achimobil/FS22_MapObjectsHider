--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

ObjectHideRequestEvent = {}
local ObjectHideRequestEvent_mt = Class(ObjectHideRequestEvent, Event)

InitEventClass(ObjectHideRequestEvent, "ObjectHideRequestEvent")

---@return table
function ObjectHideRequestEvent.emptyNew()
    local o = Event.new(ObjectHideRequestEvent_mt)
    o.className = "ObjectHideRequestEvent"
    return o
end

---@param objectIndex string
---@return table
function ObjectHideRequestEvent.new(objectIndex)
    local o = ObjectHideRequestEvent.emptyNew()
    o.objectIndex = objectIndex
    return o
end

---@param streamId integer
function ObjectHideRequestEvent:writeStream(streamId, _)
    streamWriteString(streamId, self.objectIndex)
end

---@param streamId integer
---@param connection Connection
function ObjectHideRequestEvent:readStream(streamId, connection)
    self.objectIndex = streamReadString(streamId)
    self:run(connection)
end

---@param connection Connection
function ObjectHideRequestEvent:run(connection)
    if g_server ~= nil then
        MapObjectsHider:hideObject(EntityUtility.indexToNode(self.objectIndex, MapObjectsHider.mapNode), nil, g_currentMission.userManager:getUserByConnection(connection):getNickname())
    end
end

---@param objectId integer
function ObjectHideRequestEvent.sendToServer(objectId)
    if g_server == nil then
        g_client:getServerConnection():sendEvent(ObjectHideRequestEvent.new(EntityUtility.nodeToIndex(objectId, MapObjectsHider.mapNode)))
    end
end