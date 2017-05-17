
CWD = $(CURDIR)
GZ = $(CWD)/gz
DIRS = $(GZ)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)