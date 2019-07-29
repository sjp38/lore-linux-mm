Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F278C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBADD2171F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PNwlQ8P7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBADD2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72068E0002; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF9DF8E0009; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C99DF8E0002; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 923088E0009
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so38524736pfo.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WNbeZsrKTCXULf+D139i7mF6RNWaCytF37Kc/BZsHxE=;
        b=tHG9RLsjpyx/Es7+cd84j+EStUe+jZXG3uwlqVuPU027FDVbby82GSageI5T36AdKK
         E8SGzAUPJJLALz3MQTjQ/NQrBXBjk1FM/i6m3SPMRBt+b4Ovfr5FRklfk+JuhHXh2OS6
         6OIhWZxA6ps+9fFgo6fxFhvyhngvuzmaE8y9RmO9Cc0RfALw9/+XBk8ubBH68ZUqk3Az
         DF4zsp74Uq/Qt10salJnydtu73riDQy8PR+MqTEGZIETZNr86xkiPSIGxUoDRJWHvojI
         HFF+7L6fIF0Z0+u2/3+NFV4m7/7LszhvfbVehbaaFZKsqjhB6m1Q4t5pkHx6cc4uYSAU
         uVyw==
X-Gm-Message-State: APjAAAW6L5vX9yCXY/X+pvF5qGods/cgEhR0YwYT76d9sJ/2C6oAhqm4
	AtwedO0Uxnp/13sNY1Xg7JUbgeKTadPGQ2jWgz3t6Lr9YMa1DDG+izWdyZXwH0vIaugPa+DW5Ul
	MRU02aqTgB0zFbESyggrhJEfiiF4iiW+sLNhlqO/N7vSTVnDyuDbOK5t/p8teddM=
X-Received: by 2002:a63:7e1d:: with SMTP id z29mr104464363pgc.346.1564410547162;
        Mon, 29 Jul 2019 07:29:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRzsFNrVNcCb7Zf3adhJlU8prbqzW1S1tHnGSjF2zGE/rmHSOgJX+S+tDLQUGy+5azfX9P
X-Received: by 2002:a63:7e1d:: with SMTP id z29mr104464322pgc.346.1564410546403;
        Mon, 29 Jul 2019 07:29:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410546; cv=none;
        d=google.com; s=arc-20160816;
        b=0zDKS9UcN8qQ83PYQD1W4R+pWktiJO/U3bk/16vAqTUTYJJhgpFyy72WPfvrMhhO3o
         K5YavXNie8Mx6hSR/7PMBCA45FNyXFEnuaDmCdrVOLmhDz5rg8WUle7j4ADBXGKKAfyb
         WJ0rnwPs4ghb7vi7aEjqwUq03sBJc2UOFjFdLNoJxrblbhshnaV+ygnKrxFgkzldo59E
         nM5ZhUSi5qD7WYMAq9dbxt87MuI7RpiHMtf96wA1C/ZYG3T5hYk4Ooji+xI5fbaBUFjo
         F+RJBKfiXsM548G1nlqLwlzzl3nYMV6tstcBIABlbDw8L1OQO8dL/e0wRTnpOrrE9gnb
         glmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WNbeZsrKTCXULf+D139i7mF6RNWaCytF37Kc/BZsHxE=;
        b=YP6xfemKI5t/xBCcJ7S+z65c/r5+muKp5jJy4geKPWf8K75oA3Vo22AfJUfI4W3b2M
         YcaL9ycy9OD5jb/Nucq7P1QQvKJ0sReJUgYV5LOMoiuCDb3FSztwjiu1L9RGgbf1jeQc
         OE4fiWFVA7fr61WuqWcjYylqevcvqlBl5PtrA62nqjmGVbzPQWV3ecdiChwZst268BiU
         ZORk1DsBN2FN+BWt93tSxMcsjXn0Fez50etR4SvfDNkp5sno35nLl3GKZaiBwsKMvX8I
         g/Of+OTWZRRZEyNwLGFxtFFVu73JpK4yfY4voE2KrpZ1lks1H1DBdntO07h2sLkF8oOL
         xQ/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PNwlQ8P7;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j74si27402227pje.12.2019.07.29.07.29.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PNwlQ8P7;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WNbeZsrKTCXULf+D139i7mF6RNWaCytF37Kc/BZsHxE=; b=PNwlQ8P7J1JXZHPMS7QK4NjaHG
	1+8pEBbPQHaghI0tSWAiWKebJ404qQV4Xce2AcNcWX9NFpjoevp8RCfsf18lI1+fCw1lJJKNjf3FF
	MsSlQ+bLSfnbxCpCa9NB74M7o25AVZ4thH8mGldmmc45goQWJVzg0laJPaqtvQ7SJhD+Gj4bkTuNJ
	O0TjODMfJ7YNGm4PkjN1dEUUlWeXMej2J2htzQFjaDwRnUJ6dQUyH+8s67xOKPhi2+BnUaDzhIhqa
	iC4R6p6ARtEIqs4TqPjrH7YXMsZtpQjnTi/vL+ithy4Tsi3xX+SGuxR6G12prx/Lk8g+dBL5NvP2t
	PuE+xgUQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6e6-0006JY-RO; Mon, 29 Jul 2019 14:29:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/9] nouveau: factor out device memory address calculation
Date: Mon, 29 Jul 2019 17:28:37 +0300
Message-Id: <20190729142843.22320-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142843.22320-1-hch@lst.de>
References: <20190729142843.22320-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factor out the repeated device memory address calculation into
a helper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 42 +++++++++++---------------
 1 file changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index e696157f771e..d469bc334438 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -102,6 +102,14 @@ struct nouveau_migrate {
 	unsigned long dma_nr;
 };
 
+static unsigned long nouveau_dmem_page_addr(struct page *page)
+{
+	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
+	unsigned long idx = page_to_pfn(page) - chunk->pfn_first;
+
+	return (idx << PAGE_SHIFT) + chunk->bo->bo.offset;
+}
+
 static void nouveau_dmem_page_free(struct page *page)
 {
 	struct nouveau_dmem_chunk *chunk = page->zone_device_data;
@@ -169,9 +177,7 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 	/* Copy things over */
 	copy = drm->dmem->migrate.copy_func;
 	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
 
 		dpage = migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
@@ -194,14 +200,10 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 			continue;
 		}
 
-		dst_addr = fault->dma[fault->npages++];
-
-		chunk = spage->zone_device_data;
-		src_addr = page_to_pfn(spage) - chunk->pfn_first;
-		src_addr = (src_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
-		ret = copy(drm, 1, NOUVEAU_APER_HOST, dst_addr,
-				   NOUVEAU_APER_VRAM, src_addr);
+		ret = copy(drm, 1, NOUVEAU_APER_HOST,
+				fault->dma[fault->npages++],
+				NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(spage));
 		if (ret) {
 			dst_pfns[i] = MIGRATE_PFN_ERROR;
 			__free_page(dpage);
@@ -687,18 +689,12 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	/* Copy things over */
 	copy = drm->dmem->migrate.copy_func;
 	for (addr = start, i = 0; addr < end; addr += PAGE_SIZE, i++) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *spage, *dpage;
-		u64 src_addr, dst_addr;
 
 		dpage = migrate_pfn_to_page(dst_pfns[i]);
 		if (!dpage || dst_pfns[i] == MIGRATE_PFN_ERROR)
 			continue;
 
-		chunk = dpage->zone_device_data;
-		dst_addr = page_to_pfn(dpage) - chunk->pfn_first;
-		dst_addr = (dst_addr << PAGE_SHIFT) + chunk->bo->bo.offset;
-
 		spage = migrate_pfn_to_page(src_pfns[i]);
 		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE)) {
 			nouveau_dmem_page_free_locked(drm, dpage);
@@ -716,10 +712,10 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 			continue;
 		}
 
-		src_addr = migrate->dma[migrate->dma_nr++];
-
-		ret = copy(drm, 1, NOUVEAU_APER_VRAM, dst_addr,
-				   NOUVEAU_APER_HOST, src_addr);
+		ret = copy(drm, 1, NOUVEAU_APER_VRAM,
+				nouveau_dmem_page_addr(dpage),
+				NOUVEAU_APER_HOST,
+				migrate->dma[migrate->dma_nr++]);
 		if (ret) {
 			nouveau_dmem_page_free_locked(drm, dpage);
 			dst_pfns[i] = 0;
@@ -846,7 +842,6 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 
 	npages = (range->end - range->start) >> PAGE_SHIFT;
 	for (i = 0; i < npages; ++i) {
-		struct nouveau_dmem_chunk *chunk;
 		struct page *page;
 		uint64_t addr;
 
@@ -864,10 +859,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 			continue;
 		}
 
-		chunk = page->zone_device_data;
-		addr = page_to_pfn(page) - chunk->pfn_first;
-		addr = (addr + chunk->bo->bo.mem.start) << PAGE_SHIFT;
-
+		addr = nouveau_dmem_page_addr(page);
 		range->pfns[i] &= ((1UL << range->pfn_shift) - 1);
 		range->pfns[i] |= (addr >> PAGE_SHIFT) << range->pfn_shift;
 	}
-- 
2.20.1

