.PHONY: help dev build export_video clean

# Default target
help:
	@echo "Available commands:"
	@echo "  make dev          - Start Remotion Studio for development"
	@echo "  make build        - Build the Remotion project"
	@echo "  make export_video - Export video (requires CONFIG and optional OUTPUT)"
	@echo "  make clean        - Clean output directory and node_modules"
	@echo ""
	@echo "Usage examples:"
	@echo "  make export_video CONFIG=config.json"
	@echo "  make export_video CONFIG=config.json OUTPUT=my_video.mp4"

dev:
	npm run dev

build:
	npm run build

export_video:
ifndef CONFIG
	@echo "Error: CONFIG parameter is required"
	@echo "Usage: make export_video CONFIG=path/to/config.json [OUTPUT=filename.mp4]"
	@exit 1
endif
ifdef OUTPUT
	./scripts/export_video.sh --config "$(CONFIG)" --output "$(OUTPUT)"
else
	./scripts/export_video.sh --config "$(CONFIG)"
endif

clean:
	rm -rf output/
	rm -rf node_modules/
	@echo "Cleaned output directory and node_modules"