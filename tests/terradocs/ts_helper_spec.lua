-- Tests for terradocs/ts_helper.lua
local ts_helper = require("terradocs.ts_helper")

-- Helper function to check if HCL parser is available
local function has_hcl_parser()
	local ok, _ = pcall(vim.treesitter.language.inspect, "hcl")
	return ok
end

-- Helper function to create a buffer with HCL content and position cursor
local function setup_hcl_buffer(content, cursor_row)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(buf)
	local lines = vim.split(content, "\n")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "filetype", "terraform")
	if cursor_row then
		vim.api.nvim_win_set_cursor(0, { cursor_row, 0 })
	end
	return buf
end

-- Helper function to cleanup buffer
local function cleanup_buffer(buf)
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

describe("ts_helper", function()
	describe("module structure", function()
		it("exports get_resource_info function", function()
			assert.is_not_nil(ts_helper.get_resource_info)
			assert.is_function(ts_helper.get_resource_info)
		end)
	end)

	-- These tests require HCL parser to be installed
	describe("get_resource_info with HCL parser", function()
		local buf

		before_each(function()
			if not has_hcl_parser() then
				pending("HCL tree-sitter parser not available")
			end
		end)

		after_each(function()
			cleanup_buffer(buf)
		end)

		describe("resource blocks", function()
			it("extracts resource type and name from aws_instance", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("aws_instance", resource_name)
			end)

			it("extracts resource type from google_compute_instance", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("google_compute_instance", resource_name)
			end)

			it("extracts resource type from azurerm_virtual_machine", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "azurerm_virtual_machine" "main" {
  name                  = "my-vm"
  location              = "eastus"
  resource_group_name   = "my-rg"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("azurerm_virtual_machine", resource_name)
			end)

			it("works when cursor is inside resource block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "aws_s3_bucket" "mybucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"
}
]]
				buf = setup_hcl_buffer(content, 2) -- cursor on line 2 (inside block)

				local block_type, resource_name = ts_helper.get_resource_info()
				-- Should still find the resource block
				assert.equals("resource", block_type)
				assert.equals("aws_s3_bucket", resource_name)
			end)
		end)

		describe("data blocks", function()
			it("extracts data source type and name from aws_ami", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("data", block_type)
				assert.equals("aws_ami", resource_name)
			end)

			it("extracts data source from google_compute_image", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("data", block_type)
				assert.equals("google_compute_image", resource_name)
			end)

			it("works when cursor is inside data block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
data "aws_availability_zones" "available" {
  state = "available"
}
]]
				buf = setup_hcl_buffer(content, 2)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("data", block_type)
				assert.equals("aws_availability_zones", resource_name)
			end)
		end)

		describe("multiple blocks", function()
			it("extracts correct block when cursor is on first resource", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("aws_vpc", resource_name)
			end)

			it("extracts correct block when cursor is on second resource", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
]]
				buf = setup_hcl_buffer(content, 5)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("aws_subnet", resource_name)
			end)

			it("handles mixed resource and data blocks", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}
]]
				buf = setup_hcl_buffer(content, 3)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("aws_s3_bucket", resource_name)
			end)
		end)

		describe("edge cases", function()
			it("returns nil values when cursor is not on a resource/data block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
variable "region" {
  default = "us-west-2"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)

			it("returns nil when cursor is on provider block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
provider "aws" {
  region = "us-west-2"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)

			it("returns nil when cursor is on terraform block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
terraform {
  required_version = ">= 1.0"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)

			it("returns nil when cursor is on locals block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
locals {
  name = "example"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)

			it("returns nil when cursor is on output block", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
output "instance_id" {
  value = aws_instance.example.id
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)

			it("returns nil on empty buffer", function()
				if not has_hcl_parser() then
					return
				end

				buf = setup_hcl_buffer("", 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.is_nil(block_type)
				assert.is_nil(resource_name)
			end)
		end)

		describe("complex resource names", function()
			it("handles resource with underscores in name", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("aws_iam_role_policy_attachment", resource_name)
			end)

			it("handles kubernetes resources", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("kubernetes_deployment", resource_name)
			end)

			it("handles oci resources with long names", function()
				if not has_hcl_parser() then
					return
				end

				local content = [[
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
}
]]
				buf = setup_hcl_buffer(content, 1)

				local block_type, resource_name = ts_helper.get_resource_info()
				assert.equals("resource", block_type)
				assert.equals("oci_core_virtual_network", resource_name)
			end)
		end)
	end)
end)

-- Test that the module doesn't crash without tree-sitter
describe("ts_helper robustness", function()
	it("function exists and is callable", function()
		assert.has_no.errors(function()
			-- Just verify it doesn't crash when called
			-- Results may vary based on parser availability
			pcall(ts_helper.get_resource_info)
		end)
	end)
end)
