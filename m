Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2296C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEEBE2084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J8lIBzK4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEEBE2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E4358E0017; Mon, 25 Feb 2019 15:30:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 594DC8E000C; Mon, 25 Feb 2019 15:30:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45F058E0017; Mon, 25 Feb 2019 15:30:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0520D8E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:30:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 38so8078768pld.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:30:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=W1sCskCGbKMTp/svdWUKRBvenMcXm3YvDbqeNwAQeMS+TW3PX/Zl+10ACymnO93wa2
         u8zrl0bRjZKlTDxoDXE0lKNhN7lcvgoikqT/2ZTIs4mZ1uPTfMub1bnWeXNnsMdz3H8w
         rcllnwbFXOgI2lBElpvzS+VLH6s+w9d6rT9OIbJJiwmZxtb7+wOrPdkDAsmGeec6TeID
         T7ndDE+UT9neLtDaJzPvbYXZ8y+jChmsotjz5uhSq5E0M6gjkszoh/xsUaYdrfxZjdab
         2aseKBWY1BtFwG9S8rX5JekouRB3Zsm85Slk4beltk4T0a9iikaoFHQJ0e6T43SjCZsK
         ERNg==
X-Gm-Message-State: AHQUAuai9gahEbUVW6qQ4C51yyFb/XVxRPQFDaaQrUzMGxs1TAh5iepi
	mLAKtAqDOv5xlXTwMkNcn59r2iq25a0UnJsZ1WhF6QVezI3dSVIC0naNsY/Wwzr37OCP0IXZr/u
	s3bOfo2uJQbYQ1gtJUQLbST6MuBW3e20eQ74d6AQKCcxy08jrpeLfhXrNZoXRn+8YjrJ01VEgir
	EhAjndcd7vwLwlcbkJPOikJ4jAY1R5pXU52EFU0STpKgC01S5JFR5VGU+wgn/pjwHPbutUTwS8d
	x54xwpv19fXKW7NUQDsS+NS9gNXRjlMDW1Yx0LvmA6rGSZ2c7IqTl9BBnAJ/BkDW5r8/OIi05XP
	OtmMEdagTGdVdmhutvTfeQq/2eOZlawO47jJWo+X+Rp96ITZ9/MsorNvRJONjPta+FnmV+Nb5Zk
	Y
X-Received: by 2002:a17:902:7242:: with SMTP id c2mr21781460pll.245.1551126648202;
        Mon, 25 Feb 2019 12:30:48 -0800 (PST)
X-Received: by 2002:a17:902:7242:: with SMTP id c2mr21781229pll.245.1551126644878;
        Mon, 25 Feb 2019 12:30:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551126644; cv=none;
        d=google.com; s=arc-20160816;
        b=YWLtdyGMoa/PsDogRFcWcAAAsINhByqrk2T0Vw2Y5yiEVBJSeo5uO1JG9Y4aeGFNCQ
         nUl3ZwJpfyHHFWIWxaphmBQjRNp2TaQJqJXxYshh5OTvJcTUncimG3Pzr+Aa6RGOr5XU
         8TYczE8vIdRNpr8gSXiPTFNxl+149jfp2HuWNCbzuvdmJmPP/VnC5lytjLF1yoQm4Oj8
         dNKwc1iBM72Z7LHaCpURWp3cutCGJV2rvTIRE2UYmdmLoAmRAit2CyAakDZ2O6idDdbp
         NRJQq//nt7qxlTXvsTIuYuPTRmHmJk31zcC0+StyJfpaLHufArFln+ux3VJaMP2smuzq
         zMTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=SubEaSc+j6oon7m6KNXB2aWF3dBXjoUAqRD6h+JcH2cysRqwTjAJy0WPb3T/IuKuzM
         HM0wovKM2mdCd9AgBawyaRcj7KaBgEyFnfWszYif14m03zUF8mEiivcZmKMaYT3Qn1pd
         waVHiQt8kr2PMGUnROPzX6Pk4N6AebW5R4zgZUs7UFZ6Gyz7TH0N1bwL7zsf9hMhCLzS
         ngT5zyJpKGo2YMAn8Giwoi9rjM1+p0cGAhJv/tAqPYyZKvHiNxNCSl41VfQfuhfNZN7g
         lINZKlZ4zPiHIoZrcQYiujPRlNVwV59BCvkk0CsPSF8HO+ea4YtqP/zUGstpnZpmLcp2
         z3kA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J8lIBzK4;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7sor6858677plz.53.2019.02.25.12.30.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:30:44 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J8lIBzK4;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JDU7hPspNg25hPl2OvBKS7YvtxIGkNRnjLg+s4xyhDM=;
        b=J8lIBzK4OGjvyRLjyJ+K5FObPBndm+0ToM32Stvzi+qPGf0dK7DMb6YKcWHEJk15VI
         jjWzfZB48rp8XU62MCONpYbeMnpSC+ukUGhNelx/qceEx/NAoeEFW1txjnVcRmrVu7iQ
         ZPJxLzSpuRkjRsmthUHap8hJWs4A+PNiDmZPa7noyHzHTbM2NRLV0ZAvOQyCXhAJfDW4
         7fwjC9R9Xn9G/wakNy2rfVXDMoyjf/TQAvQNSytbqFCE+f2e/uFJKS3Abzcwf8bIOb8V
         OJTDbZ9MNzunNpPuJ94ypgYbFj2Y0gQTfHPStBmF3IvVlNT374CDfU9284rKLf4F2Qpm
         N59A==
X-Google-Smtp-Source: AHgI3Ibqg5a8LKjDQQHis1IjRnXTK+LyQiMK038WjKg7XCtvXxwlfbV648hzZIlvDGKgU82xIQurdA==
X-Received: by 2002:a17:902:e090:: with SMTP id cb16mr21482907plb.32.1551126644333;
        Mon, 25 Feb 2019 12:30:44 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d960])
        by smtp.gmail.com with ESMTPSA id s4sm6189885pfe.16.2019.02.25.12.30.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:30:43 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/3] mm: separate memory allocation and actual work in alloc_vmap_area()
Date: Mon, 25 Feb 2019 12:30:36 -0800
Message-Id: <20190225203037.1317-3-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225203037.1317-1-guro@fb.com>
References: <20190225203037.1317-1-guro@fb.com>
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

