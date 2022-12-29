--[[
Part of Production Revamp

Copyright (C) braeven & Achimobil 2022

Author: Achimobil

Version: 1.1.0.0
Date: 22.08.2022
]]

LoadMapObjectsHiderDataResult = {}
LoadMapObjectsHiderDataResult_mt = Class(LoadMapObjectsHiderDataResult, Event)
InitEventClass(LoadMapObjectsHiderDataResult, "LoadMapObjectsHiderDataResult")

function LoadMapObjectsHiderDataResult.emptyNew()
	local self = Event.new(LoadMapObjectsHiderDataResult_mt)
	return self
end

function LoadMapObjectsHiderDataResult.new()
	MapObjectsHider.print("LoadMapObjectsHiderDataResult.new");
	local self = LoadMapObjectsHiderDataResult.emptyNew()
	return self
end

function LoadMapObjectsHiderDataResult:writeStream(streamId, connection)
	MapObjectsHider.print("LoadMapObjectsHiderDataResult:writeStream");
	
    local objectsCount = #MapObjectsHider.hiddenObjects
    local collisionsCount = 0
    local collisions = {}
    streamWriteInt32(streamId, objectsCount)
    for i = 1, objectsCount, 1 do
        local obj = MapObjectsHider.hiddenObjects[i]
        collisionsCount = collisionsCount + #obj.collisions
        for _, col in pairs(obj.collisions) do
            table.insert(collisions, col.index)
        end
        streamWriteString(streamId, obj.index)
    end
    streamWriteInt32(streamId, collisionsCount)
    for i = 1, collisionsCount, 1 do
        streamWriteString(streamId, collisions[i])
    end
end

function LoadMapObjectsHiderDataResult:readStream(streamId, connection)
	MapObjectsHider.print("LoadMapObjectsHiderDataResult:readStream");
	
    local objectsCount = streamReadInt32(streamId)
    for i = 1, objectsCount, 1 do
        local objIndex = streamReadString(streamId)
        MapObjectsHider:hideNode(EntityUtility.indexToNode(objIndex, MapObjectsHider.mapNode))
    end
    local collisionsCount = streamReadInt32(streamId)
    for i = 1, collisionsCount, 1 do
        local colIndex = streamReadString(streamId)
        MapObjectsHider:decollideNode(EntityUtility.indexToNode(colIndex, MapObjectsHider.mapNode))
    end
	
	self:run(connection)
end

function LoadMapObjectsHiderDataResult:run(connection)
	MapObjectsHider.print("LoadMapObjectsHiderDataResult:run");
end
