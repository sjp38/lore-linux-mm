Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B891C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F972089F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F972089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A95576B000C; Tue, 25 Jun 2019 03:53:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F6AE8E0003; Tue, 25 Jun 2019 03:53:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D57C8E0002; Tue, 25 Jun 2019 03:53:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 120236B000C
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:53:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so24367425edm.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:53:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7ZJiIu6+Q0/KpgqbrO7Z2w7ZhGh9YiaEfkdXVkzctqI=;
        b=RWGiPvoFqRdoATNNqc+jDqXaQjdZ4LZigITRT3zrmdtIC4f1vBryhLbdqxH4UJBO/L
         Oc6DNPbQrHVrArInXWEzODEAg/V+fjzsPHqhRjtCAzgWd+2Yei1EwRQtltRbW9AY0TgV
         q7OmdHgUVS5Zyt2+cLcOsfgF2/mQgwEhLlG0ieLoC4Jg6k7yzsUOOpKwsOwNkaCNoDX1
         QpaDWx7+PJL4Ee80YBsTJaBMMgljvPWapikxiYerYLulb6gjax/DhHgU8P1cCFwnSXSj
         m97EBDgvjtxVRgIEIA6IPqpw4gCDfPUPZ7Z6UodFztiFz/KGgsKiyKpgysiPuVrfBL/k
         vjyQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXRLDbwCXWgKJFtG0184R9INURULEE/Wqx8gy/z2aeVRrT+Bn50
	ew+PpF+0mAnENJsv59CRBaLSnX6PIiOFloFSZmT9T3QfpNuAKceuxenu/7G4mxYpnealcNq9Q1g
	64cGt1cGvMg/FiHqEKM64S5oPwBNCWPsDKnNMPZO69Vn4XYhFuLR84ZuwjEk2E/23Xg==
X-Received: by 2002:a17:906:d69:: with SMTP id s9mr30030372ejh.305.1561449192542;
        Tue, 25 Jun 2019 00:53:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUR3bS125N6BGlvqrll0D/m27aK2sWir2j3+Q0lbrzFGwUxYXpxkEJIVjBE37i2Ikj/JaF
X-Received: by 2002:a17:906:d69:: with SMTP id s9mr30030265ejh.305.1561449190404;
        Tue, 25 Jun 2019 00:53:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449190; cv=none;
        d=google.com; s=arc-20160816;
        b=I0rBPrxs7Kaufiyt5LkM/eTDX/vLOxxU3OH19G2U4pRRTY8wbx3o4Y++07v0Ca6imn
         VNw3+ytLazORKsPxAIwcI5msLKCwfzoi3U5N3ARcMLQcFLQkdWt2Saho6uo00wyqOJ+t
         xNRmHG7E6g2Y8EADrfRgV2VaU3NJPScWQQFVBHNyFmxGbd9+Ul3VxjvoR2dnPST9FuyU
         MKV17Hhej6C6oXu7iaCJfaXr0ai1Vq2VPw1Nl8JSeP82xppZIHMr5p+8k6p4UmhDTGOk
         +3XP4OPJShfRnUfAxi2XSMrKVOxc9Woylg8jvGo1uaaZ6szTQX/sSNHI89iucVMx63FE
         6Ejw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7ZJiIu6+Q0/KpgqbrO7Z2w7ZhGh9YiaEfkdXVkzctqI=;
        b=KZeRZx1TPEXECgpnApxzC1iafM6mhCs2hb9o2coBSl360ojWU57qH9xHgnTFmQZsRN
         PZyGGs9S7BpiDjj7z2lKuVjFRYaJ2fMaxPj6Dt1rOHispC361/e3uJ6vd4frvA9qy8hZ
         qNcwKMYguedlEe0PEpOrHcvOGZ4HyQnNIiFu8N5V8WJevFpzcTL+dmcl/Jt1EzGV8Q8Z
         aqqP6kh82HlpJ5L5p8TxS/OY4oHAtwcZEM+abdGuaoCEb2fJLbWseWGSOX0SsLmtcSAk
         YW/yPQRtG0ozzYwTQQj8JEVemcteNR5JQ27WIGuGTMVFCldW/jNl9Ro+KRliM46epFvr
         +8Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g39si12558324edc.434.2019.06.25.00.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:53:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 25 Jun 2019 09:53:09 +0200
Received: from suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 25 Jun 2019 08:52:35 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	dan.j.williams@intel.com,
	pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com,
	david@redhat.com,
	anshuman.khandual@arm.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
Date: Tue, 25 Jun 2019 09:52:26 +0200
Message-Id: <20190625075227.15193-5-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190625075227.15193-1-osalvador@suse.de>
References: <20190625075227.15193-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Physical memory hotadd has to allocate a memmap (struct page array) for
the newly added memory section. Currently, alloc_pages_node() is used
for those allocations.

This has some disadvantages:
 a) an existing memory is consumed for that purpose
    (~2MB per 128MB memory section on x86_64)
 b) if the whole node is movable then we have off-node struct pages
    which has performance drawbacks.

a) has turned out to be a problem for memory hotplug based ballooning
   because the userspace might not react in time to online memory while
   the memory consumed during physical hotadd consumes enough memory to
   push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
   policy for the newly added memory") has been added to workaround that
   problem.

I have also seen hot-add operations failing on powerpc due to the fact
that we try to use order-8 pages. If the base page size is 64KB, this
gives us 16MB, and if we run out of those, we simply fail.
One could arge that we can fall back to basepages as we do in x86_64, but
we can do better when CONFIG_SPARSEMEM_VMEMMAP is enabled.

Vmemap page tables can map arbitrary memory.
That means that we can simply use the beginning of each memory section and
map struct pages there.
struct pages which back the allocated space then just need to be treated
carefully.

Implementation wise we reuse vmem_altmap infrastructure to override
the default allocator used by __vmemap_populate. Once the memmap is
allocated we need a way to mark altmap pfns used for the allocation.
If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
altmap structure at the beginning of __add_pages(), and then we call
mark_vmemmap_pages().

Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
mark_vmemmap_pages() gets called at a different stage.
With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
sections have been populated.

mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:

The current layout of the Vmemmap pages are:

	[Head->refcount] : Nr sections used by this altmap
	[Head->private]  : Nr of vmemmap pages
	[Tail->freelist] : Pointer to the head page

This is done to easy the computation we need in some places.
E.g:

Example 1)
We hot-add 1GB on x86_64 (memory block 128MB) using
MHP_MEMMAP_DEVICE:

head->_refcount = 8 sections
head->private = 4096 vmemmap pages
tail's->freelist = head

Example 2)
We hot-add 1GB on x86_64 using MHP_MEMMAP_MEMBLOCK:

[at the beginning of each memblock]
head->_refcount = 1 section
head->private = 512 vmemmap pages
tail's->freelist = head

We have the refcount because when using MHP_MEMMAP_DEVICE, we need to know
how much do we have to defer the call to vmemmap_free().
The thing is that the first pages of the hot-added range are used to create
the memmap mapping, so we cannot remove those first, otherwise we would blow up
when accessing the other pages.

What we do is that since when we hot-remove a memory-range, sections are being
removed sequentially, we wait until we hit the last section, and then we free
the hole range to vmemmap_free backwards.
We know that it is the last section because in every pass we
decrease head->_refcount, and when it reaches 0, we got our last section.

We also have to be careful about those pages during online and offline
operations. They are simply skipped, so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

In offline operation we only have to check for one particularity.
Depending on how large was the hot-added range, and using MHP_MEMMAP_DEVICE,
can be that one or more than one memory block is filled with only vmemmap pages.
We just need to check for this case and skip 1) isolating 2) migrating,
because those pages do not need to be migrated anywhere, they are self-hosted.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c            |   5 +-
 arch/powerpc/mm/init_64.c      |   7 +++
 arch/s390/mm/init.c            |   6 ++
 arch/x86/mm/init_64.c          |  10 +++
 drivers/acpi/acpi_memhotplug.c |   2 +-
 drivers/base/memory.c          |   2 +-
 include/linux/memory_hotplug.h |   6 ++
 include/linux/memremap.h       |   2 +-
 mm/compaction.c                |   7 +++
 mm/memory_hotplug.c            | 138 +++++++++++++++++++++++++++++++++++------
 mm/page_alloc.c                |  22 ++++++-
 mm/page_isolation.c            |  14 ++++-
 mm/sparse.c                    |  93 +++++++++++++++++++++++++++
 13 files changed, 289 insertions(+), 25 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 93ed0df4df79..d4b5661fa6b6 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -765,7 +765,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		if (pmd_none(READ_ONCE(*pmdp))) {
 			void *p = NULL;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			if (altmap)
+				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (!p)
 				return -ENOMEM;
 
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a4e17a979e45..ff9d2c245321 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -289,6 +289,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 
 		if (base_pfn >= alt_start && base_pfn < alt_end) {
 			vmem_altmap_free(altmap, nr_pages);
+		} else if (PageVmemmap(page)) {
+			/*
+			 * runtime vmemmap pages are residing inside the memory
+			 * section so they do not have to be freed anywhere.
+			 */
+			while (PageVmemmap(page))
+				__ClearPageVmemmap(page++);
 		} else if (PageReserved(page)) {
 			/* allocated from bootmem */
 			if (page_size < PAGE_SIZE) {
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index ffb81fe95c77..c045411552a3 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -226,6 +226,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunately.
+	 */
+	restrictions->flags &= ~restrictions->flags;
+
 	if (WARN_ON_ONCE(restrictions->altmap))
 		return -EINVAL;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 688fb0687e55..00d17b666337 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -874,6 +874,16 @@ static void __meminit free_pagetable(struct page *page, int order)
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
+	/*
+	 * Runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page)) {
+		while (nr_pages--)
+			__ClearPageVmemmap(page++);
+		return;
+	}
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 860f84e82dd0..3257edb98d90 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -218,7 +218,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length, 0);
+		result = __add_memory(node, info->start_addr, info->length, MHP_MEMMAP_DEVICE);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index ad9834b8b7f7..e0ac9a3b66f8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -32,7 +32,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
 
-static int sections_per_block;
+int sections_per_block;
 
 static inline int base_memory_block_id(int section_nr)
 {
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6fdbce9d04f9..e28e226c9a20 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -375,4 +375,10 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
 		int online_type);
 extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 		unsigned long nr_pages);
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+extern void mark_vmemmap_pages(struct vmem_altmap *self);
+#else
+static inline void mark_vmemmap_pages(struct vmem_altmap *self) {}
+#endif
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 1732dea030b2..6de37e168f57 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -16,7 +16,7 @@ struct device;
  * @alloc: track pages consumed, private to vmemmap_populate()
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..40697f74b8b4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -855,6 +855,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		nr_scanned++;
 
 		page = pfn_to_page(low_pfn);
+		/*
+		 * Vmemmap pages do not need to be isolated.
+		 */
+		if (PageVmemmap(page)) {
+			low_pfn += get_nr_vmemmap_pages(page) - 1;
+			continue;
+		}
 
 		/*
 		 * Check if the pageblock has already been marked skipped.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e4e3baa6eaa7..b5106cb75795 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -42,6 +42,8 @@
 #include "internal.h"
 #include "shuffle.h"
 
+extern int sections_per_block;
+
 /*
  * online_page_callback contains pointer to current page onlining function.
  * Initially it is generic_online_page(). If it is required it could be
@@ -279,6 +281,24 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
 	return 0;
 }
 
+static void mhp_reset_altmap(unsigned long next_pfn,
+			     struct vmem_altmap *altmap)
+{
+	altmap->base_pfn = next_pfn;
+	altmap->alloc = 0;
+}
+
+static void mhp_init_altmap(unsigned long pfn, unsigned long nr_pages,
+			    unsigned long mhp_flags,
+			    struct vmem_altmap *altmap)
+{
+	if (mhp_flags & MHP_MEMMAP_DEVICE)
+		altmap->free = nr_pages;
+	else
+		altmap->free = PAGES_PER_SECTION * sections_per_block;
+	altmap->base_pfn = pfn;
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -290,8 +310,17 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 {
 	unsigned long i;
 	int start_sec, end_sec, err;
-	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap *altmap;
+	struct vmem_altmap __memblk_altmap = {};
+	unsigned long mhp_flags = restrictions->flags;
+	unsigned long sections_added;
+
+	if (mhp_flags & MHP_VMEMMAP_FLAGS) {
+		mhp_init_altmap(pfn, nr_pages, mhp_flags, &__memblk_altmap);
+		restrictions->altmap = &__memblk_altmap;
+	}
 
+	altmap = restrictions->altmap;
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -308,9 +337,10 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 	if (err)
 		return err;
 
+	sections_added = 1;
 	start_sec = pfn_to_section_nr(pfn);
 	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
-	for (i = start_sec; i <= end_sec; i++) {
+	for (i = start_sec; i <= end_sec; i++, sections_added++) {
 		unsigned long pfns;
 
 		pfns = min(nr_pages, PAGES_PER_SECTION
@@ -320,9 +350,19 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 			break;
 		pfn += pfns;
 		nr_pages -= pfns;
+
+		if (mhp_flags & MHP_MEMMAP_MEMBLOCK &&
+		    !(sections_added % sections_per_block)) {
+			mark_vmemmap_pages(altmap);
+			mhp_reset_altmap(pfn, altmap);
+		}
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
+
+	if (mhp_flags & MHP_MEMMAP_DEVICE)
+		mark_vmemmap_pages(altmap);
+
 	return err;
 }
 
@@ -642,6 +682,14 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	while (start < end) {
 		order = min(MAX_ORDER - 1,
 			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
+		/*
+		 * Check if the pfn is aligned to its order.
+		 * If not, we decrement the order until it is,
+		 * otherwise __free_one_page will bug us.
+		 */
+		while (start & ((1 << order) - 1))
+			order--;
+
 		(*online_page_callback)(pfn_to_page(start), order);
 
 		onlined_pages += (1UL << order);
@@ -654,13 +702,30 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
 	unsigned long onlined_pages = *(unsigned long *)arg;
+	unsigned long pfn = start_pfn;
+	unsigned long nr_vmemmap_pages = 0;
 
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
+	if (PageVmemmap(pfn_to_page(pfn))) {
+		/*
+		 * Do not send vmemmap pages to the page allocator.
+		 */
+		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
+		nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
+		pfn += nr_vmemmap_pages;
+		if (nr_vmemmap_pages == nr_pages)
+			/*
+			 * If the entire range contains only vmemmap pages,
+			 * there are no pages left for the page allocator.
+			 */
+			goto skip_online;
+	}
 
+	if (PageReserved(pfn_to_page(pfn)))
+		onlined_pages += online_pages_blocks(pfn, nr_pages - nr_vmemmap_pages);
+skip_online:
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-	*(unsigned long *)arg = onlined_pages;
+	*(unsigned long *)arg = onlined_pages + nr_vmemmap_pages;
 	return 0;
 }
 
@@ -1051,6 +1116,23 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 	return device_online(&mem->dev);
 }
 
+static bool mhp_check_correct_flags(unsigned long flags)
+{
+	if (flags & MHP_VMEMMAP_FLAGS) {
+		if (!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)) {
+			WARN(1, "Vmemmap capability can only be used on"
+				"CONFIG_SPARSEMEM_VMEMMAP. Ignoring flags.\n");
+			return false;
+		}
+		if ((flags & MHP_VMEMMAP_FLAGS) == MHP_VMEMMAP_FLAGS) {
+			WARN(1, "Both MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK"
+				"were passed. Ignoring flags.\n");
+			return false;
+		}
+	}
+	return true;
+}
+
 /*
  * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
  * and online/offline operations (triggered e.g. by sysfs).
@@ -1086,6 +1168,9 @@ int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags
 		goto error;
 	new_node = ret;
 
+	if (mhp_check_correct_flags(flags))
+		restrictions.flags = flags;
+
 	/* call arch's memory hotadd */
 	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
@@ -1518,12 +1603,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages;
 	unsigned long offlined_pages = 0;
+	unsigned long nr_vmemmap_pages = 0;
 	int ret, node, nr_isolate_pageblock;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
 	char *reason;
+	bool skip = false;
 
 	mem_hotplug_begin();
 
@@ -1540,15 +1627,24 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
-	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE,
-				       SKIP_HWPOISON | REPORT_FAILURE);
-	if (ret < 0) {
-		reason = "failure to isolate range";
-		goto failed_removal;
+	if (PageVmemmap(pfn_to_page(start_pfn))) {
+		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
+		nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
+		if (nr_vmemmap_pages == nr_pages)
+			skip = true;
+	}
+
+	if (!skip) {
+		/* set above range as isolated */
+		ret = start_isolate_page_range(start_pfn, end_pfn,
+					       MIGRATE_MOVABLE,
+					       SKIP_HWPOISON | REPORT_FAILURE);
+		if (ret < 0) {
+			reason = "failure to isolate range";
+			goto failed_removal;
+		}
+		nr_isolate_pageblock = ret;
 	}
-	nr_isolate_pageblock = ret;
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
@@ -1561,6 +1657,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal_isolated;
 	}
 
+	if (skip)
+		goto skip_migration;
+
 	do {
 		for (pfn = start_pfn; pfn;) {
 			if (signal_pending(current)) {
@@ -1601,7 +1700,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	   We cannot do rollback at this point. */
 	walk_system_ram_range(start_pfn, end_pfn - start_pfn,
 			      &offlined_pages, offline_isolated_pages_cb);
-	pr_info("Offlined Pages %ld\n", offlined_pages);
+
+skip_migration:
+	pr_info("Offlined Pages %ld\n", offlined_pages + nr_vmemmap_pages);
 	/*
 	 * Onlining will reset pagetype flags and makes migrate type
 	 * MOVABLE, so just need to decrease the number of isolated
@@ -1612,11 +1713,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	spin_unlock_irqrestore(&zone->lock, flags);
 
 	/* removal success */
-	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
-	zone->present_pages -= offlined_pages;
+	if (offlined_pages)
+		adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
+	zone->present_pages -= offlined_pages + nr_vmemmap_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
-	zone->zone_pgdat->node_present_pages -= offlined_pages;
+	zone->zone_pgdat->node_present_pages -= offlined_pages + nr_vmemmap_pages;
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
 	init_per_zone_wmark_min();
@@ -1645,7 +1747,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 failed_removal:
 	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
-		 (unsigned long long) start_pfn << PAGE_SHIFT,
+		 (unsigned long long) (start_pfn - nr_vmemmap_pages) << PAGE_SHIFT,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
 		 reason);
 	/* pushback to free area */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b3266d63521..7a73a06c5730 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1282,9 +1282,14 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	mm_zero_struct_page(page);
+	if (!__PageVmemmap(page)) {
+		/*
+		 * Vmemmap pages need to preserve their state.
+		 */
+		mm_zero_struct_page(page);
+		init_page_count(page);
+	}
 	set_page_links(page, zone, nid, pfn);
-	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
 	page_kasan_tag_reset(page);
@@ -8143,6 +8148,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		/*
+		 * Vmemmap pages are not needed to be moved around.
+		 */
+		if (PageVmemmap(page)) {
+			iter += get_nr_vmemmap_pages(page) - 1;
+			continue;
+		}
+
 		if (PageReserved(page))
 			goto unmovable;
 
@@ -8510,6 +8523,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
+		if (PageVmemmap(page)) {
+			pfn += get_nr_vmemmap_pages(page);
+			continue;
+		}
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index e3638a5bafff..128c47a27925 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -146,7 +146,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 static inline struct page *
 __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 {
-	int i;
+	unsigned long i;
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
@@ -154,6 +154,10 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 		page = pfn_to_online_page(pfn + i);
 		if (!page)
 			continue;
+		if (PageVmemmap(page)) {
+			i += get_nr_vmemmap_pages(page) - 1;
+			continue;
+		}
 		return page;
 	}
 	return NULL;
@@ -268,6 +272,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		/*
+		 * Vmemmap pages are not isolated. Skip them.
+		 */
+		if (PageVmemmap(page)) {
+			pfn += get_nr_vmemmap_pages(page);
+			continue;
+		}
+
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
diff --git a/mm/sparse.c b/mm/sparse.c
index b77ca21a27a4..04b395fb4463 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -635,6 +635,94 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+void mark_vmemmap_pages(struct vmem_altmap *self)
+{
+	unsigned long pfn = self->base_pfn + self->reserve;
+	unsigned long nr_pages = self->alloc;
+	unsigned long nr_sects = self->free / PAGES_PER_SECTION;
+	unsigned long i;
+	struct page *head;
+
+	if (!nr_pages)
+		return;
+
+	pr_debug("%s: marking %px - %px as Vmemmap (%ld pages)\n",
+						__func__,
+						pfn_to_page(pfn),
+						pfn_to_page(pfn + nr_pages - 1),
+						nr_pages);
+
+	/*
+	 * All allocations for the memory hotplug are the same sized so align
+	 * should be 0.
+	 */
+	WARN_ON(self->align);
+
+	/*
+	 * Layout of vmemmap pages:
+	 * [Head->refcount] : Nr sections used by this altmap
+	 * [Head->private]  : Nr of vmemmap pages
+	 * [Tail->freelist] : Pointer to the head page
+	 */
+
+	/*
+	 * Head, first vmemmap page
+	 */
+	head = pfn_to_page(pfn);
+	for (i = 0; i < nr_pages; i++, pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		mm_zero_struct_page(page);
+		__SetPageVmemmap(page);
+		page->freelist = head;
+		init_page_count(page);
+	}
+	set_page_count(head, (int)nr_sects);
+	set_page_private(head, nr_pages);
+}
+/*
+ * If the range we are trying to remove was hot-added with vmemmap pages
+ * using MHP_MEMMAP_DEVICE, we need to keep track of it to know how much
+ * do we have do defer the free up.
+ * Since sections are removed sequentally in __remove_pages()->
+ * __remove_section(), we just wait until we hit the last section.
+ * Once that happens, we can trigger free_deferred_vmemmap_range to actually
+ * free the whole memory-range.
+ */
+static struct page *head_vmemmap_page = NULL;;
+static bool freeing_vmemmap_range = false;
+
+static inline bool vmemmap_dec_and_test(void)
+{
+	return page_ref_dec_and_test(head_vmemmap_page);
+}
+
+static void free_deferred_vmemmap_range(unsigned long start,
+                                       unsigned long end)
+{
+	unsigned long nr_pages = end - start;
+	unsigned long first_section = (unsigned long)head_vmemmap_page;
+
+	while (start >= first_section) {
+		vmemmap_free(start, end, NULL);
+		end = start;
+		start -= nr_pages;
+	}
+	head_vmemmap_page = NULL;
+	freeing_vmemmap_range = false;
+}
+
+static void deferred_vmemmap_free(unsigned long start, unsigned long end)
+{
+	if (!freeing_vmemmap_range) {
+		freeing_vmemmap_range = true;
+		head_vmemmap_page = (struct page *)start;
+	}
+
+	if (vmemmap_dec_and_test())
+		free_deferred_vmemmap_range(start, end);
+}
+
 static struct page *populate_section_memmap(unsigned long pfn,
 		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
@@ -647,6 +735,11 @@ static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
 	unsigned long start = (unsigned long) pfn_to_page(pfn);
 	unsigned long end = start + nr_pages * sizeof(struct page);
 
+	if (PageVmemmap((struct page *)start) || freeing_vmemmap_range) {
+		deferred_vmemmap_free(start, end);
+		return;
+	}
+
 	vmemmap_free(start, end, altmap);
 }
 static void free_map_bootmem(struct page *memmap)
-- 
2.12.3

