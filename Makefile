BUILD = $(shell gcc -dumpmachine)
HOST = i686-pc-mingw32
TARGET = i486-elf
# arm-none-eabi

GCC_VER			= 7.1.0
BINUTILS_VER	= 2.28
GMP_VER			= 6.1.2
MPFR_VER		= 3.1.5
MPC_VER			= 1.0.3

.PHONY: all
all: gcc_b

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

GCC = gcc-$(GCC_VER)
GCC_GZ = $(GCC).tar.bz2

BINUTILS = binutils-$(BINUTILS_VER)
BINUTILS_GZ = $(BINUTILS).tar.bz2

GMP = gmp-$(GMP_VER)
GMP_GZ = $(GMP).tar.bz2

MPFR = mpfr-$(MPFR_VER)
MPFR_GZ = $(MPFR).tar.bz2

MPC = mpc-$(MPC_VER)
MPC_GZ = $(MPC).tar.gz

WGET = wget -P $(GZ)
.PHONY: gz
gz: $(GZ)/$(GCC_GZ) $(GZ)/$(BINUTILS_GZ) $(GZ)/$(GMP_GZ) $(GZ)/$(MPFR_GZ) $(GZ)/$(MPC_GZ)
$(GZ)/$(GCC_GZ):
	$(WGET) http://gcc.skazkaforyou.com/releases/$(GCC)/$(GCC_GZ) && touch $@
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
$(GZ)/$(GMP_GZ):
	$(WGET) https://gmplib.org/download/gmp/$(GMP_GZ) && touch $@
$(GZ)/$(MPFR_GZ):
	$(WGET) http://www.mpfr.org/mpfr-current/$(MPFR_GZ) && touch $@
$(GZ)/$(MPC_GZ):
	$(WGET) ftp://ftp.gnu.org/gnu/mpc/$(MPC_GZ)
	
.PHONY: src
src: $(SRC)/$(BINUTILS)/README

$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) ; bzcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.gz
	cd $(SRC) ;  zcat $< | tar x && touch $@
	
CFG = configure --disable-doc
CFG_B = $(CFG) --prefix=$(B) --datarootdir=$(TMP)

CFG_BINUTILS_B = --disable-nls --target=$(BUILD)
CFG_GCC_B = $(CFG_BINUTILS_B) --disable-bootstrap --enable-languages="c" \
	--with-gmp=$(B) --with-mpfr=$(B) --with-mpc=$(B) \
	--disable-multilib

NO_CORES = $(shell grep processor /proc/cpuinfo|wc -l)

XPATH = PATH=$(B)/bin:$(PATH)
 
.PHONY: binutils_b binutils_h binutils_t
binutils_b: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ;\
		$(XPATH) $(SRC)/$(BINUTILS)/$(CFG_B) $(CFG_BINUTILS_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
		
CFG_GMP_B = --disable-shared
CFG_MPFR_B = $(CFG_GMP_B) --with-gmp=$(B)
CFG_MPC_B = $(CFG_MPFR_B) --with-mpfr=$(B)

.PHONY: libs_b
libs_b: gmp_b mpfr_b mpc_b
		
.PHONY: gmp_b
gmp_b: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP)
	cd $(TMP)/$(GMP) ; $(XPATH) $(SRC)/$(GMP)/$(CFG_B) $(CFG_GMP_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip

.PHONY: mpfr_b
mpfr_b: $(SRC)/$(MPFR)/README
	rm -rf $(TMP)/$(MPFR) ; mkdir $(TMP)/$(MPFR)
	cd $(TMP)/$(MPFR) ; $(XPATH) $(SRC)/$(MPFR)/$(CFG_B) $(CFG_MPFR_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip

.PHONY: mpc_b
mpc_b: $(SRC)/$(MPC)/README
	rm -rf $(TMP)/$(MPC) ; mkdir $(TMP)/$(MPC)
	cd $(TMP)/$(MPC) ; $(XPATH) $(SRC)/$(MPC)/$(CFG_B) $(CFG_MPC_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip

.PHONY: gcc_b
gcc_b: $(SRC)/$(GCC)/README
	rm -rf $(TMP)/$(GCC) ; mkdir $(TMP)/$(GCC)
	cd $(TMP)/$(GCC) ;\
		$(XPATH) $(SRC)/$(GCC)/$(CFG_B) $(CFG_GCC_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
