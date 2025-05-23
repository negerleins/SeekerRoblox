return setmetatable({}, {
	__index = function(t, k)
		local module = script[k]
		if module then
			return require(module)
		end

		return
	end,
})
