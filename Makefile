BUILD = $(shell gcc -dumpmachine)
HOST = i686-pc-mingw32
TARGET = i486-elf
# arm-none-eabi

GCC_VER			= 7.1.0
BINUTILS_VER	= 2.28
GMP_VER			= 6.1.2
MPFR_VER		= 3.1.5
MPC_VER			= 1.0.3

MINGW_VER		= 5.0

.PHONY: all
all: mingw0

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

MINGWRT = mingwrt-$(MINGW_VER)
MINGWRT_GZ = $(MINGWRT)-mingw32-src.tar.xz
W32API = w32api-$(MINGW_VER)
W32API_GZ = $(W32API)-mingw32-src.tar.xz

WGET = wget -P $(GZ)
.PHONY: gz
gz: $(GZ)/$(GCC_GZ) $(GZ)/$(BINUTILS_GZ) \
	$(GZ)/$(GMP_GZ) $(GZ)/$(MPFR_GZ) $(GZ)/$(MPC_GZ) \
	$(GZ)/$(MINGWRT_GZ) $(GZ)/$(W32API_GZ)
$(GZ)/$(GCC_GZ):
	$(WGET) http://gcc.skazkaforyou.com/releases/$(GCC)/$(GCC_GZ) && touch $@
$(GZ)/$(BINUTILS_GZ):
	$(WGET) http://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ) && touch $@
$(GZ)/$(GMP_GZ):
	$(WGET) https://gmplib.org/download/gmp/$(GMP_GZ) && touch $@
$(GZ)/$(MPFR_GZ):
	$(WGET) http://www.mpfr.org/mpfr-current/$(MPFR_GZ) && touch $@
$(GZ)/$(MPC_GZ):
	$(WGET) ftp://ftp.gnu.org/gnu/mpc/$(MPC_GZ) && touch $@
$(GZ)/$(MINGWRT_GZ):	
	$(WGET) https://downloads.sourceforge.net/project/mingw/MinGW/Base/mingwrt/$(MINGWRT)/$(MINGWRT_GZ) && touch $@
$(GZ)/$(W32API_GZ):
	$(WGET) https://downloads.sourceforge.net/project/mingw/MinGW/Base/w32api/$(W32API)/$(W32API_GZ)	
	
.PHONY: src
src: $(SRC)/$(BINUTILS)/README

$(SRC)/%/README: $(GZ)/%.tar.bz2
	cd $(SRC) ; bzcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%.tar.gz
	cd $(SRC) ;  zcat $< | tar x && touch $@
$(SRC)/%/README: $(GZ)/%-mingw32-src.tar.xz
	cd $(SRC) ; xzcat $< | tar x && touch $@
	
CFG = configure --disable-doc --datarootdir=$(TMP)
# --build=$(BUILD)
CFG_B = $(CFG) --prefix=$(B) 
CFG_H = $(CFG) --prefix=$(H)  
#--build=$(BUILD) --host=$(BUILD)
CFG_T = $(CFG) --prefix=$(T)
# --host=$(HOST)

CFG_BINUTILS_B = --disable-nls --disable-werror --target=$(BUILD)
CFG_BINUTILS_H = --disable-nls --disable-werror --with-sysroot=$(T) --target=$(HOST)
CFG_BINUTILS_T = --disable-nls --disable-werror --with-sysroot="D:/LLVM" --target=$(TARGET)

CFG_GCC_B = $(CFG_BINUTILS_B) --disable-bootstrap --enable-languages="c" \
	--with-gmp=$(B) --with-mpfr=$(B) --with-mpc=$(B) \
	--disable-multilib --disable-libssp --disable-shared
CFG_GCC_H = $(CFG_BINUTILS_H) --disable-bootstrap --enable-languages="c" \
	--with-gmp=$(B) --with-mpfr=$(B) --with-mpc=$(B) \
	--disable-multilib --enable-shared --enable-threads \
	--disable-win32-registry --disable-sjlj-exceptions --disable-libvtv

#	--disable-libssp 

NO_CORES = $(shell grep processor /proc/cpuinfo|wc -l)

XPATH = PATH=$(B)/bin:$(H)/bin:$(PATH)

.PHONY: build
build: binutils_b libs_b gcc_b
 
.PHONY: binutils_b binutils_h binutils_t
binutils_b: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ;\
		$(XPATH) $(SRC)/$(BINUTILS)/$(CFG_B) $(CFG_BINUTILS_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
binutils_h: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ;\
		$(XPATH) $(SRC)/$(BINUTILS)/$(CFG_H) $(CFG_BINUTILS_H) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
binutils_t: $(SRC)/$(BINUTILS)/README
	rm -rf $(TMP)/$(BINUTILS) ; mkdir $(TMP)/$(BINUTILS)
	cd $(TMP)/$(BINUTILS) ;\
		$(XPATH) $(SRC)/$(BINUTILS)/$(CFG_B) $(CFG_BINUTILS_T) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
		
CFG_GMP_B = --disable-shared
CFG_MPFR_B = $(CFG_GMP_B) --with-gmp=$(B)
CFG_MPC_B = $(CFG_MPFR_B) --with-mpfr=$(B)

CFG_GMP_H = --disable-shared --host=$(BUILD) --target=$(BUILD)

.PHONY: libs_b
libs_b: gmp_b mpfr_b mpc_b
		
.PHONY: gmp_b
gmp_b: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP)
	cd $(TMP)/$(GMP) ; $(XPATH) $(SRC)/$(GMP)/$(CFG_B) $(CFG_GMP_B) &&\
		$(XPATH) make -j$(NO_CORES) && make install-strip
.PHONY: gmp_h
gmp_h: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/$(GMP) ; mkdir $(TMP)/$(GMP)
	cd $(TMP)/$(GMP) ; $(XPATH) $(SRC)/$(GMP)/$(CFG_B) $(CFG_GMP_H) &&\
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
.PHONY: gcc_h0
gcc_h0: $(SRC)/$(GCC)/README
	rm -rf $(TMP)/$(GCC) ; mkdir $(TMP)/$(GCC)
	cd $(TMP)/$(GCC) ;\
		$(XPATH) $(SRC)/$(GCC)/$(CFG_H) $(CFG_GCC_H) &&\
		$(XPATH) make -j$(NO_CORES) all-gcc && make install-strip-gcc

.PHONY: mingw0 mingw
mingw0: mingwrt0 w32api0
mingw: mingwrt w32api

.PHONY: mingwrt0
mingwrt0: $(T)/mingw/include/direct.h
$(T)/mingw/include/direct.h: $(SRC)/$(MINGWRT)/README
	rm -rf $(TMP)/$(MINGWRT) ; mkdir $(TMP)/$(MINGWRT)
	cd $(TMP)/$(MINGWRT) ;\
		$(XPATH) $(SRC)/$(MINGWRT)/configure --prefix=$(T)/mingw --host=$(HOST) &&\
		make install-headers
.PHONY: mingwrt
mingwrt: $(T)/mingw/lib/crt1.o
$(T)/mingw/lib/crt1.o: $(H)/bin/$(HOST)-gcc
	cd $(TMP)/$(MINGWRT) ;\
		$(XPATH) ./config.status --recheck ;\
		$(XPATH) ./config.status ;\
		$(XPATH) make install

.PHONY: w32api0
w32api0: $(T)/mingw/include/windows.h
$(T)/mingw/include/windows.h: $(SRC)/$(W32API)/README
	rm -rf $(TMP)/$(W32API) ; mkdir $(TMP)/$(W32API)
	cd $(TMP)/$(W32API) ;\
		$(XPATH) $(SRC)/$(W32API)/configure --prefix=$(T)/mingw --host=$(HOST) &&\
		make install-headers
.PHONY: w32api
w32api: $(H)/bin/$(HOST)-gcc
	cd $(TMP)/$(W32API) ;\
		$(XPATH) ./config.status --recheck ;\
		$(XPATH) ./config.status ;\
		$(XPATH) make install
		