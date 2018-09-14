Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAA028E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:14:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u74-v6so9267513oie.16
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:14:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e63-v6si3538993oig.210.2018.09.14.05.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:14:18 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4YKp125087
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:14:17 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgc6cst38-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:14:06 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:14:02 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 29/30] mm: remove include/linux/bootmem.h
Date: Fri, 14 Sep 2018 15:10:44 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-30-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Move remaining definitions and declarations from include/linux/bootmem.h
into include/linux/memblock.h and remove the redundant header.

The includes were replaced with the semantic patch below and then
semi-automated removal of duplicated '#include <linux/memblock.h>

@@
@@
- #include <linux/bootmem.h>
+ #include <linux/memblock.h>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/alpha/kernel/core_cia.c                |   2 +-
 arch/alpha/kernel/core_irongate.c           |   1 -
 arch/alpha/kernel/core_marvel.c             |   2 +-
 arch/alpha/kernel/core_titan.c              |   2 +-
 arch/alpha/kernel/core_tsunami.c            |   2 +-
 arch/alpha/kernel/pci-noop.c                |   2 +-
 arch/alpha/kernel/pci.c                     |   2 +-
 arch/alpha/kernel/pci_iommu.c               |   2 +-
 arch/alpha/kernel/setup.c                   |   1 -
 arch/alpha/kernel/sys_nautilus.c            |   2 +-
 arch/alpha/mm/init.c                        |   2 +-
 arch/alpha/mm/numa.c                        |   1 -
 arch/arc/kernel/unwind.c                    |   2 +-
 arch/arc/mm/highmem.c                       |   2 +-
 arch/arc/mm/init.c                          |   1 -
 arch/arm/kernel/devtree.c                   |   1 -
 arch/arm/kernel/setup.c                     |   1 -
 arch/arm/mach-omap2/omap_hwmod.c            |   2 +-
 arch/arm/mm/dma-mapping.c                   |   1 -
 arch/arm/mm/init.c                          |   1 -
 arch/arm/xen/mm.c                           |   1 -
 arch/arm/xen/p2m.c                          |   2 +-
 arch/arm64/kernel/acpi.c                    |   1 -
 arch/arm64/kernel/acpi_numa.c               |   1 -
 arch/arm64/kernel/setup.c                   |   1 -
 arch/arm64/mm/dma-mapping.c                 |   2 +-
 arch/arm64/mm/init.c                        |   1 -
 arch/arm64/mm/kasan_init.c                  |   1 -
 arch/arm64/mm/numa.c                        |   1 -
 arch/c6x/kernel/setup.c                     |   1 -
 arch/c6x/mm/init.c                          |   2 +-
 arch/h8300/kernel/setup.c                   |   1 -
 arch/h8300/mm/init.c                        |   2 +-
 arch/hexagon/kernel/dma.c                   |   2 +-
 arch/hexagon/kernel/setup.c                 |   2 +-
 arch/hexagon/mm/init.c                      |   1 -
 arch/ia64/kernel/crash.c                    |   2 +-
 arch/ia64/kernel/efi.c                      |   2 +-
 arch/ia64/kernel/ia64_ksyms.c               |   2 +-
 arch/ia64/kernel/iosapic.c                  |   2 +-
 arch/ia64/kernel/mca.c                      |   2 +-
 arch/ia64/kernel/mca_drv.c                  |   2 +-
 arch/ia64/kernel/setup.c                    |   1 -
 arch/ia64/kernel/smpboot.c                  |   2 +-
 arch/ia64/kernel/topology.c                 |   2 +-
 arch/ia64/kernel/unwind.c                   |   2 +-
 arch/ia64/mm/contig.c                       |   1 -
 arch/ia64/mm/discontig.c                    |   1 -
 arch/ia64/mm/init.c                         |   1 -
 arch/ia64/mm/numa.c                         |   2 +-
 arch/ia64/mm/tlb.c                          |   2 +-
 arch/ia64/pci/pci.c                         |   2 +-
 arch/ia64/sn/kernel/bte.c                   |   2 +-
 arch/ia64/sn/kernel/io_common.c             |   2 +-
 arch/ia64/sn/kernel/setup.c                 |   2 +-
 arch/m68k/atari/stram.c                     |   2 +-
 arch/m68k/coldfire/m54xx.c                  |   2 +-
 arch/m68k/kernel/setup_mm.c                 |   1 -
 arch/m68k/kernel/setup_no.c                 |   1 -
 arch/m68k/kernel/uboot.c                    |   2 +-
 arch/m68k/mm/init.c                         |   2 +-
 arch/m68k/mm/mcfmmu.c                       |   1 -
 arch/m68k/mm/motorola.c                     |   1 -
 arch/m68k/mm/sun3mmu.c                      |   2 +-
 arch/m68k/sun3/config.c                     |   2 +-
 arch/m68k/sun3/dvma.c                       |   2 +-
 arch/m68k/sun3/mmu_emu.c                    |   2 +-
 arch/m68k/sun3/sun3dvma.c                   |   2 +-
 arch/m68k/sun3x/dvma.c                      |   2 +-
 arch/microblaze/mm/consistent.c             |   2 +-
 arch/microblaze/mm/init.c                   |   3 +-
 arch/microblaze/pci/pci-common.c            |   2 +-
 arch/mips/ar7/memory.c                      |   2 +-
 arch/mips/ath79/setup.c                     |   2 +-
 arch/mips/bcm63xx/prom.c                    |   2 +-
 arch/mips/bcm63xx/setup.c                   |   2 +-
 arch/mips/bmips/setup.c                     |   2 +-
 arch/mips/cavium-octeon/dma-octeon.c        |   2 +-
 arch/mips/dec/prom/memory.c                 |   2 +-
 arch/mips/emma/common/prom.c                |   2 +-
 arch/mips/fw/arc/memory.c                   |   2 +-
 arch/mips/jazz/jazzdma.c                    |   2 +-
 arch/mips/kernel/crash.c                    |   2 +-
 arch/mips/kernel/crash_dump.c               |   2 +-
 arch/mips/kernel/prom.c                     |   2 +-
 arch/mips/kernel/setup.c                    |   1 -
 arch/mips/kernel/traps.c                    |   1 -
 arch/mips/kernel/vpe.c                      |   2 +-
 arch/mips/kvm/commpage.c                    |   2 +-
 arch/mips/kvm/dyntrans.c                    |   2 +-
 arch/mips/kvm/emulate.c                     |   2 +-
 arch/mips/kvm/interrupt.c                   |   2 +-
 arch/mips/kvm/mips.c                        |   2 +-
 arch/mips/lantiq/prom.c                     |   2 +-
 arch/mips/lasat/prom.c                      |   2 +-
 arch/mips/loongson64/common/init.c          |   2 +-
 arch/mips/loongson64/loongson-3/numa.c      |   1 -
 arch/mips/mm/init.c                         |   2 +-
 arch/mips/mm/pgtable-32.c                   |   2 +-
 arch/mips/mti-malta/malta-memory.c          |   2 +-
 arch/mips/netlogic/xlp/dt.c                 |   2 +-
 arch/mips/pci/pci-legacy.c                  |   2 +-
 arch/mips/pci/pci.c                         |   2 +-
 arch/mips/ralink/of.c                       |   2 +-
 arch/mips/rb532/prom.c                      |   2 +-
 arch/mips/sgi-ip27/ip27-memory.c            |   1 -
 arch/mips/sibyte/common/cfe.c               |   2 +-
 arch/mips/sibyte/swarm/setup.c              |   2 +-
 arch/mips/txx9/rbtx4938/prom.c              |   2 +-
 arch/nds32/kernel/setup.c                   |   3 +-
 arch/nds32/mm/highmem.c                     |   2 +-
 arch/nds32/mm/init.c                        |   3 +-
 arch/nios2/kernel/prom.c                    |   2 +-
 arch/nios2/kernel/setup.c                   |   1 -
 arch/nios2/mm/init.c                        |   2 +-
 arch/openrisc/kernel/setup.c                |   3 +-
 arch/openrisc/mm/init.c                     |   3 +-
 arch/parisc/mm/init.c                       |   1 -
 arch/powerpc/kernel/pci_32.c                |   2 +-
 arch/powerpc/kernel/setup_64.c              |   3 +-
 arch/powerpc/lib/alloc.c                    |   2 +-
 arch/powerpc/mm/hugetlbpage.c               |   1 -
 arch/powerpc/mm/mem.c                       |   3 +-
 arch/powerpc/mm/mmu_context_nohash.c        |   2 +-
 arch/powerpc/mm/numa.c                      |   3 +-
 arch/powerpc/platforms/powermac/nvram.c     |   2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c   |   3 +-
 arch/powerpc/platforms/ps3/setup.c          |   2 +-
 arch/powerpc/sysdev/msi_bitmap.c            |   2 +-
 arch/riscv/mm/init.c                        |   3 +-
 arch/s390/kernel/crash_dump.c               |   3 +-
 arch/s390/kernel/setup.c                    |   1 -
 arch/s390/kernel/smp.c                      |   3 +-
 arch/s390/kernel/topology.c                 |   2 +-
 arch/s390/kernel/vdso.c                     |   2 +-
 arch/s390/mm/extmem.c                       |   2 +-
 arch/s390/mm/init.c                         |   3 +-
 arch/s390/mm/vmem.c                         |   3 +-
 arch/s390/numa/mode_emu.c                   |   1 -
 arch/s390/numa/numa.c                       |   1 -
 arch/s390/numa/toptree.c                    |   2 +-
 arch/sh/mm/init.c                           |   3 +-
 arch/sh/mm/ioremap_fixed.c                  |   2 +-
 arch/sparc/kernel/mdesc.c                   |   2 -
 arch/sparc/kernel/prom_32.c                 |   2 +-
 arch/sparc/kernel/setup_64.c                |   2 +-
 arch/sparc/kernel/smp_64.c                  |   2 +-
 arch/sparc/mm/init_32.c                     |   1 -
 arch/sparc/mm/init_64.c                     |   3 +-
 arch/sparc/mm/srmmu.c                       |   2 +-
 arch/um/drivers/net_kern.c                  |   2 +-
 arch/um/drivers/vector_kern.c               |   2 +-
 arch/um/kernel/initrd.c                     |   2 +-
 arch/um/kernel/mem.c                        |   1 -
 arch/um/kernel/physmem.c                    |   1 -
 arch/unicore32/kernel/hibernate.c           |   2 +-
 arch/unicore32/kernel/setup.c               |   3 +-
 arch/unicore32/mm/init.c                    |   3 +-
 arch/unicore32/mm/mmu.c                     |   1 -
 arch/x86/kernel/acpi/boot.c                 |   2 +-
 arch/x86/kernel/acpi/sleep.c                |   1 -
 arch/x86/kernel/apic/apic.c                 |   2 +-
 arch/x86/kernel/apic/io_apic.c              |   2 +-
 arch/x86/kernel/cpu/common.c                |   2 +-
 arch/x86/kernel/e820.c                      |   3 +-
 arch/x86/kernel/mpparse.c                   |   1 -
 arch/x86/kernel/pci-dma.c                   |   2 +-
 arch/x86/kernel/pci-swiotlb.c               |   2 +-
 arch/x86/kernel/pvclock.c                   |   2 +-
 arch/x86/kernel/setup.c                     |   1 -
 arch/x86/kernel/setup_percpu.c              |   1 -
 arch/x86/kernel/smpboot.c                   |   2 +-
 arch/x86/kernel/tce_64.c                    |   1 -
 arch/x86/mm/amdtopology.c                   |   1 -
 arch/x86/mm/fault.c                         |   2 +-
 arch/x86/mm/highmem_32.c                    |   2 +-
 arch/x86/mm/init.c                          |   1 -
 arch/x86/mm/init_32.c                       |   1 -
 arch/x86/mm/init_64.c                       |   1 -
 arch/x86/mm/ioremap.c                       |   2 +-
 arch/x86/mm/kasan_init_64.c                 |   3 +-
 arch/x86/mm/numa.c                          |   1 -
 arch/x86/mm/numa_32.c                       |   1 -
 arch/x86/mm/numa_64.c                       |   2 +-
 arch/x86/mm/numa_emulation.c                |   1 -
 arch/x86/mm/pageattr-test.c                 |   2 +-
 arch/x86/mm/pageattr.c                      |   2 +-
 arch/x86/mm/pat.c                           |   2 +-
 arch/x86/mm/physaddr.c                      |   2 +-
 arch/x86/pci/i386.c                         |   2 +-
 arch/x86/platform/efi/efi.c                 |   3 +-
 arch/x86/platform/efi/efi_64.c              |   2 +-
 arch/x86/platform/efi/quirks.c              |   1 -
 arch/x86/platform/olpc/olpc_dt.c            |   2 +-
 arch/x86/power/hibernate_32.c               |   2 +-
 arch/x86/xen/enlighten.c                    |   2 +-
 arch/x86/xen/enlighten_pv.c                 |   3 +-
 arch/x86/xen/p2m.c                          |   1 -
 arch/xtensa/kernel/pci.c                    |   2 +-
 arch/xtensa/mm/cache.c                      |   2 +-
 arch/xtensa/mm/init.c                       |   2 +-
 arch/xtensa/mm/kasan_init.c                 |   3 +-
 arch/xtensa/mm/mmu.c                        |   2 +-
 arch/xtensa/platforms/iss/network.c         |   2 +-
 arch/xtensa/platforms/iss/setup.c           |   2 +-
 block/blk-settings.c                        |   2 +-
 block/bounce.c                              |   2 +-
 drivers/acpi/numa.c                         |   1 -
 drivers/acpi/tables.c                       |   3 +-
 drivers/base/platform.c                     |   2 +-
 drivers/clk/ti/clk.c                        |   2 +-
 drivers/firmware/dmi_scan.c                 |   2 +-
 drivers/firmware/efi/apple-properties.c     |   2 +-
 drivers/firmware/iscsi_ibft_find.c          |   2 +-
 drivers/firmware/memmap.c                   |   2 +-
 drivers/iommu/mtk_iommu.c                   |   2 +-
 drivers/iommu/mtk_iommu_v1.c                |   2 +-
 drivers/macintosh/smu.c                     |   3 +-
 drivers/mtd/ar7part.c                       |   2 +-
 drivers/net/arcnet/arc-rimi.c               |   2 +-
 drivers/net/arcnet/com20020-isa.c           |   2 +-
 drivers/net/arcnet/com90io.c                |   2 +-
 drivers/of/fdt.c                            |   1 -
 drivers/of/unittest.c                       |   2 +-
 drivers/s390/char/fs3270.c                  |   2 +-
 drivers/s390/char/tty3270.c                 |   2 +-
 drivers/s390/cio/cmf.c                      |   2 +-
 drivers/s390/virtio/virtio_ccw.c            |   2 +-
 drivers/sfi/sfi_core.c                      |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_core.c |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c |   2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c |   2 +-
 drivers/usb/early/xhci-dbc.c                |   1 -
 drivers/xen/balloon.c                       |   2 +-
 drivers/xen/events/events_base.c            |   2 +-
 drivers/xen/grant-table.c                   |   2 +-
 drivers/xen/swiotlb-xen.c                   |   1 -
 drivers/xen/xen-selfballoon.c               |   2 +-
 fs/dcache.c                                 |   2 +-
 fs/inode.c                                  |   2 +-
 fs/namespace.c                              |   2 +-
 fs/proc/kcore.c                             |   2 +-
 fs/proc/page.c                              |   2 +-
 fs/proc/vmcore.c                            |   2 +-
 include/linux/bootmem.h                     | 173 ----------------------------
 include/linux/memblock.h                    | 151 +++++++++++++++++++++++-
 init/main.c                                 |   2 +-
 kernel/dma/swiotlb.c                        |   2 +-
 kernel/futex.c                              |   2 +-
 kernel/locking/qspinlock_paravirt.h         |   2 +-
 kernel/pid.c                                |   2 +-
 kernel/power/snapshot.c                     |   2 +-
 kernel/printk/printk.c                      |   1 -
 kernel/profile.c                            |   2 +-
 lib/cpumask.c                               |   2 +-
 mm/hugetlb.c                                |   1 -
 mm/kasan/kasan_init.c                       |   3 +-
 mm/kmemleak.c                               |   2 +-
 mm/memblock.c                               |   1 -
 mm/memory_hotplug.c                         |   1 -
 mm/page_alloc.c                             |   1 -
 mm/page_ext.c                               |   2 +-
 mm/page_idle.c                              |   2 +-
 mm/page_owner.c                             |   2 +-
 mm/percpu.c                                 |   2 +-
 mm/sparse-vmemmap.c                         |   1 -
 mm/sparse.c                                 |   1 -
 net/ipv4/inet_hashtables.c                  |   2 +-
 net/ipv4/tcp.c                              |   2 +-
 net/ipv4/udp.c                              |   2 +-
 net/sctp/protocol.c                         |   2 +-
 net/xfrm/xfrm_hash.c                        |   2 +-
 272 files changed, 351 insertions(+), 474 deletions(-)
 delete mode 100644 include/linux/bootmem.h

diff --git a/arch/alpha/kernel/core_cia.c b/arch/alpha/kernel/core_cia.c
index 026ee95..867e873 100644
--- a/arch/alpha/kernel/core_cia.c
+++ b/arch/alpha/kernel/core_cia.c
@@ -21,7 +21,7 @@
 #include <linux/pci.h>
 #include <linux/sched.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/ptrace.h>
 #include <asm/mce.h>
diff --git a/arch/alpha/kernel/core_irongate.c b/arch/alpha/kernel/core_irongate.c
index 35572be..a9fd133 100644
--- a/arch/alpha/kernel/core_irongate.c
+++ b/arch/alpha/kernel/core_irongate.c
@@ -20,7 +20,6 @@
 #include <linux/sched.h>
 #include <linux/init.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 
 #include <asm/ptrace.h>
diff --git a/arch/alpha/kernel/core_marvel.c b/arch/alpha/kernel/core_marvel.c
index 1f00c94..8a568c4 100644
--- a/arch/alpha/kernel/core_marvel.c
+++ b/arch/alpha/kernel/core_marvel.c
@@ -18,7 +18,7 @@
 #include <linux/mc146818rtc.h>
 #include <linux/rtc.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/ptrace.h>
 #include <asm/smp.h>
diff --git a/arch/alpha/kernel/core_titan.c b/arch/alpha/kernel/core_titan.c
index 132b06b..9755159 100644
--- a/arch/alpha/kernel/core_titan.c
+++ b/arch/alpha/kernel/core_titan.c
@@ -16,7 +16,7 @@
 #include <linux/sched.h>
 #include <linux/init.h>
 #include <linux/vmalloc.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/ptrace.h>
 #include <asm/smp.h>
diff --git a/arch/alpha/kernel/core_tsunami.c b/arch/alpha/kernel/core_tsunami.c
index e7c956e..f334b89 100644
--- a/arch/alpha/kernel/core_tsunami.c
+++ b/arch/alpha/kernel/core_tsunami.c
@@ -17,7 +17,7 @@
 #include <linux/pci.h>
 #include <linux/sched.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/ptrace.h>
 #include <asm/smp.h>
diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
index 59cbfc2..a9378ee 100644
--- a/arch/alpha/kernel/pci-noop.c
+++ b/arch/alpha/kernel/pci-noop.c
@@ -7,7 +7,7 @@
 
 #include <linux/pci.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 #include <linux/capability.h>
 #include <linux/mm.h>
diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 4cc3eb9..13937e7 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -18,7 +18,7 @@
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/module.h>
 #include <linux/cache.h>
 #include <linux/slab.h>
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 5d178c7..82cf950 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -7,7 +7,7 @@
 #include <linux/mm.h>
 #include <linux/pci.h>
 #include <linux/gfp.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/scatterlist.h>
 #include <linux/log2.h>
diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
index 64c06a0..a37fd99 100644
--- a/arch/alpha/kernel/setup.c
+++ b/arch/alpha/kernel/setup.c
@@ -29,7 +29,6 @@
 #include <linux/string.h>
 #include <linux/ioport.h>
 #include <linux/platform_device.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/pci.h>
 #include <linux/seq_file.h>
diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index ff4f54b..cd9a112 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -32,7 +32,7 @@
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/reboot.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/bitops.h>
 
 #include <asm/ptrace.h>
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 853d153..a42fc5c 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -19,7 +19,7 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/init.h>
-#include <linux/bootmem.h> /* max_low_pfn */
+#include <linux/memblock.h> /* max_low_pfn */
 #include <linux/vmalloc.h>
 #include <linux/gfp.h>
 
diff --git a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
index 26cd925..74846553 100644
--- a/arch/alpha/mm/numa.c
+++ b/arch/alpha/mm/numa.c
@@ -10,7 +10,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/swap.h>
 #include <linux/initrd.h>
diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
index 2a01dd1..d34f69e 100644
--- a/arch/arc/kernel/unwind.c
+++ b/arch/arc/kernel/unwind.c
@@ -15,7 +15,7 @@
 
 #include <linux/sched.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/sort.h>
 #include <linux/slab.h>
 #include <linux/stop_machine.h>
diff --git a/arch/arc/mm/highmem.c b/arch/arc/mm/highmem.c
index f582dc8..48e7001 100644
--- a/arch/arc/mm/highmem.c
+++ b/arch/arc/mm/highmem.c
@@ -7,7 +7,7 @@
  *
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/highmem.h>
 #include <asm/processor.h>
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 0f29c65..f8fe566 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -8,7 +8,6 @@
 
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #ifdef CONFIG_BLK_DEV_INITRD
 #include <linux/initrd.h>
diff --git a/arch/arm/kernel/devtree.c b/arch/arm/kernel/devtree.c
index ecaa68d..6f26838 100644
--- a/arch/arm/kernel/devtree.c
+++ b/arch/arm/kernel/devtree.c
@@ -12,7 +12,6 @@
 #include <linux/export.h>
 #include <linux/errno.h>
 #include <linux/types.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/of.h>
 #include <linux/of_fdt.h>
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 39e6090..840a4ad 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -16,7 +16,6 @@
 #include <linux/utsname.h>
 #include <linux/initrd.h>
 #include <linux/console.h>
-#include <linux/bootmem.h>
 #include <linux/seq_file.h>
 #include <linux/screen_info.h>
 #include <linux/of_platform.h>
diff --git a/arch/arm/mach-omap2/omap_hwmod.c b/arch/arm/mach-omap2/omap_hwmod.c
index 1f9b34a..cd5732a 100644
--- a/arch/arm/mach-omap2/omap_hwmod.c
+++ b/arch/arm/mach-omap2/omap_hwmod.c
@@ -141,7 +141,7 @@
 #include <linux/cpu.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <linux/platform_data/ti-sysc.h>
 
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6656647..661fe48 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -9,7 +9,6 @@
  *
  *  DMA uncached mapping support.
  */
-#include <linux/bootmem.h>
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/genalloc.h>
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index d421a10..32e4845 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -11,7 +11,6 @@
 #include <linux/errno.h>
 #include <linux/swap.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/mman.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/task.h>
diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index 785d2a5..cb44aa2 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -1,6 +1,5 @@
 #include <linux/cpu.h>
 #include <linux/dma-mapping.h>
-#include <linux/bootmem.h>
 #include <linux/gfp.h>
 #include <linux/highmem.h>
 #include <linux/export.h>
diff --git a/arch/arm/xen/p2m.c b/arch/arm/xen/p2m.c
index 0641ba5..e70a49f 100644
--- a/arch/arm/xen/p2m.c
+++ b/arch/arm/xen/p2m.c
@@ -1,4 +1,4 @@
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 #include <linux/export.h>
 #include <linux/spinlock.h>
diff --git a/arch/arm64/kernel/acpi.c b/arch/arm64/kernel/acpi.c
index ed46dc1..44e3c35 100644
--- a/arch/arm64/kernel/acpi.c
+++ b/arch/arm64/kernel/acpi.c
@@ -16,7 +16,6 @@
 #define pr_fmt(fmt) "ACPI: " fmt
 
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
 #include <linux/cpumask.h>
 #include <linux/efi.h>
 #include <linux/efi-bgrt.h>
diff --git a/arch/arm64/kernel/acpi_numa.c b/arch/arm64/kernel/acpi_numa.c
index 4f4f181..eac1d0c 100644
--- a/arch/arm64/kernel/acpi_numa.c
+++ b/arch/arm64/kernel/acpi_numa.c
@@ -18,7 +18,6 @@
 
 #include <linux/acpi.h>
 #include <linux/bitmap.h>
-#include <linux/bootmem.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/memblock.h>
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index cf7a7b7..46d48ea 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -26,7 +26,6 @@
 #include <linux/initrd.h>
 #include <linux/console.h>
 #include <linux/cache.h>
-#include <linux/bootmem.h>
 #include <linux/screen_info.h>
 #include <linux/init.h>
 #include <linux/kexec.h>
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index cdcb73d..1469f96 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -19,7 +19,7 @@
 
 #include <linux/gfp.h>
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/cache.h>
 #include <linux/export.h>
 #include <linux/slab.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index ae21849..f44ce25 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -22,7 +22,6 @@
 #include <linux/errno.h>
 #include <linux/swap.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/cache.h>
 #include <linux/mman.h>
 #include <linux/nodemask.h>
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 2391560..3b868be 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -11,7 +11,6 @@
  */
 
 #define pr_fmt(fmt) "kasan: " fmt
-#include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/sched/task.h>
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 8f2e0e8..db9b512f 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -20,7 +20,6 @@
 #define pr_fmt(fmt) "NUMA: " fmt
 
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/module.h>
 #include <linux/of.h>
diff --git a/arch/c6x/kernel/setup.c b/arch/c6x/kernel/setup.c
index cc74cb9..811f1c6 100644
--- a/arch/c6x/kernel/setup.c
+++ b/arch/c6x/kernel/setup.c
@@ -11,7 +11,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/memblock.h>
 #include <linux/seq_file.h>
-#include <linux/bootmem.h>
 #include <linux/clkdev.h>
 #include <linux/initrd.h>
 #include <linux/kernel.h>
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index 3383df8..af5ada0 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -11,7 +11,7 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #ifdef CONFIG_BLK_DEV_RAM
 #include <linux/blkdev.h>
 #endif
diff --git a/arch/h8300/kernel/setup.c b/arch/h8300/kernel/setup.c
index 34e2df5..b32bfa1f 100644
--- a/arch/h8300/kernel/setup.c
+++ b/arch/h8300/kernel/setup.c
@@ -18,7 +18,6 @@
 #include <linux/console.h>
 #include <linux/errno.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
 #include <linux/of.h>
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index f2bf448..6519252 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -30,7 +30,7 @@
 #include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 
 #include <asm/setup.h>
diff --git a/arch/hexagon/kernel/dma.c b/arch/hexagon/kernel/dma.c
index ffc4ae8..45a1b42 100644
--- a/arch/hexagon/kernel/dma.c
+++ b/arch/hexagon/kernel/dma.c
@@ -19,7 +19,7 @@
  */
 
 #include <linux/dma-noncoherent.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/genalloc.h>
 #include <linux/module.h>
 #include <asm/page.h>
diff --git a/arch/hexagon/kernel/setup.c b/arch/hexagon/kernel/setup.c
index dc8c7e7..b3c3e04 100644
--- a/arch/hexagon/kernel/setup.c
+++ b/arch/hexagon/kernel/setup.c
@@ -20,7 +20,7 @@
 
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/mm.h>
 #include <linux/seq_file.h>
diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index 88643fa..1719ede 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -20,7 +20,6 @@
 
 #include <linux/init.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <asm/atomic.h>
 #include <linux/highmem.h>
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index 39f4433..bec762a9b 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -12,7 +12,7 @@
 #include <linux/smp.h>
 #include <linux/delay.h>
 #include <linux/crash_dump.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/kexec.h>
 #include <linux/elfcore.h>
 #include <linux/sysctl.h>
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 9c09bf3..ed47d70 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -23,7 +23,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/module.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/crash_dump.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 6b51c88..b49fe6f 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -6,7 +6,7 @@
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/compiler.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 EXPORT_SYMBOL(min_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 #endif
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 550243a..fe6e494 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -90,7 +90,7 @@
 #include <linux/slab.h>
 #include <linux/smp.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/delay.h>
 #include <asm/hw_irq.h>
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 7120976..9a6603f 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -77,7 +77,7 @@
 #include <linux/sched/task.h>
 #include <linux/interrupt.h>
 #include <linux/irq.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/acpi.h>
 #include <linux/timer.h>
 #include <linux/module.h>
diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index dfe40cb..45f956a 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -14,7 +14,7 @@
 #include <linux/interrupt.h>
 #include <linux/irq.h>
 #include <linux/kallsyms.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/acpi.h>
 #include <linux/timer.h>
 #include <linux/module.h>
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 0e6c2d9..583a374 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -27,7 +27,6 @@
 #include <linux/init.h>
 
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
 #include <linux/console.h>
 #include <linux/delay.h>
 #include <linux/cpu.h>
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 74fe317..51ec944 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -24,7 +24,7 @@
 
 #include <linux/module.h>
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/cpu.h>
 #include <linux/delay.h>
 #include <linux/init.h>
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 9b820f7..e311ee13 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -19,7 +19,7 @@
 #include <linux/node.h>
 #include <linux/slab.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/nodemask.h>
 #include <linux/notifier.h>
 #include <linux/export.h>
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index e04efa0..7601fe0 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -28,7 +28,7 @@
  *	  acquired, then the read-write lock must be acquired first.
  */
 #include <linux/module.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/elf.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 9e5c23a..6e44723 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -14,7 +14,6 @@
  * Routines used by ia64 machines with contiguous (or virtually contiguous)
  * memory.
  */
-#include <linux/bootmem.h>
 #include <linux/efi.h>
 #include <linux/memblock.h>
 #include <linux/mm.h>
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 70609f8..8a96578 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -19,7 +19,6 @@
 #include <linux/mm.h>
 #include <linux/nmi.h>
 #include <linux/swap.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/acpi.h>
 #include <linux/efi.h>
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 43ea4a4..d5e12ff 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -8,7 +8,6 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 
-#include <linux/bootmem.h>
 #include <linux/efi.h>
 #include <linux/elf.h>
 #include <linux/memblock.h>
diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index aa19b7a..3861d6e 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -15,7 +15,7 @@
 #include <linux/mm.h>
 #include <linux/node.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/module.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 5554863..ab545da 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -21,7 +21,7 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/slab.h>
 
 #include <asm/delay.h>
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 7ccc64d..508a47a 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -20,7 +20,7 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 
 #include <asm/machvec.h>
diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index 9146192..9900e6d 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -16,7 +16,7 @@
 #include <asm/nodedata.h>
 #include <asm/delay.h>
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/string.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 8b05d55..98f5522 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -6,7 +6,7 @@
  * Copyright (C) 2006 Silicon Graphics, Inc. All rights reserved.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/slab.h>
 #include <asm/sn/types.h>
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index ab2564f..71ad6b0 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -20,7 +20,7 @@
 #include <linux/mm.h>
 #include <linux/serial.h>
 #include <linux/irq.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/interrupt.h>
 #include <linux/acpi.h>
diff --git a/arch/m68k/atari/stram.c b/arch/m68k/atari/stram.c
index 1089d67..6ffc204 100644
--- a/arch/m68k/atari/stram.c
+++ b/arch/m68k/atari/stram.c
@@ -17,7 +17,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mount.h>
 #include <linux/blkdev.h>
 #include <linux/module.h>
diff --git a/arch/m68k/coldfire/m54xx.c b/arch/m68k/coldfire/m54xx.c
index adad03c..360c723 100644
--- a/arch/m68k/coldfire/m54xx.c
+++ b/arch/m68k/coldfire/m54xx.c
@@ -16,7 +16,7 @@
 #include <linux/io.h>
 #include <linux/mm.h>
 #include <linux/clk.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/pgalloc.h>
 #include <asm/machdep.h>
 #include <asm/coldfire.h>
diff --git a/arch/m68k/kernel/setup_mm.c b/arch/m68k/kernel/setup_mm.c
index 5d3596c..a1a3eae 100644
--- a/arch/m68k/kernel/setup_mm.c
+++ b/arch/m68k/kernel/setup_mm.c
@@ -20,7 +20,6 @@
 #include <linux/errno.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
diff --git a/arch/m68k/kernel/setup_no.c b/arch/m68k/kernel/setup_no.c
index cfd5475..3c5def1 100644
--- a/arch/m68k/kernel/setup_no.c
+++ b/arch/m68k/kernel/setup_no.c
@@ -27,7 +27,6 @@
 #include <linux/console.h>
 #include <linux/errno.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
diff --git a/arch/m68k/kernel/uboot.c b/arch/m68k/kernel/uboot.c
index b29c3b2..db90354 100644
--- a/arch/m68k/kernel/uboot.c
+++ b/arch/m68k/kernel/uboot.c
@@ -16,7 +16,7 @@
 #include <linux/console.h>
 #include <linux/errno.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
 #include <linux/initrd.h>
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index ae49ae4..933c33e 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -17,7 +17,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 
 #include <asm/setup.h>
diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
index 38a1d92..0de4999 100644
--- a/arch/m68k/mm/mcfmmu.c
+++ b/arch/m68k/mm/mcfmmu.c
@@ -13,7 +13,6 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 
 #include <asm/setup.h>
diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
index 2113eec..7497cf3 100644
--- a/arch/m68k/mm/motorola.c
+++ b/arch/m68k/mm/motorola.c
@@ -18,7 +18,6 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/gfp.h>
 
diff --git a/arch/m68k/mm/sun3mmu.c b/arch/m68k/mm/sun3mmu.c
index 19c05ab..f736db4 100644
--- a/arch/m68k/mm/sun3mmu.c
+++ b/arch/m68k/mm/sun3mmu.c
@@ -16,7 +16,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <linux/uaccess.h>
diff --git a/arch/m68k/sun3/config.c b/arch/m68k/sun3/config.c
index 79a2bb8..542c440 100644
--- a/arch/m68k/sun3/config.c
+++ b/arch/m68k/sun3/config.c
@@ -15,7 +15,7 @@
 #include <linux/tty.h>
 #include <linux/console.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/platform_device.h>
 
 #include <asm/oplib.h>
diff --git a/arch/m68k/sun3/dvma.c b/arch/m68k/sun3/dvma.c
index 5f92c72..a2c1c93 100644
--- a/arch/m68k/sun3/dvma.c
+++ b/arch/m68k/sun3/dvma.c
@@ -11,7 +11,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/list.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
diff --git a/arch/m68k/sun3/mmu_emu.c b/arch/m68k/sun3/mmu_emu.c
index d30da12..582a128 100644
--- a/arch/m68k/sun3/mmu_emu.c
+++ b/arch/m68k/sun3/mmu_emu.c
@@ -13,7 +13,7 @@
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
 #include <linux/delay.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/sched/mm.h>
diff --git a/arch/m68k/sun3/sun3dvma.c b/arch/m68k/sun3/sun3dvma.c
index 72d9458..8be8b75 100644
--- a/arch/m68k/sun3/sun3dvma.c
+++ b/arch/m68k/sun3/sun3dvma.c
@@ -7,7 +7,7 @@
  * Contains common routines for sun3/sun3x DVMA management.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff --git a/arch/m68k/sun3x/dvma.c b/arch/m68k/sun3x/dvma.c
index b2acbc8..89e630e 100644
--- a/arch/m68k/sun3x/dvma.c
+++ b/arch/m68k/sun3x/dvma.c
@@ -15,7 +15,7 @@
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/vmalloc.h>
 
 #include <asm/sun3x.h>
diff --git a/arch/microblaze/mm/consistent.c b/arch/microblaze/mm/consistent.c
index c9a278a..b9d90ab 100644
--- a/arch/microblaze/mm/consistent.c
+++ b/arch/microblaze/mm/consistent.c
@@ -28,7 +28,7 @@
 #include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/pci.h>
 #include <linux/interrupt.h>
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 9989740..8c14988 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -7,10 +7,9 @@
  * for more details.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
-#include <linux/memblock.h>
 #include <linux/mm.h> /* mem_init */
 #include <linux/initrd.h>
 #include <linux/pagemap.h>
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 2ffd171..6b89a66 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -20,7 +20,7 @@
 #include <linux/pci.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/shmem_fs.h>
 #include <linux/list.h>
diff --git a/arch/mips/ar7/memory.c b/arch/mips/ar7/memory.c
index 0332f05..80390a9 100644
--- a/arch/mips/ar7/memory.c
+++ b/arch/mips/ar7/memory.c
@@ -16,7 +16,7 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/pfn.h>
diff --git a/arch/mips/ath79/setup.c b/arch/mips/ath79/setup.c
index 4c7a93f..9728abc 100644
--- a/arch/mips/ath79/setup.c
+++ b/arch/mips/ath79/setup.c
@@ -14,7 +14,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/err.h>
 #include <linux/clk.h>
 #include <linux/clk-provider.h>
diff --git a/arch/mips/bcm63xx/prom.c b/arch/mips/bcm63xx/prom.c
index 7019e29..77a836e 100644
--- a/arch/mips/bcm63xx/prom.c
+++ b/arch/mips/bcm63xx/prom.c
@@ -7,7 +7,7 @@
  */
 
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/smp.h>
 #include <asm/bootinfo.h>
 #include <asm/bmips.h>
diff --git a/arch/mips/bcm63xx/setup.c b/arch/mips/bcm63xx/setup.c
index 2be9caa..e28ee9a 100644
--- a/arch/mips/bcm63xx/setup.c
+++ b/arch/mips/bcm63xx/setup.c
@@ -9,7 +9,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/delay.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ioport.h>
 #include <linux/pm.h>
 #include <asm/bootinfo.h>
diff --git a/arch/mips/bmips/setup.c b/arch/mips/bmips/setup.c
index 231fc5c..301ccb8 100644
--- a/arch/mips/bmips/setup.c
+++ b/arch/mips/bmips/setup.c
@@ -9,7 +9,7 @@
 
 #include <linux/init.h>
 #include <linux/bitops.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/clk-provider.h>
 #include <linux/ioport.h>
 #include <linux/kernel.h>
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index c44c1a6..e8eb60e 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -11,7 +11,7 @@
  * Copyright (C) 2010 Cavium Networks, Inc.
  */
 #include <linux/dma-direct.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/swiotlb.h>
 #include <linux/types.h>
 #include <linux/init.h>
diff --git a/arch/mips/dec/prom/memory.c b/arch/mips/dec/prom/memory.c
index a2acc64..5073d2e 100644
--- a/arch/mips/dec/prom/memory.c
+++ b/arch/mips/dec/prom/memory.c
@@ -8,7 +8,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/types.h>
 
 #include <asm/addrspace.h>
diff --git a/arch/mips/emma/common/prom.c b/arch/mips/emma/common/prom.c
index cae4225..675337b 100644
--- a/arch/mips/emma/common/prom.c
+++ b/arch/mips/emma/common/prom.c
@@ -22,7 +22,7 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/sched.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/addrspace.h>
 #include <asm/bootinfo.h>
diff --git a/arch/mips/fw/arc/memory.c b/arch/mips/fw/arc/memory.c
index dd9496f..429b7f8 100644
--- a/arch/mips/fw/arc/memory.c
+++ b/arch/mips/fw/arc/memory.c
@@ -17,7 +17,7 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/swap.h>
 
 #include <asm/sgialib.h>
diff --git a/arch/mips/jazz/jazzdma.c b/arch/mips/jazz/jazzdma.c
index d31bc2f..c07f097 100644
--- a/arch/mips/jazz/jazzdma.c
+++ b/arch/mips/jazz/jazzdma.c
@@ -13,7 +13,7 @@
 #include <linux/export.h>
 #include <linux/errno.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/spinlock.h>
 #include <linux/gfp.h>
 #include <linux/dma-direct.h>
diff --git a/arch/mips/kernel/crash.c b/arch/mips/kernel/crash.c
index d455363..19352ae 100644
--- a/arch/mips/kernel/crash.c
+++ b/arch/mips/kernel/crash.c
@@ -3,7 +3,7 @@
 #include <linux/smp.h>
 #include <linux/reboot.h>
 #include <linux/kexec.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/crash_dump.h>
 #include <linux/delay.h>
 #include <linux/irq.h>
diff --git a/arch/mips/kernel/crash_dump.c b/arch/mips/kernel/crash_dump.c
index a8657d2..01b2bd9 100644
--- a/arch/mips/kernel/crash_dump.c
+++ b/arch/mips/kernel/crash_dump.c
@@ -1,6 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/highmem.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/crash_dump.h>
 #include <linux/uaccess.h>
 #include <linux/slab.h>
diff --git a/arch/mips/kernel/prom.c b/arch/mips/kernel/prom.c
index 89950b7..93b8e0b 100644
--- a/arch/mips/kernel/prom.c
+++ b/arch/mips/kernel/prom.c
@@ -12,7 +12,7 @@
 #include <linux/export.h>
 #include <linux/errno.h>
 #include <linux/types.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/debugfs.h>
 #include <linux/of.h>
 #include <linux/of_fdt.h>
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 86c9eda..4efa8af 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -15,7 +15,6 @@
 #include <linux/export.h>
 #include <linux/screen_info.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/initrd.h>
 #include <linux/root_dev.h>
 #include <linux/highmem.h>
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 623dc18..0f852e1 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -28,7 +28,6 @@
 #include <linux/smp.h>
 #include <linux/spinlock.h>
 #include <linux/kallsyms.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/interrupt.h>
 #include <linux/ptrace.h>
diff --git a/arch/mips/kernel/vpe.c b/arch/mips/kernel/vpe.c
index 0bef238..6176b9a 100644
--- a/arch/mips/kernel/vpe.c
+++ b/arch/mips/kernel/vpe.c
@@ -26,7 +26,7 @@
 #include <linux/moduleloader.h>
 #include <linux/interrupt.h>
 #include <linux/poll.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/mipsregs.h>
 #include <asm/mipsmtregs.h>
 #include <asm/cacheflush.h>
diff --git a/arch/mips/kvm/commpage.c b/arch/mips/kvm/commpage.c
index f436299..5812e61 100644
--- a/arch/mips/kvm/commpage.c
+++ b/arch/mips/kvm/commpage.c
@@ -14,7 +14,7 @@
 #include <linux/err.h>
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/page.h>
 #include <asm/cacheflush.h>
 #include <asm/mmu_context.h>
diff --git a/arch/mips/kvm/dyntrans.c b/arch/mips/kvm/dyntrans.c
index f8e7725..d77b61b 100644
--- a/arch/mips/kvm/dyntrans.c
+++ b/arch/mips/kvm/dyntrans.c
@@ -16,7 +16,7 @@
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/cacheflush.h>
 
 #include "commpage.h"
diff --git a/arch/mips/kvm/emulate.c b/arch/mips/kvm/emulate.c
index 4144bfa..ec9ed23 100644
--- a/arch/mips/kvm/emulate.c
+++ b/arch/mips/kvm/emulate.c
@@ -15,7 +15,7 @@
 #include <linux/kvm_host.h>
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/random.h>
 #include <asm/page.h>
 #include <asm/cacheflush.h>
diff --git a/arch/mips/kvm/interrupt.c b/arch/mips/kvm/interrupt.c
index aa0a1a0..7257e8b6 100644
--- a/arch/mips/kvm/interrupt.c
+++ b/arch/mips/kvm/interrupt.c
@@ -13,7 +13,7 @@
 #include <linux/err.h>
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/page.h>
 #include <asm/cacheflush.h>
 
diff --git a/arch/mips/kvm/mips.c b/arch/mips/kvm/mips.c
index f7ea8e2..1fcc4d1 100644
--- a/arch/mips/kvm/mips.c
+++ b/arch/mips/kvm/mips.c
@@ -18,7 +18,7 @@
 #include <linux/vmalloc.h>
 #include <linux/sched/signal.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/fpu.h>
 #include <asm/page.h>
diff --git a/arch/mips/lantiq/prom.c b/arch/mips/lantiq/prom.c
index d984bd5..14d4c5e 100644
--- a/arch/mips/lantiq/prom.c
+++ b/arch/mips/lantiq/prom.c
@@ -8,7 +8,7 @@
 
 #include <linux/export.h>
 #include <linux/clk.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/of_fdt.h>
 
 #include <asm/bootinfo.h>
diff --git a/arch/mips/lasat/prom.c b/arch/mips/lasat/prom.c
index 37b8fc5..5ce1407 100644
--- a/arch/mips/lasat/prom.c
+++ b/arch/mips/lasat/prom.c
@@ -8,7 +8,7 @@
 #include <linux/ctype.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ioport.h>
 #include <asm/bootinfo.h>
 #include <asm/lasat/lasat.h>
diff --git a/arch/mips/loongson64/common/init.c b/arch/mips/loongson64/common/init.c
index 6ef1712..c073fbc 100644
--- a/arch/mips/loongson64/common/init.c
+++ b/arch/mips/loongson64/common/init.c
@@ -8,7 +8,7 @@
  * option) any later version.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/bootinfo.h>
 #include <asm/traps.h>
 #include <asm/smp-ops.h>
diff --git a/arch/mips/loongson64/loongson-3/numa.c b/arch/mips/loongson64/loongson-3/numa.c
index 703ad45..6227618 100644
--- a/arch/mips/loongson64/loongson-3/numa.c
+++ b/arch/mips/loongson64/loongson-3/numa.c
@@ -18,7 +18,6 @@
 #include <linux/nodemask.h>
 #include <linux/swap.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/pfn.h>
 #include <linux/highmem.h>
 #include <asm/page.h>
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 54c36be..1e3df58 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -22,7 +22,7 @@
 #include <linux/ptrace.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
diff --git a/arch/mips/mm/pgtable-32.c b/arch/mips/mm/pgtable-32.c
index b19a3c5..e2a33ad 100644
--- a/arch/mips/mm/pgtable-32.c
+++ b/arch/mips/mm/pgtable-32.c
@@ -7,7 +7,7 @@
  */
 #include <linux/init.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <asm/fixmap.h>
 #include <asm/pgtable.h>
diff --git a/arch/mips/mti-malta/malta-memory.c b/arch/mips/mti-malta/malta-memory.c
index a475567..868921a 100644
--- a/arch/mips/mti-malta/malta-memory.c
+++ b/arch/mips/mti-malta/malta-memory.c
@@ -12,7 +12,7 @@
  *          Steven J. Hill <sjhill@mips.com>
  */
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/string.h>
 
 #include <asm/bootinfo.h>
diff --git a/arch/mips/netlogic/xlp/dt.c b/arch/mips/netlogic/xlp/dt.c
index b5ba83f..c856f2a 100644
--- a/arch/mips/netlogic/xlp/dt.c
+++ b/arch/mips/netlogic/xlp/dt.c
@@ -33,7 +33,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <linux/of_fdt.h>
 #include <linux/of_platform.h>
diff --git a/arch/mips/pci/pci-legacy.c b/arch/mips/pci/pci-legacy.c
index f1e92bf..efc4f78a 100644
--- a/arch/mips/pci/pci-legacy.c
+++ b/arch/mips/pci/pci-legacy.c
@@ -11,7 +11,7 @@
 #include <linux/bug.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/types.h>
diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
index c2e94cf..e68b44b 100644
--- a/arch/mips/pci/pci.c
+++ b/arch/mips/pci/pci.c
@@ -11,7 +11,7 @@
 #include <linux/bug.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/types.h>
diff --git a/arch/mips/ralink/of.c b/arch/mips/ralink/of.c
index 1ada849..d544e7b 100644
--- a/arch/mips/ralink/of.c
+++ b/arch/mips/ralink/of.c
@@ -14,7 +14,7 @@
 #include <linux/sizes.h>
 #include <linux/of_fdt.h>
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/of_platform.h>
 #include <linux/of_address.h>
 
diff --git a/arch/mips/rb532/prom.c b/arch/mips/rb532/prom.c
index 6484e4a..361a690 100644
--- a/arch/mips/rb532/prom.c
+++ b/arch/mips/rb532/prom.c
@@ -29,7 +29,7 @@
 #include <linux/export.h>
 #include <linux/string.h>
 #include <linux/console.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ioport.h>
 #include <linux/blkdev.h>
 
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index cb1f1a6..d8b8444 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -18,7 +18,6 @@
 #include <linux/export.h>
 #include <linux/nodemask.h>
 #include <linux/swap.h>
-#include <linux/bootmem.h>
 #include <linux/pfn.h>
 #include <linux/highmem.h>
 #include <asm/page.h>
diff --git a/arch/mips/sibyte/common/cfe.c b/arch/mips/sibyte/common/cfe.c
index 092fb2a..12a780f 100644
--- a/arch/mips/sibyte/common/cfe.c
+++ b/arch/mips/sibyte/common/cfe.c
@@ -21,7 +21,7 @@
 #include <linux/linkage.h>
 #include <linux/mm.h>
 #include <linux/blkdev.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pm.h>
 #include <linux/smp.h>
 
diff --git a/arch/mips/sibyte/swarm/setup.c b/arch/mips/sibyte/swarm/setup.c
index 152ca71..3b034b7 100644
--- a/arch/mips/sibyte/swarm/setup.c
+++ b/arch/mips/sibyte/swarm/setup.c
@@ -23,7 +23,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/blkdev.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
diff --git a/arch/mips/txx9/rbtx4938/prom.c b/arch/mips/txx9/rbtx4938/prom.c
index bcb4692..2b36a2e 100644
--- a/arch/mips/txx9/rbtx4938/prom.c
+++ b/arch/mips/txx9/rbtx4938/prom.c
@@ -11,7 +11,7 @@
  */
 
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/bootinfo.h>
 #include <asm/txx9/generic.h>
 #include <asm/txx9/rbtx4938.h>
diff --git a/arch/nds32/kernel/setup.c b/arch/nds32/kernel/setup.c
index 63a1a5e..eacc790 100644
--- a/arch/nds32/kernel/setup.c
+++ b/arch/nds32/kernel/setup.c
@@ -2,9 +2,8 @@
 // Copyright (C) 2005-2017 Andes Technology Corporation
 
 #include <linux/cpu.h>
-#include <linux/bootmem.h>
-#include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/seq_file.h>
 #include <linux/console.h>
 #include <linux/screen_info.h>
 #include <linux/delay.h>
diff --git a/arch/nds32/mm/highmem.c b/arch/nds32/mm/highmem.c
index e17cb8a..022779a 100644
--- a/arch/nds32/mm/highmem.c
+++ b/arch/nds32/mm/highmem.c
@@ -6,7 +6,7 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/interrupt.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/fixmap.h>
 #include <asm/tlbflush.h>
 
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index 66d3e9c..131104b 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -7,12 +7,11 @@
 #include <linux/errno.h>
 #include <linux/swap.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mman.h>
 #include <linux/nodemask.h>
 #include <linux/initrd.h>
 #include <linux/highmem.h>
-#include <linux/memblock.h>
 
 #include <asm/sections.h>
 #include <asm/setup.h>
diff --git a/arch/nios2/kernel/prom.c b/arch/nios2/kernel/prom.c
index a6d4f75..232a36b 100644
--- a/arch/nios2/kernel/prom.c
+++ b/arch/nios2/kernel/prom.c
@@ -25,7 +25,7 @@
 
 #include <linux/init.h>
 #include <linux/types.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/of.h>
 #include <linux/of_fdt.h>
 #include <linux/io.h>
diff --git a/arch/nios2/kernel/setup.c b/arch/nios2/kernel/setup.c
index 2d0011d..6bbd4ae 100644
--- a/arch/nios2/kernel/setup.c
+++ b/arch/nios2/kernel/setup.c
@@ -16,7 +16,6 @@
 #include <linux/sched.h>
 #include <linux/sched/task.h>
 #include <linux/console.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/initrd.h>
 #include <linux/of_fdt.h>
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index 1292350..16cea57 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -23,7 +23,7 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/binfmts.h>
 
diff --git a/arch/openrisc/kernel/setup.c b/arch/openrisc/kernel/setup.c
index 9d28ab1..e7eb688 100644
--- a/arch/openrisc/kernel/setup.c
+++ b/arch/openrisc/kernel/setup.c
@@ -30,13 +30,12 @@
 #include <linux/delay.h>
 #include <linux/console.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/serial.h>
 #include <linux/initrd.h>
 #include <linux/of_fdt.h>
 #include <linux/of.h>
-#include <linux/memblock.h>
 #include <linux/device.h>
 
 #include <asm/sections.h>
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index 91a6a9a..d157310 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -26,12 +26,11 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/smp.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/blkdev.h>	/* for initrd_* */
 #include <linux/pagemap.h>
-#include <linux/memblock.h>
 
 #include <asm/segment.h>
 #include <asm/pgalloc.h>
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index bc368e9..2647120 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -14,7 +14,6 @@
 
 #include <linux/module.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/gfp.h>
 #include <linux/delay.h>
diff --git a/arch/powerpc/kernel/pci_32.c b/arch/powerpc/kernel/pci_32.c
index 2fb4781..d63be12 100644
--- a/arch/powerpc/kernel/pci_32.c
+++ b/arch/powerpc/kernel/pci_32.c
@@ -10,7 +10,7 @@
 #include <linux/capability.h>
 #include <linux/sched.h>
 #include <linux/errno.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/syscalls.h>
 #include <linux/irq.h>
 #include <linux/list.h>
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index b3e70cc..791c969 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -29,10 +29,9 @@
 #include <linux/unistd.h>
 #include <linux/serial.h>
 #include <linux/serial_8250.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pci.h>
 #include <linux/lockdep.h>
-#include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/nmi.h>
 
diff --git a/arch/powerpc/lib/alloc.c b/arch/powerpc/lib/alloc.c
index bf87d6e..5b61704 100644
--- a/arch/powerpc/lib/alloc.c
+++ b/arch/powerpc/lib/alloc.c
@@ -2,7 +2,7 @@
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/slab.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/string.h>
 #include <asm/setup.h>
 
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index e87f9ef9..50d1fb4 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -15,7 +15,6 @@
 #include <linux/export.h>
 #include <linux/of_fdt.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/moduleparam.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c141134..578cbb2 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -27,12 +27,11 @@
 #include <linux/mm.h>
 #include <linux/stddef.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/initrd.h>
 #include <linux/pagemap.h>
 #include <linux/suspend.h>
-#include <linux/memblock.h>
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 954f198..67b9d7b 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -44,7 +44,7 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/spinlock.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/slab.h>
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 5fc0587..be1dc664 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -11,7 +11,7 @@
 #define pr_fmt(fmt) "numa: " fmt
 
 #include <linux/threads.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
@@ -19,7 +19,6 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/notifier.h>
-#include <linux/memblock.h>
 #include <linux/of.h>
 #include <linux/pfn.h>
 #include <linux/cpuset.h>
diff --git a/arch/powerpc/platforms/powermac/nvram.c b/arch/powerpc/platforms/powermac/nvram.c
index f45b369..f3391be 100644
--- a/arch/powerpc/platforms/powermac/nvram.c
+++ b/arch/powerpc/platforms/powermac/nvram.c
@@ -18,7 +18,7 @@
 #include <linux/errno.h>
 #include <linux/adb.h>
 #include <linux/pmu.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/completion.h>
 #include <linux/spinlock.h>
 #include <asm/sections.h>
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 23a67b5..aba81cb 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -17,11 +17,10 @@
 #include <linux/delay.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/irq.h>
 #include <linux/io.h>
 #include <linux/msi.h>
-#include <linux/memblock.h>
 #include <linux/iommu.h>
 #include <linux/rculist.h>
 #include <linux/sizes.h>
diff --git a/arch/powerpc/platforms/ps3/setup.c b/arch/powerpc/platforms/ps3/setup.c
index 1251985..658bfab 100644
--- a/arch/powerpc/platforms/ps3/setup.c
+++ b/arch/powerpc/platforms/ps3/setup.c
@@ -24,7 +24,7 @@
 #include <linux/root_dev.h>
 #include <linux/console.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/machdep.h>
 #include <asm/firmware.h>
diff --git a/arch/powerpc/sysdev/msi_bitmap.c b/arch/powerpc/sysdev/msi_bitmap.c
index 349a9ff..2444fed 100644
--- a/arch/powerpc/sysdev/msi_bitmap.c
+++ b/arch/powerpc/sysdev/msi_bitmap.c
@@ -12,7 +12,7 @@
 #include <linux/kernel.h>
 #include <linux/kmemleak.h>
 #include <linux/bitmap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <asm/msi_bitmap.h>
 #include <asm/setup.h>
 
diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
index d58c111..1d9bfaf 100644
--- a/arch/riscv/mm/init.c
+++ b/arch/riscv/mm/init.c
@@ -13,9 +13,8 @@
 
 #include <linux/init.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
-#include <linux/initrd.h>
 #include <linux/memblock.h>
+#include <linux/initrd.h>
 #include <linux/swap.h>
 #include <linux/sizes.h>
 
diff --git a/arch/s390/kernel/crash_dump.c b/arch/s390/kernel/crash_dump.c
index d17566a..97eae38 100644
--- a/arch/s390/kernel/crash_dump.c
+++ b/arch/s390/kernel/crash_dump.c
@@ -13,10 +13,9 @@
 #include <linux/mm.h>
 #include <linux/gfp.h>
 #include <linux/slab.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/elf.h>
 #include <asm/asm-offsets.h>
-#include <linux/memblock.h>
 #include <asm/os_info.h>
 #include <asm/elf.h>
 #include <asm/ipl.h>
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index 2e29456..d55a11b 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -34,7 +34,6 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
 #include <linux/root_dev.h>
 #include <linux/console.h>
 #include <linux/kernel_stat.h>
diff --git a/arch/s390/kernel/smp.c b/arch/s390/kernel/smp.c
index 8f3aafc..f393842 100644
--- a/arch/s390/kernel/smp.c
+++ b/arch/s390/kernel/smp.c
@@ -20,7 +20,7 @@
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
 #include <linux/workqueue.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/init.h>
 #include <linux/mm.h>
@@ -35,7 +35,6 @@
 #include <linux/sched/hotplug.h>
 #include <linux/sched/task_stack.h>
 #include <linux/crash_dump.h>
-#include <linux/memblock.h>
 #include <linux/kprobes.h>
 #include <asm/asm-offsets.h>
 #include <asm/diag.h>
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 799a918..8992b04 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -8,7 +8,7 @@
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
 #include <linux/workqueue.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/uaccess.h>
 #include <linux/sysctl.h>
 #include <linux/cpuset.h>
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 3031cc6..dbcb412 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -18,7 +18,7 @@
 #include <linux/user.h>
 #include <linux/elf.h>
 #include <linux/security.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/compat.h>
 #include <asm/asm-offsets.h>
 #include <asm/pgtable.h>
diff --git a/arch/s390/mm/extmem.c b/arch/s390/mm/extmem.c
index 84111a4..eba2def 100644
--- a/arch/s390/mm/extmem.c
+++ b/arch/s390/mm/extmem.c
@@ -16,7 +16,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ctype.h>
 #include <linux/ioport.h>
 #include <asm/diag.h>
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 67bdba6..e472cd7 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -21,7 +21,7 @@
 #include <linux/smp.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/pfn.h>
 #include <linux/poison.h>
@@ -29,7 +29,6 @@
 #include <linux/export.h>
 #include <linux/cma.h>
 #include <linux/gfp.h>
-#include <linux/memblock.h>
 #include <asm/processor.h>
 #include <linux/uaccess.h>
 #include <asm/pgtable.h>
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 04638b0..0472e27 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -4,14 +4,13 @@
  *    Author(s): Heiko Carstens <heiko.carstens@de.ibm.com>
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pfn.h>
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/hugetlb.h>
 #include <linux/slab.h>
-#include <linux/memblock.h>
 #include <asm/cacheflush.h>
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
diff --git a/arch/s390/numa/mode_emu.c b/arch/s390/numa/mode_emu.c
index 5a381fc..bfba273 100644
--- a/arch/s390/numa/mode_emu.c
+++ b/arch/s390/numa/mode_emu.c
@@ -22,7 +22,6 @@
 #include <linux/kernel.h>
 #include <linux/cpumask.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/node.h>
 #include <linux/memory.h>
 #include <linux/slab.h>
diff --git a/arch/s390/numa/numa.c b/arch/s390/numa/numa.c
index 297f5d8..ae0d9e8 100644
--- a/arch/s390/numa/numa.c
+++ b/arch/s390/numa/numa.c
@@ -13,7 +13,6 @@
 #include <linux/kernel.h>
 #include <linux/mmzone.h>
 #include <linux/cpumask.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/node.h>
diff --git a/arch/s390/numa/toptree.c b/arch/s390/numa/toptree.c
index 7f61cc3..71a608c 100644
--- a/arch/s390/numa/toptree.c
+++ b/arch/s390/numa/toptree.c
@@ -8,7 +8,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/cpumask.h>
 #include <linux/list.h>
 #include <linux/list_sort.h>
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 21447f8..c8c13c77 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -11,12 +11,11 @@
 #include <linux/swap.h>
 #include <linux/init.h>
 #include <linux/gfp.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/pagemap.h>
 #include <linux/percpu.h>
 #include <linux/io.h>
-#include <linux/memblock.h>
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
 #include <asm/mmu_context.h>
diff --git a/arch/sh/mm/ioremap_fixed.c b/arch/sh/mm/ioremap_fixed.c
index 927a129..07e744d 100644
--- a/arch/sh/mm/ioremap_fixed.c
+++ b/arch/sh/mm/ioremap_fixed.c
@@ -14,7 +14,7 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/io.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <asm/fixmap.h>
 #include <asm/page.h>
diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index a41526b..9a26b44 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -5,13 +5,11 @@
  */
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/memblock.h>
 #include <linux/log2.h>
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/miscdevice.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/refcount.h>
diff --git a/arch/sparc/kernel/prom_32.c b/arch/sparc/kernel/prom_32.c
index 4389944..d41e2a7 100644
--- a/arch/sparc/kernel/prom_32.c
+++ b/arch/sparc/kernel/prom_32.c
@@ -19,7 +19,7 @@
 #include <linux/types.h>
 #include <linux/string.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/prom.h>
 #include <asm/oplib.h>
diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 5fb11ea..0143909 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -32,7 +32,7 @@
 #include <linux/initrd.h>
 #include <linux/module.h>
 #include <linux/start_kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <uapi/linux/mount.h>
 
 #include <asm/io.h>
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index 6cc80d0..4792e08 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -22,7 +22,7 @@
 #include <linux/cache.h>
 #include <linux/jiffies.h>
 #include <linux/profile.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/vmalloc.h>
 #include <linux/ftrace.h>
 #include <linux/cpu.h>
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 8807145..d900952 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -22,7 +22,6 @@
 #include <linux/initrd.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/pagemap.h>
 #include <linux/poison.h>
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index c2c8bff..4d4d331 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -11,7 +11,7 @@
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
 #include <linux/initrd.h>
@@ -25,7 +25,6 @@
 #include <linux/sort.h>
 #include <linux/ioport.h>
 #include <linux/percpu.h>
-#include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/gfp.h>
 
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index b48fea5..a6142c5 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -11,7 +11,7 @@
 
 #include <linux/seq_file.h>
 #include <linux/spinlock.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pagemap.h>
 #include <linux/vmalloc.h>
 #include <linux/kdebug.h>
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index ef19a39..6738168 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -6,7 +6,7 @@
  * Licensed under the GPL.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/inetdevice.h>
diff --git a/arch/um/drivers/vector_kern.c b/arch/um/drivers/vector_kern.c
index 9d77579..af72633 100644
--- a/arch/um/drivers/vector_kern.c
+++ b/arch/um/drivers/vector_kern.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/version.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/inetdevice.h>
diff --git a/arch/um/kernel/initrd.c b/arch/um/kernel/initrd.c
index 844056c..3678f5b 100644
--- a/arch/um/kernel/initrd.c
+++ b/arch/um/kernel/initrd.c
@@ -4,7 +4,7 @@
  */
 
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/initrd.h>
 #include <asm/types.h>
 #include <init.h>
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 2c672a8..1067469 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -5,7 +5,6 @@
 
 #include <linux/stddef.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/mm.h>
diff --git a/arch/um/kernel/physmem.c b/arch/um/kernel/physmem.c
index 296a91a..5bf56af 100644
--- a/arch/um/kernel/physmem.c
+++ b/arch/um/kernel/physmem.c
@@ -4,7 +4,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/pfn.h>
diff --git a/arch/unicore32/kernel/hibernate.c b/arch/unicore32/kernel/hibernate.c
index 9969ec3..29b71c6 100644
--- a/arch/unicore32/kernel/hibernate.c
+++ b/arch/unicore32/kernel/hibernate.c
@@ -13,7 +13,7 @@
 
 #include <linux/gfp.h>
 #include <linux/suspend.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index 9f163f9..b2c38b32 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -17,7 +17,7 @@
 #include <linux/utsname.h>
 #include <linux/initrd.h>
 #include <linux/console.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/screen_info.h>
 #include <linux/init.h>
@@ -27,7 +27,6 @@
 #include <linux/smp.h>
 #include <linux/fs.h>
 #include <linux/proc_fs.h>
-#include <linux/memblock.h>
 #include <linux/elf.h>
 #include <linux/io.h>
 
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 3e5bb45..0d2b8fe 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -11,13 +11,12 @@
 #include <linux/errno.h>
 #include <linux/swap.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mman.h>
 #include <linux/nodemask.h>
 #include <linux/initrd.h>
 #include <linux/highmem.h>
 #include <linux/gfp.h>
-#include <linux/memblock.h>
 #include <linux/sort.h>
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
index 18b355a..040a8c2 100644
--- a/arch/unicore32/mm/mmu.c
+++ b/arch/unicore32/mm/mmu.c
@@ -17,7 +17,6 @@
 #include <linux/nodemask.h>
 #include <linux/memblock.h>
 #include <linux/fs.h>
-#include <linux/bootmem.h>
 #include <linux/io.h>
 
 #include <asm/cputype.h>
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index fd887c1..35419f9 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -32,7 +32,7 @@
 #include <linux/dmi.h>
 #include <linux/irq.h>
 #include <linux/slab.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/efi-bgrt.h>
diff --git a/arch/x86/kernel/acpi/sleep.c b/arch/x86/kernel/acpi/sleep.c
index f1915b7..ca13851 100644
--- a/arch/x86/kernel/acpi/sleep.c
+++ b/arch/x86/kernel/acpi/sleep.c
@@ -7,7 +7,6 @@
  */
 
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/dmi.h>
 #include <linux/cpumask.h>
diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
index 84132ed..45ae4ce 100644
--- a/arch/x86/kernel/apic/apic.c
+++ b/arch/x86/kernel/apic/apic.c
@@ -20,7 +20,7 @@
 #include <linux/acpi_pmtmr.h>
 #include <linux/clockchips.h>
 #include <linux/interrupt.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ftrace.h>
 #include <linux/ioport.h>
 #include <linux/export.h>
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 8c74509..5fbc57e 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -47,7 +47,7 @@
 #include <linux/kthread.h>
 #include <linux/jiffies.h>	/* time_after() */
 #include <linux/slab.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/irqdomain.h>
 #include <asm/io.h>
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index f48f0b9..344865c 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1,7 +1,7 @@
 /* cpu_feature_enabled() cannot be used this early */
 #define USE_EARLY_PGTABLE_L5
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/linkage.h>
 #include <linux/bitops.h>
 #include <linux/kernel.h>
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 7ea8748..cd3b448 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -9,11 +9,10 @@
  * allocation code routines via a platform independent interface (memblock, etc.).
  */
 #include <linux/crash_dump.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/suspend.h>
 #include <linux/acpi.h>
 #include <linux/firmware-map.h>
-#include <linux/memblock.h>
 #include <linux/sort.h>
 
 #include <asm/e820/api.h>
diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index f1c5eb9..3482460 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -11,7 +11,6 @@
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/kernel_stat.h>
 #include <linux/mc146818rtc.h>
diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index 7ba73fe..f4562fc 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -3,7 +3,7 @@
 #include <linux/dma-debug.h>
 #include <linux/dmar.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 #include <linux/pci.h>
 
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 6615836..d8fb84e 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -5,7 +5,7 @@
 #include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/swiotlb.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dma-direct.h>
 #include <linux/mem_encrypt.h>
 
diff --git a/arch/x86/kernel/pvclock.c b/arch/x86/kernel/pvclock.c
index 637982e..9b158b4 100644
--- a/arch/x86/kernel/pvclock.c
+++ b/arch/x86/kernel/pvclock.c
@@ -20,7 +20,7 @@
 #include <linux/notifier.h>
 #include <linux/sched.h>
 #include <linux/gfp.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/nmi.h>
 
 #include <asm/fixmap.h>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index e493202..79b7f2c 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -30,7 +30,6 @@
 #include <linux/sfi.h>
 #include <linux/apm_bios.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/seq_file.h>
 #include <linux/console.h>
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index 483412f..e8796fc 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -4,7 +4,6 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/percpu.h>
 #include <linux/kexec.h>
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index f02ecaf..21cf1fb 100644
--- a/arch/x86/kernel/smpboot.c
+++ b/arch/x86/kernel/smpboot.c
@@ -49,7 +49,7 @@
 #include <linux/sched/hotplug.h>
 #include <linux/sched/task_stack.h>
 #include <linux/percpu.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/err.h>
 #include <linux/nmi.h>
 #include <linux/tboot.h>
diff --git a/arch/x86/kernel/tce_64.c b/arch/x86/kernel/tce_64.c
index 75730ce..285aaa6 100644
--- a/arch/x86/kernel/tce_64.c
+++ b/arch/x86/kernel/tce_64.c
@@ -30,7 +30,6 @@
 #include <linux/string.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <asm/tce.h>
 #include <asm/calgary.h>
diff --git a/arch/x86/mm/amdtopology.c b/arch/x86/mm/amdtopology.c
index 048c761..058b2f3 100644
--- a/arch/x86/mm/amdtopology.c
+++ b/arch/x86/mm/amdtopology.c
@@ -12,7 +12,6 @@
 #include <linux/string.h>
 #include <linux/nodemask.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 
 #include <asm/io.h>
 #include <linux/pci_ids.h>
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index cf16dfe..b6381b0 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -8,7 +8,7 @@
 #include <linux/sched/task_stack.h>	/* task_stack_*(), ...		*/
 #include <linux/kdebug.h>		/* oops_begin/end, ...		*/
 #include <linux/extable.h>		/* search_exception_tables	*/
-#include <linux/bootmem.h>		/* max_low_pfn			*/
+#include <linux/memblock.h>		/* max_low_pfn			*/
 #include <linux/kprobes.h>		/* NOKPROBE_SYMBOL, ...		*/
 #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
 #include <linux/perf_event.h>		/* perf_sw_event		*/
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 62915a5..0d4bdcb 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -1,7 +1,7 @@
 #include <linux/highmem.h>
 #include <linux/export.h>
 #include <linux/swap.h> /* for totalram_pages */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 void *kmap(struct page *page)
 {
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 7a8fc26..bbb91c0 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -3,7 +3,6 @@
 #include <linux/ioport.h>
 #include <linux/swap.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>	/* for max_low_pfn */
 #include <linux/swapfile.h>
 #include <linux/swapops.h>
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 8ee1e64..f2837e4 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -23,7 +23,6 @@
 #include <linux/pci.h>
 #include <linux/pfn.h>
 #include <linux/poison.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/memory_hotplug.h>
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bfb0bed..5fab264 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -20,7 +20,6 @@
 #include <linux/init.h>
 #include <linux/initrd.h>
 #include <linux/pagemap.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/proc_fs.h>
 #include <linux/pci.h>
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index c63a545..bf2a98e 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -6,7 +6,7 @@
  * (C) Copyright 1995 1996 Linus Torvalds
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/io.h>
 #include <linux/ioport.h>
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 8f87499..04a9cf6 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -5,10 +5,9 @@
 /* cpu_feature_enabled() cannot be used this early */
 #define USE_EARLY_PGTABLE_L5
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
-#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/sched.h>
 #include <linux/sched/task.h>
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 16e37d7..1308f54 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -4,7 +4,6 @@
 #include <linux/mm.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/mmzone.h>
 #include <linux/ctype.h>
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
index e8a4a09..f2bd3d6 100644
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -22,7 +22,6 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/init.h>
 
diff --git a/arch/x86/mm/numa_64.c b/arch/x86/mm/numa_64.c
index 066f351..59d8016 100644
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -3,7 +3,7 @@
  * Generic VM initialization for x86-64 NUMA setups.
  * Copyright 2002,2003 Andi Kleen, SuSE Labs.
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include "numa_internal.h"
 
diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index b54d52a..a80fdd7 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -6,7 +6,6 @@
 #include <linux/errno.h>
 #include <linux/topology.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <asm/dma.h>
 
 #include "numa_internal.h"
diff --git a/arch/x86/mm/pageattr-test.c b/arch/x86/mm/pageattr-test.c
index a25588a..08f8f76 100644
--- a/arch/x86/mm/pageattr-test.c
+++ b/arch/x86/mm/pageattr-test.c
@@ -5,7 +5,7 @@
  * Clears the a test pte bit on random pages in the direct mapping,
  * then reverts and compares page tables forwards and afterwards.
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/kthread.h>
 #include <linux/random.h>
 #include <linux/kernel.h>
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 51a5a69..83c6ea7 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -3,7 +3,7 @@
  * Thanks to Ben LaHaise for precious feedback.
  */
 #include <linux/highmem.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/interrupt.h>
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 3d0c83e..0801352 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -8,7 +8,7 @@
  */
 
 #include <linux/seq_file.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/debugfs.h>
 #include <linux/ioport.h>
 #include <linux/kernel.h>
diff --git a/arch/x86/mm/physaddr.c b/arch/x86/mm/physaddr.c
index 7f9acb6..bdc9815 100644
--- a/arch/x86/mm/physaddr.c
+++ b/arch/x86/mm/physaddr.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mmdebug.h>
 #include <linux/export.h>
 #include <linux/mm.h>
diff --git a/arch/x86/pci/i386.c b/arch/x86/pci/i386.c
index ed4ac21..8cd6615 100644
--- a/arch/x86/pci/i386.c
+++ b/arch/x86/pci/i386.c
@@ -32,7 +32,7 @@
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/errno.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/pat.h>
 #include <asm/e820/api.h>
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 9061bab..7ae939e 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -36,9 +36,8 @@
 #include <linux/efi.h>
 #include <linux/efi-bgrt.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
-#include <linux/slab.h>
 #include <linux/memblock.h>
+#include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/uaccess.h>
 #include <linux/time.h>
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index ee5d08f..ef2ffc3 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -23,7 +23,7 @@
 #include <linux/mm.h>
 #include <linux/types.h>
 #include <linux/spinlock.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ioport.h>
 #include <linux/mc146818rtc.h>
 #include <linux/efi.h>
diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
index 7b4854c..bdec6e0 100644
--- a/arch/x86/platform/efi/quirks.c
+++ b/arch/x86/platform/efi/quirks.c
@@ -8,7 +8,6 @@
 #include <linux/efi.h>
 #include <linux/slab.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/acpi.h>
 #include <linux/dmi.h>
 
diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index 140cd76..115c8e4 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -17,7 +17,7 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/of.h>
 #include <linux/of_platform.h>
 #include <linux/of_pdt.h>
diff --git a/arch/x86/power/hibernate_32.c b/arch/x86/power/hibernate_32.c
index afc4ed7..b3dacc7 100644
--- a/arch/x86/power/hibernate_32.c
+++ b/arch/x86/power/hibernate_32.c
@@ -8,7 +8,7 @@
 
 #include <linux/gfp.h>
 #include <linux/suspend.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 749fb4b..ec1394c 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #endif
 #include <linux/cpu.h>
 #include <linux/kexec.h>
diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
index ec7a420..2f6787f 100644
--- a/arch/x86/xen/enlighten_pv.c
+++ b/arch/x86/xen/enlighten_pv.c
@@ -23,7 +23,7 @@
 #include <linux/start_kernel.h>
 #include <linux/sched.h>
 #include <linux/kprobes.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/page-flags.h>
@@ -31,7 +31,6 @@
 #include <linux/console.h>
 #include <linux/pci.h>
 #include <linux/gfp.h>
-#include <linux/memblock.h>
 #include <linux/edd.h>
 #include <linux/frame.h>
 
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index b3e11af..b067317 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -67,7 +67,6 @@
 #include <linux/hash.h>
 #include <linux/sched.h>
 #include <linux/seq_file.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
index 21f13e9..5ca440a 100644
--- a/arch/xtensa/kernel/pci.c
+++ b/arch/xtensa/kernel/pci.c
@@ -24,7 +24,7 @@
 #include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/errno.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <asm/pci-bridge.h>
 #include <asm/platform.h>
diff --git a/arch/xtensa/mm/cache.c b/arch/xtensa/mm/cache.c
index 9220dcd..b27359e 100644
--- a/arch/xtensa/mm/cache.c
+++ b/arch/xtensa/mm/cache.c
@@ -21,7 +21,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/ptrace.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
 
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index f7fbe63..9750a48 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -18,7 +18,7 @@
 
 #include <linux/kernel.h>
 #include <linux/errno.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/gfp.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
diff --git a/arch/xtensa/mm/kasan_init.c b/arch/xtensa/mm/kasan_init.c
index 1a30a25..6b95ca4 100644
--- a/arch/xtensa/mm/kasan_init.c
+++ b/arch/xtensa/mm/kasan_init.c
@@ -8,11 +8,10 @@
  * Copyright (C) 2017 Cadence Design Systems Inc.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init_task.h>
 #include <linux/kasan.h>
 #include <linux/kernel.h>
-#include <linux/memblock.h>
 #include <asm/initialize_mmu.h>
 #include <asm/tlbflush.h>
 #include <asm/traps.h>
diff --git a/arch/xtensa/mm/mmu.c b/arch/xtensa/mm/mmu.c
index f33a1ff..a4dcfd3 100644
--- a/arch/xtensa/mm/mmu.c
+++ b/arch/xtensa/mm/mmu.c
@@ -4,7 +4,7 @@
  *
  * Extracted from init.c
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/percpu.h>
 #include <linux/init.h>
 #include <linux/string.h>
diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index 206b9d4..190846d 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -30,7 +30,7 @@
 #include <linux/etherdevice.h>
 #include <linux/interrupt.h>
 #include <linux/ioctl.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include <linux/platform_device.h>
diff --git a/arch/xtensa/platforms/iss/setup.c b/arch/xtensa/platforms/iss/setup.c
index 58709e8..c14cc67 100644
--- a/arch/xtensa/platforms/iss/setup.c
+++ b/arch/xtensa/platforms/iss/setup.c
@@ -16,7 +16,7 @@
  * option) any later version.
  *
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/stddef.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
diff --git a/block/blk-settings.c b/block/blk-settings.c
index ffd4599..696c04c 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -6,7 +6,7 @@
 #include <linux/init.h>
 #include <linux/bio.h>
 #include <linux/blkdev.h>
-#include <linux/bootmem.h>	/* for max_pfn/max_low_pfn */
+#include <linux/memblock.h>	/* for max_pfn/max_low_pfn */
 #include <linux/gcd.h>
 #include <linux/lcm.h>
 #include <linux/jiffies.h>
diff --git a/block/bounce.c b/block/bounce.c
index bc63b3a..6cba9d2 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -18,7 +18,7 @@
 #include <linux/init.h>
 #include <linux/hash.h>
 #include <linux/highmem.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/printk.h>
 #include <asm/tlbflush.h>
 
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 8516760..2746994 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -27,7 +27,6 @@
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/numa.h>
 #include <linux/nodemask.h>
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index a3d012b..61203ee 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -31,9 +31,8 @@
 #include <linux/irq.h>
 #include <linux/errno.h>
 #include <linux/acpi.h>
-#include <linux/bootmem.h>
-#include <linux/earlycpio.h>
 #include <linux/memblock.h>
+#include <linux/earlycpio.h>
 #include <linux/initrd.h>
 #include "internal.h"
 
diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index dff82a3..3b31ee2 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -16,7 +16,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/pm_runtime.h>
diff --git a/drivers/clk/ti/clk.c b/drivers/clk/ti/clk.c
index a0136ed..8aa5f8f 100644
--- a/drivers/clk/ti/clk.c
+++ b/drivers/clk/ti/clk.c
@@ -23,7 +23,7 @@
 #include <linux/of_address.h>
 #include <linux/list.h>
 #include <linux/regmap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/device.h>
 
 #include "clock.h"
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index f248354..099d83e 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -5,7 +5,7 @@
 #include <linux/ctype.h>
 #include <linux/dmi.h>
 #include <linux/efi.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/random.h>
 #include <asm/dmi.h>
 #include <asm/unaligned.h>
diff --git a/drivers/firmware/efi/apple-properties.c b/drivers/firmware/efi/apple-properties.c
index 2b675f7..ac1654f 100644
--- a/drivers/firmware/efi/apple-properties.c
+++ b/drivers/firmware/efi/apple-properties.c
@@ -20,7 +20,7 @@
 
 #define pr_fmt(fmt) "apple-properties: " fmt
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/efi.h>
 #include <linux/io.h>
 #include <linux/platform_data/x86/apple.h>
diff --git a/drivers/firmware/iscsi_ibft_find.c b/drivers/firmware/iscsi_ibft_find.c
index 2224f1d..72d9ea1 100644
--- a/drivers/firmware/iscsi_ibft_find.c
+++ b/drivers/firmware/iscsi_ibft_find.c
@@ -18,7 +18,7 @@
  * GNU General Public License for more details.
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/blkdev.h>
 #include <linux/ctype.h>
 #include <linux/device.h>
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 03cead6..2a23453 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -19,7 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 
diff --git a/drivers/iommu/mtk_iommu.c b/drivers/iommu/mtk_iommu.c
index f9f69f7..44bd5b9 100644
--- a/drivers/iommu/mtk_iommu.c
+++ b/drivers/iommu/mtk_iommu.c
@@ -11,7 +11,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/bug.h>
 #include <linux/clk.h>
 #include <linux/component.h>
diff --git a/drivers/iommu/mtk_iommu_v1.c b/drivers/iommu/mtk_iommu_v1.c
index 676c029..0e78084 100644
--- a/drivers/iommu/mtk_iommu_v1.c
+++ b/drivers/iommu/mtk_iommu_v1.c
@@ -13,7 +13,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  */
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/bug.h>
 #include <linux/clk.h>
 #include <linux/component.h>
diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index 0069f90..880a81c 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -23,7 +23,7 @@
 #include <linux/kernel.h>
 #include <linux/device.h>
 #include <linux/dmapool.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/vmalloc.h>
 #include <linux/highmem.h>
 #include <linux/jiffies.h>
@@ -38,7 +38,6 @@
 #include <linux/of_irq.h>
 #include <linux/of_platform.h>
 #include <linux/slab.h>
-#include <linux/memblock.h>
 #include <linux/sched/signal.h>
 
 #include <asm/byteorder.h>
diff --git a/drivers/mtd/ar7part.c b/drivers/mtd/ar7part.c
index fc15ec5..0d33cf0 100644
--- a/drivers/mtd/ar7part.c
+++ b/drivers/mtd/ar7part.c
@@ -25,7 +25,7 @@
 
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/module.h>
 
 #include <uapi/linux/magic.h>
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index a07e249..11c5bad 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -33,7 +33,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 38fa60d..28510e3 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -38,7 +38,7 @@
 #include <linux/netdevice.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/io.h>
 
 #include "arcdevice.h"
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 4e56aaf..2c54601 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -34,7 +34,7 @@
 #include <linux/ioport.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 34dd878..48314e9 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -11,7 +11,6 @@
 #include <linux/crc32.h>
 #include <linux/kernel.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/mutex.h>
 #include <linux/of.h>
diff --git a/drivers/of/unittest.c b/drivers/of/unittest.c
index 07c9217..5de5ceb 100644
--- a/drivers/of/unittest.c
+++ b/drivers/of/unittest.c
@@ -5,7 +5,7 @@
 
 #define pr_fmt(fmt) "### dt-test ### " fmt
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/clk.h>
 #include <linux/err.h>
 #include <linux/errno.h>
diff --git a/drivers/s390/char/fs3270.c b/drivers/s390/char/fs3270.c
index 16a4e85..8f3a2ee 100644
--- a/drivers/s390/char/fs3270.c
+++ b/drivers/s390/char/fs3270.c
@@ -8,7 +8,7 @@
  *     Copyright IBM Corp. 2003, 2009
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/console.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
diff --git a/drivers/s390/char/tty3270.c b/drivers/s390/char/tty3270.c
index 5b8af27..2b0c36c2 100644
--- a/drivers/s390/char/tty3270.c
+++ b/drivers/s390/char/tty3270.c
@@ -19,7 +19,7 @@
 #include <linux/workqueue.h>
 
 #include <linux/slab.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/compat.h>
 
 #include <asm/ccwdev.h>
diff --git a/drivers/s390/cio/cmf.c b/drivers/s390/cio/cmf.c
index 8af4948..72dd247 100644
--- a/drivers/s390/cio/cmf.c
+++ b/drivers/s390/cio/cmf.c
@@ -13,7 +13,7 @@
 #define KMSG_COMPONENT "cio"
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/list.h>
diff --git a/drivers/s390/virtio/virtio_ccw.c b/drivers/s390/virtio/virtio_ccw.c
index 8f5c1d7..97b6f19 100644
--- a/drivers/s390/virtio/virtio_ccw.c
+++ b/drivers/s390/virtio/virtio_ccw.c
@@ -9,7 +9,7 @@
 
 #include <linux/kernel_stat.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/err.h>
 #include <linux/virtio.h>
 #include <linux/virtio_config.h>
diff --git a/drivers/sfi/sfi_core.c b/drivers/sfi/sfi_core.c
index 153b3f3..a513690 100644
--- a/drivers/sfi/sfi_core.c
+++ b/drivers/sfi/sfi_core.c
@@ -59,7 +59,7 @@
 #define KMSG_COMPONENT "SFI"
 #define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/errno.h>
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
index 24a5f05..c547e0e 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
@@ -24,7 +24,7 @@
 #include <linux/console.h>
 #include <linux/sysrq.h>
 #include <linux/device.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dma-mapping.h>
 #include <linux/fs_uart_pd.h>
 #include <linux/of_address.h>
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
index 4eba17f..56fc527 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
@@ -19,7 +19,7 @@
 #include <linux/console.h>
 #include <linux/sysrq.h>
 #include <linux/device.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dma-mapping.h>
 
 #include <asm/io.h>
diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
index e3bff06..6a1cd03 100644
--- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
+++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
@@ -19,7 +19,7 @@
 #include <linux/console.h>
 #include <linux/sysrq.h>
 #include <linux/device.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/dma-mapping.h>
 
 #include <asm/io.h>
diff --git a/drivers/usb/early/xhci-dbc.c b/drivers/usb/early/xhci-dbc.c
index 4411404..9d4ee88 100644
--- a/drivers/usb/early/xhci-dbc.c
+++ b/drivers/usb/early/xhci-dbc.c
@@ -12,7 +12,6 @@
 #include <linux/console.h>
 #include <linux/pci_regs.h>
 #include <linux/pci_ids.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/io.h>
 #include <asm/pci-direct.h>
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index e12bb25..a3f5cbf 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -44,7 +44,7 @@
 #include <linux/cred.h>
 #include <linux/errno.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>
 #include <linux/mutex.h>
diff --git a/drivers/xen/events/events_base.c b/drivers/xen/events/events_base.c
index 08e4af0..88ec5f0 100644
--- a/drivers/xen/events/events_base.c
+++ b/drivers/xen/events/events_base.c
@@ -28,7 +28,7 @@
 #include <linux/irq.h>
 #include <linux/moduleparam.h>
 #include <linux/string.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/slab.h>
 #include <linux/irqnr.h>
 #include <linux/pci.h>
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index 7bafa70..16c9ffd 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -33,7 +33,7 @@
 
 #define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 6c13ff4..a8fb7bb 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -35,7 +35,6 @@
 
 #define pr_fmt(fmt) "xen:" KBUILD_MODNAME ": " fmt
 
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/dma-direct.h>
 #include <linux/export.h>
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 55988b8..5165aa8 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -68,7 +68,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/kernel.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/swap.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
diff --git a/fs/dcache.c b/fs/dcache.c
index c2e443f..2593153 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -26,7 +26,7 @@
 #include <linux/export.h>
 #include <linux/security.h>
 #include <linux/seqlock.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/list_lru.h>
diff --git a/fs/inode.c b/fs/inode.c
index 41812a3..db9c263 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -10,7 +10,7 @@
 #include <linux/swap.h>
 #include <linux/security.h>
 #include <linux/cdev.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/fsnotify.h>
 #include <linux/mount.h>
 #include <linux/posix_acl.h>
diff --git a/fs/namespace.c b/fs/namespace.c
index a240e20..8000a71 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -24,7 +24,7 @@
 #include <linux/uaccess.h>
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/task_work.h>
 #include <linux/file.h>
 #include <linux/sched/task.h>
diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index d297fe4..bbcc185 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -22,7 +22,7 @@
 #include <linux/vmalloc.h>
 #include <linux/highmem.h>
 #include <linux/printk.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 792c78a..6c517b1 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -1,5 +1,5 @@
 // SPDX-License-Identifier: GPL-2.0
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/compiler.h>
 #include <linux/fs.h>
 #include <linux/init.h>
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index cbde728..9106b75 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -16,7 +16,7 @@
 #include <linux/slab.h>
 #include <linux/highmem.h>
 #include <linux/printk.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/crash_dump.h>
 #include <linux/list.h>
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
deleted file mode 100644
index b58873a..0000000
--- a/include/linux/bootmem.h
+++ /dev/null
@@ -1,173 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * Discontiguous memory support, Kanoj Sarcar, SGI, Nov 1999
- */
-#ifndef _LINUX_BOOTMEM_H
-#define _LINUX_BOOTMEM_H
-
-#include <linux/mmzone.h>
-#include <linux/mm_types.h>
-#include <asm/dma.h>
-#include <asm/processor.h>
-
-/*
- *  simple boot-time physical memory area allocator.
- */
-
-extern unsigned long max_low_pfn;
-extern unsigned long min_low_pfn;
-
-/*
- * highest page
- */
-extern unsigned long max_pfn;
-/*
- * highest possible page
- */
-extern unsigned long long max_possible_pfn;
-
-extern unsigned long memblock_free_all(void);
-extern void reset_node_managed_pages(pg_data_t *pgdat);
-extern void reset_all_zones_managed_pages(void);
-
-/* We are using top down, so it is safe to use 0 here */
-#define BOOTMEM_LOW_LIMIT 0
-
-#ifndef ARCH_LOW_ADDRESS_LIMIT
-#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
-#endif
-
-/* FIXME: use MEMBLOCK_ALLOC_* variants here */
-#define BOOTMEM_ALLOC_ACCESSIBLE	0
-#define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
-
-/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
-void *memblock_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
-				      phys_addr_t min_addr,
-				      phys_addr_t max_addr, int nid);
-void *memblock_alloc_try_nid_nopanic(phys_addr_t size,
-		phys_addr_t align, phys_addr_t min_addr,
-		phys_addr_t max_addr, int nid);
-void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
-		phys_addr_t min_addr, phys_addr_t max_addr, int nid);
-void __memblock_free_early(phys_addr_t base, phys_addr_t size);
-void __memblock_free_late(phys_addr_t base, phys_addr_t size);
-
-static inline void * __init memblock_alloc(
-					phys_addr_t size,  phys_addr_t align)
-{
-	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
-					    BOOTMEM_ALLOC_ACCESSIBLE,
-					    NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_raw(
-					phys_addr_t size,  phys_addr_t align)
-{
-	return memblock_alloc_try_nid_raw(size, align, BOOTMEM_LOW_LIMIT,
-					    BOOTMEM_ALLOC_ACCESSIBLE,
-					    NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_from(
-		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
-{
-	return memblock_alloc_try_nid(size, align, min_addr,
-				      BOOTMEM_ALLOC_ACCESSIBLE,
-				      NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_nopanic(
-					phys_addr_t size, phys_addr_t align)
-{
-	return memblock_alloc_try_nid_nopanic(size, align,
-						    BOOTMEM_LOW_LIMIT,
-						    BOOTMEM_ALLOC_ACCESSIBLE,
-						    NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_low(
-					phys_addr_t size, phys_addr_t align)
-{
-	return memblock_alloc_try_nid(size, align,
-						   BOOTMEM_LOW_LIMIT,
-						   ARCH_LOW_ADDRESS_LIMIT,
-						   NUMA_NO_NODE);
-}
-static inline void * __init memblock_alloc_low_nopanic(
-					phys_addr_t size, phys_addr_t align)
-{
-	return memblock_alloc_try_nid_nopanic(size, align,
-						   BOOTMEM_LOW_LIMIT,
-						   ARCH_LOW_ADDRESS_LIMIT,
-						   NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_from_nopanic(
-		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
-{
-	return memblock_alloc_try_nid_nopanic(size, align, min_addr,
-						    BOOTMEM_ALLOC_ACCESSIBLE,
-						    NUMA_NO_NODE);
-}
-
-static inline void * __init memblock_alloc_node(
-		phys_addr_t size, phys_addr_t align, int nid)
-{
-	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
-					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
-}
-
-static inline void * __init memblock_alloc_node_nopanic(
-						phys_addr_t size, int nid)
-{
-	return memblock_alloc_try_nid_nopanic(size, 0, BOOTMEM_LOW_LIMIT,
-						    BOOTMEM_ALLOC_ACCESSIBLE,
-						    nid);
-}
-
-static inline void __init memblock_free_early(
-					phys_addr_t base, phys_addr_t size)
-{
-	__memblock_free_early(base, size);
-}
-
-static inline void __init memblock_free_early_nid(
-				phys_addr_t base, phys_addr_t size, int nid)
-{
-	__memblock_free_early(base, size);
-}
-
-static inline void __init memblock_free_late(
-					phys_addr_t base, phys_addr_t size)
-{
-	__memblock_free_late(base, size);
-}
-
-extern void *alloc_large_system_hash(const char *tablename,
-				     unsigned long bucketsize,
-				     unsigned long numentries,
-				     int scale,
-				     int flags,
-				     unsigned int *_hash_shift,
-				     unsigned int *_hash_mask,
-				     unsigned long low_limit,
-				     unsigned long high_limit);
-
-#define HASH_EARLY	0x00000001	/* Allocating during early boot? */
-#define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
-					 * shift passed via *_hash_shift */
-#define HASH_ZERO	0x00000004	/* Zero allocated hash table */
-
-/* Only NUMA needs hash distribution. 64bit NUMA architectures have
- * sufficient vmalloc space.
- */
-#ifdef CONFIG_NUMA
-#define HASHDIST_DEFAULT IS_ENABLED(CONFIG_64BIT)
-extern int hashdist;		/* Distribute hashes across NUMA nodes? */
-#else
-#define hashdist (0)
-#endif
-
-
-#endif /* _LINUX_BOOTMEM_H */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f16833c..d3bc270 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -15,6 +15,19 @@
 
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <asm/dma.h>
+
+extern unsigned long max_low_pfn;
+extern unsigned long min_low_pfn;
+
+/*
+ * highest page
+ */
+extern unsigned long max_pfn;
+/*
+ * highest possible page
+ */
+extern unsigned long long max_possible_pfn;
 
 #define INIT_MEMBLOCK_REGIONS	128
 #define INIT_PHYSMEM_REGIONS	4
@@ -119,6 +132,10 @@ int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
 enum memblock_flags choose_memblock_flags(void);
 
+unsigned long memblock_free_all(void);
+void reset_node_managed_pages(pg_data_t *pgdat);
+void reset_all_zones_managed_pages(void);
+
 /* Low level functions */
 int memblock_add_range(struct memblock_type *type,
 		       phys_addr_t base, phys_addr_t size,
@@ -315,11 +332,116 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+/* Flags for memblock allocation APIs */
+#define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
+#define MEMBLOCK_ALLOC_ACCESSIBLE	0
+
+/* We are using top down, so it is safe to use 0 here */
+#define MEMBLOCK_LOW_LIMIT 0
+
+#ifndef ARCH_LOW_ADDRESS_LIMIT
+#define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
+#endif
+
 phys_addr_t memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
 phys_addr_t memblock_phys_alloc(phys_addr_t size, phys_addr_t align);
 
+void *memblock_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
+				 phys_addr_t min_addr, phys_addr_t max_addr,
+				 int nid);
+void *memblock_alloc_try_nid_nopanic(phys_addr_t size, phys_addr_t align,
+				     phys_addr_t min_addr, phys_addr_t max_addr,
+				     int nid);
+void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+			     phys_addr_t min_addr, phys_addr_t max_addr,
+			     int nid);
+
+static inline void * __init memblock_alloc(phys_addr_t size,  phys_addr_t align)
+{
+	return memblock_alloc_try_nid(size, align, MEMBLOCK_LOW_LIMIT,
+				      MEMBLOCK_ALLOC_ACCESSIBLE, NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_raw(phys_addr_t size,
+					       phys_addr_t align)
+{
+	return memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
+					  MEMBLOCK_ALLOC_ACCESSIBLE,
+					  NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_from(phys_addr_t size,
+						phys_addr_t align,
+						phys_addr_t min_addr)
+{
+	return memblock_alloc_try_nid(size, align, min_addr,
+				      MEMBLOCK_ALLOC_ACCESSIBLE, NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_nopanic(phys_addr_t size,
+						   phys_addr_t align)
+{
+	return memblock_alloc_try_nid_nopanic(size, align, MEMBLOCK_LOW_LIMIT,
+					      MEMBLOCK_ALLOC_ACCESSIBLE,
+					      NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_low(phys_addr_t size,
+					       phys_addr_t align)
+{
+	return memblock_alloc_try_nid(size, align, MEMBLOCK_LOW_LIMIT,
+				      ARCH_LOW_ADDRESS_LIMIT, NUMA_NO_NODE);
+}
+static inline void * __init memblock_alloc_low_nopanic(phys_addr_t size,
+						       phys_addr_t align)
+{
+	return memblock_alloc_try_nid_nopanic(size, align, MEMBLOCK_LOW_LIMIT,
+					      ARCH_LOW_ADDRESS_LIMIT,
+					      NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_from_nopanic(phys_addr_t size,
+							phys_addr_t align,
+							phys_addr_t min_addr)
+{
+	return memblock_alloc_try_nid_nopanic(size, align, min_addr,
+					      MEMBLOCK_ALLOC_ACCESSIBLE,
+					      NUMA_NO_NODE);
+}
+
+static inline void * __init memblock_alloc_node(phys_addr_t size,
+						phys_addr_t align, int nid)
+{
+	return memblock_alloc_try_nid(size, align, MEMBLOCK_LOW_LIMIT,
+				      MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+}
+
+static inline void * __init memblock_alloc_node_nopanic(phys_addr_t size,
+							int nid)
+{
+	return memblock_alloc_try_nid_nopanic(size, 0, MEMBLOCK_LOW_LIMIT,
+					      MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+}
+
+static inline void __init memblock_free_early(phys_addr_t base,
+					      phys_addr_t size)
+{
+	__memblock_free_early(base, size);
+}
+
+static inline void __init memblock_free_early_nid(phys_addr_t base,
+						  phys_addr_t size, int nid)
+{
+	__memblock_free_early(base, size);
+}
+
+static inline void __init memblock_free_late(phys_addr_t base, phys_addr_t size)
+{
+	__memblock_free_late(base, size);
+}
+
 /*
  * Set the allocation direction to bottom-up or top-down.
  */
@@ -338,10 +460,6 @@ static inline bool memblock_bottom_up(void)
 	return memblock.bottom_up;
 }
 
-/* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
-#define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
-#define MEMBLOCK_ALLOC_ACCESSIBLE	0
-
 phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
 					phys_addr_t start, phys_addr_t end,
 					enum memblock_flags flags);
@@ -447,6 +565,31 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	     i < memblock_type->cnt;					\
 	     i++, rgn = &memblock_type->regions[i])
 
+extern void *alloc_large_system_hash(const char *tablename,
+				     unsigned long bucketsize,
+				     unsigned long numentries,
+				     int scale,
+				     int flags,
+				     unsigned int *_hash_shift,
+				     unsigned int *_hash_mask,
+				     unsigned long low_limit,
+				     unsigned long high_limit);
+
+#define HASH_EARLY	0x00000001	/* Allocating during early boot? */
+#define HASH_SMALL	0x00000002	/* sub-page allocation allowed, min
+					 * shift passed via *_hash_shift */
+#define HASH_ZERO	0x00000004	/* Zero allocated hash table */
+
+/* Only NUMA needs hash distribution. 64bit NUMA architectures have
+ * sufficient vmalloc space.
+ */
+#ifdef CONFIG_NUMA
+#define HASHDIST_DEFAULT IS_ENABLED(CONFIG_64BIT)
+extern int hashdist;		/* Distribute hashes across NUMA nodes? */
+#else
+#define hashdist (0)
+#endif
+
 #ifdef CONFIG_MEMTEST
 extern void early_memtest(phys_addr_t start, phys_addr_t end);
 #else
diff --git a/init/main.c b/init/main.c
index 99a9e99..473b554 100644
--- a/init/main.c
+++ b/init/main.c
@@ -25,7 +25,7 @@
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <linux/initrd.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/acpi.h>
 #include <linux/console.h>
 #include <linux/nmi.h>
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index d9fd062..7d83707 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -39,7 +39,7 @@
 #include <asm/dma.h>
 
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/iommu-helper.h>
 
 #define CREATE_TRACE_POINTS
diff --git a/kernel/futex.c b/kernel/futex.c
index 11fc3bb..2f82a24 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -65,7 +65,7 @@
 #include <linux/sched/mm.h>
 #include <linux/hugetlb.h>
 #include <linux/freezer.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/fault-inject.h>
 
 #include <asm/futex.h>
diff --git a/kernel/locking/qspinlock_paravirt.h b/kernel/locking/qspinlock_paravirt.h
index 5a0cf5f..1c960f5 100644
--- a/kernel/locking/qspinlock_paravirt.h
+++ b/kernel/locking/qspinlock_paravirt.h
@@ -4,7 +4,7 @@
 #endif
 
 #include <linux/hash.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/debug_locks.h>
 
 /*
diff --git a/kernel/pid.c b/kernel/pid.c
index cdf63e5..b2f6c50 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -31,7 +31,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/rculist.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/hash.h>
 #include <linux/pid_namespace.h>
 #include <linux/init_task.h>
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 34116a6..3c9e365 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -23,7 +23,7 @@
 #include <linux/pm.h>
 #include <linux/device.h>
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/nmi.h>
 #include <linux/syscalls.h>
 #include <linux/console.h>
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 3efcbe518..54ebe01 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -29,7 +29,6 @@
 #include <linux/delay.h>
 #include <linux/smp.h>
 #include <linux/security.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/syscalls.h>
 #include <linux/crash_core.h>
diff --git a/kernel/profile.c b/kernel/profile.c
index 9aa2a44..9c08a2c 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -16,7 +16,7 @@
 
 #include <linux/export.h>
 #include <linux/profile.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/notifier.h>
 #include <linux/mm.h>
 #include <linux/cpumask.h>
diff --git a/lib/cpumask.c b/lib/cpumask.c
index 1405cb2..75b5e76 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -4,7 +4,7 @@
 #include <linux/bitops.h>
 #include <linux/cpumask.h>
 #include <linux/export.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 /**
  * cpumask_next - get the next cpu in a cpumask
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67629dc..10b360e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -15,7 +15,6 @@
 #include <linux/compiler.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/sysfs.h>
 #include <linux/slab.h>
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 785a970..c7550eb 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -10,11 +10,10 @@
  *
  */
 
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/init.h>
 #include <linux/kasan.h>
 #include <linux/kernel.h>
-#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/pfn.h>
 #include <linux/slab.h>
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 4f7e4b5..877de4f 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -92,7 +92,7 @@
 #include <linux/stacktrace.h>
 #include <linux/cache.h>
 #include <linux/percpu.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/pfn.h>
 #include <linux/mmzone.h>
 #include <linux/slab.h>
diff --git a/mm/memblock.c b/mm/memblock.c
index 86a4b80..32e5c62 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -20,7 +20,6 @@
 #include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 
 #include <asm/sections.h>
 #include <linux/io.h>
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b7..7687271 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -33,7 +33,6 @@
 #include <linux/stop_machine.h>
 #include <linux/hugetlb.h>
 #include <linux/memblock.h>
-#include <linux/bootmem.h>
 #include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f4a8bc8..511447a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -20,7 +20,6 @@
 #include <linux/interrupt.h>
 #include <linux/pagemap.h>
 #include <linux/jiffies.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/compiler.h>
 #include <linux/kernel.h>
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 5323c2a..ae44f7a 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/mm.h>
 #include <linux/mmzone.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/page_ext.h>
 #include <linux/memory.h>
 #include <linux/vmalloc.h>
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 6302bc6..b9e4b42 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -1,6 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/init.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/fs.h>
 #include <linux/sysfs.h>
 #include <linux/kobject.h>
diff --git a/mm/page_owner.c b/mm/page_owner.c
index c2494f0..dd7b290 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -3,7 +3,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/stacktrace.h>
 #include <linux/page_owner.h>
 #include <linux/jump_label.h>
diff --git a/mm/percpu.c b/mm/percpu.c
index 86bb9f6..cac9d2f 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -65,7 +65,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/bitmap.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/err.h>
 #include <linux/lcm.h>
 #include <linux/list.h>
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 7408cab..7fec057 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -20,7 +20,6 @@
  */
 #include <linux/mm.h>
 #include <linux/mmzone.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/memremap.h>
 #include <linux/highmem.h>
diff --git a/mm/sparse.c b/mm/sparse.c
index 0dcc306..c0788e3 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -5,7 +5,6 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/mmzone.h>
-#include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/compiler.h>
 #include <linux/highmem.h>
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index f5c9ef2..411dd7a 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -19,7 +19,7 @@
 #include <linux/slab.h>
 #include <linux/wait.h>
 #include <linux/vmalloc.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 
 #include <net/addrconf.h>
 #include <net/inet_connection_sock.h>
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 67670fa..a74a4a7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -262,7 +262,7 @@
 #include <linux/net.h>
 #include <linux/socket.h>
 #include <linux/random.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/cache.h>
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f4e35b2..5852044 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -81,7 +81,7 @@
 
 #include <linux/uaccess.h>
 #include <asm/ioctls.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/types.h>
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e948db2..9b277bd 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -46,7 +46,7 @@
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
 #include <linux/seq_file.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/highmem.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
index 2ad33ce..eca8d84 100644
--- a/net/xfrm/xfrm_hash.c
+++ b/net/xfrm/xfrm_hash.c
@@ -6,7 +6,7 @@
 
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
 #include <linux/xfrm.h>
-- 
2.7.4
