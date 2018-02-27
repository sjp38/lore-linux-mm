Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8EE66B0007
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 08:36:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l1so6963031pga.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 05:36:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d16-v6si6938812pll.504.2018.02.27.05.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Feb 2018 05:36:56 -0800 (PST)
Date: Tue, 27 Feb 2018 13:36:27 +0000
From: James Hogan <jhogan@kernel.org>
Subject: [GIT PULL] Remove metag architecture
Message-ID: <20180227133626.GN6245@saruman>
References: <20180221233825.10024-1-jhogan@kernel.org>
 <CAK8P3a3CuNn-dSE33mhEZ9-iM7NOE3Y4AiJzpmF6ob5wrMuZpg@mail.gmail.com>
 <20180223110207.GA14446@saruman>
 <CAK8P3a12RKQvcmnPRHcDkDKq+uMWP79SuRdDz3_vi9YRM==GVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Zbynv6TNPa9FrOf6"
Content-Disposition: inline
In-Reply-To: <CAK8P3a12RKQvcmnPRHcDkDKq+uMWP79SuRdDz3_vi9YRM==GVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-i2c@vger.kernel.org


--Zbynv6TNPa9FrOf6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Arnd,

On Fri, Feb 23, 2018 at 01:26:09PM +0100, Arnd Bergmann wrote:
> On Fri, Feb 23, 2018 at 12:02 PM, James Hogan <jhogan@kernel.org> wrote:
> > I'm happy to put v2 in linux-next now (only patch 4 has changed, I just
> > sent an updated version), and send you a pull request early next week so
> > you can take it from there. The patches can't be directly applied with
> > git-am anyway thanks to the -D option to make them more concise.
> >
> > Sound okay?
>=20
> Yes, sounds good, thanks!

As discussed, here is a tagged branch to remove arch/metag and dependent
drivers. Its basically v2 with some acks added.

Cheers
James

The following changes since commit 91ab883eb21325ad80f3473633f794c78ac87f51:

  Linux 4.16-rc2 (2018-02-18 17:29:42 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jhogan/metag.git tags/metag=
_remove

for you to fetch changes up to ef9fb83815db7d7e03da9a0904b4ef352e633922:

  i2c: img-scb: Drop METAG dependency (2018-02-26 14:58:09 +0000)

----------------------------------------------------------------
Remove metag architecture

These patches remove the metag architecture and tightly dependent
drivers from the kernel. With the 4.16 kernel the ancient gcc 4.2.4
based metag toolchain we have been using is hitting compiler bugs, so
now seems a good time to drop it altogether.

----------------------------------------------------------------
James Hogan (13):
      metag: Remove arch/metag/
      docs: Remove metag docs
      docs: Remove remaining references to metag
      Drop a bunch of metag references
      irqchip: Remove metag irqchip drivers
      clocksource: Remove metag generic timer driver
      tty: Remove metag DA TTY and console driver
      MAINTAINERS/CREDITS: Drop METAG ARCHITECTURE
      pinctrl: Drop TZ1090 drivers
      gpio: Drop TZ1090 drivers
      watchdog: imgpdc: Drop METAG dependency
      media: img-ir: Drop METAG dependency
      i2c: img-scb: Drop METAG dependency

 CREDITS                                            |    5 +
 Documentation/00-INDEX                             |    2 -
 Documentation/admin-guide/kernel-parameters.txt    |    4 -
 Documentation/dev-tools/kmemleak.rst               |    2 +-
 .../devicetree/bindings/gpio/gpio-tz1090-pdc.txt   |   45 -
 .../devicetree/bindings/gpio/gpio-tz1090.txt       |   88 -
 Documentation/devicetree/bindings/metag/meta.txt   |   30 -
 .../bindings/pinctrl/img,tz1090-pdc-pinctrl.txt    |  127 --
 .../bindings/pinctrl/img,tz1090-pinctrl.txt        |  227 ---
 .../features/core/BPF-JIT/arch-support.txt         |    1 -
 .../core/generic-idle-thread/arch-support.txt      |    1 -
 .../features/core/jump-labels/arch-support.txt     |    1 -
 .../features/core/tracehook/arch-support.txt       |    1 -
 .../features/debug/KASAN/arch-support.txt          |    1 -
 .../debug/gcov-profile-all/arch-support.txt        |    1 -
 Documentation/features/debug/kgdb/arch-support.txt |    1 -
 .../debug/kprobes-on-ftrace/arch-support.txt       |    1 -
 .../features/debug/kprobes/arch-support.txt        |    1 -
 .../features/debug/kretprobes/arch-support.txt     |    1 -
 .../features/debug/optprobes/arch-support.txt      |    1 -
 .../features/debug/stackprotector/arch-support.txt |    1 -
 .../features/debug/uprobes/arch-support.txt        |    1 -
 .../debug/user-ret-profiler/arch-support.txt       |    1 -
 .../features/io/dma-api-debug/arch-support.txt     |    1 -
 .../features/io/dma-contiguous/arch-support.txt    |    1 -
 .../features/io/sg-chain/arch-support.txt          |    1 -
 .../features/lib/strncasecmp/arch-support.txt      |    1 -
 .../locking/cmpxchg-local/arch-support.txt         |    1 -
 .../features/locking/lockdep/arch-support.txt      |    1 -
 .../locking/queued-rwlocks/arch-support.txt        |    1 -
 .../locking/queued-spinlocks/arch-support.txt      |    1 -
 .../locking/rwsem-optimized/arch-support.txt       |    1 -
 .../features/perf/kprobes-event/arch-support.txt   |    1 -
 .../features/perf/perf-regs/arch-support.txt       |    1 -
 .../features/perf/perf-stackdump/arch-support.txt  |    1 -
 .../sched/membarrier-sync-core/arch-support.txt    |    1 -
 .../features/sched/numa-balancing/arch-support.txt |    1 -
 .../seccomp/seccomp-filter/arch-support.txt        |    1 -
 .../time/arch-tick-broadcast/arch-support.txt      |    1 -
 .../features/time/clockevents/arch-support.txt     |    1 -
 .../time/context-tracking/arch-support.txt         |    1 -
 .../features/time/irq-time-acct/arch-support.txt   |    1 -
 .../time/modern-timekeeping/arch-support.txt       |    1 -
 .../features/time/virt-cpuacct/arch-support.txt    |    1 -
 .../features/vm/ELF-ASLR/arch-support.txt          |    1 -
 .../features/vm/PG_uncached/arch-support.txt       |    1 -
 Documentation/features/vm/THP/arch-support.txt     |    1 -
 Documentation/features/vm/TLB/arch-support.txt     |    1 -
 .../features/vm/huge-vmap/arch-support.txt         |    1 -
 .../features/vm/ioremap_prot/arch-support.txt      |    1 -
 .../features/vm/numa-memblock/arch-support.txt     |    1 -
 .../features/vm/pte_special/arch-support.txt       |    1 -
 Documentation/metag/00-INDEX                       |    4 -
 Documentation/metag/kernel-ABI.txt                 |  256 ---
 MAINTAINERS                                        |   14 -
 arch/metag/Kconfig                                 |  287 ---
 arch/metag/Kconfig.debug                           |   34 -
 arch/metag/Kconfig.soc                             |   69 -
 arch/metag/Makefile                                |   89 -
 arch/metag/boot/.gitignore                         |    3 -
 arch/metag/boot/Makefile                           |   68 -
 arch/metag/boot/dts/Makefile                       |   16 -
 arch/metag/boot/dts/skeleton.dts                   |   10 -
 arch/metag/boot/dts/skeleton.dtsi                  |   15 -
 arch/metag/boot/dts/tz1090.dtsi                    |  108 --
 arch/metag/boot/dts/tz1090_generic.dts             |   10 -
 arch/metag/configs/meta1_defconfig                 |   39 -
 arch/metag/configs/meta2_defconfig                 |   40 -
 arch/metag/configs/meta2_smp_defconfig             |   41 -
 arch/metag/configs/tz1090_defconfig                |   42 -
 arch/metag/include/asm/Kbuild                      |   33 -
 arch/metag/include/asm/atomic.h                    |   49 -
 arch/metag/include/asm/atomic_lnkget.h             |  204 --
 arch/metag/include/asm/atomic_lock1.h              |  157 --
 arch/metag/include/asm/barrier.h                   |   85 -
 arch/metag/include/asm/bitops.h                    |  127 --
 arch/metag/include/asm/bug.h                       |   13 -
 arch/metag/include/asm/cache.h                     |   24 -
 arch/metag/include/asm/cacheflush.h                |  251 ---
 arch/metag/include/asm/cachepart.h                 |   43 -
 arch/metag/include/asm/checksum.h                  |   93 -
 arch/metag/include/asm/clock.h                     |   59 -
 arch/metag/include/asm/cmpxchg.h                   |   64 -
 arch/metag/include/asm/cmpxchg_irq.h               |   43 -
 arch/metag/include/asm/cmpxchg_lnkget.h            |   87 -
 arch/metag/include/asm/cmpxchg_lock1.h             |   49 -
 arch/metag/include/asm/core_reg.h                  |   36 -
 arch/metag/include/asm/cpu.h                       |   15 -
 arch/metag/include/asm/da.h                        |   44 -
 arch/metag/include/asm/delay.h                     |   30 -
 arch/metag/include/asm/div64.h                     |   13 -
 arch/metag/include/asm/dma-mapping.h               |   12 -
 arch/metag/include/asm/elf.h                       |  126 --
 arch/metag/include/asm/fixmap.h                    |   69 -
 arch/metag/include/asm/ftrace.h                    |   24 -
 arch/metag/include/asm/global_lock.h               |  101 -
 arch/metag/include/asm/highmem.h                   |   62 -
 arch/metag/include/asm/hugetlb.h                   |   75 -
 arch/metag/include/asm/hwthread.h                  |   41 -
 arch/metag/include/asm/io.h                        |  170 --
 arch/metag/include/asm/irq.h                       |   38 -
 arch/metag/include/asm/irqflags.h                  |   94 -
 arch/metag/include/asm/l2cache.h                   |  259 ---
 arch/metag/include/asm/linkage.h                   |    8 -
 arch/metag/include/asm/mach/arch.h                 |   86 -
 arch/metag/include/asm/metag_isa.h                 |   81 -
 arch/metag/include/asm/metag_mem.h                 | 1109 -----------
 arch/metag/include/asm/metag_regs.h                | 1184 ------------
 arch/metag/include/asm/mman.h                      |   12 -
 arch/metag/include/asm/mmu.h                       |   78 -
 arch/metag/include/asm/mmu_context.h               |  115 --
 arch/metag/include/asm/mmzone.h                    |   43 -
 arch/metag/include/asm/module.h                    |   38 -
 arch/metag/include/asm/page.h                      |  129 --
 arch/metag/include/asm/perf_event.h                |    4 -
 arch/metag/include/asm/pgalloc.h                   |   83 -
 arch/metag/include/asm/pgtable-bits.h              |  105 -
 arch/metag/include/asm/pgtable.h                   |  270 ---
 arch/metag/include/asm/processor.h                 |  201 --
 arch/metag/include/asm/ptrace.h                    |   61 -
 arch/metag/include/asm/setup.h                     |   10 -
 arch/metag/include/asm/smp.h                       |   28 -
 arch/metag/include/asm/sparsemem.h                 |   14 -
 arch/metag/include/asm/spinlock.h                  |   19 -
 arch/metag/include/asm/spinlock_lnkget.h           |  213 ---
 arch/metag/include/asm/spinlock_lock1.h            |  165 --
 arch/metag/include/asm/spinlock_types.h            |   21 -
 arch/metag/include/asm/stacktrace.h                |   21 -
 arch/metag/include/asm/string.h                    |   14 -
 arch/metag/include/asm/switch.h                    |   21 -
 arch/metag/include/asm/syscall.h                   |  104 -
 arch/metag/include/asm/syscalls.h                  |   40 -
 arch/metag/include/asm/tbx.h                       | 1420 --------------
 arch/metag/include/asm/tcm.h                       |   31 -
 arch/metag/include/asm/thread_info.h               |  141 --
 arch/metag/include/asm/tlb.h                       |   37 -
 arch/metag/include/asm/tlbflush.h                  |   78 -
 arch/metag/include/asm/topology.h                  |   28 -
 arch/metag/include/asm/traps.h                     |   48 -
 arch/metag/include/asm/uaccess.h                   |  213 ---
 arch/metag/include/asm/unistd.h                    |   12 -
 arch/metag/include/asm/user_gateway.h              |   45 -
 arch/metag/include/uapi/asm/Kbuild                 |   31 -
 arch/metag/include/uapi/asm/byteorder.h            |    2 -
 arch/metag/include/uapi/asm/ech.h                  |   16 -
 arch/metag/include/uapi/asm/ptrace.h               |  114 --
 arch/metag/include/uapi/asm/sigcontext.h           |   32 -
 arch/metag/include/uapi/asm/siginfo.h              |   16 -
 arch/metag/include/uapi/asm/swab.h                 |   27 -
 arch/metag/include/uapi/asm/unistd.h               |   24 -
 arch/metag/kernel/.gitignore                       |    1 -
 arch/metag/kernel/Makefile                         |   40 -
 arch/metag/kernel/asm-offsets.c                    |   15 -
 arch/metag/kernel/cachepart.c                      |  132 --
 arch/metag/kernel/clock.c                          |  110 --
 arch/metag/kernel/core_reg.c                       |  118 --
 arch/metag/kernel/da.c                             |   25 -
 arch/metag/kernel/devtree.c                        |   57 -
 arch/metag/kernel/dma.c                            |  588 ------
 arch/metag/kernel/ftrace.c                         |  121 --
 arch/metag/kernel/ftrace_stub.S                    |   62 -
 arch/metag/kernel/head.S                           |   66 -
 arch/metag/kernel/irq.c                            |  293 ---
 arch/metag/kernel/kick.c                           |  110 --
 arch/metag/kernel/machines.c                       |   21 -
 arch/metag/kernel/metag_ksyms.c                    |   55 -
 arch/metag/kernel/module.c                         |  284 ---
 arch/metag/kernel/perf/Makefile                    |    3 -
 arch/metag/kernel/perf/perf_event.c                |  879 ---------
 arch/metag/kernel/perf/perf_event.h                |  106 --
 arch/metag/kernel/perf_callchain.c                 |   97 -
 arch/metag/kernel/process.c                        |  448 -----
 arch/metag/kernel/ptrace.c                         |  427 -----
 arch/metag/kernel/setup.c                          |  622 ------
 arch/metag/kernel/signal.c                         |  336 ----
 arch/metag/kernel/smp.c                            |  668 -------
 arch/metag/kernel/stacktrace.c                     |  187 --
 arch/metag/kernel/sys_metag.c                      |  181 --
 arch/metag/kernel/tbiunexp.S                       |   23 -
 arch/metag/kernel/tcm.c                            |  152 --
 arch/metag/kernel/time.c                           |   26 -
 arch/metag/kernel/topology.c                       |   78 -
 arch/metag/kernel/traps.c                          |  992 ----------
 arch/metag/kernel/user_gateway.S                   |   98 -
 arch/metag/kernel/vmlinux.lds.S                    |   74 -
 arch/metag/lib/Makefile                            |   23 -
 arch/metag/lib/ashldi3.S                           |   34 -
 arch/metag/lib/ashrdi3.S                           |   34 -
 arch/metag/lib/checksum.c                          |  167 --
 arch/metag/lib/clear_page.S                        |   18 -
 arch/metag/lib/cmpdi2.S                            |   33 -
 arch/metag/lib/copy_page.S                         |   21 -
 arch/metag/lib/delay.c                             |   57 -
 arch/metag/lib/div64.S                             |  109 --
 arch/metag/lib/divsi3.S                            |  101 -
 arch/metag/lib/ip_fast_csum.S                      |   33 -
 arch/metag/lib/lshrdi3.S                           |   34 -
 arch/metag/lib/memcpy.S                            |  186 --
 arch/metag/lib/memmove.S                           |  346 ----
 arch/metag/lib/memset.S                            |   87 -
 arch/metag/lib/modsi3.S                            |   39 -
 arch/metag/lib/muldi3.S                            |   45 -
 arch/metag/lib/ucmpdi2.S                           |   28 -
 arch/metag/lib/usercopy.c                          | 1257 ------------
 arch/metag/mm/Kconfig                              |  147 --
 arch/metag/mm/Makefile                             |   20 -
 arch/metag/mm/cache.c                              |  521 -----
 arch/metag/mm/extable.c                            |   15 -
 arch/metag/mm/fault.c                              |  247 ---
 arch/metag/mm/highmem.c                            |  122 --
 arch/metag/mm/hugetlbpage.c                        |  251 ---
 arch/metag/mm/init.c                               |  408 ----
 arch/metag/mm/ioremap.c                            |   90 -
 arch/metag/mm/l2cache.c                            |  193 --
 arch/metag/mm/maccess.c                            |   69 -
 arch/metag/mm/mmu-meta1.c                          |  157 --
 arch/metag/mm/mmu-meta2.c                          |  208 --
 arch/metag/mm/numa.c                               |   82 -
 arch/metag/oprofile/Makefile                       |   18 -
 arch/metag/oprofile/backtrace.c                    |   63 -
 arch/metag/oprofile/backtrace.h                    |    7 -
 arch/metag/oprofile/common.c                       |   66 -
 arch/metag/tbx/Makefile                            |   22 -
 arch/metag/tbx/tbicore.S                           |  136 --
 arch/metag/tbx/tbictx.S                            |  366 ----
 arch/metag/tbx/tbictxfpu.S                         |  190 --
 arch/metag/tbx/tbidefr.S                           |  175 --
 arch/metag/tbx/tbidspram.S                         |  161 --
 arch/metag/tbx/tbilogf.S                           |   48 -
 arch/metag/tbx/tbipcx.S                            |  451 -----
 arch/metag/tbx/tbiroot.S                           |   87 -
 arch/metag/tbx/tbisoft.S                           |  237 ---
 arch/metag/tbx/tbistring.c                         |  114 --
 arch/metag/tbx/tbitimer.S                          |  207 --
 drivers/clocksource/Kconfig                        |    5 -
 drivers/clocksource/Makefile                       |    1 -
 drivers/clocksource/metag_generic.c                |  161 --
 drivers/gpio/Kconfig                               |   15 -
 drivers/gpio/Makefile                              |    2 -
 drivers/gpio/gpio-tz1090-pdc.c                     |  231 ---
 drivers/gpio/gpio-tz1090.c                         |  602 ------
 drivers/i2c/busses/Kconfig                         |    2 +-
 drivers/irqchip/Makefile                           |    2 -
 drivers/irqchip/irq-metag-ext.c                    |  871 ---------
 drivers/irqchip/irq-metag.c                        |  343 ----
 drivers/media/rc/img-ir/Kconfig                    |    2 +-
 drivers/pinctrl/Kconfig                            |   12 -
 drivers/pinctrl/Makefile                           |    2 -
 drivers/pinctrl/pinctrl-tz1090-pdc.c               |  989 ----------
 drivers/pinctrl/pinctrl-tz1090.c                   | 2005 ----------------=
----
 drivers/tty/Kconfig                                |   13 -
 drivers/tty/Makefile                               |    1 -
 drivers/tty/metag_da.c                             |  665 -------
 drivers/watchdog/Kconfig                           |    2 +-
 include/clocksource/metag_generic.h                |   21 -
 include/linux/cpuhotplug.h                         |    2 -
 include/linux/irqchip/metag-ext.h                  |   34 -
 include/linux/irqchip/metag.h                      |   25 -
 include/linux/mm.h                                 |    2 -
 include/trace/events/mmflags.h                     |    2 +-
 include/uapi/linux/elf.h                           |    3 -
 lib/Kconfig.debug                                  |    2 +-
 mm/Kconfig                                         |    7 +-
 scripts/checkstack.pl                              |    4 -
 scripts/recordmcount.c                             |   20 -
 tools/perf/perf-sys.h                              |    4 -
 266 files changed, 14 insertions(+), 31963 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/gpio/gpio-tz1090-pdc.=
txt
 delete mode 100644 Documentation/devicetree/bindings/gpio/gpio-tz1090.txt
 delete mode 100644 Documentation/devicetree/bindings/metag/meta.txt
 delete mode 100644 Documentation/devicetree/bindings/pinctrl/img,tz1090-pd=
c-pinctrl.txt
 delete mode 100644 Documentation/devicetree/bindings/pinctrl/img,tz1090-pi=
nctrl.txt
 delete mode 100644 Documentation/metag/00-INDEX
 delete mode 100644 Documentation/metag/kernel-ABI.txt
 delete mode 100644 arch/metag/Kconfig
 delete mode 100644 arch/metag/Kconfig.debug
 delete mode 100644 arch/metag/Kconfig.soc
 delete mode 100644 arch/metag/Makefile
 delete mode 100644 arch/metag/boot/.gitignore
 delete mode 100644 arch/metag/boot/Makefile
 delete mode 100644 arch/metag/boot/dts/Makefile
 delete mode 100644 arch/metag/boot/dts/skeleton.dts
 delete mode 100644 arch/metag/boot/dts/skeleton.dtsi
 delete mode 100644 arch/metag/boot/dts/tz1090.dtsi
 delete mode 100644 arch/metag/boot/dts/tz1090_generic.dts
 delete mode 100644 arch/metag/configs/meta1_defconfig
 delete mode 100644 arch/metag/configs/meta2_defconfig
 delete mode 100644 arch/metag/configs/meta2_smp_defconfig
 delete mode 100644 arch/metag/configs/tz1090_defconfig
 delete mode 100644 arch/metag/include/asm/Kbuild
 delete mode 100644 arch/metag/include/asm/atomic.h
 delete mode 100644 arch/metag/include/asm/atomic_lnkget.h
 delete mode 100644 arch/metag/include/asm/atomic_lock1.h
 delete mode 100644 arch/metag/include/asm/barrier.h
 delete mode 100644 arch/metag/include/asm/bitops.h
 delete mode 100644 arch/metag/include/asm/bug.h
 delete mode 100644 arch/metag/include/asm/cache.h
 delete mode 100644 arch/metag/include/asm/cacheflush.h
 delete mode 100644 arch/metag/include/asm/cachepart.h
 delete mode 100644 arch/metag/include/asm/checksum.h
 delete mode 100644 arch/metag/include/asm/clock.h
 delete mode 100644 arch/metag/include/asm/cmpxchg.h
 delete mode 100644 arch/metag/include/asm/cmpxchg_irq.h
 delete mode 100644 arch/metag/include/asm/cmpxchg_lnkget.h
 delete mode 100644 arch/metag/include/asm/cmpxchg_lock1.h
 delete mode 100644 arch/metag/include/asm/core_reg.h
 delete mode 100644 arch/metag/include/asm/cpu.h
 delete mode 100644 arch/metag/include/asm/da.h
 delete mode 100644 arch/metag/include/asm/delay.h
 delete mode 100644 arch/metag/include/asm/div64.h
 delete mode 100644 arch/metag/include/asm/dma-mapping.h
 delete mode 100644 arch/metag/include/asm/elf.h
 delete mode 100644 arch/metag/include/asm/fixmap.h
 delete mode 100644 arch/metag/include/asm/ftrace.h
 delete mode 100644 arch/metag/include/asm/global_lock.h
 delete mode 100644 arch/metag/include/asm/highmem.h
 delete mode 100644 arch/metag/include/asm/hugetlb.h
 delete mode 100644 arch/metag/include/asm/hwthread.h
 delete mode 100644 arch/metag/include/asm/io.h
 delete mode 100644 arch/metag/include/asm/irq.h
 delete mode 100644 arch/metag/include/asm/irqflags.h
 delete mode 100644 arch/metag/include/asm/l2cache.h
 delete mode 100644 arch/metag/include/asm/linkage.h
 delete mode 100644 arch/metag/include/asm/mach/arch.h
 delete mode 100644 arch/metag/include/asm/metag_isa.h
 delete mode 100644 arch/metag/include/asm/metag_mem.h
 delete mode 100644 arch/metag/include/asm/metag_regs.h
 delete mode 100644 arch/metag/include/asm/mman.h
 delete mode 100644 arch/metag/include/asm/mmu.h
 delete mode 100644 arch/metag/include/asm/mmu_context.h
 delete mode 100644 arch/metag/include/asm/mmzone.h
 delete mode 100644 arch/metag/include/asm/module.h
 delete mode 100644 arch/metag/include/asm/page.h
 delete mode 100644 arch/metag/include/asm/perf_event.h
 delete mode 100644 arch/metag/include/asm/pgalloc.h
 delete mode 100644 arch/metag/include/asm/pgtable-bits.h
 delete mode 100644 arch/metag/include/asm/pgtable.h
 delete mode 100644 arch/metag/include/asm/processor.h
 delete mode 100644 arch/metag/include/asm/ptrace.h
 delete mode 100644 arch/metag/include/asm/setup.h
 delete mode 100644 arch/metag/include/asm/smp.h
 delete mode 100644 arch/metag/include/asm/sparsemem.h
 delete mode 100644 arch/metag/include/asm/spinlock.h
 delete mode 100644 arch/metag/include/asm/spinlock_lnkget.h
 delete mode 100644 arch/metag/include/asm/spinlock_lock1.h
 delete mode 100644 arch/metag/include/asm/spinlock_types.h
 delete mode 100644 arch/metag/include/asm/stacktrace.h
 delete mode 100644 arch/metag/include/asm/string.h
 delete mode 100644 arch/metag/include/asm/switch.h
 delete mode 100644 arch/metag/include/asm/syscall.h
 delete mode 100644 arch/metag/include/asm/syscalls.h
 delete mode 100644 arch/metag/include/asm/tbx.h
 delete mode 100644 arch/metag/include/asm/tcm.h
 delete mode 100644 arch/metag/include/asm/thread_info.h
 delete mode 100644 arch/metag/include/asm/tlb.h
 delete mode 100644 arch/metag/include/asm/tlbflush.h
 delete mode 100644 arch/metag/include/asm/topology.h
 delete mode 100644 arch/metag/include/asm/traps.h
 delete mode 100644 arch/metag/include/asm/uaccess.h
 delete mode 100644 arch/metag/include/asm/unistd.h
 delete mode 100644 arch/metag/include/asm/user_gateway.h
 delete mode 100644 arch/metag/include/uapi/asm/Kbuild
 delete mode 100644 arch/metag/include/uapi/asm/byteorder.h
 delete mode 100644 arch/metag/include/uapi/asm/ech.h
 delete mode 100644 arch/metag/include/uapi/asm/ptrace.h
 delete mode 100644 arch/metag/include/uapi/asm/sigcontext.h
 delete mode 100644 arch/metag/include/uapi/asm/siginfo.h
 delete mode 100644 arch/metag/include/uapi/asm/swab.h
 delete mode 100644 arch/metag/include/uapi/asm/unistd.h
 delete mode 100644 arch/metag/kernel/.gitignore
 delete mode 100644 arch/metag/kernel/Makefile
 delete mode 100644 arch/metag/kernel/asm-offsets.c
 delete mode 100644 arch/metag/kernel/cachepart.c
 delete mode 100644 arch/metag/kernel/clock.c
 delete mode 100644 arch/metag/kernel/core_reg.c
 delete mode 100644 arch/metag/kernel/da.c
 delete mode 100644 arch/metag/kernel/devtree.c
 delete mode 100644 arch/metag/kernel/dma.c
 delete mode 100644 arch/metag/kernel/ftrace.c
 delete mode 100644 arch/metag/kernel/ftrace_stub.S
 delete mode 100644 arch/metag/kernel/head.S
 delete mode 100644 arch/metag/kernel/irq.c
 delete mode 100644 arch/metag/kernel/kick.c
 delete mode 100644 arch/metag/kernel/machines.c
 delete mode 100644 arch/metag/kernel/metag_ksyms.c
 delete mode 100644 arch/metag/kernel/module.c
 delete mode 100644 arch/metag/kernel/perf/Makefile
 delete mode 100644 arch/metag/kernel/perf/perf_event.c
 delete mode 100644 arch/metag/kernel/perf/perf_event.h
 delete mode 100644 arch/metag/kernel/perf_callchain.c
 delete mode 100644 arch/metag/kernel/process.c
 delete mode 100644 arch/metag/kernel/ptrace.c
 delete mode 100644 arch/metag/kernel/setup.c
 delete mode 100644 arch/metag/kernel/signal.c
 delete mode 100644 arch/metag/kernel/smp.c
 delete mode 100644 arch/metag/kernel/stacktrace.c
 delete mode 100644 arch/metag/kernel/sys_metag.c
 delete mode 100644 arch/metag/kernel/tbiunexp.S
 delete mode 100644 arch/metag/kernel/tcm.c
 delete mode 100644 arch/metag/kernel/time.c
 delete mode 100644 arch/metag/kernel/topology.c
 delete mode 100644 arch/metag/kernel/traps.c
 delete mode 100644 arch/metag/kernel/user_gateway.S
 delete mode 100644 arch/metag/kernel/vmlinux.lds.S
 delete mode 100644 arch/metag/lib/Makefile
 delete mode 100644 arch/metag/lib/ashldi3.S
 delete mode 100644 arch/metag/lib/ashrdi3.S
 delete mode 100644 arch/metag/lib/checksum.c
 delete mode 100644 arch/metag/lib/clear_page.S
 delete mode 100644 arch/metag/lib/cmpdi2.S
 delete mode 100644 arch/metag/lib/copy_page.S
 delete mode 100644 arch/metag/lib/delay.c
 delete mode 100644 arch/metag/lib/div64.S
 delete mode 100644 arch/metag/lib/divsi3.S
 delete mode 100644 arch/metag/lib/ip_fast_csum.S
 delete mode 100644 arch/metag/lib/lshrdi3.S
 delete mode 100644 arch/metag/lib/memcpy.S
 delete mode 100644 arch/metag/lib/memmove.S
 delete mode 100644 arch/metag/lib/memset.S
 delete mode 100644 arch/metag/lib/modsi3.S
 delete mode 100644 arch/metag/lib/muldi3.S
 delete mode 100644 arch/metag/lib/ucmpdi2.S
 delete mode 100644 arch/metag/lib/usercopy.c
 delete mode 100644 arch/metag/mm/Kconfig
 delete mode 100644 arch/metag/mm/Makefile
 delete mode 100644 arch/metag/mm/cache.c
 delete mode 100644 arch/metag/mm/extable.c
 delete mode 100644 arch/metag/mm/fault.c
 delete mode 100644 arch/metag/mm/highmem.c
 delete mode 100644 arch/metag/mm/hugetlbpage.c
 delete mode 100644 arch/metag/mm/init.c
 delete mode 100644 arch/metag/mm/ioremap.c
 delete mode 100644 arch/metag/mm/l2cache.c
 delete mode 100644 arch/metag/mm/maccess.c
 delete mode 100644 arch/metag/mm/mmu-meta1.c
 delete mode 100644 arch/metag/mm/mmu-meta2.c
 delete mode 100644 arch/metag/mm/numa.c
 delete mode 100644 arch/metag/oprofile/Makefile
 delete mode 100644 arch/metag/oprofile/backtrace.c
 delete mode 100644 arch/metag/oprofile/backtrace.h
 delete mode 100644 arch/metag/oprofile/common.c
 delete mode 100644 arch/metag/tbx/Makefile
 delete mode 100644 arch/metag/tbx/tbicore.S
 delete mode 100644 arch/metag/tbx/tbictx.S
 delete mode 100644 arch/metag/tbx/tbictxfpu.S
 delete mode 100644 arch/metag/tbx/tbidefr.S
 delete mode 100644 arch/metag/tbx/tbidspram.S
 delete mode 100644 arch/metag/tbx/tbilogf.S
 delete mode 100644 arch/metag/tbx/tbipcx.S
 delete mode 100644 arch/metag/tbx/tbiroot.S
 delete mode 100644 arch/metag/tbx/tbisoft.S
 delete mode 100644 arch/metag/tbx/tbistring.c
 delete mode 100644 arch/metag/tbx/tbitimer.S
 delete mode 100644 drivers/clocksource/metag_generic.c
 delete mode 100644 drivers/gpio/gpio-tz1090-pdc.c
 delete mode 100644 drivers/gpio/gpio-tz1090.c
 delete mode 100644 drivers/irqchip/irq-metag-ext.c
 delete mode 100644 drivers/irqchip/irq-metag.c
 delete mode 100644 drivers/pinctrl/pinctrl-tz1090-pdc.c
 delete mode 100644 drivers/pinctrl/pinctrl-tz1090.c
 delete mode 100644 drivers/tty/metag_da.c
 delete mode 100644 include/clocksource/metag_generic.h
 delete mode 100644 include/linux/irqchip/metag-ext.h
 delete mode 100644 include/linux/irqchip/metag.h

--Zbynv6TNPa9FrOf6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlqVXtkACgkQbAtpk944
dnpsMg//UIo7YB/oSg9r052IfddShczaaFxouX+vosS7fk7BiqTWfO7KiVtYc03w
FesvkClqYUw0eeWwTdOKHKAOlhFoy9Mls6nOUID/vzNuM9TyIy0WEJAVRNSOMOLM
a37kGyCY69WXU4W41ai58SxQWsShabenwmqn4yPZeRGe4pueEHmrpbh2BQz7aUB+
nT818fGJm/HLD90qbXMMFYhMR6EJ+UfoGy788oBgNu0xEIT3IpS/GUOMC0ArZ+sd
whDiVqJ1W9/1iYxJ2lZqveaetsFxb0D77jj/eDvtbtIa00SbEgs1H5D5ElJpoUnf
9I+6nyoUIdzSawynrsp0PVo9YFLfQz9AGWKIrhHrifFFlrgEwZEsTRRFVImiSILm
UMExoLdyRCY4RVMop5duThNFmgWV+EaLrsnIpuwv8C0Vu1DJnkCtxyOc7wa0d3o3
q3uWA4D28p/TxxuiDEm85p4p5bwBTPc3rIXv7L68OHJUR0N2lSwquvzPWZ4mGBvx
4UOj0TbpI3VltYTLEzIf65jee8Fv/XVgNqMFwS22gFLVWSCPjDgx+7wci5ZnllKo
T0GFUVP0E98FyaUOlLo5qvUsdi3KFkOdqWdJMlyVrMaXVaHytFvh1b4yN0pcLKyQ
8moHwJb3znokINPtR77Z5ikY+HWzCwZIGFkIWZ0nrt+NTas0Qvk=
=9D7a
-----END PGP SIGNATURE-----

--Zbynv6TNPa9FrOf6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
