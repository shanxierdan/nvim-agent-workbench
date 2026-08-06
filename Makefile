.PHONY: doctor format lint smoke

doctor:
	bash scripts/doctor.sh

format:
	stylua lua tests init.lua

lint:
	stylua --check lua tests init.lua
	shellcheck install.sh scripts/*.sh

smoke:
	bash scripts/smoke.sh
