.PHONY: run
run:
	zip -9 \
		-x ".vscode*" -x "*Makefile" -x "*.atom-build.json" \
		-x ".git*" -x "*.git" -x "*.gitignore" \
		-x "*.yml" -x "*.editorconfig" \
		-x "*_spec.lua" -x "*.rockspec" \
		-x "resources" \
		-r ldex.love .
	love --fused ldex.love

.PHONY: debug
debug:
	love --fused . --debug

.PHONY: clean
clean:
	rm ldex.love
