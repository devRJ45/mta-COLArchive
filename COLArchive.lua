local string_format = string.format;
local string_byte = string.byte;
local string_char = string.char;
local table_insert = table.insert;

local fileUtils = {};
fileUtils = {
	getNumberFromBytes = function (bytes)
		local sBytes = '';
		for i = 1, #bytes do
			local c = string_format('%x', string_byte(bytes:sub(i, i)));
			if #c == 1 then c = '0' .. c; end;
			sBytes = sBytes .. c;
		end

		return tonumber(sBytes, 16);
	end,
	readUInt = function (file, size, startAt)
		if not size then
			size = 4;
		end

		if startAt then
			fileSetPos(file, startAt);
		end

		local d = fileRead(file, size);
		d = d:reverse();

		return fileUtils.getNumberFromBytes(d);
	end,
	readString = function (file, size, startAt)
		if startAt then
			fileSetPos(file, startAt);
		end

		local d = fileRead(file, size);
		return d;
	end
};

--main class
COLArchive = {};
COLArchive.__index = COLArchive;

setmetatable(COLArchive, {
    __call = function (obj, ...)
        return obj.__constructor(...);
    end,
})

function COLArchive.__constructor (filepath)
    local this = setmetatable({}, COLArchive);

    this.filepath = filepath;
    this.list = {};

    -- check if file exists
    if not File.exists(filepath) then
        return false;
    end

	this.file = File(this.filepath, true); --readonly

	if not this:_readCOLFilesList() then
		return false;
	end

    return this;
end

--static
function COLArchive.isCOLHeader (bytes)
    local header = bytes:sub(1,4);
    return header == 'COLL' or header == 'COL2' or header == 'COL3';
end

function COLArchive:_readCOLFilesList ()
	local offset = 0;
	while true do
		local header = fileUtils.readString(self.file, 4, offset);

		if not COLArchive.isCOLHeader(header) then --its not a col file or end of file
			if offset == 0 then --its not a collision file
				return false;
			end
			break;
		end

		offset = offset + 4;

		local colSize = fileUtils.readUInt(self.file, 4, offset);

		offset = offset + 4;

		local colName = fileUtils.readString(self.file, 22, offset);
		--remove NOPs
		for i=1, #colName do
			if colName:sub(i,i) == string_char(0x00) then
				colName = colName:sub(1,i-1);
				break;
			end
		end

		self.list[colName] = {
			start = offset-8,
			size = colSize+8
		};

		offset = offset + colSize;
	end

	return true;
end

function COLArchive:getNames ()
	local names = {};
	local k, v = next(self.list);
	while k do
		table_insert(k);
		k, v = next(self.list, k);
	end
	return names;
end

function COLArchive:getFile (name)
	if not self.list[name] then return false; end;

	self.file:setPos(self.list[name].start);
	return self.file:read(self.list[name].size);
end

function COLArchive:destroy()
	self:__destructor();
end

function COLArchive:__destructor ()
	if self.file and isElement(self.file) then
		self.file:close();
	end
	self.file = nil;
	self.filepath = nil;
    self.list = nil;
end