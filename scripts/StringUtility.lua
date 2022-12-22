--- Royal Utility

---@author Royal Modding
---@version 2.1.1.0
---@date 05/01/2021

--- String utilities class
---@class StringUtility
StringUtility = StringUtility or {}

--- Split a string
---@param s string
---@param sep string
---@return string[]
function StringUtility.split(s, sep)
    sep = sep or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    s:gsub(
        pattern,
        function(c)
            fields[#fields + 1] = c
        end
    )
    return fields
end