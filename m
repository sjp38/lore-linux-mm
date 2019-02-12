Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 984A2C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54DF020869
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZsKPvlBS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54DF020869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8EC8E0003; Tue, 12 Feb 2019 12:57:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3B08E0001; Tue, 12 Feb 2019 12:57:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A0E38E0003; Tue, 12 Feb 2019 12:57:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7EC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:57:19 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f3so2602781pgq.13
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:57:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=epedpf7OHFHKlEKV2FaqrJiIGdLLWgqpWrEL+6mBV+M9Sl9/saiHGx1WNkIcMkbal7
         skESz9vYlIg+HaV4Na1wfOGPnDCsC0aRJg1wiSey3SiE2EwC4u1ufL/1K1vVkYx3BD0J
         +qQgg5EB6QGJiNtlX5vnEm8YgpX85KNPCnSRRZYHb5NGKDAtkTCnGP/8H1g0Fhb9FX5X
         T30blQ9rielDVjd7jDqTTBLuy4fh2ERXKsJdQ7latx8+2bvQK7AdiTWGsy4ciUuglJC4
         9CwC1doegmjsPVxeAKe7VZ/d+jyguYdwfiXNUPkg9LIcSrFZNxp4rVRWXbXJkyrDW6oK
         Vlcw==
X-Gm-Message-State: AHQUAuZp1PgEaH3RpfywbwYohWth1Q1lG75c80j5mUbdTmsjkkW2Sn0C
	Q3TY9uW9K24hkjgdKnx2taMwtE46Lw1E/Su5uXca6nsw/H95tUOjFVSPJ8AYgoovQpQqEFEVxM6
	OdVX745cJmsivp20f+YeoHjyJnigCmvdbh1dMOgm5rtPY7JJknaHCNCo2g+wr775OmJXsPy+oTm
	iw03h31nGBsnz6TULwty/ntvK7QlAfVrozcMLuRwQFRoTOULmSB2XwKhXIL6WCL65qk58zmWDhd
	6FGyvhCfe/+3bCI2FfukZ3Ev9K1HfVh3bEvcqG5z+PM9wD/zqmXWjgisaEnb0FUbr2LKoin3qFv
	V3/mlPDpM9Vi2XqL/GewzQjx6e4gqpmoi0awfGsULwoPdcWiuI2whfn0GM7QOuBmkVKvE2KMHxq
	7
X-Received: by 2002:a63:4b25:: with SMTP id y37mr4779192pga.181.1549994238885;
        Tue, 12 Feb 2019 09:57:18 -0800 (PST)
X-Received: by 2002:a63:4b25:: with SMTP id y37mr4779152pga.181.1549994238109;
        Tue, 12 Feb 2019 09:57:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994238; cv=none;
        d=google.com; s=arc-20160816;
        b=WUn9HHfTpcXt8Z2rz00D6X9P/H6NmsV6gWf8JFu3p77aZ07jzQc+tu6gdFK1GskQQ5
         I9dLsSxtwLtEjNZ1TRXBEapu+qCYOGSUsMraY0Q8K2fe64D2q8L4i8pMI0ZyeIBQ/pMW
         49NVYrIZnPyfdH0qz4wQ4Z+kVEmUGU4SGCK4RAz6WuarkTllkqVBz3uruo7HwhK2M06Y
         kk4r8v9U0+f+nXovGxWB+LAD4NXj26auyFNkvC38vW44dkFdmnmnVvH4mjHNbRzh+5wh
         GaC9wNN3W3JKo010osRdVdZ5+GQEdKQ6YcvbeZOg7K8xQ33A++Ba17It4O60jh4sSGRw
         zM6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=ZNoCN1Nxe6GQq/ROQxqcj55h8Pmm+NqU6b6cDuT/gh44fvZOLsbSPi44w1FOdtDPzk
         q9X9dmmwE6iXgikUvS/PgGOOHNcgiuXoCtCjbvoVteh1fmGWE4dxqNW8xvePjVIUOAaU
         AZVvkMLiHrn5u/EWQi6YEDFzu5DWuljFKDRCapNcWkjo4AmVrV3zMMoLB+vLd3mvdNGO
         L6opHNn+Txq0IELKwDV5xabEKSC5hBvE095zHTlmNDx3x9k87+xDtcM5lykLX6frg8va
         t2XwuwkEJsK+WO4TBuz1VvHOBKhXkRlYjTHzNzhEt01VuEdFFB2UG5n+oHaet9zmdIE+
         z03g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZsKPvlBS;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i37sor19658377plb.45.2019.02.12.09.57.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 09:57:18 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZsKPvlBS;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=ZsKPvlBSND/BBli5ocsBaMaB7S8odXyIT8DmJfUMHKbU8LQFv8ZJBe6VkCGW6UXfxg
         5qYud7MxGIilXgI8DJUK9T6Oe6cONgQuIS3uwg+cl8HAjPSL5Il/zuHcV0SIkC927B1F
         EYlJdurDGZjozSxpH5mR5GIJwSwAyxU4Kc3pQTRycew3NMPW/pfNEm3Va1/jzTICbNm+
         ToWjMq8dtVE8BV84AjpIFM2XR9De2VX/FTdBKqO7NPLnb7313azhRYP9OFQWEgljFljU
         YIGeGSOY2Sqs+QsslDvU6Sdw+WQUw2wWFSaZKaVpfLTPlADbmPMQlFn4SnDiyoPCQpkP
         iCsg==
X-Google-Smtp-Source: AHgI3IbIqG76F5iw/WVx3RtEmtdN8RqImuM6uM/rK60cWCtO/s3g+/3YiAcKucPyCDktEnwvUciCUw==
X-Received: by 2002:a17:902:1d4a:: with SMTP id u10mr5002457plu.122.1549994237645;
        Tue, 12 Feb 2019 09:57:17 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5:4d62])
        by smtp.gmail.com with ESMTPSA id z186sm18608427pfz.119.2019.02.12.09.57.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 09:57:16 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 2/3] mm: separate memory allocation and actual work in alloc_vmap_area()
Date: Tue, 12 Feb 2019 09:56:47 -0800
Message-Id: <20190212175648.28738-3-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212175648.28738-1-guro@fb.com>
References: <20190212175648.28738-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_vmap_area() is allocating memory for the vmap_area, and
performing the actual lookup of the vm area and vmap_area
initialization.

This prevents us from using a pre-allocated memory for the map_area
structure, which can be used in some cases to minimize the number
of required memory allocations.

Let's keep the memory allocation part in alloc_vmap_area() and
separate everything else into init_vmap_area().

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
---
 mm/vmalloc.c | 50 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 33 insertions(+), 17 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8f0179895fb5..f1f19d1105c4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -395,16 +395,10 @@ static void purge_vmap_area_lazy(void);
 
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 
-/*
- * Allocate a region of KVA of the specified size and alignment, within the
- * vstart and vend.
- */
-static struct vmap_area *alloc_vmap_area(unsigned long size,
-				unsigned long align,
-				unsigned long vstart, unsigned long vend,
-				int node, gfp_t gfp_mask)
+static int init_vmap_area(struct vmap_area *va, unsigned long size,
+			  unsigned long align, unsigned long vstart,
+			  unsigned long vend, int node, gfp_t gfp_mask)
 {
-	struct vmap_area *va;
 	struct rb_node *n;
 	unsigned long addr;
 	int purged = 0;
@@ -416,11 +410,6 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	might_sleep();
 
-	va = kmalloc_node(sizeof(struct vmap_area),
-			gfp_mask & GFP_RECLAIM_MASK, node);
-	if (unlikely(!va))
-		return ERR_PTR(-ENOMEM);
-
 	/*
 	 * Only scan the relevant parts containing pointers to other objects
 	 * to avoid false negatives.
@@ -516,7 +505,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	BUG_ON(va->va_start < vstart);
 	BUG_ON(va->va_end > vend);
 
-	return va;
+	return 0;
 
 overflow:
 	spin_unlock(&vmap_area_lock);
@@ -538,8 +527,35 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
 			size);
-	kfree(va);
-	return ERR_PTR(-EBUSY);
+
+	return -EBUSY;
+}
+
+/*
+ * Allocate a region of KVA of the specified size and alignment, within the
+ * vstart and vend.
+ */
+static struct vmap_area *alloc_vmap_area(unsigned long size,
+					 unsigned long align,
+					 unsigned long vstart,
+					 unsigned long vend,
+					 int node, gfp_t gfp_mask)
+{
+	struct vmap_area *va;
+	int ret;
+
+	va = kmalloc_node(sizeof(struct vmap_area),
+			gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!va))
+		return ERR_PTR(-ENOMEM);
+
+	ret = init_vmap_area(va, size, align, vstart, vend, node, gfp_mask);
+	if (ret) {
+		kfree(va);
+		return ERR_PTR(ret);
+	}
+
+	return va;
 }
 
 int register_vmap_purge_notifier(struct notifier_block *nb)
-- 
2.20.1

