Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79023C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE442089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="m8UBJ+0X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE442089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 911DE6B0007; Mon, 24 Jun 2019 01:43:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89C278E0002; Mon, 24 Jun 2019 01:43:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73D968E0001; Mon, 24 Jun 2019 01:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB116B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v6so8656896pgh.6
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=BDz3l/LsrfQZrcgmpsYBZ77lzky+dPg8LpZHiW9muyylR4QXgkk0R1RlhyqD+N0/ty
         7ihAS6T1oxZ+zRxXiB6iTpAAps4wIiV0eZiQRKa0vIQCXDdlCoR0h2pph0Ga5zrKF7Wu
         eeC0D0kernOIEJP/yj15wHN82InJKoFssHjsIchf197NbO8P0ixOcoVdDjfZm6C5ZntK
         cqh8xltdCBJ0SDIWp2VovpF0gTXZSvPAVnaYf8JoIIdjQCEtwNGhdulYGIER50NxVtnl
         rWryp3rOk6DMJqcc1tDgK8WN5HfTqzGmztUhQ2RbjrNqSwYcn1to5RyK5AoGSMbpT/6c
         LAcg==
X-Gm-Message-State: APjAAAXzrCIoXGkZO/NptDNdTMAVLD6Tr+/GSvrs5X38zfnx0KoDtyrl
	IlJDFjU49OhzkwuP8AMgWB71AL9SY2admoKQts9r/Z3mOVb7XnuGSVOaOeEnTbFwcbSqPYRBWrF
	t4PevdKa5wh8kn6NR3iOKyQbGiO/YttWwM3BAuXEk8krK3yt0uL5cbpPnSbZ9LYU=
X-Received: by 2002:a17:902:b94a:: with SMTP id h10mr34935373pls.125.1561355005913;
        Sun, 23 Jun 2019 22:43:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlECX38QEkkgnpa5gn+mdPXoNJZJO3sToq0O9nkumTAGuVOfGO0J547AlJ4pVmlhrWVpin
X-Received: by 2002:a17:902:b94a:: with SMTP id h10mr34935339pls.125.1561355005294;
        Sun, 23 Jun 2019 22:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355005; cv=none;
        d=google.com; s=arc-20160816;
        b=nHnpNptsVd7jdojpesiC/owpoeXfMsLEGGBiqHJ3RrtCXQqe7LFKEDuuhvsZzoQhp0
         S7R/Bprf6Dw5qE+aZ7U/9RB+IBIMPErv9njTsdlfeLQhJovLzxfQPZRCOdskMA3ONUs6
         R6L49ZcX4kSi24PImCP/1dBETZa9VWIQTfB4N7n9H3amHXMCnCUjxFVHa27HtOUE/6H3
         uwosgfXwZuFq0tScOZ7ge7pgnNfO2fpes3+bI00JA5siDbnjacEpTT+i/Xl/WCXACDo7
         nNzAIyJRv/KqSX8sL4YC7yst2OA3c9ZDWiiu24hr5AHplj6hlLb+9E8RRXuvDLHz51cP
         n0wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=gMUjo3HOLIi63Hxnl2NwKjNMVkHrTD3QqGWBblhMOmwdPXq+cK9C8NJfWtdeZhkiyN
         yakfy3ti7mWdrckIlRvYlKSi5NSERQSHWudPEGPxaxd2n/yRuNDga2kRKhDl+walMTFV
         hxCd0i93pVspsZvQrQDBCn8yZVBUC6wOmN3IKgXu7Rd+zdya5bkZvRFq9xg4+goH9uCt
         8sIC5xjdCAR7ZPFwqiO4FBkEY/HuHdzgNlrXTMFqENzCuXHolAXURyCl0n0bRbGWmZHH
         l9cPkG8hcuRHlSlY2WNuuCRKRXNpB2sNUaC9XNMwSibQdAuP3tAwNpRrUyBhHwwnEeOU
         8zYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=m8UBJ+0X;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s62si9769558pjc.75.2019.06.23.22.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=m8UBJ+0X;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=; b=m8UBJ+0XcFZ7O7trRjCFun/kpM
	ZZL9L8R5+7n1in9B7bBJFc+moU0JB6Hi14/as4UhSBatyUxxcjhzsdYC6kDe3REVcjNaNW5RX3Fza
	C7X9mCLwL3zA7GmD9WbrUJDOy6dtV3finn/OvuiwPpTghqZu7fQlcGpPZwA7yPEAuVDAm6/tHnW3I
	hX0KhA8ptgDt+HbonwtMMPc7CPE9Lo25J7clA4oa2UPWbkXTT8GAWx4HWmjFSd3S2S9AyvJatTWdx
	HcphWkJ03sWY5Z74c2jp+RNrCmbNpU9pJ91z9gGz1xiJzbkVWkQ1rEC/P9e68pcZCYm5ie7s48ZEu
	/Usxr9xQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlC-00065N-AR; Mon, 24 Jun 2019 05:43:23 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
Date: Mon, 24 Jun 2019 07:42:56 +0200
Message-Id: <20190624054311.30256-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The whole header file deals with swap entries and PTEs, none of which
can exist for nommu builds.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/swapops.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..b02922556846 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -6,6 +6,8 @@
 #include <linux/bug.h>
 #include <linux/mm_types.h>
 
+#ifdef CONFIG_MMU
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -50,13 +52,11 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 	return entry.val & SWP_OFFSET_MASK;
 }
 
-#ifdef CONFIG_MMU
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
 	return !pte_none(pte) && !pte_present(pte);
 }
-#endif
 
 /*
  * Convert the arch-dependent pte representation of a swp_entry_t into an
@@ -375,4 +375,5 @@ static inline int non_swap_entry(swp_entry_t entry)
 }
 #endif
 
+#endif /* CONFIG_MMU */
 #endif /* _LINUX_SWAPOPS_H */
-- 
2.20.1

