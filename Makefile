.PHONY: test

test:
	mojo --version

# check test collection (this count needs to be updated manually when tests are updated)
	pytest | grep "collected 12 items"

# Tests that do not fail
	pytest tests