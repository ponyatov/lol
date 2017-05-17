BUILD = $(shell gcc -dumpmachine)
HOST = i686-pc-mingw32
TARGET = i486-elf
# arm-none-eabi

BINUTILS_VER = 2.28
GMP_VER = 6.1.2
MPFR_VER = 3.1.5

.PHONY: all
all: mpfr_b

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

GMP = gmp-$(GMP_VER)
GMP_GZ = $(GMP).tar.bz2

MPFR = mpfr-$(MPFR_VER)
MPFR_GZ = $(MPFR).tar.bz2

WGET = wget -P $(GZ)
.PHONY: gz
gz: $(GZ)/$(BINUTILS_GZ) $(GZ)/$(GMP_GZ) $(GZ)/$(MPFR_GZ)
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
$(GZ)/$(GMP_GZ):
	$(WGET) https://gmplib.org/download/gmp/$(GMP_GZ) && touch $@
$(GZ)/$(MPFR_GZ):
	$(WGET) http://www.mpfr.org/mpfr-current/$(MPFR_GZ) && touch $@
	
.PHONY: src
src: $(SRC)/$(BINUTILS)/README

$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) ; bzcat $< | tar x && touch $@
	
CFG = configure
CFG_B = $(CFG) --prefix=$(B) --datarootdir=$(TMP) 

NO_CORES = $(shell grep processor /proc/cpuinfo|wc -l)

XPATH = PATH=$(B)/bin:$(PATH)
 
.PHONY: binutils_b binutils_h binutils_t
binutils_b: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ; $(XPATH) $(SRC)/$(BINUTILS)/$(CFG_B) \
		--disable-nls --target=$(BUILD) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
		
LIB_CFG = --disable-shared
GMP_CFG = $(LIB_CFG)
MPFR_CFG = $(GMP_CFG) --with-gmp=$(B)
		
.PHONY: gmp_b
gmp_b: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP)
	cd $(TMP)/$(GMP) ; $(XPATH) $(SRC)/$(GMP)/$(CFG_B) $(GMP_CFG) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
.PHONY: mpfr_b
mpfr_b: $(SRC)/$(MPFR)/README
	rm -rf $(TMP)/$(MPFR) ; mkdir $(TMP)/$(MPFR)
	cd $(TMP)/$(MPFR) ; $(XPATH) $(SRC)/$(MPFR)/$(CFG_B) $(MPFR_CFG) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
