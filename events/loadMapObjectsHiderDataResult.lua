--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
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
        streamWritebool(streamId, obj.onlyDecollide)
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
        local onlyDecollide = streamReadBool(streamId)
		if not onlyDecollide then
			MapObjectsHider:hideNode(EntityUtility.indexToNode(objIndex, MapObjectsHider.mapNode))
		end
    end
    local collisionsCount = streamReadInt32(streamId);
    for i = 1, collisionsCount, 1 do
        local colIndex = streamReadString(streamId);
		local colNodeId = EntityUtility.indexToNode(colIndex, MapObjectsHider.mapNode);
		if colNodeId ~= nil then
			MapObjectsHider:decollideNode(colNodeId)
		else
			Logging.warning("[%s] Can't find colision node for colision index '%s' in LoadMapObjectsHiderDataResult readStream. Collision %s of %s", self.metadata.name, colIndex, i, collisionsCount);
		end
    end
	
	self:run(connection)
end

function LoadMapObjectsHiderDataResult:run(connection)
	MapObjectsHider.print("LoadMapObjectsHiderDataResult:run");
end
