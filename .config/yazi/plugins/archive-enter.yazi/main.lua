--- @since 26.9.1

local ARCHIVE_SUFFIXES = {
	{ suffix = ".tar.bz2", kind = "tar" },
	{ suffix = ".tar.lzma", kind = "tar" },
	{ suffix = ".tar.zst", kind = "tar" },
	{ suffix = ".tar.lz4", kind = "tar" },
	{ suffix = ".tar.gz", kind = "tar" },
	{ suffix = ".tar.xz", kind = "tar" },
	{ suffix = ".tar.lz", kind = "tar" },
	{ suffix = ".tar.z", kind = "tar" },
	{ suffix = ".tar", kind = "tar" },
	{ suffix = ".tbz2", kind = "tar" },
	{ suffix = ".tlz4", kind = "tar" },
	{ suffix = ".tzst", kind = "tar" },
	{ suffix = ".tbz", kind = "tar" },
	{ suffix = ".txz", kind = "tar" },
	{ suffix = ".tgz", kind = "tar" },
	{ suffix = ".zip", kind = "zip" },
	{ suffix = ".rar", kind = "rar" },
	{ suffix = ".7z", kind = "7z" },
}

local function parse_archive(name)
	local lower = name:lower()
	local best

	for _, candidate in ipairs(ARCHIVE_SUFFIXES) do
		local suffix = candidate.suffix
		if #name > #suffix and lower:sub(-#suffix) == suffix then
			if not best or #suffix > #best.suffix then
				best = candidate
			end
		end
	end

	if not best then
		return nil
	end

	return best.kind, name:sub(1, #name - #best.suffix)
end

local get_hovered = ya.sync(function()
	local hovered = cx.active.current.hovered
	if not hovered then
		return nil
	end

	return {
		url = tostring(hovered.url),
		name = hovered.name,
		is_dir = hovered.cha.is_dir,
	}
end)

local function notify_error(content)
	ya.notify({
		title = "Extraction failed",
		content = content,
		timeout = 8,
		level = "error",
	})
end

local function extract(kind, archive, target)
	if kind == "rar" then
		return Command("unrar"):arg({ "x", "-o+", "-idq", archive, tostring(target) .. "/" }):output()
	elseif kind == "7z" then
		return Command("7z"):arg({ "x", "-y", "-o" .. tostring(target), archive }):output()
	else
		return Command("bsdtar"):arg({ "-xf", archive, "-C", tostring(target) }):output()
	end
end

local function entry()
	local hovered = get_hovered()
	if not hovered then
		return
	end

	if hovered.is_dir then
		ya.emit("enter", {})
		return
	end

	local kind, stem = parse_archive(hovered.name)
	if not kind then
		ya.emit("open", { hovered = true })
		return
	end

	local source = Url(hovered.url)
	local parent = source.parent
	if not parent then
		notify_error("Cannot determine the archive's parent directory")
		return
	end

	local timestamp = os.date("%Y%m%d_%H%M%S", math.floor(ya.time()))
	local target, target_err = fs.unique("dir", parent:join(stem .. "_" .. timestamp))
	if not target then
		notify_error(tostring(target_err))
		return
	end

	local output, output_err = extract(kind, tostring(source), target)
	if not output then
		fs.remove("dir_all", target)
		notify_error(tostring(output_err))

		return
	end

	if not output.status.success then
		fs.remove("dir_all", target)

		local message = output.stderr
		if message == "" then
			message = "Extractor exited with code " .. tostring(output.status.code)
		end

		notify_error(message)

		return
	end

	ya.emit("cd", { target })
end

return { entry = entry }
