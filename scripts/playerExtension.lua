--[[
--DE--
Teil des Map Object Hider für den LS22 von Achimobil aufgebaut auf den Skripten von Royal Modding aus dem LS 19.
Kopieren und wiederverwenden ob ganz oder in Teilen ist untersagt.

--EN--
Part of the Map Object Hider for the LS22 by Achimobil based on the scripts by Royal Modding from the LS 19.
Copying and reusing in whole or in part is prohibited.

Skript version 0.2.0.0 of 01.01.2023
]]

PlayerExtension = {}

---@param superFunc function
---@param isServer boolean
---@param isClient boolean
---@return Player
function PlayerExtension.new(isServer, isClient)
	self = Player.originalNew(isServer, isClient)
	self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_HIDE] = {
		eventId = "",
		callback = self.hideObjectActionEvent,
		triggerUp = false,
		triggerDown = true,
		triggerAlways = false,
		activeType = Player.INPUT_ACTIVE_TYPE.STARTS_ENABLED,
		callbackState = nil,
		text = g_i18n:getText("moh_HIDE"),
		textVisibility = true
	}
	self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_DECOLLIDE] = {
		eventId = "",
		callback = self.decollideObjectActionEvent,
		triggerUp = false,
		triggerDown = true,
		triggerAlways = false,
		activeType = Player.INPUT_ACTIVE_TYPE.STARTS_ENABLED,
		callbackState = nil,
		text = g_i18n:getText("moh_HIDE"),
		textVisibility = true
	}
	self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_GUI] = {
		eventId = "",
		callback = self.showHiddenObjectsListActionEvent,
		triggerUp = false,
		triggerDown = true,
		triggerAlways = false,
		activeType = Player.INPUT_ACTIVE_TYPE.STARTS_ENABLED,
		callbackState = nil,
		text = g_i18n:getText("moh_MAP_OBJECT_HIDER_GUI"),
		textVisibility = true
	}
	--Logging.info("PlayerExtension new called")
	return self
end

---@param superFunc function
---@param dt number
function PlayerExtension:update(superFunc, dt)
	superFunc(self, dt)
	if MapObjectsHider.debug and self.debugInfo ~= nil then
		DebugUtility.renderTable(0.05, 0.98, 0.009, self.debugInfo, 4, false)
	end
	if MapObjectsHider.debug and self.hideObjectDebugInfo ~= nil then
		DebugUtility.renderTable(0.35, 0.98, 0.009, self.hideObjectDebugInfo, 4, false)
	end
end

---@param superFunc function
---@param dt number
function PlayerExtension:updateTick(superFunc, dt)
	superFunc(self, dt)
	if self.isEntered and g_dedicatedServerInfo == nil then
		local x, y, z = localToWorld(self.cameraNode, 0, 0, 1.0)
		local dx, dy, dz = localDirectionToWorld(self.cameraNode, 0, 0, -1)
		if self.raycastHideObject ~= nil then
			self.lastRaycastHideObject = self.raycastHideObject
		end
		self.raycastHideObject = nil
		self.debugInfo = nil
		self.hideObjectDebugInfo = nil
		raycastAll(x, y, z, dx, dy, dz, "raycastCallback", 5, self)
	end
end

---@param hitObjectId integer
---@return boolean
function PlayerExtension:raycastCallback(hitObjectId)
	if hitObjectId ~= self.rootNode then
		if getHasClassId(hitObjectId, ClassIds.SHAPE) then
			if hitObjectId == self.lastRaycastHitObject and not MapObjectsHider.debug then
				self.raycastHideObject = self.lastRaycastHideObject
				return false
			end
			local objectFound = false
			if MapObjectsHider.debug and self.debugInfo == nil then
				-- debug first hitted object
				self.debugInfo = MapObjectsHider:getObjectDebugInfo(hitObjectId)
			end
			local rigidBodyType = getRigidBodyType(hitObjectId)
			if (rigidBodyType == RigidBodyType.STATIC or rigidBodyType == RigidBodyType.DYNAMIC) then
				if getSplitType(hitObjectId) ~= 0 then
					self.raycastHideObject = {name = getName(getParent(hitObjectId)), objectId = hitObjectId, isSplitShape = true}
					if MapObjectsHider.debug then
						-- debug placeable
						self.hideObjectDebugInfo = {type = "Split Type", splitType = g_splitTypeManager:getSplitTypeByIndex(getSplitType(hitObjectId))}
					end
					objectFound = true
				elseif g_currentMission:getNodeObject(hitObjectId) == nil then
					local object = {}
					object.id, object.name = MapObjectsHider:getRealHideObject(hitObjectId)
					if object.id ~= nil then
						self.raycastHideObject = object
						if MapObjectsHider.debug then
							-- debug hide object
							self.hideObjectDebugInfo = MapObjectsHider:getObjectDebugInfo(object.id)
						end
						objectFound = true
					end
				else
					local object = g_currentMission:getNodeObject(hitObjectId)
					if object:isa(Placeable) then
						local storeItem = g_storeManager:getItemByXMLFilename(object.configFileName)
						if storeItem ~= nil then
							local canSell = object:canBeSold() and storeItem.canBeSold and g_currentMission:getFarmId() == object:getOwnerFarmId();
							if canSell then
								self.raycastHideObject = {name = storeItem.name, object = object, isSellable = true}
								if MapObjectsHider.debug then
									-- debug placeable
									self.hideObjectDebugInfo = {type = "Placeable", storeItem = storeItem}
								end
								objectFound = true
							end
						end
					end
				end
			end
			if objectFound then
				self.lastRaycastHitObject = hitObjectId
				return false
			end
		end
	end
	return true -- continue raycast
end

---@param superFunc function
function PlayerExtension:updateActionEvents(superFunc)
	superFunc(self)
	local eventIdDecollide = self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_DECOLLIDE].eventId;
	local canDecollide = false;
	if self.raycastHideObject ~= nil then
		local id = self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_HIDE].eventId
		if self.raycastHideObject.isSellable then
			g_inputBinding:setActionEventText(id, g_i18n:getText("moh_SELL"):format(self.raycastHideObject.name))
		elseif self.raycastHideObject.isSplitShape then
			g_inputBinding:setActionEventText(id, g_i18n:getText("moh_DELETE"):format(self.raycastHideObject.name))
		else
			g_inputBinding:setActionEventText(id, g_i18n:getText("moh_HIDE"):format(self.raycastHideObject.name))
			g_inputBinding:setActionEventText(eventIdDecollide, g_i18n:getText("moh_DECOLLIDE"):format(self.raycastHideObject.name))
			canDecollide = true;
		end
		g_inputBinding:setActionEventActive(id, true)
		g_inputBinding:setActionEventTextVisibility(id, true)
	else
		local id = self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_HIDE].eventId
		g_inputBinding:setActionEventActive(id, false)
		g_inputBinding:setActionEventTextVisibility(id, false)
	end
	local id = self.inputInformation.registrationList[InputAction.MAP_OBJECT_HIDER_GUI].eventId
	g_inputBinding:setActionEventTextVisibility(id, MapObjectsHider.guiShowHelpEnabled)
	
	g_inputBinding:setActionEventActive(eventIdDecollide, canDecollide)
	g_inputBinding:setActionEventTextVisibility(eventIdDecollide, canDecollide)
end

function Player:baseObjectActionEvent(onlyDecollide)
	MapObjectsHider.print("Player:baseObjectActionEvent(%s)", onlyDecollide);
	if self.raycastHideObject ~= nil then
		self.raycastHideObjectBackup = self.raycastHideObject
		self.onlyDecollide = onlyDecollide
		if self.raycastHideObject.isSellable then
			if MapObjectsHider.sellConfirmEnabled then
				g_gui:showYesNoDialog({text = g_i18n:getText("moh_sell_dialog_text"):format(self.raycastHideObjectBackup.name), title = g_i18n:getText("moh_dialog_title"), callback = self.sellObjectDialogCallback, target = self})
			else
				self:sellObjectDialogCallback(true)
			end
		elseif self.raycastHideObject.isSplitShape then
			if MapObjectsHider.deleteSplitShapeConfirmEnabled then
				g_gui:showYesNoDialog({text = g_i18n:getText("moh_delete_split_shape_dialog_text"), title = g_i18n:getText("moh_dialog_title"), callback = self.deleteSplitShapeDialogCallback, target = self})
			else
				self:deleteSplitShapeDialogCallback(true)
			end
		else
			if MapObjectsHider.hideConfirmEnabled then
				g_gui:showYesNoDialog({text = g_i18n:getText("moh_dialog_text"):format(self.raycastHideObjectBackup.name), title = g_i18n:getText("moh_dialog_title"), callback = self.hideObjectDialogCallback, target = self})
			else
				self:hideObjectDialogCallback(true)
			end
		end
	end
end

function PlayerExtension:hideObjectActionEvent()
	MapObjectsHider.print("PlayerExtension:hideObjectActionEvent()");
	self:baseObjectActionEvent(false)
end

function PlayerExtension:decollideObjectActionEvent()
	MapObjectsHider.print("PlayerExtension:decollideObjectActionEvent()");
	self:baseObjectActionEvent(true)
end

function PlayerExtension:showHiddenObjectsListActionEvent()
	MapObjectsHider:openGui()
end

---@param yes boolean
function PlayerExtension:hideObjectDialogCallback(yes)
	MapObjectsHider.print("PlayerExtension:hideObjectDialogCallback(%s)", yes);
	if yes and self.raycastHideObjectBackup ~= nil and self.raycastHideObjectBackup.id ~= nil then
		MapObjectsHider:hideObject(self.raycastHideObjectBackup.id, nil, nil, self.onlyDecollide)
		self.raycastHideObjectBackup = nil
	end
end

---@param yes boolean
function PlayerExtension:sellObjectDialogCallback(yes)
	if yes and self.raycastHideObjectBackup ~= nil and self.raycastHideObjectBackup.object ~= nil then
		g_client:getServerConnection():sendEvent(SellPlaceableEvent.new(self.raycastHideObjectBackup.object, false, true))
	end
end

---@param yes boolean
function PlayerExtension:deleteSplitShapeDialogCallback(yes)
	if yes and self.raycastHideObjectBackup ~= nil and self.raycastHideObjectBackup.objectId ~= nil then
		g_client:getServerConnection():sendEvent(DeleteSplitShapeEvent.new(self.raycastHideObjectBackup.objectId))
	end
end
