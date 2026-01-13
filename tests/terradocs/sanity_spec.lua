-- Sanity check tests to verify test infrastructure works
describe("sanity check", function()
	it("1 equals 1", function()
		assert.equals(1, 1)
	end)

	it("true is true", function()
		assert.is_true(true)
	end)

	it("strings work", function()
		assert.equals("hello", "hello")
	end)
end)
