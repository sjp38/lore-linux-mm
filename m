Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EC4EC28D18
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4994C24DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:55:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tFue28d/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4994C24DB4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D45E86B0010; Tue,  4 Jun 2019 02:55:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCFFF6B0266; Tue,  4 Jun 2019 02:55:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC1616B0269; Tue,  4 Jun 2019 02:55:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB0C6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:55:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q2so13389488plr.19
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:55:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=97BhO94V8jLdTUMw7JoDn6KQHii2re3fulwUdwFjYBI=;
        b=QbxC61VF/VKkAA7BWoRCjH5yFXudMnJT1P9jTR8rnqPkTeWfVm/QCIXcHYxAWu5fBH
         u2TCispZgOeauqtZQCIIJZzQQ2pkQK/MfomAmxRfCb13x+m/CQ+JEU8RXJOcT70O0MHH
         NxOeCfGqFo4wWrKBmrgJQC8zXIVMrmJZvECad3dt2iGk6ETvqtSJ25TQDAxxHgoFiU3O
         lWcle57NAbybzegqBZLgZ/jOklDmhJfhQhoNuAgX0MOx3U3nUoJLl+0EdnyZc51fRAiC
         H5rN0igtUcIVUfLWutFnK3ThAKg3TkaWjOe3oPdm+1QAAtCamzFVB67+cyxcy4qf24cc
         tioQ==
X-Gm-Message-State: APjAAAWJ8UXyximHDgLFHLy76cHJaAEHUrBnDhpE3dpfsumEV6Qimz8z
	Y5hI1/YTE/lJUlyLJOhltip+BZ8ZIEED3bYLUJD8iDdjG/A8TawylfmISEfvpxwpJbuxMLza2Fx
	tsj4HGLahCgsUoBAaTRstmnFTeSqRs+GsUpiCAx2I3wXk2h1PGkRK0uP+4n6lDTA=
X-Received: by 2002:a65:5308:: with SMTP id m8mr33176075pgq.54.1559631324019;
        Mon, 03 Jun 2019 23:55:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3KU43Q1FuiY1x+4k/X2L/c7xrV3GUX8rWveRVItaxq4Xz4iU5yLu2wit2a2GeN6DNIXxc
X-Received: by 2002:a65:5308:: with SMTP id m8mr33176038pgq.54.1559631323013;
        Mon, 03 Jun 2019 23:55:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631323; cv=none;
        d=google.com; s=arc-20160816;
        b=CYtFzpwtPKNjJnJ+9B3Fx1fv+/r01kvuuk8Zk8GXSf2fWu4rYa28CSBIHJZZ0l3cvX
         1KtHgjnq2G9hzYy+14nD7Fdrkge0r5tb24/ZDEJ5NvLcnB4Wcl6V5EoG15jeOFVptATP
         wQOOMu5xJaEpv59CkQRNt/chP1KkDAmNtTm+Oc9/GijdcM3u2NZtajfD0BLNMAmnhDZf
         bK549a9/Sob20skeErIUhx1dIsFOaj7Te8dheBAS6oImI40vYUZu+7dgHRhMySt+WJ+K
         cyyaXb/XFCWr32FARVx3dj1MceY+DWc68koRGkecWE95fEYpCOFh7oBdCoMjrxrvz2ZJ
         SUvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=97BhO94V8jLdTUMw7JoDn6KQHii2re3fulwUdwFjYBI=;
        b=Z4mU4jTA6q7sBk28gToQhopdc2f9ZgY+TJBJR6+DI12GS9/3lNtOWmsB+WL0F+BfVO
         324Zm5P1PLT7idtiHVRVKIPOc//Jd633yAsItY8hsXogLDhGJPcCE4gmHg3WYBHMJNX2
         h/+VnmhRSCv73VVQ3NzFBSfFqgaK1Nwp/Xl6YFYaGaP8YhjIwln0STLsx2dvZLQo3ezc
         fwYqjA8M36BSSVDF3Q/NRwmM+/QpyVTVxBOlH11CpzUpLGO2R5Updkjj5EmFHHso8xGo
         uqASBujtrmlh1ntPZoxOnvuYfUhkv7RYo67dvDLXtm9BG8bvYf0ycLlkLLXKvdRAl1ar
         Napw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="tFue28d/";
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y135si24578796pfc.114.2019.06.03.23.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 23:55:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="tFue28d/";
       spf=pass (google.com: best guess record for domain of batv+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8160fb773a6c716236a8+5763+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=97BhO94V8jLdTUMw7JoDn6KQHii2re3fulwUdwFjYBI=; b=tFue28d/NACZJWIBnHUgst3mcC
	kSW3mXpirIcDda6kq0ORR53gZV/3aWOou7YOP7/jjVUsx9Nq13hyKqovanMtUDh+9cn+kOOfmdZ3h
	WuSN3frnRaStXDjmp8W4abdA4+x4/t6n7m3jG4/uq4kmsZCuhHmmXlB2E4Puc4LNWeUGLMuatoaxz
	zB8Wu3eSa8uwVv8yJg64x21cXloaW9LfIeeyqjQUfUuWp4EjVxWT+8wF++127uFmcK+VAEIYu4M80
	/qSyg0M7Un4DX1zlJikp5XiCM3ltmJeLSKjwcDfqc9yc30nFQLNNmq2JD/E+tAdSp53e+f8lgLCLs
	AuHQbzBw==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hY3Lo-0003ZV-DH; Tue, 04 Jun 2019 06:55:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] dma-mapping: introduce a dma_common_find_pages helper
Date: Tue,  4 Jun 2019 08:55:04 +0200
Message-Id: <20190604065504.25662-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190604065504.25662-1-hch@lst.de>
References: <20190604065504.25662-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A helper to find the backing page array based on a virtual address.
This also ensures we do the same vm_flags check everywhere instead
of slightly different or missing ones in a few places.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/dma-mapping.c   |  7 +------
 drivers/iommu/dma-iommu.c   | 15 +++------------
 include/linux/dma-mapping.h |  1 +
 kernel/dma/remap.c          | 13 +++++++++++--
 4 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 647fd25d2aba..7620d4f55e92 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1434,18 +1434,13 @@ static struct page **__atomic_get_pages(void *addr)
 
 static struct page **__iommu_get_pages(void *cpu_addr, unsigned long attrs)
 {
-	struct vm_struct *area;
-
 	if (__in_atomic_pool(cpu_addr, PAGE_SIZE))
 		return __atomic_get_pages(cpu_addr);
 
 	if (attrs & DMA_ATTR_NO_KERNEL_MAPPING)
 		return cpu_addr;
 
-	area = find_vm_area(cpu_addr);
-	if (area && (area->flags & VM_DMA_COHERENT))
-		return area->pages;
-	return NULL;
+	return dma_common_find_pages(cpu_addr);
 }
 
 static void *__iommu_alloc_simple(struct device *dev, size_t size, gfp_t gfp,
diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index cea561897086..002d3bb6254a 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -543,15 +543,6 @@ static struct page **__iommu_dma_alloc_pages(struct device *dev,
 	return pages;
 }
 
-static struct page **__iommu_dma_get_pages(void *cpu_addr)
-{
-	struct vm_struct *area = find_vm_area(cpu_addr);
-
-	if (!area || !area->pages)
-		return NULL;
-	return area->pages;
-}
-
 /**
  * iommu_dma_alloc_remap - Allocate and map a buffer contiguous in IOVA space
  * @dev: Device to allocate memory for. Must be a real device
@@ -940,7 +931,7 @@ static void __iommu_dma_free(struct device *dev, size_t size, void *cpu_addr)
 		 * If it the address is remapped, then it's either non-coherent
 		 * or highmem CMA, or an iommu_dma_alloc_remap() construction.
 		 */
-		pages = __iommu_dma_get_pages(cpu_addr);
+		pages = dma_common_find_pages(cpu_addr);
 		if (!pages)
 			page = vmalloc_to_page(cpu_addr);
 		dma_common_free_remap(cpu_addr, alloc_size);
@@ -1050,7 +1041,7 @@ static int iommu_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 		return -ENXIO;
 
 	if (IS_ENABLED(CONFIG_DMA_REMAP) && is_vmalloc_addr(cpu_addr)) {
-		struct page **pages = __iommu_dma_get_pages(cpu_addr);
+		struct page **pages = dma_common_find_pages(cpu_addr);
 
 		if (pages)
 			return __iommu_dma_mmap(pages, size, vma);
@@ -1072,7 +1063,7 @@ static int iommu_dma_get_sgtable(struct device *dev, struct sg_table *sgt,
 	int ret;
 
 	if (IS_ENABLED(CONFIG_DMA_REMAP) && is_vmalloc_addr(cpu_addr)) {
-		struct page **pages = __iommu_dma_get_pages(cpu_addr);
+		struct page **pages = dma_common_find_pages(cpu_addr);
 
 		if (pages) {
 			return sg_alloc_table_from_pages(sgt, pages,
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index ac320b7cacfd..cb07d1388d66 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -615,6 +615,7 @@ extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
 		void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		unsigned long attrs);
 
+struct page **dma_common_find_pages(void *cpu_addr);
 void *dma_common_contiguous_remap(struct page *page, size_t size,
 			pgprot_t prot, const void *caller);
 
diff --git a/kernel/dma/remap.c b/kernel/dma/remap.c
index 51958d21c810..52cdca386de0 100644
--- a/kernel/dma/remap.c
+++ b/kernel/dma/remap.c
@@ -11,6 +11,15 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 
+struct page **dma_common_find_pages(void *cpu_addr)
+{
+	struct vm_struct *area = find_vm_area(cpu_addr);
+
+	if (!area || area->flags != VM_DMA_COHERENT)
+		return NULL;
+	return area->pages;
+}
+
 static struct vm_struct *__dma_common_pages_remap(struct page **pages,
 			size_t size, pgprot_t prot, const void *caller)
 {
@@ -78,9 +87,9 @@ void *dma_common_contiguous_remap(struct page *page, size_t size,
  */
 void dma_common_free_remap(void *cpu_addr, size_t size)
 {
-	struct vm_struct *area = find_vm_area(cpu_addr);
+	struct page **pages = dma_common_find_pages(cpu_addr);
 
-	if (!area || area->flags != VM_DMA_COHERENT) {
+	if (!pages) {
 		WARN(1, "trying to free invalid coherent area: %p\n", cpu_addr);
 		return;
 	}
-- 
2.20.1

