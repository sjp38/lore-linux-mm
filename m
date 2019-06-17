Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 174C9C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8D882089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qgnwzBVA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8D882089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140568E0010; Mon, 17 Jun 2019 08:28:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F0FA8E000B; Mon, 17 Jun 2019 08:28:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED4588E0010; Mon, 17 Jun 2019 08:28:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE34E8E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so5912195plo.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uSjp1MI0/DxR5xPXt73Wodait3XTLM3SgT/b55inJKw=;
        b=t6LkhDnHAVmBZWj3lF9jSjec4qbLgKhntT88NJsbs3oPYcnd1RkwAaEha6Be44xM7d
         TbHRiHbM+UaMmLwvOnRc6HXexgGHrVuVmIKiPEFwoaPUcUFfL4XGPcuwYKDxuYE1BCsO
         42uqksHtWMWuiCpnGyLZN1qHHfNDWuZttq7IXV8E2bEDNzoqqWl0nPbf1zwB8u6rPzie
         8UxbHBGNdRmyjLL2jkJG3u5TNTbAbiuC+loGK1t1MPYdlySXrq8JNz9gxUt3kZ/tKYJq
         i7hdFISy+SM+b6v4WGeLI52uzJwjq156G5r83As3P6DL08H6/nhqSENHbS/6dFANCQjH
         k8RQ==
X-Gm-Message-State: APjAAAUowiRLkxlRV/KZr0Z72fTWGrFnsdBapJY7G6nXl9RDB7ELa3Hv
	b3W8jv6AlFyupRcAyghkr7GuW44FY8gaatMPjOakVW68So8gGi/ssuemIREl5SKEfVteHX1Zcpa
	VemBpTDYhN+l/hwor5un32P+xW+AcBwGy5Zg3xhQJ1pXJKqsZeQDYqQfom82pkh0=
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr90612874pfc.103.1560774490364;
        Mon, 17 Jun 2019 05:28:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlVGBAnX/LQ+WUNG10404yQHaW3vQfJtk5/5sQ64HiJpLs23t9jjfAG3IqNUhQXGIDM85P
X-Received: by 2002:a62:7a8a:: with SMTP id v132mr90612808pfc.103.1560774489295;
        Mon, 17 Jun 2019 05:28:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774489; cv=none;
        d=google.com; s=arc-20160816;
        b=WPGG99fBP21KViAyqtwBqyaqnjTbAS2i2HQQ04X5JGqMex1+BsoiEl/aOydpXGcjza
         39Ih5Zes3B4GbFBvTL3kA6LpoCXujaEknyDc9/kyko0zH7vB67eKpFwZeGXTJctK1MNd
         o2pMLeMJ5DTpNCwtiPiKloYcNn2wC/gf0hqoP0c3us1MR18kiqHMUUqYyFQFCL2Irij0
         wPHOGew04H2s6+Xx/461DboTgyfOTXMyP8j6L0EGhTt6uhBC8m24CRSWSpItHl6czQO4
         Vuxefp+MAlTj9UUdv5X604TnG7KJFkcKlIRv8WgTMyEd+KjYo1I+38DRPmm5rD5RE8Xa
         S+og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uSjp1MI0/DxR5xPXt73Wodait3XTLM3SgT/b55inJKw=;
        b=q2Szlh9dCk3Zl8zkq61WF4Vd3EXdfLDHKEsHXK7mRHyaapJ8hh4lSADyi+KfI2xsEw
         lZI002P03Y7Ef7g5ytHneo9Gv6OawMnufk8qq0eAj/44HjK6/0sd6L7DzWsfeWojVM9l
         ETBX1IptJqaRO8ugdjmKfJ+AIKSPQBqMO5ZdaQGKiRZaStRcZ8fMATfG35GjYRbDX5oq
         EgxP7xCIU5uBzvZGsWke6jYbxvodJQYSdhNKl4Ta0J4YHATXnJgiPgo58OCSxY+I+1eV
         RfKjoBBInGYipq9cVsn4tMFaNQxeccHuEQBzuzXUit1h+hCZVZTPR8tcM07qT4Fx2sWs
         9/QA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qgnwzBVA;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d31si10237525pld.248.2019.06.17.05.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qgnwzBVA;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uSjp1MI0/DxR5xPXt73Wodait3XTLM3SgT/b55inJKw=; b=qgnwzBVAM+YfsPgl6+X6TbbF07
	np3jaACyDrf8sNmktsLdcgBaaniAVDeCLEeQ1gpYchqPIqHg4ak6NXvf2IJbGFdSl4aCzlD/6OUh3
	tSYPKbtPsWfr38tg5LTwBSiIUlRVqlIw2ifK+8dcXBt4+cgCEG+ciSFR6zQN1YKLVc6VqF892bUfL
	LSQ0uCxY4lml+pzKNaVcoXiUAwilJZgRIFAbn91YKF5rn2p9b24wvcEy3iBEwf8p8r9baGeuEL0MJ
	MKm42Vy8pvrogb7MNbe7XgcEEeT4QghjEE4XfaQ19W2XHXBi3YlixlAfVU0is7KKYc9tryjtzxtyz
	QAiVkQmQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqk2-0000Dt-40; Mon, 17 Jun 2019 12:28:06 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/25] memremap: replace the altmap_valid field with a PGMAP_ALTMAP_VALID flag
Date: Mon, 17 Jun 2019 14:27:21 +0200
Message-Id: <20190617122733.22432-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a flags field to struct dev_pagemap to replace the altmap_valid
boolean to be a little more extensible.  Also add a pgmap_altmap() helper
to find the optional altmap and clean up the code using the altmap using
it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/mm/mem.c     | 10 +---------
 arch/x86/mm/init_64.c     |  8 ++------
 drivers/nvdimm/pfn_devs.c |  3 +--
 drivers/nvdimm/pmem.c     |  1 -
 include/linux/memremap.h  | 12 +++++++++++-
 kernel/memremap.c         | 26 ++++++++++----------------
 mm/hmm.c                  |  1 -
 mm/memory_hotplug.c       |  6 ++----
 mm/page_alloc.c           |  5 ++---
 9 files changed, 29 insertions(+), 43 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index cba29131bccc..f774d80df025 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -131,17 +131,9 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct page *page;
+	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
 	int ret;
 
-	/*
-	 * If we have an altmap then we need to skip over any reserved PFNs
-	 * when querying the zone.
-	 */
-	page = pfn_to_page(start_pfn);
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
-
 	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
 
 	/* Remove htab bolted mappings for this section of memory */
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 693aaf28d5fe..3139e992ef9d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1211,13 +1211,9 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	struct page *page = pfn_to_page(start_pfn);
-	struct zone *zone;
+	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
+	struct zone *zone = page_zone(page);
 
-	/* With altmap the first mapped page is offset from @start */
-	if (altmap)
-		page += vmem_altmap_offset(altmap);
-	zone = page_zone(page);
 	__remove_pages(zone, start_pfn, nr_pages, altmap);
 	kernel_physical_mapping_remove(start, start + size);
 }
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 01f40672507f..24924a442129 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -630,7 +630,6 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 		if (offset < reserve)
 			return -EINVAL;
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
-		pgmap->altmap_valid = false;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
 		nd_pfn->npfns = PFN_SECTION_ALIGN_UP((resource_size(res)
 					- offset) / PAGE_SIZE);
@@ -642,7 +641,7 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 		memcpy(altmap, &__altmap, sizeof(*altmap));
 		altmap->free = PHYS_PFN(offset - reserve);
 		altmap->alloc = 0;
-		pgmap->altmap_valid = true;
+		pgmap->flags |= PGMAP_ALTMAP_VALID;
 	} else
 		return -ENXIO;
 
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 1ff4b1c4c7c3..7c3d388cf2f7 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -420,7 +420,6 @@ static int pmem_attach_disk(struct device *dev,
 		bb_res.start += pmem->data_offset;
 	} else if (pmem_should_map_pages(dev)) {
 		memcpy(&pmem->pgmap.res, &nsio->res, sizeof(pmem->pgmap.res));
-		pmem->pgmap.altmap_valid = false;
 		pmem->pgmap.type = MEMORY_DEVICE_FS_DAX;
 		pmem->pgmap.ops = &fsdax_pagemap_ops;
 		addr = devm_memremap_pages(dev, &pmem->pgmap);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 036c637f0150..7289eb091b04 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -88,6 +88,8 @@ struct dev_pagemap_ops {
 	vm_fault_t (*migrate_to_ram)(struct vm_fault *vmf);
 };
 
+#define PGMAP_ALTMAP_VALID	(1 << 0)
+
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
@@ -96,19 +98,27 @@ struct dev_pagemap_ops {
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
+ * @flags: PGMAP_* flags to specify defailed behavior
  * @ops: method table
  */
 struct dev_pagemap {
 	struct vmem_altmap altmap;
-	bool altmap_valid;
 	struct resource res;
 	struct percpu_ref *ref;
 	struct device *dev;
 	enum memory_type type;
+	unsigned int flags;
 	u64 pci_p2pdma_bus_offset;
 	const struct dev_pagemap_ops *ops;
 };
 
+static inline struct vmem_altmap *pgmap_altmap(struct dev_pagemap *pgmap)
+{
+	if (pgmap->flags & PGMAP_ALTMAP_VALID)
+		return &pgmap->altmap;
+	return NULL;
+}
+
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 9dd5ccdb1adb..b41d98a64ebf 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -54,14 +54,8 @@ static void pgmap_array_delete(struct resource *res)
 
 static unsigned long pfn_first(struct dev_pagemap *pgmap)
 {
-	const struct resource *res = &pgmap->res;
-	struct vmem_altmap *altmap = &pgmap->altmap;
-	unsigned long pfn;
-
-	pfn = res->start >> PAGE_SHIFT;
-	if (pgmap->altmap_valid)
-		pfn += vmem_altmap_offset(altmap);
-	return pfn;
+	return (pgmap->res.start >> PAGE_SHIFT) +
+		vmem_altmap_offset(pgmap_altmap(pgmap));
 }
 
 static unsigned long pfn_end(struct dev_pagemap *pgmap)
@@ -109,7 +103,7 @@ static void devm_memremap_pages_release(void *data)
 				align_size >> PAGE_SHIFT, NULL);
 	} else {
 		arch_remove_memory(nid, align_start, align_size,
-				pgmap->altmap_valid ? &pgmap->altmap : NULL);
+				pgmap_altmap(pgmap));
 		kasan_remove_zero_shadow(__va(align_start), align_size);
 	}
 	mem_hotplug_done();
@@ -129,8 +123,8 @@ static void devm_memremap_pages_release(void *data)
  * 1/ At a minimum the res, ref and type and ops members of @pgmap must be
  *    initialized by the caller before passing it to this function
  *
- * 2/ The altmap field may optionally be initialized, in which case altmap_valid
- *    must be set to true
+ * 2/ The altmap field may optionally be initialized, in which case
+ *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
  *
  * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
  *    at devm_memremap_pages_release() time, or if this routine fails.
@@ -142,15 +136,13 @@ static void devm_memremap_pages_release(void *data)
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
 	resource_size_t align_start, align_size, align_end;
-	struct vmem_altmap *altmap = pgmap->altmap_valid ?
-			&pgmap->altmap : NULL;
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
 	struct mhp_restrictions restrictions = {
 		/*
 		 * We do not want any optional features only our own memmap
 		*/
-		.altmap = altmap,
+		.altmap = pgmap_altmap(pgmap),
 	};
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
@@ -277,7 +269,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, altmap);
+				align_size >> PAGE_SHIFT, pgmap_altmap(pgmap));
 	}
 
 	mem_hotplug_done();
@@ -322,7 +314,9 @@ EXPORT_SYMBOL_GPL(devm_memunmap_pages);
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap)
 {
 	/* number of pfns from base where pfn_to_page() is valid */
-	return altmap->reserve + altmap->free;
+	if (altmap)
+		return altmap->reserve + altmap->free;
+	return 0;
 }
 
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns)
diff --git a/mm/hmm.c b/mm/hmm.c
index 8a0e04bbeee6..307c12d7531c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1439,7 +1439,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 	devmem->pagemap.res = *devmem->resource;
 	devmem->pagemap.ops = &hmm_pagemap_ops;
-	devmem->pagemap.altmap_valid = false;
 	devmem->pagemap.ref = &devmem->ref;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e096c987d261..6166ba5a15f3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -557,10 +557,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	int sections_to_remove;
 
 	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	}
+	if (is_dev_zone(zone))
+		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..17a39d40a556 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5853,6 +5853,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 {
 	unsigned long pfn, end_pfn = start_pfn + size;
 	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct vmem_altmap *altmap = pgmap_altmap(pgmap);
 	unsigned long zone_idx = zone_idx(zone);
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
@@ -5865,9 +5866,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	 * of the pages reserved for the memmap, so we can just jump to
 	 * the end of that region and start processing the device pages.
 	 */
-	if (pgmap->altmap_valid) {
-		struct vmem_altmap *altmap = &pgmap->altmap;
-
+	if (altmap) {
 		start_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
 		size = end_pfn - start_pfn;
 	}
-- 
2.20.1

