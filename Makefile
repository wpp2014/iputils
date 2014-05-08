#
# Configuration
#

# CC
#指定gcc程序
CC=gcc
# Path to parent kernel include files directory
#指定库函数的路径
LIBC_INCLUDE=/usr/include
# Libraries
#添加其他的库（包括静态的和动态的）
ADDLIB=    #不添加其他的库
# Linker flags
#链接的标志
#Wl选项告诉编译器将后面的参数传递给链接器
#-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接
#-Wl,-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接
LDFLAG_STATIC=-Wl,-Bstatic
LDFLAG_DYNAMIC=-Wl,-Bdynamic
#指定加载的库
LDFLAG_CAP=-lcap
LDFLAG_GNUTLS=-lgnutls-openssl
LDFLAG_CRYPTO=-lcrypto
LDFLAG_IDN=-lidn
LDFLAG_RESOLV=-lresolv
LDFLAG_SYSFS=-lsysfs

#
# Options
#

# Capability support (with libcap) [yes|static|no]
#变量定义，设置开关
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]
USE_SYSFS=no
# IDN support (experimental) [no|yes|static]
USE_IDN=no

# Do not use getifaddrs [no|yes|static]
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]
#允许ping6使用加密协议库
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]
#允许和ping6共享加密的库
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]

USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#如果函数的声明或定义没有指出参数类型，编译器就发出警告
#使用-fno-strict-aliasing参数进行编译
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
#3使用级优化
CCOPTOPT=-O3 
#表示编写的代码符合GUN规范
#于Linux下的信号量/读写锁文件进行编译，需要在编译选项中指明-D_GNU_SOURCE 
DEFINES=
LDLIB=

#选择库函数
#如果过滤掉参数1中除了静态函数外的其他函数，就将$(1)),$(LDFLAG_STATIC) $(2)这几个变量所代表的库赋给FUNC_LIB
#否则，只将参数2赋给FUNC_LIB
FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
#如果USE_GNUTLS不是"no",则以变量USE_GNUTLS和LDFLAG_GNUTLS的内容为参数调用FUNC_LIB,并将结果赋给LIB_CRYPTO。
#因为USE_GNUTLS的值是yes,所以可以调用。
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	#将-DUSE_GNUTLS这个参数赋给DEF_CRYPTO.
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))	#否则，以变量USE_CRYPTO和LDFLAG_CRYPTO的内容为参数调用FUNC_LIB,并将结果赋给LIB_CRYPTO。
endif

# USE_RESOLV: LIB_RESOLV
#以变量USE_RESOLV和LDFLAG_RESOLV的内容为参数调用FUNC_LIB,并将结果赋给LIB_RESOLV。
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
ifneq ($(USE_CAP),no)			#判断USE_CAP的值是否为no。
	DEF_CAP = -DCAPABILITIES	#如果不是则将参数-DCAPABILITIES赋给DEF_CAP
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))	#以变量USE_CAP和LDFLAG_CAP的内容为参数调用FUNC_LIB,并将结果赋给LIB_RESOLV。
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)   #编译选项
LDLIBS=$(LDLIB) $(ADDLIB)			     #链接的库函数

#将命令 uname -n 的输出给变量UNAME_N
UNAME_N:=$(shell uname -n)
#将HEAD中的-.*替换为/
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
#以%Y/%m/%d的格式输出年月日。如：20140508， 并保存到TODAY变量中。
TODAY=$(shell date +%Y/%m/%d)
#将TODAY中的内容赋给DATE。以%Y%m%d的格式。
DATE=$(shell date --date $(TODAY) +%Y%m%d)
#将TODAY的内容赋给TAG，以s%Y%m%d的格式
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
#伪指令，make+不同的命令来执行。
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

all: $(TARGETS)
#删除所有的.o文件，将所有的.c文件编译成对应的.s文件。
%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
#删除所有的.o文件，将所有的.s文件编译成对应的.o文件。
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
#将所有的.o文件编译生成目标所要的可执行文件。
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
	

# COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除,  DEF_ping
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)
#
#
#以ping为例，翻译为：e
# gcc -O3 -fno-strict-aliasing -Wstrict-prototypes -Wall -g -D_GNU_SOURCE    -c ping.c -DCAPABILITIES   -o ping.o
#gcc   ping.o ping_common.o -lcap    -o ping
# -------------------------------------
# arping
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif

# clockdiff
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
DEF_rarpd =
LIB_rarpd =

# rdisc
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(D将HEAD中的-.*替换为/EF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

#tftpd依赖tftpsus.o文件
tftpd: tftpsubs.o	
#tftpd.o和tftpsubs.o文件依赖tftp.h头文件
tftpd.o tftpsubs.o: tftp.h      
	

# -------------------------------------
# ninfod
#生成ninfod可执行文件
ninfod:
	@set -e; \					#如果ninfod目录下没有Makefiel文件，就创建一个。
		if [ ! -f ninfod/Makefile ]; then \ 
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
		$(MAKE) -C ninfod		#否则，直接指定ninfod为读取Makefile的一个路径。

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#检查内核
check-kernel:              
ifeq ($(KERNEL_INCLUDE),)			#如果变量KERNEL_INCLUDE是空，则报错。
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \           #如果autoconf.h不是一个可读文件，则报错。
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules    #指定Modules路径中的Makefile文件编译内核

# -------------------------------------
man:
	$(MAKE) -C doc man	#生成man的帮助文档
html:
	$(MAKE) -C doc html	#生成网页格式的帮助文档

clean:
	@rm -f *.o $(TARGETS)  #删除所有生成的目标的二进制文件
	#指定读取makefile的目录。
	@$(MAKE) -C Modules clean  #执行Modules目录下Makefile中的clean，删除指定的文件。
	@$(MAKE) -C doc clean		#执行doc目录下Makefile中的clean，删除指定的文件。
	@set -e; \
		if [ -f ninfod/Makefile ]; then \	#如果ninfod目录下存在makefile文件，就进入ninfod目录并读取malefile文件，
							#执行clean操作， 清除之前编译的可执行文件及配置文件。
			$(MAKE) -C ninfod clean; \
		fi

#清除ninfod目录下所有生成的文件。
distclean: clean					
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	#如果UNAME_N和pleiades的十六进制不等，提示信息，并退出。
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	#将TAG变量的内容重定向到RELNOTES.NEW文档中。
	@echo "[$(TAG)]" > RELNOTES.NEW
	#输出一个空行
	@echo >>RELNOTES.NEW
	#将git log和git shortlog的输出信息重定向到RELOTES.NEW文档里。
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	#输出一个空行
	@echo >> RELNOTES.NEW
	#将RELNOTES里的内容重定向的RELNOTES.NEW文档里。
	@cat RELNOTES >> RELNOTES.NEW
	#将RELNOTES.NEW文档重命名为RELNOTES
	@mv RELNOTES.NEW RELNOTES
	#将日期以及
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	#将inputils.spec.tmp重命名为iputils.spec.
	@mv iputils.spec.tmp iputils.spec
	#将TAG变量中的内容以"static char SNAPSHOT[] = \"$(TAG)\"的形式重定向到SNAPSHOT.h文档中
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	#生成snapshot的doc文档。
	@$(MAKE) -C doc snapshot
	#执行man命令
	@$(MAKE) man	
	#修改/添加/上传 文件
	@git commit -a -m "iputils-$(TAG)"
	#创建带有说明的标签，并用私钥签名
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	#打包，供别人下载
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2
