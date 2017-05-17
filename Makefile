BUILD = $(shell gcc -dumpmachine)
HOST = i686-pc-mingw32
TARGET = i486-elf
# arm-none-eabi

BINUTILS_VER = 2.28

.PHONY: all
all: binutils_b

CWD = $(CURDIR)
GZ = $(CWD)/gz
B = $(CWD)/$(BUILD)
H = $(CWD)/$(HOST)
T = $(CWD)/$(TARGET)
TMP = $(CWD)/tmp
SRC = $(CWD)/src
DIRS = $(GZ) $(B) $(H) $(T) $(SRC) $(TMP)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)

BINUTILS = binutils-$(BINUTILS_VER)
BINUTILS_GZ = $(BINUTILS).tar.bz2

WGET = wget -P $(GZ)
.PHONY: gz
gz: $(GZ)/$(BINUTILS_GZ)
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
	
.PHONY: src
src: $(SRC)/$(BINUTILS)/README

$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) ; bzcat $< | tar x && touch $@
	
CFG = configure --disable-nls
CFG_B = $(CFG) --prefix=$(B) --target=$(BUILD)

NO_CORES = $(shell grep processor /proc/cpuinfo|wc -l)
 
.PHONY: binutils_b binutils_h binutils_t
binutils_b: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ; $(SRC)/$(BINUTILS)/$(CFG_B) &&\
		make -j$(NO_CORES) && make install-strip