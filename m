Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20F8EC4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8C4021924
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 12:59:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="L9GUFdT6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C4021924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCBFB6B02A5; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B58F96B02AA; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F9B36B02A9; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD856B02A5
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 08:59:36 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0D85F8768
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:36 +0000 (UTC)
X-FDA: 75948047952.17.rice42_53af53a49a361
X-HE-Tag: rice42_53af53a49a361
X-Filterd-Recvd-Size: 19881
Received: from pio-pvt-msa2.bahnhof.se (pio-pvt-msa2.bahnhof.se [79.136.2.41])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 12:59:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 52BE43FBB0;
	Wed, 18 Sep 2019 14:59:28 +0200 (CEST)
Authentication-Results: pio-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=L9GUFdT6;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J6g-nBY-BBV3; Wed, 18 Sep 2019 14:59:27 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id AAB473F746;
	Wed, 18 Sep 2019 14:59:24 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 18D413602D9;
	Wed, 18 Sep 2019 14:59:24 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568811564; bh=8endBo4LYeRXjKpQW+eclcRDwX2DG11DoosCTAG8UE8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=L9GUFdT6PefsBIiZsfCr9qPb1w/PpHYQ2WRSZi1zMMn55SxVWMIdnNaO7Vbs5y0qP
	 qfN0To//3d1Rit4sPvLhpO15DQnew7ORKTsQrwVjlJALXDaqs3pJaO2aTIzZMjUzsY
	 e+1uzuDjV2GxMtg49NJOxESG8d8iVnRQBq6Vccso=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thomas_os@shipmail.org>
To: linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org
Cc: pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 1/7] mm: Add write-protect and clean utilities for address space ranges
Date: Wed, 18 Sep 2019 14:59:08 +0200
Message-Id: <20190918125914.38497-2-thomas_os@shipmail.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190918125914.38497-1-thomas_os@shipmail.org>
References: <20190918125914.38497-1-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

Add two utilities to a) write-protect and b) clean all ptes pointing into
a range of an address space.
The utilities are intended to aid in tracking dirty pages (either
driver-allocated system memory or pci device memory).
The write-protect utility should be used in conjunction with
page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
accesses. Typically one would want to use this on sparse accesses into
large memory regions. The clean utility should be used to utilize
hardware dirtying functionality and avoid the overhead of page-faults,
typically on large accesses into small memory regions.

The added file "as_dirty_helpers.c" is initially listed as maintained by
VMware under our DRM driver. If somebody would like it elsewhere,
that's of course no problem.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
---
 MAINTAINERS           |   1 +
 include/linux/mm.h    |  13 +-
 mm/Kconfig            |   3 +
 mm/Makefile           |   1 +
 mm/as_dirty_helpers.c | 392 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 409 insertions(+), 1 deletion(-)
 create mode 100644 mm/as_dirty_helpers.c

diff --git a/MAINTAINERS b/MAINTAINERS
index c2d975da561f..b596c7cf4a85 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5287,6 +5287,7 @@ T:	git git://people.freedesktop.org/~thomash/linux
 S:	Supported
 F:	drivers/gpu/drm/vmwgfx/
 F:	include/uapi/drm/vmwgfx_drm.h
+F:	mm/as_dirty_helpers.c
=20
 DRM DRIVERS
 M:	David Airlie <airlied@linux.ie>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..27ff341ecbdc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2657,7 +2657,6 @@ typedef int (*pte_fn_t)(pte_t *pte, unsigned long a=
ddr, void *data);
 extern int apply_to_page_range(struct mm_struct *mm, unsigned long addre=
ss,
 			       unsigned long size, pte_fn_t fn, void *data);
=20
-
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
 extern void kernel_poison_pages(struct page *page, int numpages, int ena=
ble);
@@ -2891,5 +2890,17 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
=20
+#ifdef CONFIG_AS_DIRTY_HELPERS
+unsigned long apply_as_clean(struct address_space *mapping,
+			     pgoff_t first_index, pgoff_t nr,
+			     pgoff_t bitmap_pgoff,
+			     unsigned long *bitmap,
+			     pgoff_t *start,
+			     pgoff_t *end);
+
+unsigned long apply_as_wrprotect(struct address_space *mapping,
+				 pgoff_t first_index, pgoff_t nr);
+#endif
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 56cec636a1fc..594350e9d78e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -736,4 +736,7 @@ config ARCH_HAS_PTE_SPECIAL
 config ARCH_HAS_HUGEPD
 	bool
=20
+config AS_DIRTY_HELPERS
+        bool
+
 endmenu
diff --git a/mm/Makefile b/mm/Makefile
index d0b295c3b764..4086f1eefbc6 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -105,3 +105,4 @@ obj-$(CONFIG_PERCPU_STATS) +=3D percpu-stats.o
 obj-$(CONFIG_ZONE_DEVICE) +=3D memremap.o
 obj-$(CONFIG_HMM_MIRROR) +=3D hmm.o
 obj-$(CONFIG_MEMFD_CREATE) +=3D memfd.o
+obj-$(CONFIG_AS_DIRTY_HELPERS) +=3D as_dirty_helpers.o
diff --git a/mm/as_dirty_helpers.c b/mm/as_dirty_helpers.c
new file mode 100644
index 000000000000..d4cc37dcb144
--- /dev/null
+++ b/mm/as_dirty_helpers.c
@@ -0,0 +1,392 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/mm.h>
+#include <linux/mm_types.h>
+#include <linux/hugetlb.h>
+#include <linux/bitops.h>
+#include <linux/mmu_notifier.h>
+#include <asm/cacheflush.h>
+#include <asm/tlbflush.h>
+
+/**
+ * struct as_walk - Argument to struct as_walk_ops callbacks.
+ * @vma: Pointer to the struct vmw_area_struct currently being walked.
+ *
+ * Embeddable argument to struct as_walk_ops callbacks.
+ */
+struct as_walk {
+	struct vm_area_struct *vma;
+};
+
+/**
+ * struct as_walk_ops - Callbacks for entries of various page table leve=
ls.
+ * extend for additional level support.
+ */
+struct as_walk_ops {
+	/**
+	 * pte-entry: Callback for PTEs
+	 * @pte: Pointer to the PTE.
+	 * @addr: Virtual address.
+	 * @asw: Struct as_walk argument for the walk. Embed for additional
+	 * data.
+	 */
+	void (*const pte_entry) (pte_t *pte, unsigned long addr,
+				 struct as_walk *asw);
+};
+
+/* Page-walking code */
+static void walk_as_pte_range(pmd_t *pmd, unsigned long addr, unsigned l=
ong end,
+			      const struct as_walk_ops *ops,
+			      struct as_walk *asw)
+{
+	struct mm_struct *mm =3D asw->vma->vm_mm;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte =3D (mm =3D=3D &init_mm) ?
+		pte_offset_kernel(pmd, addr) :
+		pte_offset_map_lock(mm, pmd, addr, &ptl);
+
+	arch_enter_lazy_mmu_mode();
+
+	do {
+		ops->pte_entry(pte++, addr, asw);
+	} while (addr +=3D PAGE_SIZE, addr !=3D end);
+
+	arch_leave_lazy_mmu_mode();
+
+	if (mm !=3D &init_mm)
+		pte_unmap_unlock(pte - 1, ptl);
+}
+
+static void walk_as_pmd_range(pud_t *pud, unsigned long addr, unsigned l=
ong end,
+			      const struct as_walk_ops *ops,
+			      struct as_walk *asw)
+{
+	pmd_t *pmd =3D pmd_offset(pud, addr);
+	unsigned long next;
+
+	do {
+		next =3D pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		if (WARN_ON(pmd_huge(*pmd)))
+			continue;
+		walk_as_pte_range(pmd, addr, next, ops, asw);
+	} while (pmd++, addr =3D next, addr !=3D end);
+}
+
+static void walk_as_pud_range(p4d_t *p4d, unsigned long addr, unsigned l=
ong end,
+			      const struct as_walk_ops *ops,
+			      struct as_walk *asw)
+{
+	pud_t *pud =3D pud_offset(p4d, addr);
+	unsigned long next;
+
+	do {
+		next =3D pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		if (WARN_ON(pud_huge(*pud)))
+			continue;
+		walk_as_pmd_range(pud, addr, next, ops, asw);
+	} while (pud++, addr =3D next, addr !=3D end);
+}
+
+static void walk_as_p4d_range(pgd_t *pgd, unsigned long addr, unsigned l=
ong end,
+			      const struct as_walk_ops *ops,
+			      struct as_walk *asw)
+{
+	p4d_t *p4d =3D p4d_offset(pgd, addr);
+	unsigned long next;
+
+	do {
+		next =3D p4d_addr_end(addr, end);
+		if (p4d_none_or_clear_bad(p4d))
+			continue;
+		walk_as_pud_range(p4d, addr, next, ops, asw);
+	} while (p4d++, addr =3D next, addr !=3D end);
+}
+
+static void walk_as_pfn_range(unsigned long addr, unsigned long end,
+			      const struct as_walk_ops *ops,
+			      struct as_walk *asw)
+{
+	pgd_t *pgd =3D pgd_offset(asw->vma->vm_mm, addr);
+	unsigned long next;
+
+	do {
+		next =3D pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		walk_as_p4d_range(pgd, addr, next, ops, asw);
+	} while (pgd++, addr =3D next, addr !=3D end);
+}
+
+
+/**
+ * struct as_walk_range - Argument for apply_as_range
+ * @asw: The struct as_walk we embed for the page walk
+ * @start: Address of first modified pte
+ * @end: Address of last modified pte + 1
+ * @total: Total number of modified ptes
+ */
+struct as_walk_range {
+	struct as_walk base;
+	unsigned long start;
+	unsigned long end;
+	unsigned long total;
+};
+
+#define to_as_walk_range(_asw) container_of(_asw, struct as_walk_range, =
base)
+
+/**
+ * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
+ * @pte: Pointer to the pte
+ * @addr: The virtual page address
+ * @asw: Pointer to a struct as_walk embedded in a struct as_walk_range
+ *
+ * The function write-protects a pte and records the range in
+ * virtual address space of touched ptes for efficient range TLB flushes=
.
+ */
+static void apply_pt_wrprotect(pte_t *pte, unsigned long addr,
+			       struct as_walk *asw)
+{
+	struct as_walk_range *awr =3D to_as_walk_range(asw);
+	pte_t ptent =3D *pte;
+
+	if (pte_write(ptent)) {
+		pte_t old_pte =3D ptep_modify_prot_start(asw->vma, addr, pte);
+
+		ptent =3D pte_wrprotect(old_pte);
+		ptep_modify_prot_commit(asw->vma, addr, pte, old_pte, ptent);
+		awr->total++;
+		awr->start =3D min(awr->start, addr);
+		awr->end =3D max(awr->end, addr + PAGE_SIZE);
+	}
+}
+
+/**
+ * struct as_walk_clean - Argument structure for apply_pt_clean
+ * @base: struct as_walk we derive from
+ * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
+ * @bitmap: Bitmap with one bit for each page offset in the address_spac=
e range
+ * covered.
+ * @start: Address_space page offset of first modified pte relative
+ * to @bitmap_pgoff
+ * @end: Address_space page offset of last modified pte relative
+ * to @bitmap_pgoff
+ */
+struct as_walk_clean {
+	struct as_walk_range base;
+	pgoff_t bitmap_pgoff;
+	unsigned long *bitmap;
+	pgoff_t start;
+	pgoff_t end;
+};
+
+#define to_as_walk_clean(_awr) container_of(_awr, struct as_walk_clean, =
base)
+
+/**
+ * apply_pt_clean - Leaf pte callback to clean a pte
+ * @pte: Pointer to the pte
+ * @addr: The virtual page address
+ * @asw: Pointer to a struct as_walk embedded in a struct as_walk_clean
+ *
+ * The function cleans a pte and records the range in
+ * virtual address space of touched ptes for efficient TLB flushes.
+ * It also records dirty ptes in a bitmap representing page offsets
+ * in the address_space, as well as the first and last of the bits
+ * touched.
+ */
+static void apply_pt_clean(pte_t *pte, unsigned long addr, struct as_wal=
k *asw)
+{
+	struct as_walk_range *awr =3D to_as_walk_range(asw);
+	struct as_walk_clean *clean =3D to_as_walk_clean(awr);
+	pte_t ptent =3D *pte;
+
+	if (pte_dirty(ptent)) {
+		pgoff_t pgoff =3D ((addr - asw->vma->vm_start) >> PAGE_SHIFT) +
+			asw->vma->vm_pgoff - clean->bitmap_pgoff;
+		pte_t old_pte =3D ptep_modify_prot_start(asw->vma, addr, pte);
+
+		ptent =3D pte_mkclean(old_pte);
+		ptep_modify_prot_commit(asw->vma, addr, pte, old_pte, ptent);
+
+		awr->total++;
+		awr->start =3D min(awr->start, addr);
+		awr->end =3D max(awr->end, addr + PAGE_SIZE);
+
+		__set_bit(pgoff, clean->bitmap);
+		clean->start =3D min(clean->start, pgoff);
+		clean->end =3D max(clean->end, pgoff + 1);
+	}
+}
+
+/**
+ * apply_as_range - Apply a pte callback to all PTEs pointing into a ran=
ge
+ * of an address_space.
+ * @mapping: Pointer to the struct address_space
+ * @aas: Closure structure
+ * @first_index: First page offset in the address_space
+ * @nr: Number of incremental page offsets to cover
+ *
+ * Return: Number of ptes touched. Note that this number might be larger
+ * than @nr if there are overlapping vmas
+ */
+static unsigned long apply_as_range(struct address_space *mapping,
+				    pgoff_t first_index, pgoff_t nr,
+				    const struct as_walk_ops *ops,
+				    struct as_walk_range *awr)
+{
+	struct vm_area_struct *vma;
+	pgoff_t vba, vea, cba, cea;
+	unsigned long start_addr, end_addr;
+	struct mmu_notifier_range range;
+
+	i_mmap_lock_read(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, first_index,
+				  first_index + nr - 1) {
+		unsigned long vm_flags =3D READ_ONCE(vma->vm_flags);
+
+		/*
+		 * We can only do advisory flag tests below, since we can't
+		 * require the mm's mmap_sem to be held to protect the flags.
+		 * Therefore, callers that strictly depend on specific vm_flags
+		 * to remain constant throughout the operation must ensure
+		 * those flags are immutable for all relevant vmas or can't use
+		 * this function. Fixing this properly would require the
+		 * vm_flags to be protected by a separate lock taken after the
+		 * i_mmap_lock
+		 */
+
+		/* Skip non-applicable VMAs */
+		if ((vm_flags & (VM_SHARED | VM_WRITE)) !=3D
+		    (VM_SHARED | VM_WRITE))
+			continue;
+
+		/* Warn on and skip VMAs whose flags indicate illegal usage */
+		if (WARN_ON((vm_flags & (VM_HUGETLB | VM_IO)) !=3D VM_IO))
+			continue;
+
+		/* Clip to the vma */
+		vba =3D vma->vm_pgoff;
+		vea =3D vba + vma_pages(vma);
+		cba =3D first_index;
+		cba =3D max(cba, vba);
+		cea =3D first_index + nr;
+		cea =3D min(cea, vea);
+
+		/* Translate to virtual address */
+		start_addr =3D ((cba - vba) << PAGE_SHIFT) + vma->vm_start;
+		end_addr =3D ((cea - vba) << PAGE_SHIFT) + vma->vm_start;
+		if (start_addr >=3D end_addr)
+			continue;
+
+		awr->base.vma =3D vma;
+		awr->start =3D end_addr;
+		awr->end =3D start_addr;
+
+		mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE, 0,
+					vma, vma->vm_mm, start_addr, end_addr);
+		mmu_notifier_invalidate_range_start(&range);
+
+		/* Is this needed when we only change protection? */
+		flush_cache_range(vma, start_addr, end_addr);
+
+		/*
+		 * We're not using tlb_gather_mmu() since typically
+		 * only a small subrange of PTEs are affected, whereas
+		 * tlb_gather_mmu() records the full range.
+		 */
+		inc_tlb_flush_pending(vma->vm_mm);
+		walk_as_pfn_range(start_addr, end_addr, ops, &awr->base);
+		if (awr->end > awr->start)
+			flush_tlb_range(vma, awr->start, awr->end);
+
+		mmu_notifier_invalidate_range_end(&range);
+		dec_tlb_flush_pending(vma->vm_mm);
+	}
+	i_mmap_unlock_read(mapping);
+
+	return awr->total;
+}
+
+/**
+ * apply_as_wrprotect - Write-protect all ptes in an address_space range
+ * @mapping: The address_space we want to write protect
+ * @first_index: The first page offset in the range
+ * @nr: Number of incremental page offsets to cover
+ *
+ * WARNING: This function should only be used for address spaces whose
+ * vmas are marked VM_IO and that do not contain huge pages.
+ * To avoid interference with COW'd pages, vmas not marked VM_SHARED are
+ * simply skipped.
+ *
+ * Return: The number of ptes actually write-protected. Note that
+ * already write-protected ptes are not counted.
+ */
+unsigned long apply_as_wrprotect(struct address_space *mapping,
+				 pgoff_t first_index, pgoff_t nr)
+{
+	static const struct as_walk_ops ops =3D {
+		.pte_entry =3D apply_pt_wrprotect
+	};
+	struct as_walk_range awr =3D { .total =3D 0 };
+
+	return apply_as_range(mapping, first_index, nr, &ops, &awr);
+}
+EXPORT_SYMBOL_GPL(apply_as_wrprotect);
+
+/**
+ * apply_as_clean - Clean all ptes in an address_space range
+ * @mapping: The address_space we want to clean
+ * @first_index: The first page offset in the range
+ * @nr: Number of incremental page offsets to cover
+ * @bitmap_pgoff: The page offset of the first bit in @bitmap
+ * @bitmap: Pointer to a bitmap of at least @nr bits. The bitmap needs t=
o
+ * cover the whole range @first_index..@first_index + @nr.
+ * @start: Pointer to number of the first set bit in @bitmap.
+ * is modified as new bits are set by the function.
+ * @end: Pointer to the number of the last set bit in @bitmap.
+ * none set. The value is modified as new bits are set by the function.
+ *
+ * Note: When this function returns there is no guarantee that a CPU has
+ * not already dirtied new ptes. However it will not clean any ptes not
+ * reported in the bitmap.
+ *
+ * If a caller needs to make sure all dirty ptes are picked up and none
+ * additional are added, it first needs to write-protect the address-spa=
ce
+ * range and make sure new writers are blocked in page_mkwrite() or
+ * pfn_mkwrite(). And then after a TLB flush following the write-protect=
ion
+ * pick up all dirty bits.
+ *
+ * WARNING: This function should only be used for address spaces whose
+ * vmas are marked VM_IO and that do not contain huge pages.
+ * To avoid interference with COW'd pages, vmas not marked VM_SHARED are
+ * simply skipped.
+ *
+ * Return: The number of dirty ptes actually cleaned.
+ */
+unsigned long apply_as_clean(struct address_space *mapping,
+			     pgoff_t first_index, pgoff_t nr,
+			     pgoff_t bitmap_pgoff,
+			     unsigned long *bitmap,
+			     pgoff_t *start,
+			     pgoff_t *end)
+{
+	bool none_set =3D (*start >=3D *end);
+	static const struct as_walk_ops ops =3D { .pte_entry =3D apply_pt_clean=
 };
+	struct as_walk_clean clean =3D {
+		.base =3D { .total =3D 0, },
+		.bitmap_pgoff =3D bitmap_pgoff,
+		.bitmap =3D bitmap,
+		.start =3D none_set ? nr : *start,
+		.end =3D none_set ? 0 : *end,
+	};
+	unsigned long ret =3D apply_as_range(mapping, first_index, nr, &ops,
+					   &clean.base);
+	*start =3D clean.start;
+	*end =3D clean.end;
+	return ret;
+}
+EXPORT_SYMBOL_GPL(apply_as_clean);
--=20
2.20.1


