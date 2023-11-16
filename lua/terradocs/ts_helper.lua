local M = {}

--
-- Obtain the Tree-sitter parser for the current buffer (the open file in Neovim).
-- Extract the syntax tree from the parser.
-- Determine the cursor's position in the buffer.
-- Define a Tree-sitter query to look for identifiers in the syntax tree.
-- Iterate over the results of this query to find the node (piece of syntax) that the cursor is currently on.
-- If such a node is found, return its text, which is the identifier at the cursor's position.
--
M.get_resource_info = function()
	local parser = vim.treesitter.get_parser(0)
	local tree = parser:parse()[1]
	local root = tree:root()

	-- Tree-sitter query to capture block types and their first string literal
	local query = vim.treesitter.query.parse(
		"hcl",
		[[
        (block
            (identifier) @block_type (#match? @block_type "resource|data")
            (string_lit
              (template_literal) @template_literal
            )
        )
    ]]
	)

	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local cursor_row = cursor_pos[1] - 1

	local block_type, first_template_literal
	local found_block = false

	for id, node in query:iter_captures(root, 0, cursor_row, cursor_row + 1) do
		local node_type = query.captures[id]
		local node_start_row, _, node_end_row, _ = node:range()

		if cursor_row >= node_start_row and cursor_row <= node_end_row then
			found_block = true

			if node_type == "block_type" then
				block_type = vim.treesitter.get_node_text(node, 0)
			elseif node_type == "template_literal" and not first_template_literal then
				first_template_literal = vim.treesitter.get_node_text(node, 0)
				break
			end
		end
	end

	return block_type, first_template_literal
end

return M
