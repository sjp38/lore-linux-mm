Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3513C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909C42084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ikcpIHXB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909C42084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A66008E0017; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A174C8E000B; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CD4A8E0019; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 353C78E0017
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f2so5877685plr.0
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p1ZrEtGR2yZrdK074qYGx4skRkZcef7n/LfOoR6uVVM=;
        b=B/fIWsv9k/Qmj4zrnrazvCC0L0LVCULvK7zZQmhvdNRdxTbbfZIn6B6Sm0P2I3h3S2
         qRLIv6M70QuGNHDBtS2Aljobgt3GN/sOrR1BFNiyTnyMgrmf7RE+/L8SBuDPACkn0x4r
         MH88vXDLPH85CnTq/i4Zb8HAxKUOXjV6dUinypcuX3ZlRMttKR3HY8PqAb2cXKsD5twb
         FMPhouU8BhltGc5eqn9Xpazlx+vSfRN1y9xZV+8gPynkLBgRaxk5K7Stwski06A567ON
         nb7tl94GsOaAoBjEXzbHIDT79XpLcWt3GAGjzup94Dyu0prIK390lzBfmli9jcJfXLNM
         o6EA==
X-Gm-Message-State: APjAAAXrfGuDkzGUaswrOcF44zW9ff0csH4HJ+ZNZXv5hDjZe2AHQUX9
	iP5M4YLceZ1sktyZXYaBMRyrofMQkkLHI0cU7ukCfI/4RuGhDxt0iZcS3Lkf7ICfOylH1sQjm1z
	gYnlQ6rmHOIPVBHXRnXKEUKan/ZiyQAZqd3K/eSt6ZV1Bo0oa57IFNcelHOshLkQ=
X-Received: by 2002:a17:90a:9291:: with SMTP id n17mr25422689pjo.66.1560774508814;
        Mon, 17 Jun 2019 05:28:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxT4rOWYLyHcUgpi29Ueto1rcTCuEgEXL+xeFFDJcC1luxagNRKdwW2sFFi/jjgoiOI2EqB
X-Received: by 2002:a17:90a:9291:: with SMTP id n17mr25422617pjo.66.1560774507645;
        Mon, 17 Jun 2019 05:28:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774507; cv=none;
        d=google.com; s=arc-20160816;
        b=v0dt4AqTkeWxmLugKTPEH4Q3I34AbLqYiTZBqkS+dVw7AwI576rHHjW/+3VU01dVOF
         Iw16+q7eBdIIKPejcWN5I1ZuXVzN2GmweCFp6W0SNw2mtxDteMlkYlr1dNaTmbjfEeL6
         +vxiHQluWdBN7RVsvBiNqwkBL2Gdz8z3bHjDu/6QZIMFnD1rFpk9w+/UnGm9zeQHLhgq
         nEllODr/qo2Jltw0l5OMdCivWTuDxSPg/b47XdQwCdy8/ZTOcdl8bWYXyshLMaDIlbj9
         tThtQzgeSyOAMLbohGDIGw0yVVeNoJjuzhhojpvEjn+0EoOc7loMPyXtX8AvUCh/eBLv
         Makg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=p1ZrEtGR2yZrdK074qYGx4skRkZcef7n/LfOoR6uVVM=;
        b=uFOPRHJ73oWdBlrgd3+f2rx+95Hr0hAw+c+XM8pvuHazlpr3Kmv93MypkTtrY2b3KE
         67ibGHherKxzVA9DXPaPQ3XdnfLZ7xN5VU8wLrSTdWEnHtKaG7sFE04tQ9ZkVW50NpQl
         gHGXxx8I+FaxrxecyIQ3s/POj73rMm4o481dE6wEPaddcthvROn4MgMOVcWd1zqa+BGO
         xyfHpjdgvzIkBOCGW6hyAA2MPJYM3i7nqRym12xwja9vJqpkbnyvPFCQ1bo7z1Eg4K8r
         UdhUpD6y/FJZ7lHC86irbA0hyVTJ7M+ccDngFE17857YoM7p/q/EBSGEB+8oghM++0Qn
         tKrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ikcpIHXB;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1si10149519pli.151.2019.06.17.05.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ikcpIHXB;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=p1ZrEtGR2yZrdK074qYGx4skRkZcef7n/LfOoR6uVVM=; b=ikcpIHXBPSyetnmjaGo2E9ZIsW
	47HEbyazOAyqWhsgjHN6tpxC4KMjCz7r7jdtURQnDY/ZTB2t1kgJMv2x03ocveBfX+ORj7e8sZA6R
	ieSeEYAqaDfExWXGSnzeMI0yTrExKrE0fMJPOAw/b4ddlk2ssmwGQ/BucqJEhR4PbovdTLprqbWip
	ca3eKxXEyvES9BB5GD1sh9R3VksCOisfE5Vq3HDM8SL2TPRBHQeVfuArHveID8tC06UO/2Joj+ZEo
	aD9QhETPJxx7sQj4d3rNLB3MJlhCc+8k0Sc55VlUja1/YodNjUQHHp7AE12rvOYXozFN7osSinvis
	bb2gYvew==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkH-0000Nl-Ia; Mon, 17 Jun 2019 12:28:21 +0000
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
Subject: [PATCH 20/25] mm: remove hmm_devmem_add
Date: Mon, 17 Jun 2019 14:27:28 +0200
Message-Id: <20190617122733.22432-21-hch@lst.de>
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

There isn't really much value add in the hmm_devmem_add wrapper and
more, as using devm_memremap_pages directly now is just as simple.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 Documentation/vm/hmm.rst |  26 --------
 include/linux/hmm.h      | 129 ---------------------------------------
 mm/hmm.c                 | 110 ---------------------------------
 3 files changed, 265 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 7b6eeda5a7c0..b1c960fe246d 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -336,32 +336,6 @@ directly using struct page for device memory which left most kernel code paths
 unaware of the difference. We only need to make sure that no one ever tries to
 map those pages from the CPU side.
 
-HMM provides a set of helpers to register and hotplug device memory as a new
-region needing a struct page. This is offered through a very simple API::
-
- struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-                                   struct device *device,
-                                   unsigned long size);
- void hmm_devmem_remove(struct hmm_devmem *devmem);
-
-The hmm_devmem_ops is where most of the important things are::
-
- struct hmm_devmem_ops {
-     void (*free)(struct hmm_devmem *devmem, struct page *page);
-     vm_fault_t (*fault)(struct hmm_devmem *devmem,
-                  struct vm_area_struct *vma,
-                  unsigned long addr,
-                  struct page *page,
-                  unsigned flags,
-                  pmd_t *pmdp);
- };
-
-The first callback (free()) happens when the last reference on a device page is
-dropped. This means the device page is now free and no longer used by anyone.
-The second callback happens whenever the CPU tries to access a device page
-which it cannot do. This second callback must trigger a migration back to
-system memory.
-
 
 Migration to and from device memory
 ===================================
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 89571e8d9c63..50ef29958604 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -587,135 +587,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-struct hmm_devmem;
-
-/*
- * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
- *
- * @free: call when refcount on page reach 1 and thus is no longer use
- * @fault: call when there is a page fault to unaddressable memory
- *
- * Both callback happens from page_free() and page_fault() callback of struct
- * dev_pagemap respectively. See include/linux/memremap.h for more details on
- * those.
- *
- * The hmm_devmem_ops callback are just here to provide a coherent and
- * uniq API to device driver and device driver should not register their
- * own page_free() or page_fault() but rely on the hmm_devmem_ops call-
- * back.
- */
-struct hmm_devmem_ops {
-	/*
-	 * free() - free a device page
-	 * @devmem: device memory structure (see struct hmm_devmem)
-	 * @page: pointer to struct page being freed
-	 *
-	 * Call back occurs whenever a device page refcount reach 1 which
-	 * means that no one is holding any reference on the page anymore
-	 * (ZONE_DEVICE page have an elevated refcount of 1 as default so
-	 * that they are not release to the general page allocator).
-	 *
-	 * Note that callback has exclusive ownership of the page (as no
-	 * one is holding any reference).
-	 */
-	void (*free)(struct hmm_devmem *devmem, struct page *page);
-	/*
-	 * fault() - CPU page fault or get user page (GUP)
-	 * @devmem: device memory structure (see struct hmm_devmem)
-	 * @vma: virtual memory area containing the virtual address
-	 * @addr: virtual address that faulted or for which there is a GUP
-	 * @page: pointer to struct page backing virtual address (unreliable)
-	 * @flags: FAULT_FLAG_* (see include/linux/mm.h)
-	 * @pmdp: page middle directory
-	 * Return: VM_FAULT_MINOR/MAJOR on success or one of VM_FAULT_ERROR
-	 *   on error
-	 *
-	 * The callback occurs whenever there is a CPU page fault or GUP on a
-	 * virtual address. This means that the device driver must migrate the
-	 * page back to regular memory (CPU accessible).
-	 *
-	 * The device driver is free to migrate more than one page from the
-	 * fault() callback as an optimization. However if the device decides
-	 * to migrate more than one page it must always priotirize the faulting
-	 * address over the others.
-	 *
-	 * The struct page pointer is only given as a hint to allow quick
-	 * lookup of internal device driver data. A concurrent migration
-	 * might have already freed that page and the virtual address might
-	 * no longer be backed by it. So it should not be modified by the
-	 * callback.
-	 *
-	 * Note that mmap semaphore is held in read mode at least when this
-	 * callback occurs, hence the vma is valid upon callback entry.
-	 */
-	vm_fault_t (*fault)(struct hmm_devmem *devmem,
-		     struct vm_area_struct *vma,
-		     unsigned long addr,
-		     const struct page *page,
-		     unsigned int flags,
-		     pmd_t *pmdp);
-};
-
-/*
- * struct hmm_devmem - track device memory
- *
- * @completion: completion object for device memory
- * @pfn_first: first pfn for this resource (set by hmm_devmem_add())
- * @pfn_last: last pfn for this resource (set by hmm_devmem_add())
- * @resource: IO resource reserved for this chunk of memory
- * @pagemap: device page map for that chunk
- * @device: device to bind resource to
- * @ops: memory operations callback
- * @ref: per CPU refcount
- * @page_fault: callback when CPU fault on an unaddressable device page
- *
- * This is a helper structure for device drivers that do not wish to implement
- * the gory details related to hotplugging new memoy and allocating struct
- * pages.
- *
- * Device drivers can directly use ZONE_DEVICE memory on their own if they
- * wish to do so.
- *
- * The page_fault() callback must migrate page back, from device memory to
- * system memory, so that the CPU can access it. This might fail for various
- * reasons (device issues,  device have been unplugged, ...). When such error
- * conditions happen, the page_fault() callback must return VM_FAULT_SIGBUS and
- * set the CPU page table entry to "poisoned".
- *
- * Note that because memory cgroup charges are transferred to the device memory,
- * this should never fail due to memory restrictions. However, allocation
- * of a regular system page might still fail because we are out of memory. If
- * that happens, the page_fault() callback must return VM_FAULT_OOM.
- *
- * The page_fault() callback can also try to migrate back multiple pages in one
- * chunk, as an optimization. It must, however, prioritize the faulting address
- * over all the others.
- */
-
-struct hmm_devmem {
-	struct completion		completion;
-	unsigned long			pfn_first;
-	unsigned long			pfn_last;
-	struct resource			*resource;
-	struct device			*device;
-	struct dev_pagemap		pagemap;
-	const struct hmm_devmem_ops	*ops;
-	struct percpu_ref		ref;
-};
-
-/*
- * To add (hotplug) device memory, HMM assumes that there is no real resource
- * that reserves a range in the physical address space (this is intended to be
- * use by unaddressable device memory). It will reserve a physical range big
- * enough and allocate struct page for it.
- *
- * The device driver can wrap the hmm_devmem struct inside a private device
- * driver struct.
- */
-struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-				  struct device *device,
-				  unsigned long size);
-
 /*
  * hmm_devmem_page_set_drvdata - set per-page driver data field
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index 0ef1a1921afb..17ed080d9c32 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1324,113 +1324,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
 }
 EXPORT_SYMBOL(hmm_range_dma_unmap);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-
-
-#if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-static void hmm_devmem_ref_release(struct percpu_ref *ref)
-{
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(ref, struct hmm_devmem, ref);
-	complete(&devmem->completion);
-}
-
-static void hmm_devmem_ref_exit(struct dev_pagemap *pgmap)
-{
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(pgmap, struct hmm_devmem, pagemap);
-	wait_for_completion(&devmem->completion);
-	percpu_ref_exit(pgmap->ref);
-}
-
-static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
-{
-	percpu_ref_kill(pgmap->ref);
-}
-
-static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
-{
-	struct hmm_devmem *devmem =
-		container_of(vmf->page->pgmap, struct hmm_devmem, pagemap);
-
-	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
-			vmf->flags, vmf->pmd);
-}
-
-static void hmm_devmem_free(struct page *page)
-{
-	struct hmm_devmem *devmem =
-		container_of(page->pgmap, struct hmm_devmem, pagemap);
-
-	devmem->ops->free(devmem, page);
-}
-
-static const struct dev_pagemap_ops hmm_pagemap_ops = {
-	.page_free		= hmm_devmem_free,
-	.kill			= hmm_devmem_ref_kill,
-	.cleanup		= hmm_devmem_ref_exit,
-	.migrate_to_ram		= hmm_devmem_migrate_to_ram,
-};
-
-/*
- * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
- *
- * @ops: memory event device driver callback (see struct hmm_devmem_ops)
- * @device: device struct to bind the resource too
- * @size: size in bytes of the device memory to add
- * Return: pointer to new hmm_devmem struct ERR_PTR otherwise
- *
- * This function first finds an empty range of physical address big enough to
- * contain the new resource, and then hotplugs it as ZONE_DEVICE memory, which
- * in turn allocates struct pages. It does not do anything beyond that; all
- * events affecting the memory will go through the various callbacks provided
- * by hmm_devmem_ops struct.
- *
- * Device driver should call this function during device initialization and
- * is then responsible of memory management. HMM only provides helpers.
- */
-struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
-				  struct device *device,
-				  unsigned long size)
-{
-	struct hmm_devmem *devmem;
-	void *result;
-	int ret;
-
-	devmem = devm_kzalloc(device, sizeof(*devmem), GFP_KERNEL);
-	if (!devmem)
-		return ERR_PTR(-ENOMEM);
-
-	init_completion(&devmem->completion);
-	devmem->pfn_first = -1UL;
-	devmem->pfn_last = -1UL;
-	devmem->resource = NULL;
-	devmem->device = device;
-	devmem->ops = ops;
-
-	ret = percpu_ref_init(&devmem->ref, &hmm_devmem_ref_release,
-			      0, GFP_KERNEL);
-	if (ret)
-		return ERR_PTR(ret);
-
-	devmem->resource = devm_request_free_mem_region(device, &iomem_resource,
-			size);
-	if (IS_ERR(devmem->resource))
-		return ERR_CAST(devmem->resource);
-	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
-	devmem->pfn_last = devmem->pfn_first +
-			   (resource_size(devmem->resource) >> PAGE_SHIFT);
-
-	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
-	devmem->pagemap.res = *devmem->resource;
-	devmem->pagemap.ops = &hmm_pagemap_ops;
-	devmem->pagemap.ref = &devmem->ref;
-
-	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
-	if (IS_ERR(result))
-		return result;
-	return devmem;
-}
-EXPORT_SYMBOL_GPL(hmm_devmem_add);
-#endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
-- 
2.20.1

