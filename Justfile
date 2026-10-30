run:
    swift run

build:
    swift build
    
clean:
    swift package clean

test:
    swift test

release:
    swift build -c release

# Update changelog
changelog:
	cz ch
    
# Bump version according to changelog
bump: changelog
	cz bump

# Re-apply the exact-ledger-number patch after refreshing the vendored openapi.yaml
exact-numbers:
    python3 scripts/exact-numbers.py
