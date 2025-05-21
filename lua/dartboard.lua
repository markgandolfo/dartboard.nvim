-- A plugin to mark files and quickly access them, inspired by Harpoon and Lasso

local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Storage for marked files
M.marks = {}
M.config = {
	marks_file = vim.fn.stdpath("data") .. "/dartboard.json",
}

-- Save marks to disk
local function save_marks()
	local file = io.open(M.config.marks_file, "w")
	if file then
		file:write(vim.fn.json_encode(M.marks))
		file:close()
	end
end

-- Load marks from disk
local function load_marks()
	local file = io.open(M.config.marks_file, "r")
	if file then
		local content = file:read("*all")
		file:close()

		if content and content ~= "" then
			local ok, decoded = pcall(vim.fn.json_decode, content)
			if ok and type(decoded) == "table" then
				M.marks = decoded
				return
			end
		end
	end
	M.marks = {}
end

-- Add current file to marks
function M.add_file()
	local current_file = vim.fn.expand("%:p")

	-- Don't add if it's empty or not a proper file
	if current_file == "" then
		vim.notify("No file open to mark", vim.log.levels.WARN)
		return
	end

	-- Check if file is already in marks
	for _, file in ipairs(M.marks) do
		if file == current_file then
			vim.notify("File already marked", vim.log.levels.INFO)
			return
		end
	end

	table.insert(M.marks, current_file)
	save_marks()
	vim.notify("File marked: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
end

-- Remove file from marks
function M.remove_file()
	local current_file = vim.fn.expand("%:p")

	for i, file in ipairs(M.marks) do
		if file == current_file then
			table.remove(M.marks, i)
			save_marks()
			vim.notify("File unmarked: " .. vim.fn.fnamemodify(current_file, ":t"), vim.log.levels.INFO)
			return
		end
	end

	vim.notify("File not in mark list", vim.log.levels.WARN)
end

-- Go to mark by index
function M.goto_file(index)
	if index > 0 and index <= #M.marks then
		local file = M.marks[index]
		if file and vim.fn.filereadable(file) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(file))
		else
			vim.notify("File no longer exists: " .. file, vim.log.levels.ERROR)
			-- Optionally remove the invalid file
			table.remove(M.marks, index)
			save_marks()
		end
	else
		vim.notify("No file at index " .. index, vim.log.levels.WARN)
	end
end

-- Clear all marks
function M.clear_marks()
	M.marks = {}
	save_marks()
	vim.notify("All marks cleared", vim.log.levels.INFO)
end

-- Show marks in Telescope
function M.show_marks()
	if #M.marks == 0 then
		vim.notify("No marked files", vim.log.levels.INFO)
		return
	end

	local items = {}
	for i, file in ipairs(M.marks) do
		local display = string.format("%d: %s", i, vim.fn.fnamemodify(file, ":~:."))
		table.insert(items, {
			index = i,
			value = file,
			display = display,
		})
	end

	pickers
		.new({}, {
			prompt_title = "Dartboard",
			finder = finders.new_table({
				results = items,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.display,
						ordinal = entry.display,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				-- Open file on selection
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value then
						vim.cmd("edit " .. vim.fn.fnameescape(selection.value.value))
					end
				end)

				-- Remove file from list
				map("i", "<C-d>", function()
					local selection = action_state.get_selected_entry()
					if selection and selection.value then
						local index = selection.value.index
						table.remove(M.marks, index)
						save_marks()

						-- Refresh the picker
						actions.close(prompt_bufnr)
						M.show_marks()
					end
				end)

				return true
			end,
		})
		:find()
end

-- Setup function
function M.setup(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", M.config, opts)

	-- Load marks from disk
	load_marks()

	-- Create user commands
	vim.api.nvim_create_user_command("DartboardAdd", M.add_file, {})
	vim.api.nvim_create_user_command("DartboardRemove", M.remove_file, {})
	vim.api.nvim_create_user_command("DartboardClear", M.clear_marks, {})
	vim.api.nvim_create_user_command("DartboardList", M.show_marks, {})

	-- Create commands for quick navigation
	for i = 1, 9 do
		vim.api.nvim_create_user_command("DartboardGoto" .. i, function()
			M.goto_file(i)
		end, {})
	end

	-- Set up default keybindings if not disabled
	if opts.use_default_keymaps ~= false then
		-- Add current file to marks
		vim.keymap.set("n", "<leader>da", ":DartboardAdd<CR>", { desc = "[D]artboard [A]dd file" })

		-- Remove current file from marks
		vim.keymap.set("n", "<leader>dr", ":DartboardRemove<CR>", { desc = "[D]artboard [R]emove file" })

		-- Show marked files in Telescope
		vim.keymap.set("n", "<leader>dl", ":DartboardList<CR>", { desc = "[D]artboard [L]ist files" })

		-- Clear all marks
		vim.keymap.set("n", "<leader>dc", ":DartboardClear<CR>", { desc = "[D]artboard [C]lear all" })

		-- Quick navigation to marks by index
		for i = 1, 5 do
			vim.keymap.set(
				"n",
				"<leader>" .. i,
				":DartboardGoto" .. i .. "<CR>",
				{ desc = "Go to dartboard mark " .. i }
			)
		end
	end
end

return M
