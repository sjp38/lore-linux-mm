Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AC68C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A27A7206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FZkGMICQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A27A7206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41B968E0005; Sun, 10 Mar 2019 21:08:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A14A8E0002; Sun, 10 Mar 2019 21:08:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2685C8E0005; Sun, 10 Mar 2019 21:08:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F14448E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:08:26 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f70so3263601qke.8
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:08:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0YdAVJOsub1ouxSrbSwMtQqJcFX4a2eTBDmV3Tq0WPQ=;
        b=C4/U5a+lhuzYOSFsL5nco1Tc1uYj1AgI+P7PT0LbeyyNCWBx8Mqv+pkhy2hP9GZQAR
         IrMBzhyhZ/lzRskb3LJM2yzmxVLuBMXa99ixBYLV/214i1TNUtlXKIz7bmyxeoxQa6o4
         5o0VQUOBe4UtDy4AbYpkg6BBsWvtSJdCzXEACWKpIru93LslZPPvkCPQnH4ai6hnmC1D
         RvKXSMaoYsG3rTVJ3x+HJ0qzVzZpMUNsRepi49zVgWpyHYbQsvSLxevrXTB9DloldGNc
         muSJqeupTS/SteUuKPLhrx5jgH839LtA4k2uw3fTU7YRoZGnlJtZLVths/SpkSoW4zv5
         oXLw==
X-Gm-Message-State: APjAAAVMIQggHu4sMmFT3VuByPS21v0xo0n72XKF6J2J7rKIu5K0FJzL
	E/60MJuhNiOQF2CAxS48V84Y4QJATF0gJ6cfVkHgPxNybSquTumj9eP9sLy90A6jbs7goo77EBM
	htoqIeRtt6GEGXJOlWrdb2JG4Z2/5zyFsFsrTLuc3arz5nFSaaSQImTqNIAL6BxM=
X-Received: by 2002:ac8:682:: with SMTP id f2mr6526284qth.285.1552266506695;
        Sun, 10 Mar 2019 18:08:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxR0nNPZ9px2hGSm2QcQ37YyJ1qKhG5AWq+AEjcTUmrF+tqTaIYTMV/WYndxWo+/WFun51
X-Received: by 2002:ac8:682:: with SMTP id f2mr6526249qth.285.1552266505400;
        Sun, 10 Mar 2019 18:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552266505; cv=none;
        d=google.com; s=arc-20160816;
        b=hndIW6//bJlXSvRs62O3TE4uE3J5euk6ciETwcnaDiqdMO0B9qxZu0yp314qu+r35J
         kCe6Wrox7QqG7i5GTWUwTL1/6BDhTN2/UmcVgZvOxNO9WvXBypdqOU8Qtgol05BA/m3p
         e3IWLXGgDFMkkXgWq+JNjeL19IwvcPKP8WzPjbkv/4WIb8Bqej9CjH0SY6JTVu7tzsvh
         dA2uq3SShd3sf3MCmj87y/q/FzkBZFqYnV5xBCk+poB2bQR2ndLIEn1d6duoM5MvqxL6
         S1Dp1WLN62R9xK5NIgNkxGMCukZcCiJKW2D2+bjyi7ImGZDYNGgyqCu9I2FCPkOMj1qW
         CQEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0YdAVJOsub1ouxSrbSwMtQqJcFX4a2eTBDmV3Tq0WPQ=;
        b=bhLVykE0OacMTUJMe/iG+I4GGc6ZcivR1Fz1153WoIcBugwttZrRgsT7uaSYsPs0sV
         2LTmHfyww2aFyfLkmMtjBAKe5APyZAXHuCEjUgN3nOm23EuZl1XqphDeAdVaBMpRfpet
         xildksjfGwNNqPlxLdVJl2VKPvti7+tDQ9I+sOmdDHgESdizrKqQlfzmV1Qt1StFhyOR
         8xUjDqGhPr7s6Vk0C1Hlg7aULR0kC9pRYPDIXYRtjRxY3X1cC3ADZV3VFZGoLlbRtXnH
         uBaYsZWlycMfsNZQX0hIXj0RYN0P0XMFK+eZYslc+EYcP5nN7m04pPoTp2eIddjd/2hS
         tnPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FZkGMICQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id h68si1750655qkb.14.2019.03.10.18.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:08:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FZkGMICQ;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 1C5CB20D7C;
	Sun, 10 Mar 2019 21:08:25 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 10 Mar 2019 21:08:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=0YdAVJOsub1ouxSrbSwMtQqJcFX4a2eTBDmV3Tq0WPQ=; b=FZkGMICQ
	RBJt7UixobVfNSBG6ZzC3alUMFvJvwoj2/NFH0E8fvRo8Sx6bbysKrp9Wfuum10m
	L7rqsn59D+3FmhUzJImeA6ycQNy10ZP3YuveStk3D21Teyl+r2hEmej23RmjD9rB
	CS3x5CRp744TUjAaq64/9gA+UWf7v2at5yQr+LPyKYahGe7E8Ke6+u/qe5prO2Fj
	8Qo9MNjj7is532Wc3BXmJaQf3kq7w3ElgHiDymGC7s2lVhKi7ejWU8n7aEgklYEi
	GgHH6Z9qk3nUjBffVK+kxcKNtxzqr8USQiZ9CrLgL9skyYKDbjD09pQ0N8EElyur
	vXFybCJG0UnS2Q==
X-ME-Sender: <xms:CLWFXB81MkiCi86xfm_0QPG0vwfdPDQnOZFkyff4A4fKH6wU2xoAwQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeftdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedu
X-ME-Proxy: <xmx:CLWFXJ9PVf86PWqAOaocg7GbhSR0RPzK4Uf0QYakrrCZkVjd50gPcg>
    <xmx:CLWFXCJlZe39PDfUUZyQo1UcfN-Vo2LjriZFLif0ytfRvE7UuakY1Q>
    <xmx:CLWFXDzTQqrSag6WwVDOpFdY5y6K3-yGpQW1-wDesMSta1KYq7EtXg>
    <xmx:CbWFXGz0YMbeLzF8QFx36Xtjtnt3s_FFKt9xoe6o9apogoSXAqi8QQ>
Received: from eros.localdomain (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id C822010312;
	Sun, 10 Mar 2019 21:08:21 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/4] slub: Use slab_list instead of lru
Date: Mon, 11 Mar 2019 12:07:42 +1100
Message-Id: <20190311010744.5862-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190311010744.5862-1-tobin@kernel.org>
References: <20190311010744.5862-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list in the page structure (slab_list) that can be used for this
purpose.  Doing so makes the code cleaner since we are not overloading
the lru list.

Use the slab_list instead of the lru list for maintaining lists of
slabs.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b282e22885cd..d692b5e0163d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1023,7 +1023,7 @@ static void add_full(struct kmem_cache *s,
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_add(&page->lru, &n->full);
+	list_add(&page->slab_list, &n->full);
 }
 
 static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct page *page)
@@ -1032,7 +1032,7 @@ static void remove_full(struct kmem_cache *s, struct kmem_cache_node *n, struct
 		return;
 
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 }
 
 /* Tracking of the number of slabs for debugging purposes */
@@ -1773,9 +1773,9 @@ __add_partial(struct kmem_cache_node *n, struct page *page, int tail)
 {
 	n->nr_partial++;
 	if (tail == DEACTIVATE_TO_TAIL)
-		list_add_tail(&page->lru, &n->partial);
+		list_add_tail(&page->slab_list, &n->partial);
 	else
-		list_add(&page->lru, &n->partial);
+		list_add(&page->slab_list, &n->partial);
 }
 
 static inline void add_partial(struct kmem_cache_node *n,
@@ -1789,7 +1789,7 @@ static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
 	lockdep_assert_held(&n->list_lock);
-	list_del(&page->lru);
+	list_del(&page->slab_list);
 	n->nr_partial--;
 }
 
@@ -1863,7 +1863,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 		return NULL;
 
 	spin_lock(&n->list_lock);
-	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+	list_for_each_entry_safe(page, page2, &n->partial, slab_list) {
 		void *t;
 
 		if (!pfmemalloc_match(page, flags))
@@ -2407,7 +2407,7 @@ static unsigned long count_partial(struct kmem_cache_node *n,
 	struct page *page;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
+	list_for_each_entry(page, &n->partial, slab_list)
 		x += get_count(page);
 	spin_unlock_irqrestore(&n->list_lock, flags);
 	return x;
@@ -3702,10 +3702,10 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 
 	BUG_ON(irqs_disabled());
 	spin_lock_irq(&n->list_lock);
-	list_for_each_entry_safe(page, h, &n->partial, lru) {
+	list_for_each_entry_safe(page, h, &n->partial, slab_list) {
 		if (!page->inuse) {
 			remove_partial(n, page);
-			list_add(&page->lru, &discard);
+			list_add(&page->slab_list, &discard);
 		} else {
 			list_slab_objects(s, page,
 			"Objects remaining in %s on __kmem_cache_shutdown()");
@@ -3713,7 +3713,7 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 	}
 	spin_unlock_irq(&n->list_lock);
 
-	list_for_each_entry_safe(page, h, &discard, lru)
+	list_for_each_entry_safe(page, h, &discard, slab_list)
 		discard_slab(s, page);
 }
 
@@ -3993,7 +3993,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		 * Note that concurrent frees may occur while we hold the
 		 * list_lock. page->inuse here is the upper limit.
 		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
+		list_for_each_entry_safe(page, t, &n->partial, slab_list) {
 			int free = page->objects - page->inuse;
 
 			/* Do not reread page->inuse */
@@ -4003,10 +4003,10 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 			BUG_ON(free <= 0);
 
 			if (free == page->objects) {
-				list_move(&page->lru, &discard);
+				list_move(&page->slab_list, &discard);
 				n->nr_partial--;
 			} else if (free <= SHRINK_PROMOTE_MAX)
-				list_move(&page->lru, promote + free - 1);
+				list_move(&page->slab_list, promote + free - 1);
 		}
 
 		/*
@@ -4019,7 +4019,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, &discard, lru)
+		list_for_each_entry_safe(page, t, &discard, slab_list)
 			discard_slab(s, page);
 
 		if (slabs_node(s, node))
@@ -4211,11 +4211,11 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 	for_each_kmem_cache_node(s, node, n) {
 		struct page *p;
 
-		list_for_each_entry(p, &n->partial, lru)
+		list_for_each_entry(p, &n->partial, slab_list)
 			p->slab_cache = s;
 
 #ifdef CONFIG_SLUB_DEBUG
-		list_for_each_entry(p, &n->full, lru)
+		list_for_each_entry(p, &n->full, slab_list)
 			p->slab_cache = s;
 #endif
 	}
@@ -4432,7 +4432,7 @@ static int validate_slab_node(struct kmem_cache *s,
 
 	spin_lock_irqsave(&n->list_lock, flags);
 
-	list_for_each_entry(page, &n->partial, lru) {
+	list_for_each_entry(page, &n->partial, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4443,7 +4443,7 @@ static int validate_slab_node(struct kmem_cache *s,
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
 
-	list_for_each_entry(page, &n->full, lru) {
+	list_for_each_entry(page, &n->full, slab_list) {
 		validate_slab_slab(s, page, map);
 		count++;
 	}
@@ -4639,9 +4639,9 @@ static int list_locations(struct kmem_cache *s, char *buf,
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(page, &n->partial, lru)
+		list_for_each_entry(page, &n->partial, slab_list)
 			process_slab(&t, s, page, alloc, map);
-		list_for_each_entry(page, &n->full, lru)
+		list_for_each_entry(page, &n->full, slab_list)
 			process_slab(&t, s, page, alloc, map);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
-- 
2.21.0

