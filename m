Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B4D4C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C424B21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C424B21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61F0D6B0010; Wed, 12 Jun 2019 11:20:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE616B0266; Wed, 12 Jun 2019 11:20:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46FD36B0269; Wed, 12 Jun 2019 11:20:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAE116B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:20:42 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id m2so2746832lfj.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O/scPoTelHO43E+MbA6Ha0AEBPHsVri9EkWUeYkw1Bk=;
        b=WHTplLqZsAIwx/cRbA74fZyfsqJYaxtPL6ZdhKb8DFwo+BOSE4m7JkqOXUvivxeTvY
         WOmFYx5wrS2KvY3aPy907hn2op+kuk/icWDVeQLh8BXDC3wqLP/xeoLEzFfdbiy7gObB
         OkYlkqgWGCFbZmw9no/XfvT6Z6vgMTVJ6hZUwnRCkipQoxzDmgOR5trsqFhAopphfkB3
         XK/3ixYFF764dRaTWhg9Dcf0Xzg/m9STtMxYuSJlqVubvWYg9wWbqkmotEb7PMLohlkT
         UtCawpEZlOQsoTJdMFRrWqnfSiaUIJQs5+Y4W0s5p1g7qm239nMMrs1LEdOOJQm6NYw1
         FaAA==
X-Gm-Message-State: APjAAAUcNRxX9EPmFe8P9cjRsJ3MaVjcomZZBHiKEkkckfjNoftm7UMN
	zXi5Oc7+eE+ThonBIfDtkV8/wZ/+1vS8NvflK/jI39xantu0jEXzCKtUNu72cU7CbFGKikd9V1N
	i2bDLA3M0AiNDXmbDMwq8V3lGZqmi4GSersGHpJGw9cY1Vt1uCwHu7WCHo8+zn32/rw==
X-Received: by 2002:a2e:934e:: with SMTP id m14mr17084824ljh.116.1560352842068;
        Wed, 12 Jun 2019 08:20:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/6Qp+6jYCDRF5meSHsZ+/GK81oZ3vp3h1H53k3gcDZljGEWagut5/fk3uvSjF0ZSLoRy6
X-Received: by 2002:a2e:934e:: with SMTP id m14mr17084766ljh.116.1560352840746;
        Wed, 12 Jun 2019 08:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560352840; cv=none;
        d=google.com; s=arc-20160816;
        b=0O0VvfMd1ufYD3laXrOPajaTbQdNjsyEZEqOnlKpJkY8t6wRAiHjVDfD2RKwxeo/Ry
         9ucSV06QIp7z81dNXTtIsLCZrb3Y5WO6LM8T+PTrPahiz0BVFKCRyHH682aHB6iic1lL
         4eEUXUXGIHFwcsi88Og3Wql0dZ7z6hyMn5NK5l8jt6Hag25LAtHQ42O3HfqBcL4NUDjn
         hr2RUdKJhvKkxB1V+aKnibs0PujI5P6CA010sT8VsTtCWrGkPEcMhnaWJ5W+dnlvrppQ
         nDHTXDbZjC2giRlTKTnRWOMohT9CufW0aSAFpgDflTL17DVme4XSqBJUhwzzbSSE/jjC
         FNCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=O/scPoTelHO43E+MbA6Ha0AEBPHsVri9EkWUeYkw1Bk=;
        b=elpC8CcOjqMmgaWFTypLSt2mA2bS4Sdkv/3iHmaL9tSBfWDyEeTGVku7f9Lc6cYL3b
         UVdm357EE8R9MC3bxGORHr4AEuQlRnNeO/byZEb3yONx/lPLnns81pHl00xZ5+paIgOg
         mDT5DDuPeBge6dNLBgqJhj5NSP0IgepcqjY4gBQXT5BpJehQH+kKsuKY/YLEopquCk4K
         oirdMo8DxxB00u2M9RwaqlL+xUa6K6dJbhJTereG47RJguL4Ja2WbWGyzVmTWOR7ituo
         xtQ3w65NUDOc2BprQKb7pq9RbV2sxZoW+exFfja085DO9VkmV1rK2K7q9CC0X6G8fF2G
         wxhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b="w/adqvAZ";
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from pio-pvt-msa3.bahnhof.se (pio-pvt-msa3.bahnhof.se. [79.136.2.42])
        by mx.google.com with ESMTPS id 78si4894206lje.126.2019.06.12.08.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 08:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) client-ip=79.136.2.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b="w/adqvAZ";
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.42 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTP id 6531A3FBDC;
	Wed, 12 Jun 2019 17:20:35 +0200 (CEST)
Authentication-Results: pio-pvt-msa3.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=w/adqvAZ;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa3.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa3.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KKfFjVyV6tCd; Wed, 12 Jun 2019 17:20:21 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa3.bahnhof.se (Postfix) with ESMTPA id 2D2E43FBE2;
	Wed, 12 Jun 2019 17:20:10 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id C5E56361DE0;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560352809;
	bh=oDQQZpNtRPA3kHDLYhK4x6N9U1hVC2W22kTL8rIAhNc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=w/adqvAZ//L29D8ZXgScWhgDE7/L78qsjAMjWZVf2r3OSxQOnOPjawnVoVn51b9+2
	 edOdzJLwI2JU3xioGRvbWjBPhUN89/ZJZS5nKT9+mn2FzkdU4y3V8xkIoewgMrdIlo
	 RJkV+kmLoYbitkctF0PryOi8O3zXvVlaBpe4sD5M=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	hch@infradead.org,
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
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v6 3/9] mm: Add write-protect and clean utilities for address space ranges
Date: Wed, 12 Jun 2019 17:19:44 +0200
Message-Id: <20190612151950.2870-4-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190612151950.2870-1-thellstrom@vmwopensource.org>
References: <20190612151950.2870-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
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

Notable changes since RFC:
- Added comments to help avoid the usage of these function for VMAs
  it's not intended for. We also do advisory checks on the vm_flags and
  warn on illegal usage.
- Perform the pte modifications the same way softdirty does.
- Add mmu_notifier range invalidation calls.
- Add a config option so that this code is not unconditionally included.
- Tell the mmu_gather code about pending tlb flushes.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
---
 MAINTAINERS           |   1 +
 include/linux/mm.h    |   9 +-
 mm/Kconfig            |   3 +
 mm/Makefile           |   1 +
 mm/as_dirty_helpers.c | 300 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 313 insertions(+), 1 deletion(-)
 create mode 100644 mm/as_dirty_helpers.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 7a2f487ea49a..a55d4ef91b0b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5179,6 +5179,7 @@ T:	git git://people.freedesktop.org/~thomash/linux
 S:	Supported
 F:	drivers/gpu/drm/vmwgfx/
 F:	include/uapi/drm/vmwgfx_drm.h
+F:	mm/as_dirty_helpers.c
 
 DRM DRIVERS
 M:	David Airlie <airlied@linux.ie>
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3d06ce2a64af..a0bc2a82917e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2685,7 +2685,14 @@ struct pfn_range_apply {
 };
 extern int apply_to_pfn_range(struct pfn_range_apply *closure,
 			      unsigned long address, unsigned long size);
-
+unsigned long apply_as_wrprotect(struct address_space *mapping,
+				 pgoff_t first_index, pgoff_t nr);
+unsigned long apply_as_clean(struct address_space *mapping,
+			     pgoff_t first_index, pgoff_t nr,
+			     pgoff_t bitmap_pgoff,
+			     unsigned long *bitmap,
+			     pgoff_t *start,
+			     pgoff_t *end);
 #ifdef CONFIG_PAGE_POISONING
 extern bool page_poisoning_enabled(void);
 extern void kernel_poison_pages(struct page *page, int numpages, int enable);
diff --git a/mm/Kconfig b/mm/Kconfig
index f0c76ba47695..5006d0e6a5c7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -765,4 +765,7 @@ config GUP_BENCHMARK
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+config AS_DIRTY_HELPERS
+        bool
+
 endmenu
diff --git a/mm/Makefile b/mm/Makefile
index ac5e5ba78874..f5d412bbc2f7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -104,3 +104,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_AS_DIRTY_HELPERS) += as_dirty_helpers.o
diff --git a/mm/as_dirty_helpers.c b/mm/as_dirty_helpers.c
new file mode 100644
index 000000000000..f600e31534fb
--- /dev/null
+++ b/mm/as_dirty_helpers.c
@@ -0,0 +1,300 @@
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
+ * struct apply_as - Closure structure for apply_as_range
+ * @base: struct pfn_range_apply we derive from
+ * @start: Address of first modified pte
+ * @end: Address of last modified pte + 1
+ * @total: Total number of modified ptes
+ * @vma: Pointer to the struct vm_area_struct we're currently operating on
+ */
+struct apply_as {
+	struct pfn_range_apply base;
+	unsigned long start;
+	unsigned long end;
+	unsigned long total;
+	struct vm_area_struct *vma;
+};
+
+/**
+ * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
+ * @pte: Pointer to the pte
+ * @token: Page table token, see apply_to_pfn_range()
+ * @addr: The virtual page address
+ * @closure: Pointer to a struct pfn_range_apply embedded in a
+ * struct apply_as
+ *
+ * The function write-protects a pte and records the range in
+ * virtual address space of touched ptes for efficient range TLB flushes.
+ *
+ * Return: Always zero.
+ */
+static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
+			      unsigned long addr,
+			      struct pfn_range_apply *closure)
+{
+	struct apply_as *aas = container_of(closure, typeof(*aas), base);
+	pte_t ptent = *pte;
+
+	if (pte_write(ptent)) {
+		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
+
+		ptent = pte_wrprotect(old_pte);
+		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
+		aas->total++;
+		aas->start = min(aas->start, addr);
+		aas->end = max(aas->end, addr + PAGE_SIZE);
+	}
+
+	return 0;
+}
+
+/**
+ * struct apply_as_clean - Closure structure for apply_as_clean
+ * @base: struct apply_as we derive from
+ * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
+ * @bitmap: Bitmap with one bit for each page offset in the address_space range
+ * covered.
+ * @start: Address_space page offset of first modified pte relative
+ * to @bitmap_pgoff
+ * @end: Address_space page offset of last modified pte relative
+ * to @bitmap_pgoff
+ */
+struct apply_as_clean {
+	struct apply_as base;
+	pgoff_t bitmap_pgoff;
+	unsigned long *bitmap;
+	pgoff_t start;
+	pgoff_t end;
+};
+
+/**
+ * apply_pt_clean - Leaf pte callback to clean a pte
+ * @pte: Pointer to the pte
+ * @token: Page table token, see apply_to_pfn_range()
+ * @addr: The virtual page address
+ * @closure: Pointer to a struct pfn_range_apply embedded in a
+ * struct apply_as_clean
+ *
+ * The function cleans a pte and records the range in
+ * virtual address space of touched ptes for efficient TLB flushes.
+ * It also records dirty ptes in a bitmap representing page offsets
+ * in the address_space, as well as the first and last of the bits
+ * touched.
+ *
+ * Return: Always zero.
+ */
+static int apply_pt_clean(pte_t *pte, pgtable_t token,
+			  unsigned long addr,
+			  struct pfn_range_apply *closure)
+{
+	struct apply_as *aas = container_of(closure, typeof(*aas), base);
+	struct apply_as_clean *clean = container_of(aas, typeof(*clean), base);
+	pte_t ptent = *pte;
+
+	if (pte_dirty(ptent)) {
+		pgoff_t pgoff = ((addr - aas->vma->vm_start) >> PAGE_SHIFT) +
+			aas->vma->vm_pgoff - clean->bitmap_pgoff;
+		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
+
+		ptent = pte_mkclean(old_pte);
+		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
+
+		aas->total++;
+		aas->start = min(aas->start, addr);
+		aas->end = max(aas->end, addr + PAGE_SIZE);
+
+		__set_bit(pgoff, clean->bitmap);
+		clean->start = min(clean->start, pgoff);
+		clean->end = max(clean->end, pgoff + 1);
+	}
+
+	return 0;
+}
+
+/**
+ * apply_as_range - Apply a pte callback to all PTEs pointing into a range
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
+				    struct apply_as *aas,
+				    pgoff_t first_index, pgoff_t nr)
+{
+	struct vm_area_struct *vma;
+	pgoff_t vba, vea, cba, cea;
+	unsigned long start_addr, end_addr;
+	struct mmu_notifier_range range;
+
+	i_mmap_lock_read(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, first_index,
+				  first_index + nr - 1) {
+		unsigned long vm_flags = READ_ONCE(vma->vm_flags);
+
+		/*
+		 * We can only do advisory flag tests below, since we can't
+		 * require the vm's mmap_sem to be held to protect the flags.
+		 * Therefore, callers that strictly depend on specific mmap
+		 * flags to remain constant throughout the operation must
+		 * either ensure those flags are immutable for all relevant
+		 * vmas or can't use this function. Fixing this properly would
+		 * require the vma::vm_flags to be protected by a separate
+		 * lock taken after the i_mmap_lock
+		 */
+
+		/* Skip non-applicable VMAs */
+		if ((vm_flags & (VM_SHARED | VM_WRITE)) !=
+		    (VM_SHARED | VM_WRITE))
+			continue;
+
+		/* Warn on and skip VMAs whose flags indicate illegal usage */
+		if (WARN_ON((vm_flags & (VM_HUGETLB | VM_IO)) != VM_IO))
+			continue;
+
+		/* Clip to the vma */
+		vba = vma->vm_pgoff;
+		vea = vba + vma_pages(vma);
+		cba = first_index;
+		cba = max(cba, vba);
+		cea = first_index + nr;
+		cea = min(cea, vea);
+
+		/* Translate to virtual address */
+		start_addr = ((cba - vba) << PAGE_SHIFT) + vma->vm_start;
+		end_addr = ((cea - vba) << PAGE_SHIFT) + vma->vm_start;
+		if (start_addr >= end_addr)
+			continue;
+
+		aas->base.mm = vma->vm_mm;
+		aas->vma = vma;
+		aas->start = end_addr;
+		aas->end = start_addr;
+
+		mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE, 0,
+					vma, vma->vm_mm, start_addr, end_addr);
+		mmu_notifier_invalidate_range_start(&range);
+
+		/* Needed when we only change protection? */
+		flush_cache_range(vma, start_addr, end_addr);
+
+		/*
+		 * We're not using tlb_gather_mmu() since typically
+		 * only a small subrange of PTEs are affected.
+		 */
+		inc_tlb_flush_pending(vma->vm_mm);
+
+		/* Should not error since aas->base.alloc == 0 */
+		WARN_ON(apply_to_pfn_range(&aas->base, start_addr,
+					   end_addr - start_addr));
+		if (aas->end > aas->start)
+			flush_tlb_range(vma, aas->start, aas->end);
+
+		mmu_notifier_invalidate_range_end(&range);
+		dec_tlb_flush_pending(vma->vm_mm);
+	}
+	i_mmap_unlock_read(mapping);
+
+	return aas->total;
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
+	struct apply_as aas = {
+		.base = {
+			.alloc = 0,
+			.ptefn = apply_pt_wrprotect,
+		},
+		.total = 0,
+	};
+
+	return apply_as_range(mapping, &aas, first_index, nr);
+}
+EXPORT_SYMBOL_GPL(apply_as_wrprotect);
+
+/**
+ * apply_as_clean - Clean all ptes in an address_space range
+ * @mapping: The address_space we want to clean
+ * @first_index: The first page offset in the range
+ * @nr: Number of incremental page offsets to cover
+ * @bitmap_pgoff: The page offset of the first bit in @bitmap
+ * @bitmap: Pointer to a bitmap of at least @nr bits. The bitmap needs to
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
+ * additional are added, it first needs to write-protect the address-space
+ * range and make sure new writers are blocked in page_mkwrite() or
+ * pfn_mkwrite(). And then after a TLB flush following the write-protection
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
+	bool none_set = (*start >= *end);
+	struct apply_as_clean clean = {
+		.base = {
+			.base = {
+				.alloc = 0,
+				.ptefn = apply_pt_clean,
+			},
+			.total = 0,
+		},
+		.bitmap_pgoff = bitmap_pgoff,
+		.bitmap = bitmap,
+		.start = none_set ? nr : *start,
+		.end = none_set ? 0 : *end,
+	};
+	unsigned long ret = apply_as_range(mapping, &clean.base, first_index,
+					   nr);
+
+	*start = clean.start;
+	*end = clean.end;
+	return ret;
+}
+EXPORT_SYMBOL_GPL(apply_as_clean);
-- 
2.20.1

