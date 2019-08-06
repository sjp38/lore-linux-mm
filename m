Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 826BBC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37E0F20679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TdJihcN0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37E0F20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87D186B026A; Tue,  6 Aug 2019 12:06:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82D436B026B; Tue,  6 Aug 2019 12:06:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680B16B026C; Tue,  6 Aug 2019 12:06:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32F3C6B026A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so48563372pls.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e9aFg9y3NWAnc2PsHRJxtyHwhE0a0AbbxTY4a2BFPAw=;
        b=VEpmBiHUoxfnIwAR98yci5z32UScbw5/ec75pMFBCTws9vcH2zBSyBqg83q4Toy7Co
         UBw15mzfPprFmotbevnkU2nJDhros7292lbEc8nEGtwE89xrojazm1aRUDjIDTED9av6
         Bh1sRgnDE+HOeDBJJqnat5nUQUG9T84T+KKlNZvNFuzsW3qyTXyyIVVtsVJ62h8TZZt5
         gG64Sz8J4UGc8JaxmeUGELJtzDc1iR2BryBCsg//xA+36iiWriziMeYopMjG1vScqCRI
         cFfObn4ss45tqYv6QKV5jUpP8QprtouU4aGAMQ3Q02A8aCOUgh9WE01Js/htjmLD4I8o
         qS7A==
X-Gm-Message-State: APjAAAX4Jd8pBrwkcnq7Cmoq1DrsMmMZXZLfT7MZCDVFBoPGOYl1DGKk
	144NOeTMnvdXjreLR9oxd5J5ewA2/QqavsXbZJLe5Yd3YKhXo/ktOP3UVI+8j6s3Zml7+nr56hQ
	XkZcV27cQPVTxzfcKhhMiNtmuEwM/7kBzWVj8EkfDf2DTPznStCRYNKPxAvTNu/s=
X-Received: by 2002:a17:902:aa88:: with SMTP id d8mr3707251plr.274.1565107588863;
        Tue, 06 Aug 2019 09:06:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQTfy7BSXa9V6vaGOzSiAF2OVos0mqNa1+JRt/gLp5cCK+hG4ClKR35yD6ENqZLCO4uwwE
X-Received: by 2002:a17:902:aa88:: with SMTP id d8mr3707209plr.274.1565107588136;
        Tue, 06 Aug 2019 09:06:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107588; cv=none;
        d=google.com; s=arc-20160816;
        b=jAew3GrZOxeiWmSygCBKOZx/6HTnqsbSqxoVK5yhdWezchYOSWIhb/2pw3Gfy/YUEV
         3naL+8dajThF1qQbbil+Dezl1TcLjrR4i003guMNCG4/oQhk8SPp3pmaV9rArY28szyb
         5jF5GgrXLOKic4NMzJRXcE/XBOQm4uKqqLrzp+Yb/buRoIEy9o9jQ651YxchADGzeW2r
         58y4qC87RTavT9tF6Mo2MWe7XLPixL6L06ZGCzpBlja5XN8pobxBZziAh5AXYEzm6k0r
         hqeyxinBo7bsJfpBbf2ZjOUIqnZN5tigiPCdLnwEXTTke9SdqN0+sVCLFi5Hya+dgzZY
         Jf5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=e9aFg9y3NWAnc2PsHRJxtyHwhE0a0AbbxTY4a2BFPAw=;
        b=Kn959FdD9H+rY4P/O+HSWz+ERyy6zjfCbAjjkFapI/MLFGQ3GcobSjmbWsR3XRVLoM
         y16n7S4O0wDBe1FWom4HgnBRt8i5XvyJdyLlnUqax9sf8+4cflv1Mv0G7+PHqsYOta6a
         JsXBHfLPLkwFOFPwghsAC41K1QmWHVECLi7FWyqC5F18hTUwqE3m6RmBrsz0xV754uAw
         v1pPWvbkI1UVVFEv8vDZXhW8KM4F99R1f87Ntj6Qew4Ie0lm6wN5gZj+6XbCHMGA5h+q
         OVTqygzLX1JHIGJsCg5M4u4qhMRHS2VgHqTER9MEctGN0w0W9dJw0rxOAJTjQE7XhJO9
         C7BA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TdJihcN0;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s24si48566477pgq.372.2019.08.06.09.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TdJihcN0;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=e9aFg9y3NWAnc2PsHRJxtyHwhE0a0AbbxTY4a2BFPAw=; b=TdJihcN0imUrB+DXTgmH0YwTUb
	lhLq60JHilI/KNarxExvblJfGtJD/KeWw1YixvJmmQjZxBo3be+cmgsarEog2qaCkGzoYPJY6s8qs
	zDZh/xO+rJ1KZCNRLgq3pmAluvXZ31iOXadZOdkkZWIPMLgaTQONiL10gRria1wqAe3NyDFV1xDmY
	lHYDcFCpFmiKOrErT1VtfkzdIfcB6wRbYd0gXaFxWTUZ19blXt2ymzvsasYfbVxQsnFGJeH5AWd0S
	OPiYzPzKK5xu5e0oJQoArM98BctBcV8Y0EJN1AwB6LCKDlcmolgWN0XhXCXtGgkezGIKL8Zu2VFTc
	qp692nQg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yi-0000cX-Ex; Tue, 06 Aug 2019 16:06:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/15] mm: cleanup the hmm_vma_handle_pmd stub
Date: Tue,  6 Aug 2019 19:05:49 +0300
Message-Id: <20190806160554.14046-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Stub out the whole function when CONFIG_TRANSPARENT_HUGEPAGE is not set
to make the function easier to read.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 5e7afe685213..4aa7135f1094 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -455,13 +455,10 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 				range->flags[HMM_PFN_VALID];
 }
 
-static int hmm_vma_handle_pmd(struct mm_walk *walk,
-			      unsigned long addr,
-			      unsigned long end,
-			      uint64_t *pfns,
-			      pmd_t pmd)
-{
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
+		unsigned long end, uint64_t *pfns, pmd_t pmd)
+{
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct dev_pagemap *pgmap = NULL;
@@ -490,11 +487,12 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 		put_dev_pagemap(pgmap);
 	hmm_vma_walk->last = end;
 	return 0;
-#else
-	/* If THP is not enabled then we should never reach this code ! */
-	return -EINVAL;
-#endif
 }
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+/* stub to allow the code below to compile */
+int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
+		unsigned long end, uint64_t *pfns, pmd_t pmd);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
 {
-- 
2.20.1

