.PHONY: run
run:
	zip -9 -x ".vscode*" -x ".git*" -x "*.git" -x "Makefile" -x "resources" -r ldex.love .
	love --fused ldex.love

.PHONY: debug
debug:
	love --fused . --debug

.PHONY: clean
clean:
	rm ldex.love
