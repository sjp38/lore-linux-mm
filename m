Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36153C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3AD020866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="D9E3AJHJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3AD020866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F30B96B026B; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBA586B026C; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81AF6B026D; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A90B6B026C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j7so1813565pfn.10
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WrqEw/kh06rUcYlXeZlC7gMu2XY6dy0Gg8ARfs+ZAOQ=;
        b=ayaKlBZSgcBOKg0Z8kbNg8zCtKepEe4c/X0Fzs3WpmJwQ0g30HL2w5Y+5/M4z4wgvr
         vvCKk0zqRs440z7iDhpICoq48U3PlOhsJGpd6tzrdHlcWFfkccX7bE5oBQzNj/iY+KgN
         poxDdQhpU6KTT1ojxbebyE2CHmpmPeUGI+ZFA61gF0FNLvzA4bcHG7uNfykniLLx0Cnb
         en3zBRKcJg/iB9oth6EdYhS288/Y7rEZuPLnUoe3Howw5eKn3EIZgomwwp/9AQHI9nOZ
         XChxIUmHBGOjdx2Xm3QOrYQJgYuv2WBRMTIM0xCGVGYJ3+ZqXxBkpQyGV+5RiisGUS0o
         7NVg==
X-Gm-Message-State: APjAAAXb3ZN3Xc5eoFd1i/u/jtF2JZwDNPzXINaEiQkBRIh1gpvBKar5
	YQlSf4Ch+N3dvVxwuIBUsLU0G02PQSj2b7vFG2Qr086/7teQpaOaWxyT2Bl5TG8Lcp1TXVu7BDi
	6ml+qy0Gc1HyuixI4CtW5ArJk2TW85JKEGogwAV/vyZR8lIGzOcJbvpH2N/fbBE4=
X-Received: by 2002:a17:90a:1706:: with SMTP id z6mr10930721pjd.108.1560520095276;
        Fri, 14 Jun 2019 06:48:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuN36V1EXZ9CBLu6qvS4BvCXb2lueAammANIkI07rHors2lrrCPP5jsehCLIOWiK035L7o
X-Received: by 2002:a17:90a:1706:: with SMTP id z6mr10930652pjd.108.1560520094381;
        Fri, 14 Jun 2019 06:48:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520094; cv=none;
        d=google.com; s=arc-20160816;
        b=gPXxbz+on0QqZRneKgRLJzp16lpYt5ecXqKBMKfYYCDQxtTULUcB2zTaeu1gqaK1LB
         FWtpEERhoukUmFBZS0yrck9reDiLL3vBgGuo6rbSsbO+pi3m4LS7xL61J4Du+71yuJVt
         zezHQ2NIuSS2a3iNEiOXSlcqv+9m0laMPGyVraui7LlbGrBHrkPIgsKtz5+94vbiAVRW
         v33pkFWqvosbcRNDzWspEO7k+EGuuFEvL40SC8RruezJRrXwMQ2FBAbqnmy+UrWjMTh3
         uPlZUiWMFVU3YInuSiyia9bcuQPFWOk53GCJC7aLZKxXXKmnis0oj3cH3QoiNBHJV4tZ
         WQqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WrqEw/kh06rUcYlXeZlC7gMu2XY6dy0Gg8ARfs+ZAOQ=;
        b=jFE1FN0XT+hj8p1CLLr2iTN2YQ4aGTZJF8vwwjVNba6N6mkOP9o7rhWWtEirBQ4V3H
         qTEnwgZU9c40SqonVvPtm2fu3ACTi+dchgtkIaXJV+HaP+y+6XGvC4QEFWoTfF+oAGys
         /aAoRz/s/umh4KP4jMqq0sVLOEThE6OeArhH3QvRS2pwvtliMy3iwMdkJqHRDhbnO3gj
         clai5+Qbhu42hPovebb6ciP8s9At56cT+3hqc5pliO5OLLsYN7E5iiiXcYJGM2MMUuDd
         kukraNktpX86Spblxj6z6h2zickXS4VmdIajgzx1ZYNa03EbjZHxyN6s45Zz8FZ4d1tF
         KlwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D9E3AJHJ;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k38si2674982pgm.500.2019.06.14.06.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D9E3AJHJ;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WrqEw/kh06rUcYlXeZlC7gMu2XY6dy0Gg8ARfs+ZAOQ=; b=D9E3AJHJkUDDZwGDrICOo8xwSr
	Vfy2Y+1OPPXLUbN3S6PHwsqy/cmVJE6bpXLngdX6RBjQJ/8loJlNzq/VgpjqMsVb1OYqTqcJSfd/w
	ZTqwdyKvGBMYP+UdZr0PKY3UL+ICZo9n3syFkXle/QjrUYo22kN1OHsSkJTQETCKs6U3FbdS8UCIf
	15Qj3v6xgo6FD+k3Nt1TmpLZAWT2c/I9/ZkVi1twL1+1sce+5xjQNfVhNk5NtWjFrcrhDuua7gZwL
	8uwyLJmwGpEV23Kpn/3zN/KpBzDqAa5QVnZBlqDFG7exUujjmNHagTqiWfvxlzNuK2Z5Pu6tCggvd
	mp08sq1Q==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYg-0005D2-H3; Fri, 14 Jun 2019 13:47:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/16] IB/qib: stop passing bogus gfp flags arguments to dma_alloc_coherent
Date: Fri, 14 Jun 2019 15:47:18 +0200
Message-Id: <20190614134726.3827-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

dma_alloc_coherent is not just the page allocator.  The only valid
arguments to pass are either GFP_ATOMIC or GFP_ATOMIC with possible
modifiers of __GFP_NORETRY or __GFP_NOWARN.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/infiniband/hw/qib/qib_iba6120.c |  2 +-
 drivers/infiniband/hw/qib/qib_init.c    | 20 +++-----------------
 2 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/infiniband/hw/qib/qib_iba6120.c b/drivers/infiniband/hw/qib/qib_iba6120.c
index 531d8a1db2c3..d8a0b8993d22 100644
--- a/drivers/infiniband/hw/qib/qib_iba6120.c
+++ b/drivers/infiniband/hw/qib/qib_iba6120.c
@@ -2076,7 +2076,7 @@ static void alloc_dummy_hdrq(struct qib_devdata *dd)
 	dd->cspec->dummy_hdrq = dma_alloc_coherent(&dd->pcidev->dev,
 					dd->rcd[0]->rcvhdrq_size,
 					&dd->cspec->dummy_hdrq_phys,
-					GFP_ATOMIC | __GFP_COMP);
+					GFP_ATOMIC);
 	if (!dd->cspec->dummy_hdrq) {
 		qib_devinfo(dd->pcidev, "Couldn't allocate dummy hdrq\n");
 		/* fallback to just 0'ing */
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index d4fd8a6cff7b..072885a6684d 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -1547,18 +1547,13 @@ int qib_create_rcvhdrq(struct qib_devdata *dd, struct qib_ctxtdata *rcd)
 
 	if (!rcd->rcvhdrq) {
 		dma_addr_t phys_hdrqtail;
-		gfp_t gfp_flags;
-
 		amt = ALIGN(dd->rcvhdrcnt * dd->rcvhdrentsize *
 			    sizeof(u32), PAGE_SIZE);
-		gfp_flags = (rcd->ctxt >= dd->first_user_ctxt) ?
-			GFP_USER : GFP_KERNEL;
 
 		old_node_id = dev_to_node(&dd->pcidev->dev);
 		set_dev_node(&dd->pcidev->dev, rcd->node_id);
 		rcd->rcvhdrq = dma_alloc_coherent(
-			&dd->pcidev->dev, amt, &rcd->rcvhdrq_phys,
-			gfp_flags | __GFP_COMP);
+			&dd->pcidev->dev, amt, &rcd->rcvhdrq_phys, GFP_KERNEL);
 		set_dev_node(&dd->pcidev->dev, old_node_id);
 
 		if (!rcd->rcvhdrq) {
@@ -1578,7 +1573,7 @@ int qib_create_rcvhdrq(struct qib_devdata *dd, struct qib_ctxtdata *rcd)
 			set_dev_node(&dd->pcidev->dev, rcd->node_id);
 			rcd->rcvhdrtail_kvaddr = dma_alloc_coherent(
 				&dd->pcidev->dev, PAGE_SIZE, &phys_hdrqtail,
-				gfp_flags);
+				GFP_KERNEL);
 			set_dev_node(&dd->pcidev->dev, old_node_id);
 			if (!rcd->rcvhdrtail_kvaddr)
 				goto bail_free;
@@ -1622,17 +1617,8 @@ int qib_setup_eagerbufs(struct qib_ctxtdata *rcd)
 	struct qib_devdata *dd = rcd->dd;
 	unsigned e, egrcnt, egrperchunk, chunk, egrsize, egroff;
 	size_t size;
-	gfp_t gfp_flags;
 	int old_node_id;
 
-	/*
-	 * GFP_USER, but without GFP_FS, so buffer cache can be
-	 * coalesced (we hope); otherwise, even at order 4,
-	 * heavy filesystem activity makes these fail, and we can
-	 * use compound pages.
-	 */
-	gfp_flags = __GFP_RECLAIM | __GFP_IO | __GFP_COMP;
-
 	egrcnt = rcd->rcvegrcnt;
 	egroff = rcd->rcvegr_tid_base;
 	egrsize = dd->rcvegrbufsize;
@@ -1664,7 +1650,7 @@ int qib_setup_eagerbufs(struct qib_ctxtdata *rcd)
 		rcd->rcvegrbuf[e] =
 			dma_alloc_coherent(&dd->pcidev->dev, size,
 					   &rcd->rcvegrbuf_phys[e],
-					   gfp_flags);
+					   GFP_KERNEL);
 		set_dev_node(&dd->pcidev->dev, old_node_id);
 		if (!rcd->rcvegrbuf[e])
 			goto bail_rcvegrbuf_phys;
-- 
2.20.1

