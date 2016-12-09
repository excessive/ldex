.PHONY: run
run:
	zip -9 \
		-x ".vscode*" -x ".swp" -x "*.atom-build.json" -x "*Makefile" \
		-x ".git*" -x "*.git" -x "*.gitignore" \
		-x "*.yml" -x "*.editorconfig" \
		-x "*_spec.lua" -x "*.rockspec" \
		-x "resources" \
		-r ldex.love .
	love --fused ldex.love

.PHONY: debug
debug:
	love --fused . --debug --hud

.PHONY: clean
clean:
	rm ldex.love
