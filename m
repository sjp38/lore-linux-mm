Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAF8AC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8618D21473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="udKbgJZR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8618D21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A36A76B0272; Thu, 13 Jun 2019 05:44:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E9806B0273; Thu, 13 Jun 2019 05:44:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750D16B0274; Thu, 13 Jun 2019 05:44:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 356FB6B0272
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j21so14099429pff.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bHeNfTwD4XAIS0eLeLiZcWglvOw+19Z/Sq7aWx7Y048=;
        b=LlVhpOAhtMRh7k/XusKW1u69O/HDt1mX9nFhYsjYullevexykT5l/G65vi+evOTy1U
         AdBG3+AdKAZXvINFBeIdObRasPDl9TwaZtg3NTpfQ3+8U2DuTayKwgp1Ehwi6Rd2Z0Is
         ICQ1q20fkE0D6yCA/qyMMCZClK1PwHz7ycnyH+853st2CpH+1MgKqFkZ+nNGM9foePwG
         vztLwTqm/ZCoWcL6ktoDDUNT6ySI31vSLiM7iEjLK13PfBXUxj7to39dxY4fybcUb9YA
         in43NFra34FBqd+4TuH4N42KXlp2GF5bjRej4i8NHo0KT38Zo9xoEh6GJaUSNP1rfvrB
         Y+Hg==
X-Gm-Message-State: APjAAAXluJ1Gm49fIJOcXpwmZQsNRIjKXbHOBj9MPuJG9ZWRcfvfuQZx
	4PS7kYbJHjSSWg/Bj8QFGqMydumY9fx8GegmNkzX/Gdo6lirZlappkN2yzFxYw2My2bhxYHvzSi
	H/PP05S79ZFMVfOfcYKvkqDsnScD+l+sAgyOy6HzJfBLCdv8XHwYTLkwctnuzCUM=
X-Received: by 2002:a65:40cb:: with SMTP id u11mr6661578pgp.333.1560419062740;
        Thu, 13 Jun 2019 02:44:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5v+363VnDcRr3qDG0gIqr3IrYwLNo197/K8A56BsSPb6AddepQBVXtoNqMDXMNHy2Jt2y
X-Received: by 2002:a65:40cb:: with SMTP id u11mr6661428pgp.333.1560419061267;
        Thu, 13 Jun 2019 02:44:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419061; cv=none;
        d=google.com; s=arc-20160816;
        b=q4k7qTvRItFshXPIYj3OL8/5v9ChcQDVMLZy2cc/Yp7tyQmHjYDYJvw5AD5LsEIsbO
         wBRTz99avGJ3AMZpWdSyGM/45/mXJ4qyLN6AuLDnykpxrGh+C5yg0/rBdKIoAxfA9PR0
         57kospFv2lCK33OjgGYHx6LVI+zHpoNH3solRdVN2+umNctlbWp2s8PpxFN11xb58e6m
         mgfGVpOcxZsiUXhLnxgjRvZyHn6TMw/SB5/rfbquv83DTBckvLBTo5rTcPgVcVLBQYiJ
         0NnDXM2+wp8aDpKJBh5LSc9smXSivJXBnEIYB/GhBYXrxcuBh7Egiplk8M+0z5/oqhFF
         6N1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bHeNfTwD4XAIS0eLeLiZcWglvOw+19Z/Sq7aWx7Y048=;
        b=Vd50JjEGt964mhodq02DHnlJmLLzD4cmOAPLra3GsKuGPAWr++YPoE3JOOYGdCjtWd
         NtpX9QRZMdhenx+1OaujHcB++74jJnoc56foqluiB3FQiofQCS/PHNiLFBrzn0qrt5VB
         acMDGfI7mr0J/DgkQysI/W7wH+nziR74xNmuqT8K3zuGTvxiPAM6g5KDO1rCaF3uIGKH
         28ZWnh9wrzn5EaukAeylZ1QLeiKPI5SPpi8q4w+Vt7CdZ9c6ImQlhtixD2M54O5SDDlz
         WwP9acwm3XH3eIgVi23i1u1VaXMv/Uy5xSiD3Sdm2I51P295yTK7p/n+ugJzXwTKElBp
         68Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=udKbgJZR;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a9si2475307pls.109.2019.06.13.02.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=udKbgJZR;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=bHeNfTwD4XAIS0eLeLiZcWglvOw+19Z/Sq7aWx7Y048=; b=udKbgJZRJ+SciwR1Pd2q2Ka65G
	9Skj/f/gJTQ+G9l3fpEf5dUSUFcYh4QSwiDYZHL2RgWWhVw1acSH3tCYUNAdEMgWjvKo9XmZJKowh
	ynPRiFcvwNh6m1Qke2wr57eEX6NYF82GOwMdjZuINowQ/aiErhvPQvL+uj9CEzkporjQHs5Iji2lr
	OdhXwDyPRQt5lyuEIA33C7LIhZVxwjAv+lbGWP3qPVg3XyAWri6plie5WWu1n/mj/M+A76ZBdXqMx
	zpQCcIA67an3Shb/STrkhn7Fz+6a7GXN3TcVMw1u7P1mN1h2pWvHraQmJn4sm19vwHc16182jf4WO
	A19H4NrA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMHK-0001uV-3d; Thu, 13 Jun 2019 09:44:18 +0000
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
Subject: [PATCH 17/22] mm: remove hmm_devmem_add
Date: Thu, 13 Jun 2019 11:43:20 +0200
Message-Id: <20190613094326.24093-18-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't really much value add in the hmm_devmem_add wrapper.  Just
factor out a little helper to find the resource, and otherwise let the
driver implement the dev_pagemap_ops directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 Documentation/vm/hmm.rst |  26 --------
 include/linux/hmm.h      | 129 ---------------------------------------
 mm/hmm.c                 | 115 ----------------------------------
 3 files changed, 270 deletions(-)

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
index 0e61d830b0a9..13152ab504ec 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -551,135 +551,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
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
index c15283f9bbf0..5b2e9bb6063a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1290,118 +1290,3 @@ long hmm_range_dma_unmap(struct hmm_range *range,
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
-static void hmm_devmem_ref_exit(void *data)
-{
-	struct percpu_ref *ref = data;
-	struct hmm_devmem *devmem;
-
-	devmem = container_of(ref, struct hmm_devmem, ref);
-	wait_for_completion(&devmem->completion);
-	percpu_ref_exit(ref);
-}
-
-static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
-{
-	percpu_ref_kill(pgmap->ref);
-}
-
-static vm_fault_t hmm_devmem_migrate(struct vm_fault *vmf)
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
-	.migrate		= hmm_devmem_migrate,
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
-	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit, &devmem->ref);
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
-	devmem->pagemap.altmap_valid = false;
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

