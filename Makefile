.PHONY: render check test clean

render:
	./scripts/render-copilot-review.sh

check:
	./scripts/check-output.sh dist/copilot-review.gif

test:
	./scripts/test.sh

clean:
	rm -rf dist
