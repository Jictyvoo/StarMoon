local Tag = {}; Tag.__index = Tag

local function generateAttributesString(attributes)
    local attributeString = ""; local count = 0
    for name, value in pairs(attributes) do
        local value = value ~= "" and string.format("\"%s\"", value) or true
        if name:match("-") then name = string.format("[\"%s\"]", name) end
        if count > 0 then
            attributeString = string.format("%s, %s: %s", attributeString, name:gsub("/", ""), value)
        else
            attributeString = string.format("%s: %s", name:gsub("/", ""), value)
        end
        count = count + 1
    end
    return attributeString
end

Tag = setmetatable(Tag, {
    __call = function(self, tagInfo)
        local this = tagInfo or {name = "", attributes = {}, content = "", children = {}}
        this.tabs = 2
        return setmetatable({
            getName = function() return this.name end,
            setName = function(name) this.name = name end,
            getAttributes = function() return this.attributes end,
            getContent = function() return this.content end,
            setContent = function(content) this.content = content end,
            getChildren = function() return this.children end,
            addChild = function(child) table.insert(this.children, child) end,
            setTabNumber = function(total) this.tabs = total end,
            getTabNumber = function() return this.tabs end,
        }, getmetatable(Tag))
    end,
    __tostring = function(self)
        local tagName = self.getName():gsub("[-,/]", "_"); local needComma = false
        if not (self.getName() ~= "select" and self.getName() ~= "table" and self.getName() ~= "!doctype") then
            tagName = "element \"" .. self.getName() .."\""; needComma = true
        end
        if needComma then tagName =  tagName .. "," end
        local openClose = 0
        local attributeString = generateAttributesString(self.getAttributes())
        if #attributeString > 0 then
            needComma = true; attributeString = " " .. attributeString; openClose = openClose + 1
        end
        local contentString = ""
        if self.getContent():gsub("\t+", ""):match("%S") ~= nil then
            contentString = string.gsub(self.getContent(), "\"", "\\\"")
            contentString = " \"" .. contentString .. "\""
            openClose = openClose + 1
            if needComma then contentString = "," .. contentString end
            needComma = true
        end
        local childrenString = ""
        if #self.getChildren() > 0 then
            childrenString = " -> \n"
            for _, child in pairs(self.getChildren()) do
                if type(child) ~= "string" then
                    child.setTabNumber(self.getTabNumber() + 1)
                    childrenString = childrenString .. tostring(child) .. "\n"
                elseif child:gsub("\t+", ""):match("%S") ~= nil then
                    childrenString = childrenString .. string.rep("\t", self.getTabNumber() + 1) .. string.format("\"%s\"", string.gsub(child, "\"", "\\\"")) .. "\n"
                end
            end
            openClose = openClose + 1
            if needComma then childrenString = "," .. childrenString end
        end
        if openClose == 0 then tagName = tagName .. "!" end
        return string.format("%s%s%s%s%s", string.rep("\t", self.getTabNumber()), tagName, attributeString, contentString, childrenString)
    end
})

return Tag