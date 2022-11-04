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

function MapObjectsHider:init()
	MapObjectsHider.isInit = true;
	if self.metadata.currentModName ~= self.metadata.modName then
		Logging.error("%s is illigal version of %s. Please load original", self.metadata.currentModName, self.metadata.modName);
		return;
	end
	Logging.info("%s - init (Version: %s)", self.metadata.name, self.metadata.version)
end
function MapObjectsHider:loadMap(filename)
	Logging.info("%s:loadMap(%s)", self.metadata.name, filename)
	-- init on first call
	if not MapObjectsHider.isInit then MapObjectsHider:init(); end
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