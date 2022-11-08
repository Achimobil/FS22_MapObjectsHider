--[[
Map Object Hider für den LS22
Basierend auf den Prinzipien des gleichnahmigen Mods von Royal Modding aus dem LS 19
]]


MapObjectsHider = {}
MapObjectsHider.metadata = {
	name = "MapObjectsHider",
	modName = "FS22_MapObjectsHider",
	currentModName = g_currentModName,
	version = "0.1.0.0",
	author = "Achimobil",
	info = "Das verändern und wiederöffentlichen, auch in Teilen, ist untersagt und wird abgemahnt."
};
MapObjectsHider.isInit = false;
MapObjectsHider.debug = true;
MapObjectsHider.md5 = not MapObjectsHider.debug
MapObjectsHider.hideConfirmEnabled = true
MapObjectsHider.sellConfirmEnabled = true
MapObjectsHider.deleteSplitShapeConfirmEnabled = true
MapObjectsHider.guiShowHelpEnabled = true
MapObjectsHider.hiddenObjects = {}

function MapObjectsHider:init()
	MapObjectsHider.isInit = true;
	if self.metadata.currentModName ~= self.metadata.modName then
		Logging.error("%s is illigal version of %s. Please load original", self.metadata.currentModName, self.metadata.modName);
		return;
	end
	Logging.info("%s - init (Version: %s)", self.metadata.name, self.metadata.version)
	
	-- Bind PlayerExtension
	-- alte funktion speichern, da keine Klassenfunktion
	if Player.originalNew == nil then
		Player.originalNew = Player.new
	end
	Player.new = Utils.overwrittenFunction(Player.new, PlayerExtension.new)
	
	
	
	Player.updateTick = Utils.overwrittenFunction(Player.updateTick, PlayerExtension.updateTick)
	Player.update = Utils.overwrittenFunction(Player.update, PlayerExtension.update)
	Player.updateActionEvents = Utils.overwrittenFunction(Player.updateActionEvents, PlayerExtension.updateActionEvents)

	if Player.raycastCallback == nil then
		Player.raycastCallback = PlayerExtension.raycastCallback
	end

	if Player.hideObjectActionEvent == nil then
		Player.hideObjectActionEvent = PlayerExtension.hideObjectActionEvent
	end

	if Player.hideObjectDialogCallback == nil then
		Player.hideObjectDialogCallback = PlayerExtension.hideObjectDialogCallback
	end

	if Player.sellObjectDialogCallback == nil then
		Player.sellObjectDialogCallback = PlayerExtension.sellObjectDialogCallback
	end

	if Player.deleteSplitShapeDialogCallback == nil then
		Player.deleteSplitShapeDialogCallback = PlayerExtension.deleteSplitShapeDialogCallback
	end

	if Player.showHiddenObjectsListActionEvent == nil then
		Player.showHiddenObjectsListActionEvent = PlayerExtension.showHiddenObjectsListActionEvent
	end
	
end

function MapObjectsHider:loadMap(filename)
	Logging.info("%s:loadMap(%s)", self.metadata.name, filename)
	-- init on first call
	if not MapObjectsHider.isInit then MapObjectsHider:init(); end
end

---@param objectId integer
---@return table
function MapObjectsHider:getObjectDebugInfo(objectId)
	local debugInfo = {}
	debugInfo.type = "Object Debug Info"
	debugInfo.id = objectId
	debugInfo.objectClassId, debugInfo.objectClass = EntityUtility.getObjectClass(objectId)
	debugInfo.object = g_currentMission:getNodeObject(objectId) or "nil"
	debugInfo.rigidBodyType = getRigidBodyType(objectId)
	debugInfo.index = EntityUtility.nodeToIndex(objectId, self.mapNode)
	debugInfo.name = getName(objectId)
	debugInfo.clipDistance = getClipDistance(objectId)
	debugInfo.mask = getObjectMask(objectId)

	if debugInfo.objectClassId == ClassIds.SHAPE then
		debugInfo.isNonRenderable = getIsNonRenderable(objectId)
		debugInfo.geometry = getGeometry(objectId)
		debugInfo.material = getMaterial(objectId, 0)
		debugInfo.materialName = getName(debugInfo.material)
	end

	return debugInfo
end

---@param objectId integer
---@return integer | nil
---@return string
function MapObjectsHider:getRealHideObject(objectId)
	-- local amo = self.animatedMapObjectCollisions[objectId]
	-- if amo ~= nil then
		-- return amo.mapObjectsHider.rootNode, getName(amo.mapObjectsHider.rootNode)
	-- end

	-- try to intercept big sized objects with LOD such as houses
	if getName(getParent(objectId)) == "LOD0" then
		local rootNode = getParent(getParent(objectId))
		return rootNode, getName(rootNode)
	end

	local name = ""
	local id = nil

	-- try to intercept medium sized objects such as electric cabins
	local parent = getParent(objectId)
	if getNumOfChildren(objectId) <= 8 then
		EntityUtility.queryNodeHierarchy(
			parent,
			function(_, nodeName, depth)
				if depth == 2 then
					if string.find(string.lower(nodeName), "decal", 1, true) then
						name = getName(parent)
						id = parent
					end
				end
			end
		)
		if id ~= nil then
			return id, name
		end
	end

	EntityUtility.queryNodeParents(
		objectId,
		function(node, nodeName)
			-- do some extra checks to ensure that's the real object
			if getVisibility(node) then
				id = node
				name = nodeName
				return false
			end
			return true
		end
	)
	return id, name
end

---@param objectId integer
---@param name string
---@param hiderPlayerName string
function MapObjectsHider:hideObject(objectId, name, hiderPlayerName)
	if g_server ~= nil then
		local objectName = name or getName(objectId)

		local object = MapObjectsHider:getHideObject(objectId, objectName, hiderPlayerName)

		if MapObjectsHider:checkHideObject(object) then
			self:hideNode(object.id)
			HideDecollideNodeEvent.sendToClients(object.index, true)
			for _, collision in pairs(object.collisions) do
				self:decollideNode(collision.id)
				HideDecollideNodeEvent.sendToClients(collision.index, false)
			end
			table.insert(self.hiddenObjects, object)
		end
	else
		ObjectHideRequestEvent.sendToServer(objectId)
	end
end

---@param objectId integer
---@param objectName string
---@param hiderPlayerName string
---@return HideObject
function MapObjectsHider:getHideObject(objectId, objectName, hiderPlayerName)
	---@class HideObject
	local object = {}
	object.index = EntityUtility.nodeToIndex(objectId, self.mapNode)
	object.id = objectId
	object.hash = EntityUtility.getNodeHierarchyHash(objectId, self.mapNode, self.md5)
	object.name = objectName
	object.date = getDate("%d/%m/%Y")
	object.time = getDate("%H:%M:%S")
	object.timestamp = Utility.getTimestamp()
	object.player = hiderPlayerName or g_currentMission.userManager:getUserByUserId(g_currentMission.player.userId):getNickname()

	---@type HideObjectCollision[]
	object.collisions = {}
	EntityUtility.queryNodeHierarchy(
		objectId,
		---@param node integer
		---@param name string
		function(node, name)
			local rigidType = getRigidBodyType(node)
			if rigidType ~= "NoRigidBody" then
				---@class HideObjectCollision
				local col = {}
				col.index = EntityUtility.nodeToIndex(node, self.mapNode)
				col.name = name
				col.id = node
				col.rigidBodyType = rigidType
				table.insert(object.collisions, col)
			end
		end
	)
	return object
end

---@param object HideObject
---@return boolean
function MapObjectsHider:checkHideObject(object)
    if type(object.id) ~= "number" or not entityExists(object.id) then
        return false
    end

    if object.hash ~= EntityUtility.getNodeHierarchyHash(object.id, self.mapNode, self.md5) then
        return false
    end

    if object.name ~= getName(object.id) then
        return false
    end

    for _, collision in pairs(object.collisions) do
        if type(collision.id) ~= "number" or not entityExists(collision.id) then
            return false
        end

        if collision.rigidBodyType ~= getRigidBodyType(collision.id) then
            return false
        end

        if collision.name ~= getName(collision.id) then
            return false
        end
    end

    return true
end
---@param nodeId integer
function MapObjectsHider:hideNode(nodeId)
    setVisibility(nodeId, false)
end

---@param nodeId integer
function MapObjectsHider:decollideNode(nodeId)
    setRigidBodyType(nodeId, RigidBodyType.NONE)
end

-- function MapObjectsHider:update(dt)
	-- Logging.info("%s:update(dt)", self.metadata.name)
-- end

-- function MapObjectsHider:deleteMap()
	-- Logging.info("%s:deleteMap()", self.metadata.name)
-- end

-- function MapObjectsHider:draw()
	-- Logging.info("%s:draw(), self.metadata.name")
-- end

addModEventListener(MapObjectsHider);