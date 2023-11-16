local ts_helper = require("terradocs.ts_helper")

local M = {}

M.config = {
	-- Default configuration values
	keymap = "<leader>t",
}

local function preview_markdown(content, search_url)
	local readme_content = content

	local tempfile = vim.fn.tempname() .. ".md"
	vim.fn.writefile(vim.fn.split(readme_content, "\n"), tempfile)

	local width = math.min(math.max(80, vim.o.columns - 20), vim.o.columns)
	local height = math.min(math.max(20, vim.o.lines - 10), vim.o.lines)
	local col = (vim.o.columns - width) / 2
	local row = (vim.o.lines - height) / 2

	local buf = vim.api.nvim_create_buf(false, true)
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.fn.readfile(tempfile))
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", ":bd!<CR>", { nowait = true, noremap = true, silent = true })

	local escaped_url = vim.fn.shellescape(search_url, 1)
	local command = string.format(':execute "!open %s"<CR>', escaped_url)
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", command, { nowait = true, noremap = true, silent = true })
end

local function check_provider(provider)
	local hashicorp_providers = {
		"ad",
		"archive",
		"aws",
		"awscc",
		"azuread",
		"azurerm",
		"azurestack",
		"boundary",
		"cloudinit",
		"consul",
		"dns",
		"external",
		"google",
		"google-beta",
		"googleworkspace",
		"kubernetes",
		"hcp",
		"hcs",
		"helm",
		"http",
		"local",
		"nomad",
		"null",
		"random",
		"salesforce",
		"tfe",
		"time",
		"tls",
		"vault",
		"vsphere",
	}
	local oracle_providers = {
		"oci",
	}
	for _, v in pairs(oracle_providers) do
		if v == provider then
			return "oracle"
		end
	end
	for _, v in pairs(hashicorp_providers) do
		if v == provider then
			return "hashicorp"
		end
	end
	return nil
end

local function generate_search_urls(provider_org, provider_name, declaration)
	if declaration == "resource" or declaration == "data" then
		local registry_url = "https://registry.terraform.io/providers/"
			.. provider_org
			.. "/"
			.. provider_name
			.. "/latest/docs/"
		local github_api_base = "https://api.github.com/repos/"
			.. provider_org
			.. "/terraform-provider-"
			.. provider_name
			.. "/contents/website/docs/"
		if declaration == "resource" then
			registry_url = registry_url .. "resources/"
			github_api_base = github_api_base .. "r/"
		elseif declaration == "data" then
			registry_url = registry_url .. "data-sources/"
			github_api_base = github_api_base .. "d/"
		end
		return registry_url, github_api_base
	else
		print("declaration is not resource or data")
		return 1
	end
end

local function terraform_search(declaration, resource_type)
	local registry_url
	local github_api_url
	local provider_match = string.match(resource_type, "^([^_]+)_")
	local provider_name = ""

	if provider_match then
		provider_name = string.lower(provider_match)
	else
		print("Could not find provider match in resource name.")
		return
	end

	local provider_org = check_provider(provider_name)
	if provider_org == nil then
		print("provider not found: " .. provider_name)
		return
	end

	registry_url, github_api_url = generate_search_urls(provider_org, provider_name, declaration)

	if string.match(resource_type, "^%a+_%a+") then
		resource_type = string.gsub(resource_type, "^%a+_", "")
	end

	local file_path = resource_type .. ".html.markdown"
	local github_api_url = github_api_url .. file_path

	local search_url = registry_url .. resource_type

	local curl_cmd = "curl -s " .. vim.fn.shellescape(github_api_url)
	local json_response = vim.fn.system(curl_cmd)

	if vim.v.shell_error ~= 0 then
		print("Error fetching the documentation.")
		return
	end

	local success, decoded_json = pcall(vim.fn.json_decode, json_response)
	if not success then
		print("Failed to decode JSON. Invalid JSON response.") -- decoded_json in this context is the error message
		return
	end

	-- Check if decoded_json is not nil and has a "content" field
	if decoded_json and decoded_json["content"] then
		local content_base64 = decoded_json["content"]
		local decoded_content = vim.fn.system("echo " .. vim.fn.shellescape(content_base64) .. " | base64 --decode")

		if vim.v.shell_error ~= 0 then
			print("Error decoding base64 content.")
			return
		end

		preview_markdown(decoded_content, search_url)
	else
		print("JSON does not have the 'content' field or is nil" .. json_response)
		print("search_url is " .. search_url)
		print("type is " .. declaration .. " and resource_type is " .. resource_type)
		return
	end
end

function M.setup()
	-- Command to search for the current word under the cursor
	vim.api.nvim_create_user_command("TFSearch", function()
		local declaration, resource_type = ts_helper.get_resource_info()
		if declaration and resource_type then
			if declaration == "resource" or declaration == "data" then
				-- Assuming terraform_search can take two arguments, the previous word and the current word
				terraform_search(declaration, resource_type)
			else
				print("Identifier not a resource or data type")
			end
		end
	end, {})

	-- Optional: Map a key to the search command for convenience
	vim.api.nvim_set_keymap("n", "<leader>t", ":TFSearch<CR>", { noremap = true, silent = true })
end

return M
