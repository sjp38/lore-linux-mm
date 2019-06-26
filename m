Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EBB5C48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECEB020663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N9Fj6S/h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECEB020663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F48D8E0012; Wed, 26 Jun 2019 08:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 454A58E000E; Wed, 26 Jun 2019 08:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A7B58E0012; Wed, 26 Jun 2019 08:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD1378E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so1681151pfy.9
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O7gxV+NMGR5OMAJyXLh5ldD7ILUOCB34MSOaQp729Ms=;
        b=tqETbhS3H4dSQu0vaotZXT0UcS8OvSxtX2hXV02cndyFTfCCJR7VNZS9HfYlFh4cxO
         O/RsyG3sw70q8x/FKw5zhCc9fRM+VGvk0Q2GV96kg27X7MZiG6VCVzAPpy5rDJDAGXbD
         A7nB2T1NcDWHxVS0T4JwEi7SECwX7sqr3UnKioaWplT+vuMdGKAFa5XS7MbNRFmMhZ1y
         c08Kaz8IaCN7f43fCEE4jp8APgYxfF4BLxaJ4C42K7O3Y+u6CHg0hiG3uQ1YpYLts7IB
         LbZLPpYCouWPoPE+uiyXDv7qd4oWAJ4ATqDXW1q+aOzBocShVc6qKb1J4U0WQnyp58wF
         mSng==
X-Gm-Message-State: APjAAAXUnMGxU6M8whujNnr1lhtXSl/MPRnZZ1ycHjpB1Ct10+iWm0F+
	hm59T/qIFS+QYYImI0AvZy7bMMZtmu5exlTiifyKL0IVRoANErmv7RmoCKOhm23WSuq9XvvIPQR
	UA6UTHXihoKH/17+M8zQDjym7fmyP49XKp3/yBj1NX452l529Him/RU/rb3PtBp8=
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr5284156plq.144.1561552076541;
        Wed, 26 Jun 2019 05:27:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2ORsluZjYXJEzviowles2tlgMwx0w5Phke5JMoe0iDAfs9bIl7BmEGQo83sFtoSPpOHNX
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr5283996plq.144.1561552074583;
        Wed, 26 Jun 2019 05:27:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552074; cv=none;
        d=google.com; s=arc-20160816;
        b=xw29p4Lk5yPWKxhyjMqhsc6fRSDEabOgEAwdq1L4oH5V+sdXS7pse63MmpdtxxwBix
         twvqJkCf2qtecZqBiUfGjAbyI+XsqdkbrF8fBeDoOxJiHy8WZQ2liTk4f67H4IPE5nx8
         RlSZjuAVbhIcKBsXX0JJm27Cmz5vMN7mxdg40CTVCXRViiW4LjNB06rl79u1xrSshoQn
         SAns7Ncn/3FPFuydKJDeS2JvPNypTUUnP9AKVp9pxgwlTMOCbbYIJsLIaXA/zY5Izj50
         FB4WivXoTlrMWfq7TiuDM7sshqZi12lMxicgSAeOtpMJuuRjVRtkBFaovi+yzb1ZQa93
         eLrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=O7gxV+NMGR5OMAJyXLh5ldD7ILUOCB34MSOaQp729Ms=;
        b=tnOp7HTx5u5eE6i7+SD/PJCahCJX6llBGq5pSssWIQzPTew5WyLaLvWv7QOEdzSBcQ
         D92OXF5ZDu0FEz0yW+qJCQ0a2FabKtcRQgAg1ipVhcdER2FXDrml4rmwphcVcdiLV42W
         BdGQ1yppg8tE+XFj1R4WT0G59M2N4nC6ZOH8IBQPt4oJj+heQgttT58acSpj8U+KHblM
         BY+NYRIgkyiDzUmhIivH1w87ID9nR1K329nBu9RSTqJXs90zga01kC/ewKhgNMetdpp/
         4jjlT6xP85nEh+Y6UORguF6p01D6ehaDlCxnfe+41NZCBUTFthA3d9JwLBvDGQhWk8eK
         o39w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N9Fj6S/h";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33si3256592pli.144.2019.06.26.05.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N9Fj6S/h";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=O7gxV+NMGR5OMAJyXLh5ldD7ILUOCB34MSOaQp729Ms=; b=N9Fj6S/hfmh+xqoXQ2sKM4yEgo
	KQKDPRUD2DMRRWWh3kRReAFyWfPFSSCJD6pLgCupss5O0nGrMxNWM3kzDH1P+hOfn+gAZX7J6UK+c
	6WwwHY7valGqsYL6wEmFG+GsB569g46DYmfmqUDJPq0gQm9wOy2VnCdKDq1ubjf4XkvAokS27pEbF
	GsZTXPff7fToySN3h4SyuiHyicp700RDTVheBiSVxnp37LoY25H+f8KJI46YJFPS8ih6ENjtR63k+
	7OM4tWWuWvow4DYqQHA5GNzwoGcukTKJlGK0Amn0AyBR8XC85TKtuK7IqUACVduy5OTBwcvyC38Y7
	p+sG9z4g==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71j-0001Os-5v; Wed, 26 Jun 2019 12:27:51 +0000
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
	linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>
Subject: [PATCH 09/25] memremap: move dev_pagemap callbacks into a separate structure
Date: Wed, 26 Jun 2019 14:27:08 +0200
Message-Id: <20190626122724.13313-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dev_pagemap is a growing too many callbacks.  Move them into a
separate ops structure so that they are not duplicated for multiple
instances, and an attacker can't easily overwrite them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/dax/device.c              | 11 ++++++----
 drivers/dax/pmem/core.c           |  2 +-
 drivers/nvdimm/pmem.c             | 19 +++++++++-------
 drivers/pci/p2pdma.c              |  8 +++++--
 include/linux/memremap.h          | 36 +++++++++++++++++--------------
 kernel/memremap.c                 | 18 ++++++++--------
 mm/hmm.c                          | 10 ++++++---
 tools/testing/nvdimm/test/iomap.c |  7 +++---
 8 files changed, 65 insertions(+), 46 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 79014baa782d..f390083a64d7 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -36,9 +36,8 @@ static void dev_dax_percpu_exit(struct percpu_ref *ref)
 	percpu_ref_exit(ref);
 }
 
-static void dev_dax_percpu_kill(struct percpu_ref *data)
+static void dev_dax_percpu_kill(struct percpu_ref *ref)
 {
-	struct percpu_ref *ref = data;
 	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
 
 	dev_dbg(&dev_dax->dev, "%s\n", __func__);
@@ -442,6 +441,11 @@ static void dev_dax_kill(void *dev_dax)
 	kill_dev_dax(dev_dax);
 }
 
+static const struct dev_pagemap_ops dev_dax_pagemap_ops = {
+	.kill		= dev_dax_percpu_kill,
+	.cleanup	= dev_dax_percpu_exit,
+};
+
 int dev_dax_probe(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
@@ -466,9 +470,8 @@ int dev_dax_probe(struct device *dev)
 		return rc;
 
 	dev_dax->pgmap.ref = &dev_dax->ref;
-	dev_dax->pgmap.kill = dev_dax_percpu_kill;
-	dev_dax->pgmap.cleanup = dev_dax_percpu_exit;
 	dev_dax->pgmap.type = MEMORY_DEVICE_DEVDAX;
+	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
diff --git a/drivers/dax/pmem/core.c b/drivers/dax/pmem/core.c
index f9f51786d556..6eb6dfdf19bf 100644
--- a/drivers/dax/pmem/core.c
+++ b/drivers/dax/pmem/core.c
@@ -16,7 +16,7 @@ struct dev_dax *__dax_pmem_probe(struct device *dev, enum dev_dax_subsys subsys)
 	struct dev_dax *dev_dax;
 	struct nd_namespace_io *nsio;
 	struct dax_region *dax_region;
-	struct dev_pagemap pgmap = { 0 };
+	struct dev_pagemap pgmap = { };
 	struct nd_namespace_common *ndns;
 	struct nd_dax *nd_dax = to_nd_dax(dev);
 	struct nd_pfn *nd_pfn = &nd_dax->nd_pfn;
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 24d7fe7c74ed..c2449af2b388 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -303,7 +303,7 @@ static const struct attribute_group *pmem_attribute_groups[] = {
 	NULL,
 };
 
-static void __pmem_release_queue(struct percpu_ref *ref)
+static void pmem_pagemap_cleanup(struct percpu_ref *ref)
 {
 	struct request_queue *q;
 
@@ -313,10 +313,10 @@ static void __pmem_release_queue(struct percpu_ref *ref)
 
 static void pmem_release_queue(void *ref)
 {
-	__pmem_release_queue(ref);
+	pmem_pagemap_cleanup(ref);
 }
 
-static void pmem_freeze_queue(struct percpu_ref *ref)
+static void pmem_pagemap_kill(struct percpu_ref *ref)
 {
 	struct request_queue *q;
 
@@ -339,19 +339,24 @@ static void pmem_release_pgmap_ops(void *__pgmap)
 	dev_pagemap_put_ops();
 }
 
-static void fsdax_pagefree(struct page *page, void *data)
+static void pmem_pagemap_page_free(struct page *page, void *data)
 {
 	wake_up_var(&page->_refcount);
 }
 
+static const struct dev_pagemap_ops fsdax_pagemap_ops = {
+	.page_free		= pmem_pagemap_page_free,
+	.kill			= pmem_pagemap_kill,
+	.cleanup		= pmem_pagemap_cleanup,
+};
+
 static int setup_pagemap_fsdax(struct device *dev, struct dev_pagemap *pgmap)
 {
 	dev_pagemap_get_ops();
 	if (devm_add_action_or_reset(dev, pmem_release_pgmap_ops, pgmap))
 		return -ENOMEM;
 	pgmap->type = MEMORY_DEVICE_FS_DAX;
-	pgmap->page_free = fsdax_pagefree;
-
+	pgmap->ops = &fsdax_pagemap_ops;
 	return 0;
 }
 
@@ -409,8 +414,6 @@ static int pmem_attach_disk(struct device *dev,
 
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
-	pmem->pgmap.kill = pmem_freeze_queue;
-	pmem->pgmap.cleanup = __pmem_release_queue;
 	if (is_nd_pfn(dev)) {
 		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
 			return -ENOMEM;
diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index a98126ad9c3a..13f0380a8c7f 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -152,6 +152,11 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
 	return error;
 }
 
+static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
+	.kill		= pci_p2pdma_percpu_kill,
+	.cleanup	= pci_p2pdma_percpu_cleanup,
+};
+
 /**
  * pci_p2pdma_add_resource - add memory for use as p2p memory
  * @pdev: the device to add the memory to
@@ -207,8 +212,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
 	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
 		pci_resource_start(pdev, bar);
-	pgmap->kill = pci_p2pdma_percpu_kill;
-	pgmap->cleanup = pci_p2pdma_percpu_cleanup;
+	pgmap->ops = &pci_p2pdma_pagemap_ops;
 
 	addr = devm_memremap_pages(&pdev->dev, pgmap);
 	if (IS_ERR(addr)) {
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 0c86f2c5ac9c..919755f48c7e 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -63,41 +63,45 @@ enum memory_type {
 	MEMORY_DEVICE_PCI_P2PDMA,
 };
 
-/*
- * Additional notes about MEMORY_DEVICE_PRIVATE may be found in
- * include/linux/hmm.h and Documentation/vm/hmm.rst. There is also a brief
- * explanation in include/linux/memory_hotplug.h.
- *
- * The page_free() callback is called once the page refcount reaches 1
- * (ZONE_DEVICE pages never reach 0 refcount unless there is a refcount bug.
- * This allows the device driver to implement its own memory management.)
- */
-typedef void (*dev_page_free_t)(struct page *page, void *data);
+struct dev_pagemap_ops {
+	/*
+	 * Called once the page refcount reaches 1.  (ZONE_DEVICE pages never
+	 * reach 0 refcount unless there is a refcount bug. This allows the
+	 * device driver to implement its own memory management.)
+	 */
+	void (*page_free)(struct page *page, void *data);
+
+	/*
+	 * Transition the refcount in struct dev_pagemap to the dead state.
+	 */
+	void (*kill)(struct percpu_ref *ref);
+
+	/*
+	 * Wait for refcount in struct dev_pagemap to be idle and reap it.
+	 */
+	void (*cleanup)(struct percpu_ref *ref);
+};
 
 /**
  * struct dev_pagemap - metadata for ZONE_DEVICE mappings
- * @page_free: free page callback when page refcount reaches 1
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
- * @kill: callback to transition @ref to the dead state
- * @cleanup: callback to wait for @ref to be idle and reap it
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
+ * @ops: method table
  */
 struct dev_pagemap {
-	dev_page_free_t page_free;
 	struct vmem_altmap altmap;
 	bool altmap_valid;
 	struct resource res;
 	struct percpu_ref *ref;
-	void (*kill)(struct percpu_ref *ref);
-	void (*cleanup)(struct percpu_ref *ref);
 	struct device *dev;
 	void *data;
 	enum memory_type type;
 	u64 pci_p2pdma_bus_offset;
+	const struct dev_pagemap_ops *ops;
 };
 
 #ifdef CONFIG_ZONE_DEVICE
diff --git a/kernel/memremap.c b/kernel/memremap.c
index abda62d1e5a3..0824237ef979 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -92,10 +92,10 @@ static void devm_memremap_pages_release(void *data)
 	unsigned long pfn;
 	int nid;
 
-	pgmap->kill(pgmap->ref);
+	pgmap->ops->kill(pgmap->ref);
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
-	pgmap->cleanup(pgmap->ref);
+	pgmap->ops->cleanup(pgmap->ref);
 
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -128,8 +128,8 @@ static void devm_memremap_pages_release(void *data)
  * @pgmap: pointer to a struct dev_pagemap
  *
  * Notes:
- * 1/ At a minimum the res, ref and type members of @pgmap must be initialized
- *    by the caller before passing it to this function
+ * 1/ At a minimum the res, ref and type and ops members of @pgmap must be
+ *    initialized by the caller before passing it to this function
  *
  * 2/ The altmap field may optionally be initialized, in which case altmap_valid
  *    must be set to true
@@ -179,7 +179,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		break;
 	}
 
-	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
+	if (!pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
+	    !pgmap->ops->cleanup) {
 		WARN(1, "Missing reference count teardown definition\n");
 		return ERR_PTR(-EINVAL);
 	}
@@ -293,9 +294,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:
-	pgmap->kill(pgmap->ref);
-	pgmap->cleanup(pgmap->ref);
-
+	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->cleanup(pgmap->ref);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
@@ -388,7 +388,7 @@ void __put_devmap_managed_page(struct page *page)
 
 		mem_cgroup_uncharge(page);
 
-		page->pgmap->page_free(page, page->pgmap->data);
+		page->pgmap->ops->page_free(page, page->pgmap->data);
 	} else if (!count)
 		__put_page(page);
 }
diff --git a/mm/hmm.c b/mm/hmm.c
index 48574f8485bb..583a02a16872 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1384,6 +1384,12 @@ static void hmm_devmem_free(struct page *page, void *data)
 	devmem->ops->free(devmem, page);
 }
 
+static const struct dev_pagemap_ops hmm_pagemap_ops = {
+	.page_free		= hmm_devmem_free,
+	.kill			= hmm_devmem_ref_kill,
+	.cleanup		= hmm_devmem_ref_exit,
+};
+
 /*
  * hmm_devmem_add() - hotplug ZONE_DEVICE memory for device memory
  *
@@ -1438,12 +1444,10 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 
 	devmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
 	devmem->pagemap.res = *devmem->resource;
-	devmem->pagemap.page_free = hmm_devmem_free;
+	devmem->pagemap.ops = &hmm_pagemap_ops;
 	devmem->pagemap.altmap_valid = false;
 	devmem->pagemap.ref = &devmem->ref;
 	devmem->pagemap.data = devmem;
-	devmem->pagemap.kill = hmm_devmem_ref_kill;
-	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index 076df22e4bda..cf3f064a697d 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -100,9 +100,10 @@ static void nfit_test_kill(void *_pgmap)
 {
 	struct dev_pagemap *pgmap = _pgmap;
 
-	WARN_ON(!pgmap || !pgmap->ref || !pgmap->kill || !pgmap->cleanup);
-	pgmap->kill(pgmap->ref);
-	pgmap->cleanup(pgmap->ref);
+	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
+		!pgmap->ops->cleanup);
+	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->cleanup(pgmap->ref);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

