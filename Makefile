MODULE ?= 00
IMAGE  ?= 26.04
CPUS   ?= 2
MEM    ?= 2G
DISK   ?= 10G

VM     = labk3s-$(MODULE)
DIR    = $(firstword $(wildcard modules/$(MODULE)-*))
STATE  = .state

export VM IMAGE CPUS MEM DISK STATE

.PHONY: help up check incident reset clean guard

help:
	@echo "usage: make <target> [MODULE=NN]"
	@echo
	@echo "  up        create the VM and build this module's layer"
	@echo "  check     does the layer hold? exit 0 green, non-zero red"
	@echo "  incident  trigger this module's fault"
	@echo "  reset     destroy and rebuild from zero"
	@echo "  clean     destroy and leave nothing behind"
	@echo
	@echo "modules:"
	@ls -d modules/*/ 2>/dev/null | sed 's|modules/|  |; s|/$$||'

up check incident: guard
	@$(DIR)/$@.sh

reset: clean up

clean: guard
	@multipass delete --purge $(VM) 2>/dev/null || true
	@rm -f $(STATE)/$(VM).generation
	@echo "clean: $(VM) is gone"

guard:
	@test -n "$(DIR)" || { echo "no module $(MODULE) under modules/" >&2; exit 1; }
