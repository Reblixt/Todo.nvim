local M = {}

local function expand_path(path)
	if path:sub(1, 1) == "~" then
		return os.getenv("HOME") .. path:sub(2)
	end
	return path
end

local function win_config()
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)

	return {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		border = "rounded",
		style = "minimal",
	}
end

local function open_floating_file(target_file)
	local expand_path = expand_path(target_file)
	if vim.fn.filereadable(expand_path) == 0 then
		vim.notify("Todo file does not exists at directory: " .. expand_path, vim.log.levels.ERROR)
	end

	local buf = vim.fn.bufnr(expand_path, true)

	if buf == -1 then
		buf = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_set_name(buf, expand_path)
	end

	vim.bo[buf].swapfile = false

	local win = vim.api.nvim_open_win(buf, true, win_config())

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				vim.notify("save your changes please", vim.log.levels.WARN)
			else
				vim.api.nvim_win_close(0, true)
			end
		end,
	})
end

local function setup_user_comands(opts)
	local target_file = opts.target_file or "todo.md"
	vim.api.nvim_create_user_command("Td", function()
		open_floating_file(target_file)
	end, {})
end

M.setup = function(opts)
	setup_user_comands(opts)
end

return M
