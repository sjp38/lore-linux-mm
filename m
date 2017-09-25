From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [RFC v1 1/2] VS1544 KSM generic memory comparison functions
Date: Mon, 25 Sep 2017 10:46:13 +0200
Message-ID: <1506329174-19265-2-git-send-email-imbrenda@linux.vnet.ibm.com>
References: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: borntraeger@de.ibm.com, kvm@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, akpm@linux-foundation.org, aarcange@redhat.com, mingo@kernel.org, zhongjiang@huawei.com, kirill.shutemov@linux.intel.com, arvind.yadav.cs@gmail.com, solee@os.korea.ac.kr, ak@linux.intel.com
List-Id: linux-mm.kvack.org

This is just a refactoring of the existing code:

* Split the page checksum and page comparison functions from ksm.c into
  a new asm-generic header (page_memops.h)

* Add a line in every Kbuild of every arch, to use the generic version
  of page_memops.h

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 arch/alpha/include/asm/Kbuild      |  1 +
 arch/arc/include/asm/Kbuild        |  1 +
 arch/arm/include/asm/Kbuild        |  1 +
 arch/arm64/include/asm/Kbuild      |  1 +
 arch/blackfin/include/asm/Kbuild   |  1 +
 arch/c6x/include/asm/Kbuild        |  1 +
 arch/cris/include/asm/Kbuild       |  1 +
 arch/frv/include/asm/Kbuild        |  1 +
 arch/h8300/include/asm/Kbuild      |  1 +
 arch/hexagon/include/asm/Kbuild    |  1 +
 arch/ia64/include/asm/Kbuild       |  1 +
 arch/m32r/include/asm/Kbuild       |  1 +
 arch/m68k/include/asm/Kbuild       |  1 +
 arch/metag/include/asm/Kbuild      |  1 +
 arch/microblaze/include/asm/Kbuild |  1 +
 arch/mips/include/asm/Kbuild       |  1 +
 arch/mn10300/include/asm/Kbuild    |  1 +
 arch/nios2/include/asm/Kbuild      |  1 +
 arch/openrisc/include/asm/Kbuild   |  1 +
 arch/parisc/include/asm/Kbuild     |  1 +
 arch/powerpc/include/asm/Kbuild    |  1 +
 arch/s390/include/asm/Kbuild       |  1 +
 arch/score/include/asm/Kbuild      |  1 +
 arch/sh/include/asm/Kbuild         |  1 +
 arch/sparc/include/asm/Kbuild      |  1 +
 arch/tile/include/asm/Kbuild       |  1 +
 arch/um/include/asm/Kbuild         |  1 +
 arch/unicore32/include/asm/Kbuild  |  1 +
 arch/x86/include/asm/Kbuild        |  1 +
 arch/xtensa/include/asm/Kbuild     |  1 +
 include/asm-generic/page_memops.h  | 31 +++++++++++++++++++++++++++++++
 mm/ksm.c                           | 27 +++------------------------
 32 files changed, 64 insertions(+), 24 deletions(-)
 create mode 100644 include/asm-generic/page_memops.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index d103db5..ad3bbfd 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -6,6 +6,7 @@ generic-y += export.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 353dae3..7039177 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += msi.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += pci.h
 generic-y += percpu.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 721ab5e..ce1c939 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -10,6 +10,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mm-arch-hooks.h
 generic-y += msi.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += preempt.h
 generic-y += rwsem.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index f81c7b6..c6070f3 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += msi.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += segment.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index fe73697..c450957 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += percpu.h
 generic-y += pgalloc.h
 generic-y += preempt.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index d717329..69e46f6 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -23,6 +23,7 @@ generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += mmu.h
 generic-y += mmu_context.h
+generic-y += page_memops.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += pgalloc.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 460349c..4d274ad 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += sections.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 2cf7648..c767527 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -7,6 +7,7 @@ generic-y += fb.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index bc07749..f877554 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -31,6 +31,7 @@ generic-y += mm-arch-hooks.h
 generic-y += mmu.h
 generic-y += mmu_context.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += pgalloc.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 3401368..75a8ae4 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 1d7641f..5c28f3a 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -3,6 +3,7 @@ generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vtime.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 7e11b12..07096a2 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -7,6 +7,7 @@ generic-y += kprobes.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 59d6d0d..73b48b4 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += sections.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 3fba97e..9d33550 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 9d66f77..34bd980 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -20,6 +20,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 7c8aab2..119854c8 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -9,6 +9,7 @@ generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index db5b578..302d58f 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -8,6 +8,7 @@ generic-y += fb.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index 896c26a..819ae2c 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -26,6 +26,7 @@ generic-y += local.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 5bea416..f123dd3 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -25,6 +25,7 @@ generic-y += local.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index a411395..875c2c2 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -14,6 +14,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += seccomp.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 5c4fbc8..66f5c0b 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index b3c8847..e68b429 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -14,6 +14,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 54b3b20..ea172d3 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += extable.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 1a6f9c3..10fd909 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -10,6 +10,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 80ddc01..17817e5 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -14,6 +14,7 @@ generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += serial.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index d28d2b8..6e6da6c 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -11,6 +11,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += preempt.h
 generic-y += seccomp.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 50a32c3..fcb3f70 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -17,6 +17,7 @@ generic-y += irq_work.h
 generic-y += kdebug.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += param.h
 generic-y += pci.h
 generic-y += percpu.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index fda7e21..4908550 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += local.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
+generic-y += page_memops.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 5d6a53f..669409d30 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index dff7cc3..1b97064 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -18,6 +18,7 @@ generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += page_memops.h
 generic-y += param.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/include/asm-generic/page_memops.h b/include/asm-generic/page_memops.h
new file mode 100644
index 0000000..fd14160
--- /dev/null
+++ b/include/asm-generic/page_memops.h
@@ -0,0 +1,31 @@
+#ifndef _ASM_GENERIC_PAGE_MEMOPS_H
+#define _ASM_GENERIC_PAGE_MEMOPS_H
+
+#include <linux/mm_types.h>
+#include <linux/highmem.h>
+#include <linux/jhash.h>
+
+static inline u32 calc_page_checksum(struct page *page)
+{
+	void *addr = kmap_atomic(page);
+	u32 checksum;
+
+	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	kunmap_atomic(addr);
+	return checksum;
+}
+
+static inline int memcmp_pages(struct page *page1, struct page *page2)
+{
+	char *addr1, *addr2;
+	int ret;
+
+	addr1 = kmap_atomic(page1);
+	addr2 = kmap_atomic(page2);
+	ret = memcmp(addr1, addr2, PAGE_SIZE);
+	kunmap_atomic(addr2);
+	kunmap_atomic(addr1);
+	return ret;
+}
+
+#endif
diff --git a/mm/ksm.c b/mm/ksm.c
index db20f84..3de568c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -41,6 +41,7 @@
 #include <linux/numa.h>
 
 #include <asm/tlbflush.h>
+#include <asm/page_memops.h>
 #include "internal.h"
 
 #ifdef CONFIG_NUMA
@@ -982,28 +983,6 @@ static int unmerge_and_remove_all_rmap_items(void)
 }
 #endif /* CONFIG_SYSFS */
 
-static u32 calc_checksum(struct page *page)
-{
-	u32 checksum;
-	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
-	kunmap_atomic(addr);
-	return checksum;
-}
-
-static int memcmp_pages(struct page *page1, struct page *page2)
-{
-	char *addr1, *addr2;
-	int ret;
-
-	addr1 = kmap_atomic(page1);
-	addr2 = kmap_atomic(page2);
-	ret = memcmp(addr1, addr2, PAGE_SIZE);
-	kunmap_atomic(addr2);
-	kunmap_atomic(addr1);
-	return ret;
-}
-
 static inline int pages_identical(struct page *page1, struct page *page2)
 {
 	return !memcmp_pages(page1, page2);
@@ -2049,7 +2028,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	 * don't want to insert it in the unstable tree, and we don't want
 	 * to waste our time searching for something identical to it there.
 	 */
-	checksum = calc_checksum(page);
+	checksum = calc_page_checksum(page);
 	if (rmap_item->oldchecksum != checksum) {
 		rmap_item->oldchecksum = checksum;
 		return;
@@ -3055,7 +3034,7 @@ static int __init ksm_init(void)
 	int err;
 
 	/* The correct value depends on page size and endianness */
-	zero_checksum = calc_checksum(ZERO_PAGE(0));
+	zero_checksum = calc_page_checksum(ZERO_PAGE(0));
 	/* Default to false for backwards compatibility */
 	ksm_use_zero_pages = false;
 
-- 
2.7.4
