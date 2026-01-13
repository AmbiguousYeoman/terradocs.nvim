-- Tests for terradocs/init.lua
local ok, terradocs = pcall(require, "terradocs")
if not ok then
	print("ERROR loading terradocs: " .. tostring(terradocs))
	error("Failed to load terradocs module")
end

describe("terradocs", function()
	describe("config", function()
		it("has default keymap configuration", function()
			assert.is_not_nil(terradocs.config)
			assert.is_not_nil(terradocs.config.keymap)
			assert.equals("<leader>t", terradocs.config.keymap)
		end)
	end)

	describe("_hashicorp_providers", function()
		it("contains expected providers", function()
			local providers = terradocs._hashicorp_providers
			assert.is_table(providers)
			assert.is_true(#providers > 0)

			-- Check for key providers
			local has_aws = false
			local has_google = false
			local has_azurerm = false
			for _, v in ipairs(providers) do
				if v == "aws" then
					has_aws = true
				end
				if v == "google" then
					has_google = true
				end
				if v == "azurerm" then
					has_azurerm = true
				end
			end
			assert.is_true(has_aws, "aws should be in hashicorp_providers")
			assert.is_true(has_google, "google should be in hashicorp_providers")
			assert.is_true(has_azurerm, "azurerm should be in hashicorp_providers")
		end)

		it("contains all 30 hashicorp providers", function()
			local expected_providers = {
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
			assert.equals(#expected_providers, #terradocs._hashicorp_providers)
		end)
	end)

	describe("_oracle_providers", function()
		it("contains oci provider", function()
			local providers = terradocs._oracle_providers
			assert.is_table(providers)
			assert.equals(1, #providers)
			assert.equals("oci", providers[1])
		end)
	end)

	describe("_check_provider", function()
		describe("HashiCorp providers", function()
			it("returns 'hashicorp' for aws", function()
				assert.equals("hashicorp", terradocs._check_provider("aws"))
			end)

			it("returns 'hashicorp' for google", function()
				assert.equals("hashicorp", terradocs._check_provider("google"))
			end)

			it("returns 'hashicorp' for azurerm", function()
				assert.equals("hashicorp", terradocs._check_provider("azurerm"))
			end)

			it("returns 'hashicorp' for kubernetes", function()
				assert.equals("hashicorp", terradocs._check_provider("kubernetes"))
			end)

			it("returns 'hashicorp' for vault", function()
				assert.equals("hashicorp", terradocs._check_provider("vault"))
			end)

			it("returns 'hashicorp' for google-beta", function()
				assert.equals("hashicorp", terradocs._check_provider("google-beta"))
			end)

			it("returns 'hashicorp' for all listed hashicorp providers", function()
				for _, provider in ipairs(terradocs._hashicorp_providers) do
					assert.equals(
						"hashicorp",
						terradocs._check_provider(provider),
						"Expected 'hashicorp' for provider: " .. provider
					)
				end
			end)
		end)

		describe("Oracle providers", function()
			it("returns 'oracle' for oci", function()
				assert.equals("oracle", terradocs._check_provider("oci"))
			end)

			it("returns 'oracle' for all listed oracle providers", function()
				for _, provider in ipairs(terradocs._oracle_providers) do
					assert.equals(
						"oracle",
						terradocs._check_provider(provider),
						"Expected 'oracle' for provider: " .. provider
					)
				end
			end)
		end)

		describe("Unknown providers", function()
			it("returns nil for unknown provider", function()
				assert.is_nil(terradocs._check_provider("unknown"))
			end)

			it("returns nil for empty string", function()
				assert.is_nil(terradocs._check_provider(""))
			end)

			it("returns nil for datadog (unsupported)", function()
				assert.is_nil(terradocs._check_provider("datadog"))
			end)

			it("returns nil for newrelic (unsupported)", function()
				assert.is_nil(terradocs._check_provider("newrelic"))
			end)

			it("returns nil for cloudflare (unsupported)", function()
				assert.is_nil(terradocs._check_provider("cloudflare"))
			end)
		end)

		describe("Edge cases", function()
			it("is case sensitive - AWS (uppercase) returns nil", function()
				assert.is_nil(terradocs._check_provider("AWS"))
			end)

			it("is case sensitive - Aws (mixed case) returns nil", function()
				assert.is_nil(terradocs._check_provider("Aws"))
			end)

			it("handles provider with extra whitespace in name", function()
				assert.is_nil(terradocs._check_provider("aws "))
				assert.is_nil(terradocs._check_provider(" aws"))
			end)
		end)
	end)

	describe("_generate_search_urls", function()
		describe("resource URLs", function()
			it("generates correct URLs for hashicorp/aws resource", function()
				local registry_url, github_url = terradocs._generate_search_urls("hashicorp", "aws", "resource")
				assert.equals("https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/", registry_url)
				assert.equals(
					"https://api.github.com/repos/hashicorp/terraform-provider-aws/contents/website/docs/r/",
					github_url
				)
			end)

			it("generates correct URLs for hashicorp/google resource", function()
				local registry_url, github_url = terradocs._generate_search_urls("hashicorp", "google", "resource")
				assert.equals(
					"https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/",
					registry_url
				)
				assert.equals(
					"https://api.github.com/repos/hashicorp/terraform-provider-google/contents/website/docs/r/",
					github_url
				)
			end)

			it("generates correct URLs for oracle/oci resource", function()
				local registry_url, github_url = terradocs._generate_search_urls("oracle", "oci", "resource")
				assert.equals("https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/", registry_url)
				assert.equals(
					"https://api.github.com/repos/oracle/terraform-provider-oci/contents/website/docs/r/",
					github_url
				)
			end)

			it("generates correct URLs for hashicorp/azurerm resource", function()
				local registry_url, github_url = terradocs._generate_search_urls("hashicorp", "azurerm", "resource")
				assert.equals(
					"https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/",
					registry_url
				)
				assert.equals(
					"https://api.github.com/repos/hashicorp/terraform-provider-azurerm/contents/website/docs/r/",
					github_url
				)
			end)
		end)

		describe("data source URLs", function()
			it("generates correct URLs for hashicorp/aws data source", function()
				local registry_url, github_url = terradocs._generate_search_urls("hashicorp", "aws", "data")
				assert.equals(
					"https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/",
					registry_url
				)
				assert.equals(
					"https://api.github.com/repos/hashicorp/terraform-provider-aws/contents/website/docs/d/",
					github_url
				)
			end)

			it("generates correct URLs for hashicorp/google data source", function()
				local registry_url, github_url = terradocs._generate_search_urls("hashicorp", "google", "data")
				assert.equals(
					"https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/",
					registry_url
				)
				assert.equals(
					"https://api.github.com/repos/hashicorp/terraform-provider-google/contents/website/docs/d/",
					github_url
				)
			end)

			it("generates correct URLs for oracle/oci data source", function()
				local registry_url, github_url = terradocs._generate_search_urls("oracle", "oci", "data")
				assert.equals(
					"https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/",
					registry_url
				)
				assert.equals(
					"https://api.github.com/repos/oracle/terraform-provider-oci/contents/website/docs/d/",
					github_url
				)
			end)
		end)

		describe("invalid declaration", function()
			it("returns 1 for 'module' declaration", function()
				local result = terradocs._generate_search_urls("hashicorp", "aws", "module")
				assert.equals(1, result)
			end)

			it("returns 1 for empty declaration", function()
				local result = terradocs._generate_search_urls("hashicorp", "aws", "")
				assert.equals(1, result)
			end)

			it("returns 1 for nil declaration", function()
				local result = terradocs._generate_search_urls("hashicorp", "aws", nil)
				assert.equals(1, result)
			end)

			it("returns 1 for invalid declaration type", function()
				local result = terradocs._generate_search_urls("hashicorp", "aws", "provider")
				assert.equals(1, result)
			end)
		end)

		describe("URL structure verification", function()
			it("registry URL ends with trailing slash for resources", function()
				local registry_url, _ = terradocs._generate_search_urls("hashicorp", "aws", "resource")
				assert.is_true(string.sub(registry_url, -1) == "/")
			end)

			it("registry URL ends with trailing slash for data", function()
				local registry_url, _ = terradocs._generate_search_urls("hashicorp", "aws", "data")
				assert.is_true(string.sub(registry_url, -1) == "/")
			end)

			it("github URL ends with trailing slash for resources", function()
				local _, github_url = terradocs._generate_search_urls("hashicorp", "aws", "resource")
				assert.is_true(string.sub(github_url, -1) == "/")
			end)

			it("github URL ends with trailing slash for data", function()
				local _, github_url = terradocs._generate_search_urls("hashicorp", "aws", "data")
				assert.is_true(string.sub(github_url, -1) == "/")
			end)

			it("github URL contains correct repo name format", function()
				local _, github_url = terradocs._generate_search_urls("hashicorp", "aws", "resource")
				assert.is_truthy(string.match(github_url, "terraform%-provider%-aws"))
			end)
		end)
	end)

	describe("setup", function()
		it("creates TFSearch command", function()
			-- Setup the plugin
			terradocs.setup()

			-- Check if command exists
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.TFSearch)
		end)

		it("creates default keymap", function()
			-- Setup the plugin
			terradocs.setup()

			-- Get keymaps for normal mode
			local keymaps = vim.api.nvim_get_keymap("n")
			local found = false
			for _, keymap in ipairs(keymaps) do
				if keymap.lhs == "<leader>t" or keymap.lhs == " t" then
					found = true
					break
				end
			end
			assert.is_true(found, "Expected keymap <leader>t to be set")
		end)
	end)
end)

describe("provider extraction logic", function()
	-- Test the pattern matching used in terraform_search
	local function extract_provider(resource_type)
		return string.match(resource_type, "^([^_]+)_")
	end

	local function extract_resource_name(resource_type)
		if string.match(resource_type, "^%a+_%a+") then
			return string.gsub(resource_type, "^%a+_", "")
		end
		return resource_type
	end

	describe("extract_provider pattern", function()
		it("extracts aws from aws_instance", function()
			assert.equals("aws", extract_provider("aws_instance"))
		end)

		it("extracts google from google_compute_instance", function()
			assert.equals("google", extract_provider("google_compute_instance"))
		end)

		it("extracts oci from oci_core_instance", function()
			assert.equals("oci", extract_provider("oci_core_instance"))
		end)

		it("extracts azurerm from azurerm_virtual_machine", function()
			assert.equals("azurerm", extract_provider("azurerm_virtual_machine"))
		end)

		it("returns nil for invalid resource type without underscore", function()
			assert.is_nil(extract_provider("invalidresource"))
		end)

		it("extracts kubernetes from kubernetes_deployment", function()
			assert.equals("kubernetes", extract_provider("kubernetes_deployment"))
		end)
	end)

	describe("extract_resource_name pattern", function()
		it("extracts instance from aws_instance", function()
			assert.equals("instance", extract_resource_name("aws_instance"))
		end)

		it("extracts compute_instance from google_compute_instance", function()
			assert.equals("compute_instance", extract_resource_name("google_compute_instance"))
		end)

		it("extracts core_instance from oci_core_instance", function()
			assert.equals("core_instance", extract_resource_name("oci_core_instance"))
		end)

		it("extracts s3_bucket from aws_s3_bucket", function()
			assert.equals("s3_bucket", extract_resource_name("aws_s3_bucket"))
		end)

		it("extracts virtual_machine from azurerm_virtual_machine", function()
			assert.equals("virtual_machine", extract_resource_name("azurerm_virtual_machine"))
		end)
	end)
end)

describe("URL construction for real resources", function()
	-- Integration-style tests for full URL construction
	local function build_github_api_url(provider_org, provider_name, declaration, resource_name)
		local _, github_base = terradocs._generate_search_urls(provider_org, provider_name, declaration)
		if github_base == 1 then
			return nil
		end
		return github_base .. resource_name .. ".html.markdown"
	end

	local function build_registry_url(provider_org, provider_name, declaration, resource_name)
		local registry_base, _ = terradocs._generate_search_urls(provider_org, provider_name, declaration)
		if type(registry_base) == "number" then
			return nil
		end
		return registry_base .. resource_name
	end

	describe("AWS resources", function()
		it("builds correct URL for aws_instance resource", function()
			local url = build_github_api_url("hashicorp", "aws", "resource", "instance")
			assert.equals(
				"https://api.github.com/repos/hashicorp/terraform-provider-aws/contents/website/docs/r/instance.html.markdown",
				url
			)
		end)

		it("builds correct URL for aws_s3_bucket resource", function()
			local url = build_github_api_url("hashicorp", "aws", "resource", "s3_bucket")
			assert.equals(
				"https://api.github.com/repos/hashicorp/terraform-provider-aws/contents/website/docs/r/s3_bucket.html.markdown",
				url
			)
		end)

		it("builds correct registry URL for aws_instance", function()
			local url = build_registry_url("hashicorp", "aws", "resource", "instance")
			assert.equals("https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance", url)
		end)

		it("builds correct URL for aws_ami data source", function()
			local url = build_github_api_url("hashicorp", "aws", "data", "ami")
			assert.equals(
				"https://api.github.com/repos/hashicorp/terraform-provider-aws/contents/website/docs/d/ami.html.markdown",
				url
			)
		end)
	end)

	describe("Google resources", function()
		it("builds correct URL for google_compute_instance", function()
			local url = build_github_api_url("hashicorp", "google", "resource", "compute_instance")
			assert.equals(
				"https://api.github.com/repos/hashicorp/terraform-provider-google/contents/website/docs/r/compute_instance.html.markdown",
				url
			)
		end)

		it("builds correct registry URL for google_compute_instance", function()
			local url = build_registry_url("hashicorp", "google", "resource", "compute_instance")
			assert.equals(
				"https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance",
				url
			)
		end)
	end)

	describe("Azure resources", function()
		it("builds correct URL for azurerm_virtual_machine", function()
			local url = build_github_api_url("hashicorp", "azurerm", "resource", "virtual_machine")
			assert.equals(
				"https://api.github.com/repos/hashicorp/terraform-provider-azurerm/contents/website/docs/r/virtual_machine.html.markdown",
				url
			)
		end)
	end)

	describe("OCI resources", function()
		it("builds correct URL for oci_core_instance", function()
			local url = build_github_api_url("oracle", "oci", "resource", "core_instance")
			assert.equals(
				"https://api.github.com/repos/oracle/terraform-provider-oci/contents/website/docs/r/core_instance.html.markdown",
				url
			)
		end)
	end)
end)
