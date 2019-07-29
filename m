Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 995EBC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50FC7217D9
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZXUwnk7x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50FC7217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01A0C8E000F; Mon, 29 Jul 2019 10:29:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0CA48E0009; Mon, 29 Jul 2019 10:29:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD7748E000F; Mon, 29 Jul 2019 10:29:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 997A68E0009
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so33248277plp.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=btXxqezSTYpMi2lLCeQ3gcAVYHUyBBOdSXXsZurrEew=;
        b=K4ByIMtenqG6hisresGuAwUuJpgWr4CgSEoCFAMsNIhqRu7tNFc6IoKyNG3wP1RrOJ
         Y8hcnfou80r02HCMFQsIIRNfrlBEpe4NQq0MdBc0RfWXUnE0IIpxtFOWSgzdTvJ8NFHM
         HvTcQPJYypVOToUGcOvlA3QudpurMr4+XlKlRzdL8I1ePUraDh7c1sEfovs+wXJ7ftKw
         v2Zj1ZabVZ3g7b1W0ys63j8Ony7yJntWhuB5CgC6WgXTDt4c0I4MeIZRinKYuaT4cYew
         +1HsZLXlUKtQt0ynvJZTQqEqUJjXzYv0sUfmmDXJkShCXZ2B9zUzhdYermlJDFpmk5dP
         crVA==
X-Gm-Message-State: APjAAAXARd02/tSWq2Nj8mijvL+wzLPkzFlX9b/0hxw1bdD+kgA8HNy1
	8YxN4B/9tOt52D5jlkZKTxna8WFdtIKFgqnbU7aHiB/J739fumMJ9fBt62wYFezg9G83XEbHSvd
	cpWPMxRPzl2L9JsjJGEo883dQAPh6txThHyMiZI4ReaXAvs+CGmwYUuxFOY3sDsc=
X-Received: by 2002:a63:e901:: with SMTP id i1mr87615873pgh.451.1564410560210;
        Mon, 29 Jul 2019 07:29:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5wjfPiWsv/EG9qRKN6fvgca9dSPtfZyhz5HvbfMV1e2e1ALyktZRdiLkJ2e3cY7TkJuRm
X-Received: by 2002:a63:e901:: with SMTP id i1mr87615830pgh.451.1564410559451;
        Mon, 29 Jul 2019 07:29:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410559; cv=none;
        d=google.com; s=arc-20160816;
        b=Yts1hJnAli7oh3/LRE81RWyY7bV/1/lLcoa258qAG0w2dQutwFJeQ/eBKjow71hW0N
         bS8+4YnwHnrj+fphrtScgEYjMA3ZIISaPXBzar1c5BgN1JEnwKanvo2E9jfpDXDUDOc0
         sAb8mR4a4UgusKbfy6k+mA3r+S8UwqDbZdMnOIa8+/dUEP4X2qMLaij/hoDyg2Cxti4o
         wOBDYmi2/wLiNYwQTFYNXGotdaij0Il5oWHMCLqAlncVKQJc9HR+A13ka+laWANlOICE
         EeKNg1c8k8F2Dl23PIrvUaJUUTqrA3FIx+zCXltgcgUYGUhTR2ZGDOxLCD2JXc4/PimA
         Zyzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=btXxqezSTYpMi2lLCeQ3gcAVYHUyBBOdSXXsZurrEew=;
        b=MD0//sdtIkcRKNTLHadk34OsOkHEH9r6FLWomyZeTsoOkTTz2DEAHYMe+0gtWNTMgR
         iltGrPUK7eHkXNIEpp3d9KNAHDqRdLvTzniomgi7CRb3ZgikuLyIgI2euot5MzGF11XD
         yczSArFwiljlQRk9YYAsU66pQzCHI1vBDMAiBL+yDDBm/eLYgS2zFpP4i7O7MQKYFEKU
         DRbg/UONjOB8O/94Rb4HEUW0xPbFXwgrFv460YgaEPvo3lAmY2/RWZp6aqTqFGonMB3s
         Yg0pxwaU5SnI4UoBAQJ4HkQRokybF2oHDctk8X7luBMFExmkMVZghexrto9/3qgh0wVZ
         bdVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZXUwnk7x;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y70si27825125pfg.184.2019.07.29.07.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZXUwnk7x;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=btXxqezSTYpMi2lLCeQ3gcAVYHUyBBOdSXXsZurrEew=; b=ZXUwnk7xK0eKvyNMCJiotaRVYY
	rDFhDzOGkIe8OqjwqnrED1/er13fgyYhrlvT/BdF5iqD2+fHbtr+SI6BVjX7Y8UUDrM5++0RTtGD+
	A6wiqxzp5hNljbLRwzQ62Oxo0eirdUqNPJBq/QV7OfJFQt+QafoC8dV+5GO3zFNzfnYPHLQIGe9Me
	uVgP7tYhnsmBNwE9+DLYy6MFGcMI2KOY40RRE4FWvTaRyAvNOgfRu14N1QeGfaqlBnzHHd60ZFwpx
	XrKs7PeR4RmkKc8b/thC2CTBP75FhQaJQp1/nAV/tBf5G2wLyPJyvf25PxBVnv3It7Os91C9hkzNf
	KazPletQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6eK-0006O9-Rc; Mon, 29 Jul 2019 14:29:17 +0000
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
Subject: [PATCH 8/9] mm: remove the unused MIGRATE_PFN_DEVICE flag
Date: Mon, 29 Jul 2019 17:28:42 +0300
Message-Id: <20190729142843.22320-9-hch@lst.de>
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

No one ever checks this flag, and we could easily get that information
from the page if needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 +--
 include/linux/migrate.h                | 1 -
 mm/migrate.c                           | 4 ++--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 6cb930755970..f04686a2c21f 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -582,8 +582,7 @@ static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm,
 			*dma_addr))
 		goto out_dma_unmap;
 
-	return migrate_pfn(page_to_pfn(dpage)) |
-		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
+	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
 
 out_dma_unmap:
 	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 229153c2c496..8b46cfdb1a0e 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -166,7 +166,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_MIGRATE	(1UL << 1)
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
-#define MIGRATE_PFN_DEVICE	(1UL << 4)
 #define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index dc4e60a496f2..74735256e260 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2237,8 +2237,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				goto next;
 
 			page = device_private_entry_to_page(entry);
-			mpfn = migrate_pfn(page_to_pfn(page))|
-				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
+			mpfn = migrate_pfn(page_to_pfn(page)) |
+					MIGRATE_PFN_MIGRATE;
 			if (is_write_device_private_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
-- 
2.20.1

