.PHONY: doctor format lint smoke

doctor:
	bash scripts/doctor.sh

format:
	stylua lua init.lua

lint:
	stylua --check lua init.lua
	shellcheck install.sh scripts/*.sh

smoke:
	bash scripts/smoke.sh
